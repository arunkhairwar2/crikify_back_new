import jwt from 'jsonwebtoken';
import { SECRET_KEY } from '@config';
import { HttpException } from '@exceptions/HttpException';
import { DataStoredInToken, RequestWithUser } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';
import { NextFunction, Response } from 'express';
import prisma from '@databases/prisma';

const authMiddleware = async (req: RequestWithUser, _res: Response, next: NextFunction) => {
  try {
    const authHeader = req.header('Authorization') || '';
    const Authorization = req.cookies['Authorization'] || (authHeader.includes('Bearer ') ? authHeader.split('Bearer ')[1] : null);

    if (Authorization) {
      const secretKey: string = SECRET_KEY ?? '';
      const verificationResponse = jwt.verify(Authorization, secretKey) as DataStoredInToken;
      const userId = verificationResponse.userId;
      const findUser = await prisma.user.findUnique({ where: { userId } });

      if (findUser) {
        req.user = findUser as unknown as User;
        next();
      } else {
        next(new HttpException(401, 'Wrong authentication token'));
      }
    } else {
      next(new HttpException(404, 'Authentication token missing'));
    }
  } catch (_error) {
    next(new HttpException(401, 'Wrong authentication token'));
  }
};

export default authMiddleware;
