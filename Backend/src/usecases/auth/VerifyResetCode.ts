import type { VerifyResetCodeDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { PasswordResetRepository } from '../../interfaces/repositories/PasswordResetRepository.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const VerifyResetCode = async (data: VerifyResetCodeDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);

  const user = await UserRepository.findByEmail(normalizedEmail);
  if (!user) {
    throw new Error("Invalid or expired code.");
  }

  const token = await PasswordResetRepository.findValidToken(user.userid, data.resetcode);

  if (!token) {
    throw new Error("Invalid or expired code.");
  }

  return {
    success: true,
    message: "Code verified successfully.",
    userid: user.userid,
  };
};
