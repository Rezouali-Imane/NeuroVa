import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'secret';

export const JWTService = {
  /**
   * Generate a JWT token for a user
   */
  generateToken(payload: { userid: string; role: string }): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
  },

  /**
   * Verify and decode a JWT token
   */
  verifyToken(token: string): { userid: string; role: string } {
    try {
      return jwt.verify(token, JWT_SECRET) as { userid: string; role: string };
    } catch (error) {
      throw new Error('Token invalide ou expiré.');
    }
  },

  /**
   * Generate a refresh token (longer expiration)
   */
  generateRefreshToken(payload: { userid: string }): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' });
  }
};
