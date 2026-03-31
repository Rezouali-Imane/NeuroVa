import type { RegisterDTO } from '../../interfaces/dtos/Auth.dto.js';
import { v4 as uuidv4 } from 'uuid';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { StudentRepository, AdminRepository } from '../../interfaces/repositories/RoleRepository.js';
import { SendVerificationCode } from './SendVerificationCode.js';
import { UserRole } from '../../entities/User.js';
import { PasswordService } from '../../infrastructure/auth/passwordService.js';
import { AuthValidators } from '../../infrastructure/auth/validators.js';

export const Register = async (data: RegisterDTO) => {
  const normalizedEmail = AuthValidators.normalizeEmail(data.email);
  const normalizedUsername = AuthValidators.normalizeUsername(data.username);

  const emailValidation = AuthValidators.validateEmail(normalizedEmail);
  if (!emailValidation.valid) {
    throw new Error(emailValidation.message);
  }

  const usernameValidation = AuthValidators.validateUsername(normalizedUsername);
  if (!usernameValidation.valid) {
    throw new Error(usernameValidation.message);
  }

  const passwordValidation = PasswordService.validateFormat(data.password);
  if (!passwordValidation.valid) {
    throw new Error(passwordValidation.message);
  }

  const existingEmail = await UserRepository.findByEmail(normalizedEmail);
  if (existingEmail) {
    throw new Error('This email address is already in use.');
  }

  const existingUsername = await UserRepository.findByUsername(normalizedUsername);
  if (existingUsername) {
    throw new Error('This username is already taken.');
  }

  const passwordhash = await PasswordService.hash(data.password);
  const userid = uuidv4();

  const user = await UserRepository.create({
    userid,
    name: data.name,
    lastname: data.lastname,
    username: normalizedUsername,
    email: normalizedEmail,
    passwordhash,
    userrole: data.role || UserRole.STUDENT,
  });

  if (user.userrole === UserRole.STUDENT) {
    await StudentRepository.create(user.userid);
  } else if (user.userrole === UserRole.ADMIN) {
    await AdminRepository.create(user.userid);
  }

  const verification = await SendVerificationCode(user.userid, user.email);

  return {
    success: true,
    message: 'Registration successful. Please verify your email.',
    userid: user.userid,
    verificationToken: verification.verificationToken,
  };
};
