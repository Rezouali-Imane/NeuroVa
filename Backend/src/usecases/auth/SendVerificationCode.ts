import { EmailTokenRepository } from '../../interfaces/repositories/EmailTokenRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { TokenGenerator } from '../../infrastructure/auth/tokenGenerator.js';

export const SendVerificationCode = async (userid: string, email: string) => {
  // Generate 6-digit code
  const code = TokenGenerator.generateVerificationCode();
  
  // Set expiration to 1 hour from now
  const expiresat = TokenGenerator.getExpirationDate(1);

  // Invalidate old tokens
  await EmailTokenRepository.invalidateOldTokens(userid);

  // Create new token
  await EmailTokenRepository.create(userid, code, expiresat);

  // Send email
  await MailService.sendVerificationCode(email, code);

  return {
    success: true,
    message: "Code de vérification envoyé.",
  };
};
