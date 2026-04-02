import { Router } from 'express';
import { AuthController } from '../controllers/AuthController.js';
import { authMiddleware } from '../../infrastructure/middleware/authMiddleware.js';

const router = Router();

router.post('/register', AuthController.register);

router.post('/login', AuthController.login);
router.get('/me', authMiddleware, AuthController.me);
router.post('/logout', AuthController.logout);
router.get('/verify-email', AuthController.verifyEmail);
router.post('/resend-verification', authMiddleware, AuthController.resendVerification);
router.post('/forgot-password', AuthController.forgotPassword);
router.post('/reset-password', AuthController.resetPassword);
router.post('/refresh-token', AuthController.refreshToken);

export default router;
