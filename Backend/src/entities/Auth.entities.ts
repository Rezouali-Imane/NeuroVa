export interface AuthUserSession {
  userid: string;
  username: string;
  email: string;
  role: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface VerifyEmailTokenPayload {
  userid: string;
  code?: string;
}
