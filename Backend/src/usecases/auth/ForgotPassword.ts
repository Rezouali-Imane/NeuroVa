import type { ForgotPasswordDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { TokenGenerator } from '../../infrastructure/auth/tokenGenerator.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const ForgotPassword = async (data: ForgotPasswordDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);

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
  const resetcode = TokenGenerator.generateResetToken();

  // Set expiration to 1 hour from now
  const expiresat = TokenGenerator.getExpirationDate(1);

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
