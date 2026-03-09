/**
 * Generate verification codes and reset tokens
 */
export const TokenGenerator = {
  /**
   * Generate a 6-digit verification code
   */
  generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  },

  /**
   * Generate a random token for password reset
   */
  generateResetToken(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  },

  /**
   * Get expiration date (default 1 hour from now)
   */
  getExpirationDate(hours: number = 1): Date {
    const expiresat = new Date();
    expiresat.setHours(expiresat.getHours() + hours);
    return expiresat;
  }
};
