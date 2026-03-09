import { Router } from 'express';
import { AuthController } from '../controllers/AuthController.js';

const router = Router();

// Sign up
router.post('/signup', AuthController.signUp);

// Login
router.post('/login', AuthController.login);

// Verify email
router.post('/verify-email', AuthController.verifyEmail);

// Forgot password
router.post('/forgot-password', AuthController.forgotPassword);

// Verify reset code
router.post('/verify-reset-code', AuthController.verifyResetCode);

// Reset password
router.post('/reset-password', AuthController.resetPassword);

export default router;
