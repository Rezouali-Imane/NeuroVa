import type { VerifyEmailDTO } from '../../interfaces/dtos/Auth.dto.js';
import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { HmacClient } from '../../infrastructure/hmac.client.js';
import { JwtClient } from '../../infrastructure/jwt.client.js';
import crypto from 'node:crypto';

const hashToken = (token: string): string => {
  return crypto.createHash('sha256').update(token).digest('hex');
};

export const VerifyEmail = async (data: VerifyEmailDTO) => {
  const decoded = HmacClient.verify(data.token);
  const tokenHash = hashToken(data.token);

  const tokenRecord = await EmailTokenRepository.findValidToken(decoded.userid, tokenHash);

  if (!tokenRecord) {
    throw new Error("Invalid or expired verification link.");
  }

  await UserRepository.markUserAsVerified(decoded.userid);
  await EmailTokenRepository.markAsUsed(tokenRecord.tokenid);

  const user = await UserRepository.findById(decoded.userid);
  if (!user) {
    throw new Error('User not found after verification.');
  }

  const accessToken = JwtClient.signAccessToken({
    userid: user.userid,
    role: user.userrole,
    isverified: true,
  });

  return {
    success: true,
    message: "Email verified successfully. You can now log in.",
    accessToken,
  };
};
