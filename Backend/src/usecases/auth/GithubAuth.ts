import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { StudentRepository } from '../../interfaces/repositories/RoleRepository.js';
import { UserRole } from '../../entities/User.js';
import { JwtClient } from '../../infrastructure/jwt.client.js';

export const GithubAuth = async ({ code }: { code: string }) => {
  if (!code) throw new Error('GitHub code is required.');
  const tokenResponse = await axios.post(
    'https://github.com/login/oauth/access_token',
    {
      client_id: process.env.GITHUB_CLIENT_ID,
      client_secret: process.env.GITHUB_CLIENT_SECRET,
      code,
    },
    { headers: { Accept: 'application/json' } },
  );

  const accessTokenGithub = tokenResponse.data.access_token;
  if (!accessTokenGithub) throw new Error('Failed to get GitHub access token.');


  const userResponse = await axios.get('https://api.github.com/user', {
    headers: { Authorization: `Bearer ${accessTokenGithub}` },
  });

  const githubUser = userResponse.data;

  let email: string | undefined = githubUser.email;
  if (!email) {
    const emailResponse = await axios.get('https://api.github.com/user/emails', {
      headers: { Authorization: `Bearer ${accessTokenGithub}` },
    });
    const primary = emailResponse.data.find(
      (e: any) => e.primary && e.verified,
    );
    email = primary?.email;
  }

  if (!email) throw new Error('Could not retrieve email from GitHub account.');

  let user = await UserRepository.findByEmail(email);
  const userAlreadyExisted = !!user;

  if (!user) {
    const userid = uuidv4();
    const nameParts = (githubUser.name ?? githubUser.login ?? 'User').split(' ');
    const name = nameParts[0] ?? 'User';
    const lastname = nameParts.slice(1).join(' ') ?? '';
    const base = githubUser.login.toLowerCase().replace(/[^a-z0-9_]/g, '_');
    const username = `${base}_${userid.slice(0, 5)}`;

    await UserRepository.create({
      userid,
      name,
      lastname,
      username,
      email,
      passwordhash: 'Via GitHub',
      userrole: UserRole.STUDENT,
      isverified: true,
    });

    await UserRepository.markUserAsVerified(userid);
    await StudentRepository.create(userid);
    user = await UserRepository.findByEmail(email);
  }

  if (!user) throw new Error('Failed to create or retrieve user.');

  const accessToken = JwtClient.signAccessToken({
    userid: user.userid,
    role: user.userrole,
    isverified: true,
  });

  const refreshToken = JwtClient.signRefreshToken({ userid: user.userid });

  return {
    success: true,
    accessToken,
    refreshToken,
    isNewUser: !userAlreadyExisted,
    user: {
      id: user.userid,
      username: user.username,
      email: user.email,
      role: user.userrole,
      isverified: true,
    },
  };
};