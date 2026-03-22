import { UserRole } from '../../entities/User.js';

export interface RegisterDTO {
  name: string;
  lastname: string;
  username: string;
  email: string;
  password: string;
  role?: UserRole;
}

export interface LoginDTO {
  identifier: string; // email or username
  password: string;
}

export interface VerifyEmailDTO {
  token: string;
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

export interface LogoutDTO {
  userId?: string;
  refreshToken?: string;
}

export interface RefreshTokenDTO {
  refreshToken: string;
}

export type RegisterUserDTO = RegisterDTO;
export type LoginUserDTO = LoginDTO;
export type EmailVerificationDTO = VerifyEmailDTO;
