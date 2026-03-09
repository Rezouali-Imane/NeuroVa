import type { ResetPasswordDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import { PasswordService } from '../../infrastructure/auth/passwordService.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const ResetPassword = async (data: ResetPasswordDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);

  // Validate new password
  const passwordValidation = PasswordService.validateFormat(data.newPassword);
  if (!passwordValidation.valid) {
    throw new Error(passwordValidation.message);
  }

  // Find user
  const user = await UserRepository.findByEmail(normalizedEmail);
  if (!user) {
    throw new Error("Code invalide ou expiré.");
  }

  // Find valid token
  const tokenRecord = await PasswordResetRepository.findValidToken(user.userid, data.resetcode);

  if (!tokenRecord) {
    throw new Error("Code invalide ou expiré.");
  }

  // Hash new password
  const newPasswordHash = await PasswordService.hash(data.newPassword);

  // Update password
  await UserRepository.resetUserPassword(user.userid, newPasswordHash);

  // Mark token as used
  await PasswordResetRepository.markAsUsed(tokenRecord.tokenid);

  return {
    success: true,
    message: "Mot de passe réinitialisé avec succès.",
  };
};
