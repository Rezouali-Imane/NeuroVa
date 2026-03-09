import type { ForgotPasswordDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { TokenGenerator } from '../../infrastructure/auth/tokenGenerator.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const ForgotPassword = async (data: ForgotPasswordDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);

  const user = await UserRepository.findByEmail(normalizedEmail);
  if (!user) {
    return {
      success: true,
      message: "Si ce compte existe, un code de réinitialisation a été envoyé.",
    };
  }

  const resetcode = TokenGenerator.generateResetToken();
  const expiresat = TokenGenerator.getExpirationDate(1);

  await PasswordResetRepository.invalidateOldTokens(user.userid);
  await PasswordResetRepository.create(user.userid, resetcode, expiresat);
  await MailService.sendResetPasswordCode(user.email, resetcode);

  return {
    success: true,
    message: "Si ce compte existe, un code de réinitialisation a été envoyé.",
  };
};
