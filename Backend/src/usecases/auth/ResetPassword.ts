import type { ResetPasswordDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import { PasswordService } from '../../infrastructure/auth/passwordService.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const ResetPassword = async (data: ResetPasswordDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);

  const passwordValidation = PasswordService.validateFormat(data.newPassword);
  if (!passwordValidation.valid) {
    throw new Error(passwordValidation.message);
  }

  const user = await UserRepository.findByEmail(normalizedEmail);
  if (!user) {
    throw new Error("Invalid or expired code.");
  }

  const tokenRecord = await PasswordResetRepository.findValidToken(user.userid, data.resetcode);

  if (!tokenRecord) {
    throw new Error("Invalid or expired code.");
  }

  const newPasswordHash = await PasswordService.hash(data.newPassword);

  await UserRepository.resetUserPassword(user.userid, newPasswordHash);
  await PasswordResetRepository.markAsUsed(tokenRecord.tokenid);

  return {
    success: true,
    message: "Password reset successfully.",
  };
};
