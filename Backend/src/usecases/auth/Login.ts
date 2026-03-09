import type { LoginUserDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { SendVerificationCode } from './SendVerificationCode.js';
import { PasswordService } from '../../infrastructure/auth/passwordService.js';
import { JWTService } from '../../infrastructure/auth/jwtService.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const Login = async (data: LoginUserDTO) => {
  const normalizedIdentifier = AuthValidators.normalizeEmail(data.identifier);

  const user = await UserRepository.findByEmailOrUsername(normalizedIdentifier);
  if (!user) {
    throw new Error("Invalid credentials.");
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
    throw new Error("Invalid credentials.");
  }

  if (user.failedloginattempts > 0) {
    await UserRepository.updateLoginAttempts(user.userid, 0, false);
  }

  if (!user.isverified) {
    await SendVerificationCode(user.userid, user.email);

    return {
      success: false,
      requiresVerification: true,
      userid: user.userid,
      message: "Please verify your email. A new code has been sent.",
    };
  }

  const token = JWTService.generateToken({
    userid: user.userid,
    role: user.userrole
  });

  return {
    success: true,
    token,
    user: {
      id: user.userid,
      username: user.username,
      email: user.email,
      role: user.userrole,
    },
  };
};
