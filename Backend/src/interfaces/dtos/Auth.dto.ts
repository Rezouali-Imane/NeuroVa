import { UserRole } from '../../entities/User.js';

export interface RegisterUserDTO {
  name: string;
  lastname: string;
  username: string;
  email: string;
  password: string;
  role?: UserRole;
}

export interface LoginUserDTO {
  identifier: string; // email or username
  password: string;
}

export interface EmailVerificationDTO {
  userid: string;
  verificationcode: string;
}

export interface ForgotPasswordDTO {
  email: string;
}

export interface VerifyResetCodeDTO {
  email: string;
  resetcode: string;
}

export interface ResetPasswordDTO {
  email: string;
  resetcode: string;
  newPassword: string;
}
