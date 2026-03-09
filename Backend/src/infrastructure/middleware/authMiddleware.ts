import type { Request, Response, NextFunction } from 'express';
import { JWTService } from '../auth/jwtService.js';

interface AuthRequest extends Request {
  user?: {
    userid: string;
    role: string;
  };
}

export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Missing token.",
      });
    }

    const decoded = JWTService.verifyToken(token);

    req.user = decoded;
    next();
  } catch (error: any) {
    return res.status(401).json({
      success: false,
      message: error.message || "Invalid or expired token.",
    });
  }
};

export const requireAdmin = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({
      success: false,
      message: "Access restricted to administrators.",
    });
  }
  next();
};
