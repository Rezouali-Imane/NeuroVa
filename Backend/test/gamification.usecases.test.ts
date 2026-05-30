import { beforeEach, describe, expect, it, vi } from 'vitest';
import { XPSource } from '../src/entities/Gamification.entities.js';
import { GamificationRepository } from '../src/interfaces/repositories/GamificationRepository.js';
import { NotificationService } from '../src/usecases/Notification/NotificationService.js';
import { GamificationService } from '../src/usecases/Gamification/GamificationService.js';
import { CompleteChallenge } from '../src/usecases/Gamification/CompleteChallenge.js';
import { GetActiveDailyChallenges } from '../src/usecases/Gamification/GetActiveDailyChallenges.js';
import * as AssignDailyChallengeModule from '../src/usecases/Gamification/AssignDailyChallenge.js';

describe('gamification usecases', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('awards XP and updates user total', async () => {
    const txSpy = vi.spyOn(GamificationRepository, 'createXPTransaction').mockResolvedValue({ transactionid: 'tx1' } as any);
    const xpSpy = vi.spyOn(GamificationRepository, 'incrementUserXP').mockResolvedValue({ userid: 'usr1', xppoints: 200 } as any);

    await GamificationService.awardXP(
      'usr1',
      50,
      XPSource.SESSION_COMPLETED,
      'Session completion bonus',
    );

    expect(txSpy).toHaveBeenCalledWith(expect.objectContaining({ userid: 'usr1', amount: 50 }));
    expect(xpSpy).toHaveBeenCalledWith('usr1', 50);
  });

  it('assigns a daily challenge and notifies the user', async () => {
    vi.spyOn(GamificationRepository, 'getActiveChallengesByUser').mockResolvedValue([] as any);
    vi.spyOn(GamificationRepository, 'getFirstChallengeTemplate').mockResolvedValue({ templateid: 'tmp1' } as any);
    vi.spyOn(GamificationRepository, 'getChallengeTemplateById').mockResolvedValue({ templateid: 'tmp1' } as any);
    const createSpy = vi.spyOn(GamificationRepository, 'createDailyChallenge').mockResolvedValue({ challengeid: 'ch1' } as any);
    vi.spyOn(NotificationService, 'getSettings').mockResolvedValue({ dailychallengealerts: true } as any);
    const notifySpy = vi.spyOn(NotificationService, 'scheduleNotification').mockResolvedValue({ notificationid: 'n1' } as any);

    const result = await GamificationService.assignDailyChallenge('usr1');

    expect(result).toEqual({ success: true, message: 'Daily challenge assigned' });
    expect(createSpy).toHaveBeenCalledTimes(1);
    expect(notifySpy).toHaveBeenCalledWith('usr1', expect.objectContaining({
      title: 'New Daily Challenge Available',
    }));

    vi.spyOn(GamificationRepository, 'getActiveChallengesByUser').mockResolvedValue([{ challengeid: 'active', templateid: 'tmp1' }] as any);
    await expect(GamificationService.assignDailyChallenge('usr1')).resolves.toEqual({
      success: false,
      message: 'Challenge already assigned',
    });
  });

  it('fills daily challenges up to four when the app requests them', async () => {
    const activeSpy = vi.spyOn(GamificationRepository, 'getActiveChallengesByUser')
      .mockResolvedValueOnce([] as any)
      .mockResolvedValueOnce([] as any)
      .mockResolvedValueOnce([] as any)
      .mockResolvedValueOnce([] as any)
      .mockResolvedValueOnce([] as any)
      .mockResolvedValueOnce([
        { challengeid: 'ch1', templateid: 'tmp1' },
        { challengeid: 'ch2', templateid: 'tmp2' },
        { challengeid: 'ch3', templateid: 'tmp3' },
        { challengeid: 'ch4', templateid: 'tmp4' },
      ] as any);
    vi.spyOn(GamificationRepository, 'getAllChallengeTemplates').mockResolvedValue([
      { templateid: 'tmp1', title: 'Challenge 1', xpreward: 10 },
      { templateid: 'tmp2', title: 'Challenge 2', xpreward: 20 },
      { templateid: 'tmp3', title: 'Challenge 3', xpreward: 30 },
      { templateid: 'tmp4', title: 'Challenge 4', xpreward: 40 },
    ] as any);
    vi.spyOn(GamificationRepository, 'getChallengeTemplateById').mockImplementation(async (templateid: string) => ({
      templateid,
      title: `Challenge ${templateid.slice(-1)}`,
      xpreward: 10,
    }) as any);
    const createSpy = vi.spyOn(GamificationRepository, 'createDailyChallenge').mockResolvedValue({ challengeid: 'new' } as any);
    vi.spyOn(NotificationService, 'getSettings').mockResolvedValue({ dailychallengealerts: true } as any);
    vi.spyOn(NotificationService, 'scheduleNotification').mockResolvedValue({ notificationid: 'n1' } as any);

    const result = await GetActiveDailyChallenges('usr1');

    expect(result.success).toBe(true);
    expect(createSpy).toHaveBeenCalledTimes(4);
    expect(activeSpy).toHaveBeenCalled();
    expect(result.data).toHaveLength(4);
  });

  it('seeds default templates when fewer than four exist', async () => {
    vi.spyOn(GamificationRepository, 'getAllChallengeTemplates')
      .mockResolvedValueOnce([
        { templateid: 'tmp1', title: 'Triple Focus', xpreward: 75 },
      ] as any)
      .mockResolvedValueOnce([
        { templateid: 'tmp1', title: 'Triple Focus', xpreward: 75 },
        { templateid: 'tmp2', title: 'Task Master', xpreward: 50 },
        { templateid: 'tmp3', title: 'Note Taker', xpreward: 30 },
        { templateid: 'tmp4', title: 'Early Bird', xpreward: 100 },
      ] as any);
    vi.spyOn(GamificationRepository, 'createDailyChallengeTemplates').mockResolvedValue({ count: 3 } as any);
    vi.spyOn(GamificationRepository, 'getActiveChallengesByUser')
      .mockResolvedValueOnce([] as any)
      .mockResolvedValueOnce([
        { challengeid: 'ch1', templateid: 'tmp1' },
        { challengeid: 'ch2', templateid: 'tmp2' },
        { challengeid: 'ch3', templateid: 'tmp3' },
        { challengeid: 'ch4', templateid: 'tmp4' },
      ] as any);
    const assignSpy = vi.spyOn(AssignDailyChallengeModule, 'AssignDailyChallenge').mockResolvedValue({ success: true, message: 'Daily challenge assigned' } as any);

    const result = await GetActiveDailyChallenges('usr1');

    expect(result.success).toBe(true);
    expect(assignSpy).toHaveBeenCalledTimes(4);
    expect(result.data).toHaveLength(4);
  });

  it('completes a challenge and awards XP', async () => {
    vi.spyOn(GamificationRepository, 'findChallengeById').mockResolvedValue({
      challengeid: 'ch1',
      userid: 'usr1',
      templateid: 'tmp1',
      iscompleted: false,
      expiresat: new Date(Date.now() + 60_000),
    } as any);
    vi.spyOn(GamificationRepository, 'completeDailyChallenge').mockResolvedValue({
      challengeid: 'ch1',
      userid: 'usr1',
    } as any);
    vi.spyOn(GamificationRepository, 'getChallengeTemplateById').mockResolvedValue({
      templateid: 'tmp1',
      title: 'Study 30 minutes',
      xpreward: 250,
    } as any);
    vi.spyOn(GamificationRepository, 'getAllChallengeTemplates')
      .mockResolvedValueOnce([
        { templateid: 'tmp1', title: 'Study 30 minutes', xpreward: 250 },
        { templateid: 'tmp2', title: 'Task Master', xpreward: 50 },
        { templateid: 'tmp3', title: 'Note Taker', xpreward: 30 },
        { templateid: 'tmp4', title: 'Early Bird', xpreward: 100 },
      ] as any)
      .mockResolvedValueOnce([
        { templateid: 'tmp1', title: 'Study 30 minutes', xpreward: 250 },
        { templateid: 'tmp2', title: 'Task Master', xpreward: 50 },
        { templateid: 'tmp3', title: 'Note Taker', xpreward: 30 },
        { templateid: 'tmp4', title: 'Early Bird', xpreward: 100 },
      ] as any);
    vi.spyOn(GamificationRepository, 'getActiveChallengesByUser')
      .mockResolvedValueOnce([
        { challengeid: 'ch2', userid: 'usr1', templateid: 'tmp2' },
        { challengeid: 'ch3', userid: 'usr1', templateid: 'tmp3' },
        { challengeid: 'ch4', userid: 'usr1', templateid: 'tmp4' },
      ] as any)
      .mockResolvedValueOnce([
        { challengeid: 'ch2', userid: 'usr1', templateid: 'tmp2' },
        { challengeid: 'ch3', userid: 'usr1', templateid: 'tmp3' },
        { challengeid: 'ch4', userid: 'usr1', templateid: 'tmp4' },
      ] as any)
      .mockResolvedValueOnce([
        { challengeid: 'ch2', userid: 'usr1', templateid: 'tmp2' },
        { challengeid: 'ch3', userid: 'usr1', templateid: 'tmp3' },
        { challengeid: 'ch4', userid: 'usr1', templateid: 'tmp4' },
        { challengeid: 'ch5', userid: 'usr1', templateid: 'tmp1' },
      ] as any);
    vi.spyOn(GamificationRepository, 'createDailyChallenge').mockResolvedValue({ challengeid: 'ch5' } as any);
    const txSpy = vi.spyOn(GamificationRepository, 'createXPTransaction').mockResolvedValue({ transactionid: 'tx1' } as any);
    const xpSpy = vi.spyOn(GamificationRepository, 'incrementUserXP').mockResolvedValue({ userid: 'usr1' } as any);
    vi.spyOn(NotificationService, 'getSettings').mockResolvedValue({ dailychallengealerts: true } as any);
    const notifySpy = vi.spyOn(NotificationService, 'scheduleNotification').mockResolvedValue({ notificationid: 'n1' } as any);

    const result = await CompleteChallenge({ challengeid: 'ch1' });

    expect(result.success).toBe(true);
    expect(result).toMatchObject({ xpReward: 250 });
    expect(txSpy).toHaveBeenCalledWith(expect.objectContaining({ source: XPSource.CHALLENGE_COMPLETED, amount: 250 }));
    expect(xpSpy).toHaveBeenCalledWith('usr1', 250);
    expect(result.challenges).toHaveLength(4);
    expect(notifySpy).toHaveBeenCalledWith('usr1', expect.objectContaining({
      type: expect.anything(),
      title: 'Daily Challenge Completed',
    }));
  });

  it('calculates streak and updates student streak count', async () => {
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
    vi.spyOn(GamificationRepository, 'getLastCompletedSession').mockResolvedValue({ endtime: yesterday } as any);
    vi.spyOn(GamificationRepository, 'getCurrentStreak').mockResolvedValue(2);
    const streakSpy = vi.spyOn(GamificationRepository, 'updateStreak').mockResolvedValue({ userid: 'usr1', focusstreak: 3 } as any);

    const result = await GamificationService.calculateStreak('usr1');

    expect(result).toMatchObject({ success: true, streak: 3 });
    expect(streakSpy).toHaveBeenCalledWith('usr1', 3);
  });
});
