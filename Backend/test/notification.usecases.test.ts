import { beforeEach, describe, expect, it, vi } from 'vitest';
import { NotificationType } from '../src/entities/Notification.js';
import { NotificationRepository } from '../src/interfaces/repositories/NotificationRepository.js';
import { UserRepository } from '../src/interfaces/repositories/UserRepository.js';
import { MailService } from '../src/infrastructure/email/MailService.js';
import { NotificationService } from '../src/usecases/Notification/NotificationService.js';
import { CreateNotification } from '../src/usecases/Notification/CreateNotification.js';

describe('notification usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('validates notification creation payload', async () => {
    await expect(CreateNotification({
      userid: '',
      type: NotificationType.SYSTEM,
      title: 'Title',
      message: 'Message',
    } as any)).rejects.toThrow('User ID is required');

    await expect(CreateNotification({
      userid: 'usr1',
      type: NotificationType.SYSTEM,
      title: '',
      message: 'Message',
    } as any)).rejects.toThrow('Title is required');
  });

  it('schedules notifications through service', async () => {
    const createSpy = vi.spyOn(NotificationRepository, 'createNotification').mockResolvedValue({ notificationid: 'n1' } as any);

    await NotificationService.scheduleNotification('usr1', {
      type: NotificationType.SYSTEM,
      title: 'Heads up',
      message: 'Something happened',
    });

    expect(createSpy).toHaveBeenCalledWith(expect.objectContaining({
      userid: 'usr1',
      type: NotificationType.SYSTEM,
      title: 'Heads up',
    }));
  });

  it('sends email notifications when enabled', async () => {
    vi.spyOn(UserRepository, 'findById').mockResolvedValue({ userid: 'usr1', email: 'a@test.com' } as any);
    vi.spyOn(NotificationRepository, 'getSettings').mockResolvedValue({ emailenabled: true } as any);
    const mailSpy = vi.spyOn(MailService, 'sendNotification').mockResolvedValue(undefined as any);
    const createSpy = vi.spyOn(NotificationRepository, 'createNotification').mockResolvedValue({ notificationid: 'n1' } as any);

    await NotificationService.sendEmail('usr1', 'Test Subject', 'Test Body');

    expect(mailSpy).toHaveBeenCalledWith('a@test.com', 'Test Subject', 'Test Body');
    expect(createSpy).toHaveBeenCalledTimes(1);
  });

  it('does not send email notifications when disabled', async () => {
    vi.spyOn(UserRepository, 'findById').mockResolvedValue({ userid: 'usr1', email: 'a@test.com' } as any);
    vi.spyOn(NotificationRepository, 'getSettings').mockResolvedValue({ emailenabled: false } as any);
    const mailSpy = vi.spyOn(MailService, 'sendNotification').mockResolvedValue(undefined as any);

    const result = await NotificationService.sendEmail('usr1', 'Test Subject', 'Test Body');

    expect(result).toBeUndefined();
    expect(mailSpy).not.toHaveBeenCalled();
  });

  it('sends push notifications when enabled and persists notification', async () => {
    vi.spyOn(NotificationRepository, 'getSettings').mockResolvedValue({ pushenabled: true } as any);
    const createSpy = vi.spyOn(NotificationRepository, 'createNotification').mockResolvedValue({ notificationid: 'n1' } as any);

    await NotificationService.sendPush('usr1', 'Push title', 'Push body', NotificationType.DAILY_CHALLENGE);

    expect(createSpy).toHaveBeenCalledWith(expect.objectContaining({
      userid: 'usr1',
      title: 'Push title',
      type: NotificationType.DAILY_CHALLENGE,
    }));
  });

  it('marks notification read and mark-all flows', async () => {
    vi.spyOn(NotificationRepository, 'findById').mockResolvedValue({ notificationid: 'n1', userid: 'usr1' } as any);
    const readSpy = vi.spyOn(NotificationRepository, 'markAsRead').mockResolvedValue({ notificationid: 'n1', isread: true } as any);
    const allSpy = vi.spyOn(NotificationRepository, 'markAllAsRead').mockResolvedValue({ count: 3 } as any);

    await NotificationService.markAsRead('n1', 'usr1');
    await NotificationService.markAllRead('usr1');

    expect(readSpy).toHaveBeenCalledWith('n1');
    expect(allSpy).toHaveBeenCalledWith('usr1');
  });
});
