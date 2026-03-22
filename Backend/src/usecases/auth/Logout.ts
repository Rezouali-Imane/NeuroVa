import type { LogoutDTO } from '../../interfaces/dtos/Auth.dto.js';

export const Logout = async (_data: LogoutDTO) => {
  return {
    success: true,
    message: 'Logged out successfully.',
  };
};
