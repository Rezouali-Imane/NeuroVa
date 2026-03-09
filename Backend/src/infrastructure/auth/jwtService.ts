import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'secret';

export const JWTService = {
  generateToken(payload: { userid: string; role: string }): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
  },

  verifyToken(token: string): { userid: string; role: string } {
    try {
      return jwt.verify(token, JWT_SECRET) as { userid: string; role: string };
    } catch (error) {
      throw new Error('Invalid or expired token.');
    }
  },

  generateRefreshToken(payload: { userid: string }): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });
  }
};
