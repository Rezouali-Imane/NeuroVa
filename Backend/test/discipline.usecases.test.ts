import { beforeEach, describe, expect, it, vi } from 'vitest';

const prismaMock = vi.hoisted(() => ({
  digitaldisciplinesettings: {
    findUnique: vi.fn(),
    create: vi.fn(),
  },
  blockedapp: {
    findFirst: vi.fn(),
    create: vi.fn(),
  },
  usagelimit: {
    findFirst: vi.fn(),
  },
  usagelog: {
    create: vi.fn(),
  },
  disciplinealert: {
    create: vi.fn(),
  },
}));

vi.mock('../src/infrastructure/database/prisma.client.js', () => ({
  default: prismaMock,
}));

import { GetSettings } from '../src/usecases/discipline/GetSettings.js';
import { AddBlockedApp } from '../src/usecases/discipline/AddBlockedApp.js';
import { LogUsage } from '../src/usecases/discipline/LogUsage.js';

describe('discipline service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('creates settings when missing', async () => {
    prismaMock.digitaldisciplinesettings.findUnique.mockResolvedValue(null);
    prismaMock.digitaldisciplinesettings.create.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });

    const result = await GetSettings('usr1');

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

    const result = await AddBlockedApp('usr1', { appname: 'TikTok' });

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

    const result = await LogUsage('usr1', {
      appname: 'Instagram',
      usageminutes: 45,
    });

    expect(result).toEqual({ logid: 'log1' });
    expect(prismaMock.disciplinealert.create).toHaveBeenCalledTimes(1);
  });
});
