import bcrypt from 'bcrypt';

const SALT_ROUNDS = 10;

export const PasswordService = {
  async hash(password: string): Promise<string> {
    return await bcrypt.hash(password, SALT_ROUNDS);
  },

  async compare(password: string, hashedPassword: string): Promise<boolean> {
    return await bcrypt.compare(password, hashedPassword);
  },

  validateFormat(password: string): { valid: boolean; message?: string } {
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    const emojiRegex = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/u;

    if (emojiRegex.test(password)) {
      return {
        valid: false,
        message: "Les emojis ne sont pas autorisés dans le mot de passe."
      };
    }

    if (!passwordRegex.test(password)) {
      return {
        valid: false,
        message: "Le mot de passe doit contenir au moins 8 caractères, incluant une majuscule, une minuscule, un chiffre et un caractère spécial (@$!%*?&)."
      };
    }

    return { valid: true };
  }
};
