import type { EmailVerificationDTO } from '../../interfaces/dtos/Auth.dto.js';
import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';

export const VerifyEmail = async (data: EmailVerificationDTO) => {
  const { userid, verificationcode: token } = data;

  // Find valid token
  const tokenRecord = await EmailTokenRepository.findValidToken(userid, token);

  if (!tokenRecord) {
    throw new Error("Code de vérification invalide ou expiré.");
  }

  // Mark user as verified
  await UserRepository.markUserAsVerified(userid);

  // Mark token as used
  await EmailTokenRepository.markAsUsed(tokenRecord.tokenid);

  return {
    success: true,
    message: "Email vérifié avec succès. Vous pouvez maintenant vous connecter.",
  };
};
