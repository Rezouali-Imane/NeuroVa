import type { RegisterUserDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { StudentRepository, AdminRepository } from '../../interfaces/repositories/RoleRepository.js';
import { SendVerificationCode } from './SendVerificationCode.js';
import { UserRole } from '../../entities/User.js';
import { PasswordService } from '../../infrastructure/auth/passwordService.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const SignUp = async (data: RegisterUserDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);
  const normalizedUsername = AuthValidators.normalizeUsername(data.username);

  // Validate email format
  const emailValidation = AuthValidators.validateEmail(normalizedEmail);
  if (!emailValidation.valid) {
    throw new Error(emailValidation.message);
  }

  // Validate username format
  const usernameValidation = AuthValidators.validateUsername(normalizedUsername);
  if (!usernameValidation.valid) {
    throw new Error(usernameValidation.message);
  }

  // Validate password format
  const passwordValidation = PasswordService.validateFormat(data.password);
  if (!passwordValidation.valid) {
    throw new Error(passwordValidation.message);
  }

  // Check if email or username already exists
  const existingEmail = await UserRepository.findByEmail(normalizedEmail);
  if (existingEmail) {
    throw new Error("Cette adresse email est déjà utilisée.");
  }

  const existingUsername = await UserRepository.findByUsername(normalizedUsername);
  if (existingUsername) {
    throw new Error("Ce nom d'utilisateur est déjà pris.");
  }

  // Hash password
  const passwordhash = await PasswordService.hash(data.password);

  // Create user
  const user = await UserRepository.create({
    name: data.name,
    lastname: data.lastname,
    username: normalizedUsername,
    email: normalizedEmail,
    passwordhash,
    userrole: data.role || UserRole.STUDENT,
  });

  // Create role-specific entry
  if (user.userrole === UserRole.STUDENT) {
    await StudentRepository.create(user.userid);
  } else if (user.userrole === UserRole.ADMIN) {
    await AdminRepository.create(user.userid);
  }

  // Send verification code
  await SendVerificationCode(user.userid, user.email);

  return {
    success: true,
    message: "Inscription réussie. Veuillez vérifier votre email.",
    userid: user.userid,
  };
};
