import { CreateUserDto } from '@dtos/users.dto';
import { TokenData } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';
import jwt from 'jsonwebtoken';
import { compare, hash } from 'bcrypt';
import prisma from '@databases/prisma';
import { SECRET_KEY } from '@/config';

class AuthService {
  public async signup(userData: CreateUserDto): Promise<User> {
    const existingUser = await prisma.user.findUnique({ where: { email: userData.email } });
    if (existingUser) {
      throw Object.assign(new Error(`This email ${userData.email} already exists`), { status: 409 });
    }

    const hashedPassword = await hash(userData.password, 10);
    const user = await prisma.user.create({
      data: { ...userData, password: hashedPassword },
    });

    return user as unknown as User;
  }

  public async login(userData: CreateUserDto): Promise<{ cookie: string; user: User }> {
    const findUser = await prisma.user.findUnique({ where: { email: userData.email } });
    if (!findUser) {
      throw Object.assign(new Error(`This email ${userData.email} was not found`), { status: 409 });
    }

    const isPasswordMatching = await compare(userData.password, findUser.password);
    if (!isPasswordMatching) {
      throw Object.assign(new Error('Password is not matching'), { status: 409 });
    }

    const tokenData = this.createToken(findUser as unknown as User);
    const cookie = this.createCookie(tokenData);

    return { cookie, user: findUser as unknown as User };
  }

  public async logout(userData: User): Promise<User> {
    return userData;
  }

  public createToken(user: User): TokenData {
    const expiresIn = 60 * 60;
    return { expiresIn, token: jwt.sign({ userId: user.userId }, SECRET_KEY, { expiresIn }) };
  }

  public createCookie(tokenData: TokenData): string {
    return `Authorization=${tokenData.token}; HttpOnly; Max-Age=${tokenData.expiresIn};`;
  }
}

export default AuthService;
