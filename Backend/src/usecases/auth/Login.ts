import type { LoginDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { SendVerificationCode } from './SendVerificationCode.js';
import { PasswordService } from '../../infrastructure/auth/passwordService.js';
import { JwtClient } from '../../infrastructure/jwt.client.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const Login = async (data: LoginDTO) => {
  const normalizedIdentifier = AuthValidators.normalizeEmail(data.identifier);

  const user = await UserRepository.findByEmailOrUsername(normalizedIdentifier);
  if (!user) {
    throw new Error("This email or username is not registered. Please sign up first.");
  }

  if (user.islocked) {
    throw new Error(
      "Your account is locked after too many attempts. Please contact support."
    );
  }

  const isPasswordValid = await PasswordService.compare(data.password, user.passwordhash);

  if (!isPasswordValid) {
    const newAttempts = user.failedloginattempts + 1;
    const shouldLock = newAttempts >= 5;

    await UserRepository.updateLoginAttempts(user.userid, newAttempts, shouldLock);
    throw new Error("Incorrect password. Please try again.");
  }

  if (user.failedloginattempts > 0) {
    await UserRepository.updateLoginAttempts(user.userid, 0, false);
  }

  // Send verification email if not yet verified
  if (!user.isverified) {
    await SendVerificationCode(user.userid, user.email);
  }

  const accessToken = JwtClient.signAccessToken({
    userid: user.userid,
    role: user.userrole,
    isverified: user.isverified,
  });

  const refreshToken = JwtClient.signRefreshToken({ userid: user.userid });

  return {
    success: true,
    accessToken,
    refreshToken,
    user: {
      id: user.userid,
      username: user.username,
      email: user.email,
      role: user.userrole,
    },
  };
};
