import { IsEmail, IsOptional, IsString, IsEnum } from 'class-validator';
import { UserRole } from '@/generated/prisma/enums';

export class CreateUserDto {
  @IsEmail()
  public email!: string;

  @IsString()
  public password!: string;

  @IsOptional()
  @IsString()
  public name?: string;

  @IsOptional()
  @IsEnum(UserRole)
  public role?: UserRole;
}
