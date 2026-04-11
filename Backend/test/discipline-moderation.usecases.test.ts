import { beforeEach, describe, expect, it, vi } from 'vitest';

const prismaMock = vi.hoisted(() => ({
  digitaldisciplinesettings: {
    findUnique: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    upsert: vi.fn(),
  },
  blockedapp: {
    findFirst: vi.fn(),
    create: vi.fn(),
    delete: vi.fn(),
  },
  blockedwebsite: {
    findFirst: vi.fn(),
    create: vi.fn(),
    delete: vi.fn(),
  },
  usagelimit: {
    create: vi.fn(),
    findFirst: vi.fn(),
  },
  usagelog: {
    create: vi.fn(),
    findMany: vi.fn(),
  },
  disciplinealert: {
    create: vi.fn(),
    findMany: vi.fn(),
  },
  disciplinescore: {
    upsert: vi.fn(),
  },
  contentmoderationpolicy: {
    upsert: vi.fn(),
    update: vi.fn(),
  },
}));

vi.mock('../src/infrastructure/database/prisma.client.js', () => ({
  default: prismaMock,
}));

import { DisciplineService } from '../src/usecases/discipline/DisciplineService.js';
import { ContentModerationService } from '../src/usecases/contentModeration/ContentModerationService.js';

describe('discipline and moderation services', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('creates settings when missing', async () => {
    prismaMock.digitaldisciplinesettings.findUnique.mockResolvedValue(null);
    prismaMock.digitaldisciplinesettings.create.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });

    const result = await DisciplineService.getSettings('usr1');

    expect(prismaMock.digitaldisciplinesettings.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ userid: 'usr1' }),
      }),
    );
    expect(result).toMatchObject({ settingsid: 'set1', userid: 'usr1' });
  });

  it('creates a blocked app without duplicates', async () => {
    prismaMock.digitaldisciplinesettings.findUnique.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });
    prismaMock.blockedapp.findFirst.mockResolvedValue(null);
    prismaMock.blockedapp.create.mockResolvedValue({ appid: 'app1', appname: 'TikTok' });

    const result = await DisciplineService.addBlockedApp('usr1', { appname: 'TikTok' });

    expect(result).toEqual({ appid: 'app1', appname: 'TikTok' });
    expect(prismaMock.blockedapp.create).toHaveBeenCalledTimes(1);
  });

  it('creates an alert when usage exceeds limit', async () => {
    prismaMock.digitaldisciplinesettings.findUnique.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });
    prismaMock.usagelimit.findFirst.mockResolvedValue({
      dailylimitminutes: 30,
    });
    prismaMock.usagelog.create.mockResolvedValue({ logid: 'log1' });
    prismaMock.disciplinealert.create.mockResolvedValue({ alertid: 'a1' });

    const result = await DisciplineService.logUsage('usr1', {
      appname: 'Instagram',
      usageminutes: 45,
    });

    expect(result).toEqual({ logid: 'log1' });
    expect(prismaMock.disciplinealert.create).toHaveBeenCalledTimes(1);
  });

  it('blocks unsafe text content', async () => {
    prismaMock.digitaldisciplinesettings.upsert.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });
    prismaMock.contentmoderationpolicy.upsert.mockResolvedValue({
      policyid: 'pol1',
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });

    const result = await ContentModerationService.analyzeText({
      userid: 'usr1',
      content: 'This contains violence and hate speech',
    });

    expect(result.decision).toBe('BLOCK');
    expect(result.reason).toContain('Unsafe');
  });

  it('updates moderation policy', async () => {
    prismaMock.digitaldisciplinesettings.upsert.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });
    prismaMock.contentmoderationpolicy.upsert.mockResolvedValue({
      policyid: 'pol1',
      settingsid: 'set1',
    });
    prismaMock.contentmoderationpolicy.update.mockResolvedValue({
      policyid: 'pol1',
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });

    const result = await ContentModerationService.updatePolicy('usr1', {
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });

    expect(result).toMatchObject({
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });
  });
});
