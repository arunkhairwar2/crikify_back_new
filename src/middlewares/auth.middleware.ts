// import { SECRET_KEY } from '@config';
import { HttpException } from '@exceptions/HttpException';
import { RequestWithUser } from '@interfaces/auth.interface';
import { NextFunction, Response } from 'express';

const authMiddleware = async (req: RequestWithUser, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.header('Authorization') || '';
    const Authorization = req.cookies['Authorization'] || (authHeader.includes('Bearer ') ? authHeader.split('Bearer ')[1] : null);

    if (Authorization) {
      // TODO: Uncomment when userModel is available
      // const _secretKey: string = SECRET_KEY ?? '';
      // const _verificationResponse = (await verify(Authorization, _secretKey)) as DataStoredInToken;
      // const _userId = _verificationResponse._id;
      // const findUser = await userModel.findById(_userId);
      const findUser = { _id: 'wefiwbevfv', email: '[EMAIL_ADDRESS]', password: '[PASSWORD]' };

      if (findUser) {
        req.user = findUser;
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
