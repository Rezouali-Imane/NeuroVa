import type { RegisterDTO } from '../../interfaces/dtos/Auth.dto.js';
import { Register } from './Register.js';

export const SignUp = async (data: RegisterDTO) => Register(data);
