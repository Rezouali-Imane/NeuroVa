import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { HmacClient } from '../../infrastructure/hmac.client.js';
import crypto from 'node:crypto';

const hashToken = (token: string): string => {
  return crypto.createHash('sha256').update(token).digest('hex');
};

export const SendVerificationCode = async (userid: string, email: string) => {
  const expiresat = new Date(Date.now() + 15 * 60 * 1000);
  const verificationToken = HmacClient.generate({ userid }, 15 * 60);
  const verificationTokenHash = hashToken(verificationToken);
  const apiBaseUrl = (process.env.BACKEND_BASE_URL || 'http://localhost:3000').replace(/\/$/, '');
  const verificationLink = `${apiBaseUrl}/api/auth/verify-email?token=${encodeURIComponent(verificationToken)}`;

  await EmailTokenRepository.invalidateOldTokens(userid);
  await EmailTokenRepository.create(userid, verificationTokenHash, expiresat);
  await MailService.sendVerificationCode(email, verificationLink);

  return {
    success: true,
    message: "Verification code sent.",
  };
};
