import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { TokenGenerator } from '../../infrastructure/auth/tokenGenerator.js';

export const SendVerificationCode = async (userid: string, email: string) => {
  const code = TokenGenerator.generateVerificationCode();
  const expiresat = new Date(Date.now() + 15 * 60 * 1000);

  await EmailTokenRepository.invalidateOldTokens(userid);
  await EmailTokenRepository.create(userid, code, expiresat);
  await MailService.sendVerificationCode(email, code);

  return {
    success: true,
    message: "Verification code sent.",
  };
};
