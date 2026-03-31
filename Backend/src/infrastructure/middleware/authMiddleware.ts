import type { Request, Response, NextFunction } from 'express';
import { JwtClient } from '../jwt.client.js';

export interface AuthRequest extends Request {
  user?: {
    userid: string;
    role: string;
  };
}

export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authorization = req.headers.authorization;
    const [scheme, token] = authorization ? authorization.split(' ') : [];

    if (scheme !== 'Bearer' || !token) {
      return res.status(401).json({
        success: false,
        message: 'Missing or invalid bearer token.',
      });
    }

    const decoded = JwtClient.verifyAccessToken(token);

    req.user = decoded;
    next();
  } catch (error: any) {
    return res.status(401).json({
      success: false,
      message: error.message || 'Invalid or expired token.',
    });
  }
};

export const requireAdmin = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({
      success: false,
      message: 'Access restricted to administrators.',
    });
  }
  next();
};
