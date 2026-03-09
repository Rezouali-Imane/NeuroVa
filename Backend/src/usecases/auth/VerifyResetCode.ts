import type { VerifyResetCodeDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';

export const VerifyResetCode = async (data: VerifyResetCodeDTO) => {
  const normalizedEmail = data.email.toLowerCase().trim();

  // Find user
  const user = await UserRepository.findByEmail(normalizedEmail);
  if (!user) {
    throw new Error("Code invalide ou expiré.");
  }

  // Find valid token
  const token = await PasswordResetRepository.findValidToken(user.userid, data.resetcode);

  if (!token) {
    throw new Error("Code invalide ou expiré.");
  }

  return {
    success: true,
    message: "Code vérifié avec succès.",
    userid: user.userid,
  };
};
