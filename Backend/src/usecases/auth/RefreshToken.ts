import type { RefreshTokenDTO } from '../../interfaces/dtos/Auth.dto.js';
import { JwtClient } from '../../infrastructure/jwt.client.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';

export const RefreshToken = async (data: RefreshTokenDTO) => {
  const payload = JwtClient.verifyRefreshToken(data.refreshToken);

  const user = await UserRepository.findById(payload.userid);
  if (!user) {
    throw new Error('User not found.');
  }

  if (user.islocked) {
    throw new Error('Account is locked.');
  }

  const accessToken = JwtClient.signAccessToken({
    userid: user.userid,
    role: user.userrole,
  });

  const refreshToken = JwtClient.signRefreshToken({ userid: user.userid });

  return {
    success: true,
    accessToken,
    refreshToken,
  };
};
