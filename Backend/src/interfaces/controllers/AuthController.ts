import type { Request, Response } from 'express';
import type { AuthRequest } from '../../infrastructure/middleware/authMiddleware.js';
import { Register } from '../../usecases/auth/Register.js';
import { Login } from '../../usecases/auth/Login.js';
import { VerifyEmail } from '../../usecases/auth/VerifyEmail.js';
import { ForgotPassword } from '../../usecases/auth/ForgotPassword.js';
import { ResetPassword } from '../../usecases/auth/ResetPassword.js';
import { Logout } from '../../usecases/auth/Logout.js';
import { RefreshToken } from '../../usecases/auth/RefreshToken.js';
import { SendVerificationCode } from '../../usecases/auth/SendVerificationCode.js';
import { UserRepository } from '../repositories/UserRepository.js';

export const AuthController = {
  me(req: AuthRequest, res: Response) {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Unauthorized.',
      });
      return;
    }

    res.status(200).json({
      success: true,
      user: req.user,
    });
  },

  async register(req: Request, res: Response) {
    try {
      const result = await Register(req.body);
      res.status(201).json(result);
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'A technical error occurred.',
      });
    }
  },

  async login(req: Request, res: Response) {
    try {
      const result = await Login(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: error.message || 'Login failed.',
      });
    }
  },

  async verifyEmail(req: Request, res: Response) {
    try {
      const token = String(req.query.token || '');
      const result = await VerifyEmail({ token });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Verification failed.',
      });
    }
  },

  async forgotPassword(req: Request, res: Response) {
    try {
      const result = await ForgotPassword(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'An error occurred.',
      });
    }
  },

  async resetPassword(req: Request, res: Response) {
    try {
      const result = await ResetPassword(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || 'Password reset failed.',
      });
    }
  },

  async logout(req: Request, res: Response) {
    try {
      const result = await Logout(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: error.message || 'Logout failed.',
      });
    }
  },

  async refreshToken(req: Request, res: Response) {
    try {
      const result = await RefreshToken(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: error.message || 'Refresh token failed.',
      });
    }
  },

  async resendVerification(req: AuthRequest, res: Response) {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized.',
        });
        return;
      }

      const user = await UserRepository.findById(req.user.userid);
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found.',
        });
        return;
      }

      if (user.isverified) {
        res.status(400).json({
          success: false,
          message: 'Email is already verified.',
        });
        return;
      }

      const result = await SendVerificationCode(user.userid, user.email);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to resend verification code.',
      });
    }
  },
};
