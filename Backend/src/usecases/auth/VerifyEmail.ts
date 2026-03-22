import type { VerifyEmailDTO } from '../../interfaces/dtos/Auth.dto.js';
import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { HmacClient } from '../../infrastructure/hmac.client.js';

export const VerifyEmail = async (data: VerifyEmailDTO) => {
  const decoded = HmacClient.verify(data.token);

  if (!decoded.code) {
    throw new Error('Verification code missing from token.');
  }

  const tokenRecord = await EmailTokenRepository.findValidToken(decoded.userid, decoded.code);

  if (!tokenRecord) {
    throw new Error("Invalid or expired verification code.");
  }

  await UserRepository.markUserAsVerified(decoded.userid);
  await EmailTokenRepository.markAsUsed(tokenRecord.tokenid);

  return {
    success: true,
    message: "Email verified successfully. You can now log in.",
  };
};
