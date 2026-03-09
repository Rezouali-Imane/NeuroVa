/**
 * Validation utilities for authentication
 */
export const AuthValidators = {
  /**
   * Validate email format
   */
  validateEmail(email: string): { valid: boolean; message?: string } {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    
    if (!emailRegex.test(email)) {
      return {
        valid: false,
        message: "L'adresse email est mal formée."
      };
    }

    return { valid: true };
  },

  /**
   * Normalize email (lowercase and trim)
   */
  normalizeEmail(email: string): string {
    return email.toLowerCase().trim();
  },

  /**
   * Normalize username (lowercase and trim)
   */
  normalizeUsername(username: string): string {
    return username.toLowerCase().trim();
  },

  /**
   * Validate username format
   */
  validateUsername(username: string): { valid: boolean; message?: string } {
    if (username.length < 3) {
      return {
        valid: false,
        message: "Le nom d'utilisateur doit contenir au moins 3 caractères."
      };
    }

    if (username.length > 30) {
      return {
        valid: false,
        message: "Le nom d'utilisateur ne peut pas dépasser 30 caractères."
      };
    }

    const usernameRegex = /^[a-zA-Z0-9_-]+$/;
    if (!usernameRegex.test(username)) {
      return {
        valid: false,
        message: "Le nom d'utilisateur ne peut contenir que des lettres, chiffres, tirets et underscores."
      };
    }

    return { valid: true };
  }
};
