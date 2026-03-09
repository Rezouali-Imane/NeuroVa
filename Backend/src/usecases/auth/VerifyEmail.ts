import type { EmailVerificationDTO } from '../../interfaces/dtos/Auth.dto.js';
import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';

export const VerifyEmail = async (data: EmailVerificationDTO) => {
  const { userid, verificationcode: token } = data;

  const tokenRecord = await EmailTokenRepository.findValidToken(userid, token);

  if (!tokenRecord) {
    throw new Error("Invalid or expired verification code.");
  }

  await UserRepository.markUserAsVerified(userid);
  await EmailTokenRepository.markAsUsed(tokenRecord.tokenid);

  return {
    success: true,
    message: "Email verified successfully. You can now log in.",
  };
};
