import type { RegisterUserDTO } from '../../interfaces/dtos/Auth.dto.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { StudentRepository, AdminRepository } from '../../interfaces/repositories/RoleRepository.js';
import { SendVerificationCode } from './SendVerificationCode.js';
import { UserRole } from '../../entities/User.js';
import bcrypt from 'bcrypt';

export const SignUp = async (data: RegisterUserDTO) => {
  const normalizedEmail = data.email.toLowerCase().trim();
  const normalizedUsername = data.username.toLowerCase().trim();

  // Validate email format
  const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (!emailRegex.test(normalizedEmail)) {
    throw new Error("L'adresse email est mal formée.");
  }

  // Validate password format
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
  const emojiRegex = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/u;

  if (emojiRegex.test(data.password)) {
    throw new Error("Les emojis ne sont pas autorisés dans le mot de passe.");
  }

  if (!passwordRegex.test(data.password)) {
    throw new Error(
      "Le mot de passe doit contenir au moins 8 caractères, incluant une majuscule, une minuscule, un chiffre et un caractère spécial (@$!%*?&)."
    );
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
  const passwordhash = await bcrypt.hash(data.password, 10);

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
