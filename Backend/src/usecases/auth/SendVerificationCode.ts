import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { TokenGenerator } from '../../infrastructure/auth/tokenGenerator.js';

export const SendVerificationCode = async (userid: string, email: string) => {
  const code = TokenGenerator.generateVerificationCode();
  const expiresat = TokenGenerator.getExpirationDate(1);

  await EmailTokenRepository.invalidateOldTokens(userid);
  await EmailTokenRepository.create(userid, code, expiresat);
  await MailService.sendVerificationCode(email, code);

  return {
    success: true,
    message: "Code de vérification envoyé.",
  };
};
