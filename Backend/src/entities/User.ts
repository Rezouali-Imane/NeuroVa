export enum UserRole {
  ADMIN = "ADMIN",
  STUDENT = "STUDENT",
}

export interface User {
  userid: string;
  name: string;
  lastname: string;
  username: string;
  email: string;
  passwordhash: string;
  userrole: UserRole;
  failedloginattempts: number;
  isverified: boolean;
  islocked: boolean;
  createdat: Date;
}

export interface EmailVerificationToken {
  tokenid: string;
  userid: string;
  token: string;
  createdat: Date;
  expiresat: Date;
  isverified: boolean;
  verifiedat?: Date;
}

export interface PasswordResetToken {
  tokenid: string;
  userid: string;
  tokenhash: string;
  createdat: Date;
  expiresat: Date;
  usedat?: Date;
}

export interface Student {
  userid: string;
  major?: string;
  focusstreak: number;
  productivitypoints: number;
  focusmodeenabled: boolean;
}

export interface Admin {
  userid: string;
}
