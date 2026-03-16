import { Router } from 'express';
import { AuthController } from '../controllers/AuthController.js';

const router = Router();

// Create a new account.
router.post('/signup', AuthController.signUp);

// Sign in to an existing account.
router.post('/login', AuthController.login);

// Confirm email with the verification code.
router.post('/verify-email', AuthController.verifyEmail);

// Send password reset code.
router.post('/forgot-password', AuthController.forgotPassword);

// Check password reset code.
router.post('/verify-reset-code', AuthController.verifyResetCode);

// Set a new password.
router.post('/reset-password', AuthController.resetPassword);

export default router;
