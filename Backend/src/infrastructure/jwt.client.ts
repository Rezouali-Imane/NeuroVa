import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'change_me_jwt_secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || '30d';

type AccessPayload = {
  userid: string;
  role: string;
};

type RefreshPayload = {
  userid: string;
};

export const JwtClient = {
  signAccessToken(payload: AccessPayload): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN as any });
  },

  signRefreshToken(payload: RefreshPayload): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_REFRESH_EXPIRES_IN as any });
  },

  verifyAccessToken(token: string): AccessPayload {
    return jwt.verify(token, JWT_SECRET) as AccessPayload;
  },

  verifyRefreshToken(token: string): RefreshPayload {
    return jwt.verify(token, JWT_SECRET) as RefreshPayload;
  },
};
