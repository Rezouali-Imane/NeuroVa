import type { ForgotPasswordDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';

export const ForgotPassword = async (data: ForgotPasswordDTO) => {
  const normalizedEmail = data.email.toLowerCase().trim();

  // Find user
  const user = await UserRepository.findByEmail(normalizedEmail);
  if (!user) {
    // Don't reveal if email exists
    return {
      success: true,
      message: "Si ce compte existe, un code de réinitialisation a été envoyé.",
    };
  }

  // Generate 6-digit code
  const code = Math.floor(100000 + Math.random() * 900000).toString();

  // Set expiration to 1 hour from now
  const expiresat = new Date();
  expiresat.setHours(expiresat.getHours() + 1);

  // Invalidate old tokens
  await PasswordResetRepository.invalidateOldTokens(user.userid);

  // Create new token (store the code as tokenhash for now)
  await PasswordResetRepository.create(user.userid, code, expiresat);

  // Send email
  await MailService.sendResetPasswordCode(user.email, code);

  return {
    success: true,
    message: "Si ce compte existe, un code de réinitialisation a été envoyé.",
  };
};
