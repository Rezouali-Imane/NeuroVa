import type { LoginUserDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { SendVerificationCode } from './SendVerificationCode.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export const Login = async (data: LoginUserDTO) => {
  const normalizedIdentifier = data.identifier.toLowerCase().trim();

  // Find user by email or username
  const user = await UserRepository.findByEmailOrUsername(normalizedIdentifier);
  if (!user) {
    throw new Error("Identifiants invalides.");
  }

  // Check if account is locked
  if (user.islocked) {
    throw new Error(
      "Votre compte est bloqué suite à trop de tentatives. Veuillez contacter le support."
    );
  }

  // Verify password
  const isPasswordValid = await bcrypt.compare(data.password, user.passwordhash);

  if (!isPasswordValid) {
    const newAttempts = user.failedloginattempts + 1;
    const shouldLock = newAttempts >= 5;

    await UserRepository.updateLoginAttempts(user.userid, newAttempts, shouldLock);
    throw new Error("Identifiants invalides.");
  }

  // Reset failed attempts if password is valid
  if (user.failedloginattempts > 0) {
    await UserRepository.updateLoginAttempts(user.userid, 0, false);
  }

  // Check if email is verified
  if (!user.isverified) {
    await SendVerificationCode(user.userid, user.email);

    return {
      success: false,
      requiresVerification: true,
      userid: user.userid,
      message: "Veuillez vérifier votre email. Un nouveau code a été envoyé.",
    };
  }

  // Generate JWT token
  const token = jwt.sign(
    { userid: user.userid, role: user.userrole },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "24h" }
  );

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
