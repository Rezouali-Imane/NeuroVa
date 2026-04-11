import { beforeEach, describe, expect, it, vi } from 'vitest';
import { UserRepository } from '../src/interfaces/repositories/UserRepository.js';
import { StudentRepository, AdminRepository } from '../src/interfaces/repositories/RoleRepository.js';
import { PasswordResetRepository } from '../src/interfaces/repositories/PasswordResetRepository.js';
import { EmailTokenRepository } from '../src/interfaces/repositories/EmailTokenRepository.js';
import { MailService } from '../src/infrastructure/email/MailService.js';
import { PasswordService } from '../src/infrastructure/auth/passwordService.js';
import { JWTService } from '../src/infrastructure/auth/jwtService.js';
import { JwtClient } from '../src/infrastructure/jwt.client.js';
import { HmacClient } from '../src/infrastructure/hmac.client.js';
import { TokenGenerator } from '../src/infrastructure/auth/tokenGenerator.js';
import { SignUp } from '../src/usecases/auth/SignUp.js';
import { Login } from '../src/usecases/auth/Login.js';
import { ForgotPassword } from '../src/usecases/auth/ForgotPassword.js';
import { VerifyResetCode } from '../src/usecases/auth/VerifyResetCode.js';
import { ResetPassword } from '../src/usecases/auth/ResetPassword.js';
import { SendVerificationCode } from '../src/usecases/auth/SendVerificationCode.js';
import { VerifyEmail } from '../src/usecases/auth/VerifyEmail.js';
import { UserRole } from '../src/entities/User.js';

