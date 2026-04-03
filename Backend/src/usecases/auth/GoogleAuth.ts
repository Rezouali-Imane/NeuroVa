import { OAuth2Client } from 'google-auth-library';
import { v4 as uuidv4 } from 'uuid';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { StudentRepository } from '../../interfaces/repositories/RoleRepository.js';
import { UserRole } from '../../entities/User.js';
import { JwtClient } from '../../infrastructure/jwt.client.js';

const googleClientId = process.env.GOOGLE_CLIENT_ID;
if (!googleClientId) {
  throw new Error('GOOGLE_CLIENT_ID is not set in environment variables.');
}

const client = new OAuth2Client(googleClientId);

export const GoogleAuth = async ({ idToken }: { idToken: string }) => {
  if (!idToken) {
    throw new Error('Google ID token is required.');
  }

  const ticket = await client.verifyIdToken({
    idToken,
    audience: googleClientId,
  });

  const payload = ticket.getPayload();

  
  const email: string | undefined = payload?.email;
  const givenName: string = payload?.given_name ?? 'User';
  const familyName: string = payload?.family_name ?? '';

  if (!email) {
    throw new Error('Could not retrieve email from Google account.');
  }

  let user = await UserRepository.findByEmail(email);

  if (!user) {
    const userid = uuidv4();
   const parts = email.split('@');
    const localPart = parts[0] !== undefined ? parts[0] : email;
    const base = localPart.toLowerCase().replace(/[^a-z0-9_]/g, '_');
    const username = `${base}_${userid.slice(0, 5)}`;

    await UserRepository.create({
      userid,
      name: givenName,
      lastname: familyName,
      username,
      email,
      passwordhash: 'Via Google',
      userrole: UserRole.STUDENT,
      isverified: true,
    });

    await UserRepository.markUserAsVerified(userid);
    await StudentRepository.create(userid);

    user = await UserRepository.findByEmail(email);
  }

  if (!user) {
    throw new Error('Failed to create or retrieve user.');
  }

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
    user: {
      id: user.userid,
      username: user.username,
      email: user.email,
      role: user.userrole,
      isverified: true,
    },
  };
};