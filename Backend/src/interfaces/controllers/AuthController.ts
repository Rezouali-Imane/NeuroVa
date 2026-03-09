import type { Request, Response } from 'express';
import { SignUp } from '../../usecases/auth/SignUp.js';
import { Login } from '../../usecases/auth/Login.js';
import { VerifyEmail } from '../../usecases/auth/VerifyEmail.js';
import { ForgotPassword } from '../../usecases/auth/ForgotPassword.js';
import { VerifyResetCode } from '../../usecases/auth/VerifyResetCode.js';
import { ResetPassword } from '../../usecases/auth/ResetPassword.js';

export const AuthController = {
  async signUp(req: Request, res: Response) {
    try {
      const result = await SignUp(req.body);
      res.status(201).json(result);
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || "Une erreur technique est survenue.",
      });
    }
  },

  async login(req: Request, res: Response) {
    try {
      const result = await Login(req.body);
      
      if (result.requiresVerification) {
        res.status(403).json(result);
      } else {
        res.status(200).json(result);
      }
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: error.message || "Échec de la connexion.",
      });
    }
  },

  async verifyEmail(req: Request, res: Response) {
    try {
      const result = await VerifyEmail(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || "Échec de la vérification.",
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
        message: "Une erreur est survenue.",
      });
    }
  },

  async verifyResetCode(req: Request, res: Response) {
    try {
      const result = await VerifyResetCode(req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({
        success: false,
        message: error.message || "Code invalide.",
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
        message: error.message || "Échec de la réinitialisation.",
      });
    }
  }
};
