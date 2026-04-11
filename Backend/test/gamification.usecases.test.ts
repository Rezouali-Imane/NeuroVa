import { beforeEach, describe, expect, it, vi } from 'vitest';
import { XPSource } from '../src/entities/Gamification.entities.js';
import { GamificationRepository } from '../src/interfaces/repositories/GamificationRepository.js';
import { GamificationService } from '../src/usecases/Gamification/GamificationService.js';
import { CompleteChallenge } from '../src/usecases/Gamification/CompleteChallenge.js';

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

  it('assigns a daily challenge only when no active challenge exists', async () => {
    vi.spyOn(GamificationRepository, 'findActiveChallengeByUserId').mockResolvedValue(null as any);
    vi.spyOn(GamificationRepository, 'getFirstChallengeTemplate').mockResolvedValue({ templateid: 'tmp1' } as any);
    vi.spyOn(GamificationRepository, 'getChallengeTemplateById').mockResolvedValue({ templateid: 'tmp1' } as any);
    const createSpy = vi.spyOn(GamificationRepository, 'createDailyChallenge').mockResolvedValue({ challengeid: 'ch1' } as any);

    const result = await GamificationService.assignDailyChallenge('usr1');

    expect(result).toEqual({ success: true, message: 'Daily challenge assigned' });
    expect(createSpy).toHaveBeenCalledTimes(1);

    vi.spyOn(GamificationRepository, 'findActiveChallengeByUserId').mockResolvedValue({ challengeid: 'active' } as any);
    await expect(GamificationService.assignDailyChallenge('usr1')).resolves.toEqual({
      success: false,
      message: 'User already has an active challenge',
    });
  });

  it('completes a challenge and awards XP', async () => {
    vi.spyOn(GamificationRepository, 'findChallengeById').mockResolvedValue({
      challengeid: 'ch1',
      userid: 'usr1',
      iscompleted: false,
      expiresat: new Date(Date.now() + 60_000),
    } as any);
    vi.spyOn(GamificationRepository, 'completeDailyChallenge').mockResolvedValue({
      challengeid: 'ch1',
      userid: 'usr1',
    } as any);
    const txSpy = vi.spyOn(GamificationRepository, 'createXPTransaction').mockResolvedValue({ transactionid: 'tx1' } as any);
    const xpSpy = vi.spyOn(GamificationRepository, 'incrementUserXP').mockResolvedValue({ userid: 'usr1' } as any);

    const result = await CompleteChallenge({ challengeid: 'ch1' });

    expect(result.success).toBe(true);
    expect(txSpy).toHaveBeenCalledWith(expect.objectContaining({ source: XPSource.CHALLENGE_COMPLETED, amount: 100 }));
    expect(xpSpy).toHaveBeenCalledWith('usr1', 100);
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
