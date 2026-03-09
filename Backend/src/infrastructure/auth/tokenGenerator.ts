export const TokenGenerator = {
  generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  },

  generateResetToken(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  },

  getExpirationDate(hours: number = 1): Date {
    const expiresat = new Date();
    expiresat.setHours(expiresat.getHours() + hours);
    return expiresat;
  }
};