describe('auth usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('SignUp creates a student account and sends verification code', async () => {
    vi.spyOn(UserRepository, 'findByEmail').mockResolvedValue(null as any);
    vi.spyOn(UserRepository, 'findByUsername').mockResolvedValue(null as any);
    vi.spyOn(PasswordService, 'hash').mockResolvedValue('hashed');
    vi.spyOn(JwtClient, 'signAccessToken').mockReturnValue('access-token');
    vi.spyOn(JwtClient, 'signRefreshToken').mockReturnValue('refresh-token');
    vi.spyOn(UserRepository, 'create').mockResolvedValue({ userid: 'usr1', userrole: UserRole.STUDENT, email: 'a@test.com', username: 'student1', isverified: false } as any);
    vi.spyOn(StudentRepository, 'create').mockResolvedValue({ userid: 'usr1' } as any);
    vi.spyOn(EmailTokenRepository, 'invalidateOldTokens').mockResolvedValue(undefined as any);
    vi.spyOn(EmailTokenRepository, 'create').mockResolvedValue({ tokenid: 'evt1' } as any);
    vi.spyOn(MailService, 'sendVerificationCode').mockResolvedValue(undefined as any);

    await expect(SignUp({ name: 'A', lastname: 'B', username: 'student1', email: 'a@test.com', password: 'StrongP@ss1' } as any)).resolves.toMatchObject({
      success: true,
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      message: 'Registration successful. Verify your email from Settings.',
      user: {
        id: 'usr1',
        username: 'student1',
        email: 'a@test.com',
        role: UserRole.STUDENT,
        isverified: false,
      },
    });
  });

  it('Login returns token for verified user and verification prompt for unverified user', async () => {
    vi.spyOn(UserRepository, 'findByEmailOrUsername').mockResolvedValue({ userid: 'usr1', passwordhash: 'hash', islocked: false, failedloginattempts: 0, isverified: true, userrole: UserRole.STUDENT, username: 'student1', email: 'a@test.com' } as any);
    vi.spyOn(PasswordService, 'compare').mockResolvedValue(true);
    vi.spyOn(JwtClient, 'signAccessToken').mockReturnValue('access-token');
    vi.spyOn(JwtClient, 'signRefreshToken').mockReturnValue('refresh-token');
    await expect(Login({ identifier: 'a@test.com', password: 'StrongP@ss1' } as any)).resolves.toMatchObject({
      success: true,
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      user: { id: 'usr1', username: 'student1', email: 'a@test.com', role: UserRole.STUDENT },
    });

    vi.spyOn(UserRepository, 'findByEmailOrUsername').mockResolvedValue({ userid: 'usr2', passwordhash: 'hash', islocked: false, failedloginattempts: 0, isverified: false, userrole: UserRole.STUDENT, username: 'student2', email: 'b@test.com' } as any);
    vi.spyOn(EmailTokenRepository, 'invalidateOldTokens').mockResolvedValue(undefined as any);
    vi.spyOn(EmailTokenRepository, 'create').mockResolvedValue({ tokenid: 'evt2' } as any);
    vi.spyOn(MailService, 'sendVerificationCode').mockResolvedValue(undefined as any);
    await expect(Login({ identifier: 'b@test.com', password: 'StrongP@ss1' } as any)).resolves.toMatchObject({
      success: true,
      accessToken: expect.any(String),
      refreshToken: expect.any(String),
      user: { id: 'usr2', username: 'student2', email: 'b@test.com', role: UserRole.STUDENT },
    });
  });

  it('Login increments attempts when password is invalid', async () => {
    vi.spyOn(UserRepository, 'findByEmailOrUsername').mockResolvedValue({ userid: 'usr1', passwordhash: 'hash', islocked: false, failedloginattempts: 4 } as any);
    vi.spyOn(PasswordService, 'compare').mockResolvedValue(false);
    const updateSpy = vi.spyOn(UserRepository, 'updateLoginAttempts').mockResolvedValue({} as any);
    await expect(Login({ identifier: 'a@test.com', password: 'bad' } as any)).rejects.toThrow('Invalid credentials.');
    expect(updateSpy).toHaveBeenCalledWith('usr1', 5, true);
  });

  it('ForgotPassword always returns success and sends reset email for existing users', async () => {
    vi.spyOn(UserRepository, 'findByEmail').mockResolvedValue(null as any);
    await expect(ForgotPassword({ email: 'missing@test.com' } as any)).resolves.toEqual({ success: true, message: 'If this account exists, a reset code has been sent.' });

    vi.spyOn(UserRepository, 'findByEmail').mockResolvedValue({ userid: 'usr1', email: 'a@test.com' } as any);
    vi.spyOn(TokenGenerator, 'generateResetToken').mockReturnValue('123456');
    vi.spyOn(TokenGenerator, 'getExpirationDate').mockReturnValue(new Date('2026-01-01T10:00:00Z'));
    vi.spyOn(PasswordResetRepository, 'invalidateOldTokens').mockResolvedValue(undefined as any);
    vi.spyOn(PasswordResetRepository, 'create').mockResolvedValue({ tokenid: 'prt1' } as any);
    vi.spyOn(MailService, 'sendResetPasswordCode').mockResolvedValue(undefined as any);
    await expect(ForgotPassword({ email: 'a@test.com' } as any)).resolves.toEqual({ success: true, message: 'If this account exists, a reset code has been sent.' });
  });

  it('VerifyResetCode and ResetPassword validate token flow', async () => {
    vi.spyOn(UserRepository, 'findByEmail').mockResolvedValue({ userid: 'usr1' } as any);
    vi.spyOn(PasswordResetRepository, 'findValidToken').mockResolvedValue({ tokenid: 'prt1' } as any);
    await expect(VerifyResetCode({ email: 'a@test.com', resetcode: '123456' } as any)).resolves.toEqual({ success: true, message: 'Code verified successfully.', userid: 'usr1' });

    vi.spyOn(PasswordService, 'hash').mockResolvedValue('newhash');
    vi.spyOn(UserRepository, 'resetUserPassword').mockResolvedValue({} as any);
    vi.spyOn(PasswordResetRepository, 'markAsUsed').mockResolvedValue({} as any);
    await expect(ResetPassword({ email: 'a@test.com', resetcode: '123456', newPassword: 'StrongP@ss1' } as any)).resolves.toEqual({ success: true, message: 'Password reset successfully.' });
  });

  it('SendVerificationCode stores token and sends email', async () => {
    vi.spyOn(TokenGenerator, 'generateVerificationCode').mockReturnValue('654321');
    vi.spyOn(EmailTokenRepository, 'invalidateOldTokens').mockResolvedValue(undefined as any);
    vi.spyOn(EmailTokenRepository, 'create').mockResolvedValue({ tokenid: 'evt1' } as any);
    vi.spyOn(MailService, 'sendVerificationCode').mockResolvedValue(undefined as any);
    await expect(SendVerificationCode('usr1', 'a@test.com')).resolves.toEqual({ success: true, message: 'Verification code sent.' });
  });

  it('VerifyEmail marks user verified when token exists', async () => {
    const verificationToken = HmacClient.generate({ userid: 'usr1' }, 900);
    vi.spyOn(EmailTokenRepository, 'findValidToken').mockResolvedValue({ tokenid: 'evt1' } as any);
    vi.spyOn(UserRepository, 'markUserAsVerified').mockResolvedValue({} as any);
    vi.spyOn(UserRepository, 'findById').mockResolvedValue({ userid: 'usr1', userrole: UserRole.STUDENT } as any);
    vi.spyOn(EmailTokenRepository, 'markAsUsed').mockResolvedValue({} as any);
    await expect(VerifyEmail({ token: verificationToken } as any)).resolves.toMatchObject({ success: true, message: 'Email verified successfully. You can now log in.' });
  });
});