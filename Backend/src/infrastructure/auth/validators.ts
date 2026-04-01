export const AuthValidators = {

  validateEmail(email: string): { valid: boolean; message?: string } {
    const emailToTest = email || ""; 
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    
    if (!emailRegex.test(emailToTest)) {
      return {
        valid: false,
        message: "The email address format is invalid."
      };
    }

    return { valid: true };
  },

  normalizeEmail(email: string): string {
    return email?.toLowerCase().trim() || "";
  },

  normalizeUsername(username: string): string {
    return username?.toLowerCase().trim() || "";
  },

  validateUsername(username: string): { valid: boolean; message?: string } {
    const name = username || ""; 

    if (name.length < 3) {
      return {
        valid: false,
        message: "Username must be at least 3 characters long."
      };
    }

    if (name.length > 30) {
      return {
        valid: false,
        message: "Username cannot exceed 30 characters."
      };
    }

    const usernameRegex = /^[a-zA-Z0-9_-]+$/;
    if (!usernameRegex.test(name)) {
      return {
        valid: false,
        message: "Username can only contain letters, numbers, hyphens, and underscores."
      };
    }

    return { valid: true };
  }
};