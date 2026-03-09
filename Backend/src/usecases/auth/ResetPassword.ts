import type { ResetPasswordDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import bcrypt from 'bcrypt';

export const ResetPassword = async (data: ResetPasswordDTO) => {
  const normalizedEmail = data.email.toLowerCase().trim();

  // Validate new password
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
  const emojiRegex = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/u;

  if (emojiRegex.test(data.newPassword)) {
    throw new Error("Les emojis ne sont pas autorisés dans le mot de passe.");
  }

  if (!passwordRegex.test(data.newPassword)) {
    throw new Error(
      "Le mot de passe doit contenir au moins 8 caractères, incluant une majuscule, une minuscule, un chiffre et un caractère spécial (@$!%*?&)."
    );
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
  const newPasswordHash = await bcrypt.hash(data.newPassword, 10);

  // Update password
  await UserRepository.resetUserPassword(user.userid, newPasswordHash);

  // Mark token as used
  await PasswordResetRepository.markAsUsed(tokenRecord.tokenid);

  return {
    success: true,
    message: "Mot de passe réinitialisé avec succès.",
  };
};
