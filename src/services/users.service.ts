import { CreateUserDto } from '@dtos/users.dto';
import { User } from '@interfaces/users.interface';
import prisma from '@databases/prisma';

class UserService {
  public async findAllUser(): Promise<User[]> {
    const users = await prisma.user.findMany();
    return users;
  }

  public async findUserById(userId: string): Promise<User | null> {
    const user = await prisma.user.findUnique({ where: { userId } });
    return user;
  }

  public async createUser(userData: CreateUserDto): Promise<User> {
    const user = await prisma.user.create({ data: userData });
    return user;
  }

  public async updateUser(userId: string, userData: Partial<CreateUserDto>): Promise<User> {
    const user = await prisma.user.update({ where: { userId }, data: userData });
    return user;
  }

  public async deleteUser(userId: string): Promise<void> {
    await prisma.user.delete({ where: { userId } });
  }
}

export default UserService;
