import { beforeEach, describe, expect, it, vi } from 'vitest';

const prismaMock = vi.hoisted(() => ({
  digitaldisciplinesettings: {
    upsert: vi.fn(),
  },
  blockedwebsite: {
    findMany: vi.fn(),
    createMany: vi.fn(),
  },
  contentmoderationpolicy: {
    upsert: vi.fn(),
    update: vi.fn(),
  },
}));

vi.mock('../src/infrastructure/database/prisma.client.js', () => ({
  default: prismaMock,
}));

import { AnalyzeText } from '../src/usecases/contentModeration/AnalyzeText.js';
import { UpdatePolicy } from '../src/usecases/contentModeration/UpdatePolicy.js';

describe('content moderation service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('blocks unsafe text content', async () => {
    prismaMock.digitaldisciplinesettings.upsert.mockResolvedValue({
      settingsid: 'set1',
      userid: 'usr1',
    });
    prismaMock.blockedwebsite.findMany.mockResolvedValue([]);
    prismaMock.blockedwebsite.createMany.mockResolvedValue({ count: 1 });
    prismaMock.contentmoderationpolicy.upsert.mockResolvedValue({
      policyid: 'pol1',
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });

    const result = await AnalyzeText({
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
    prismaMock.blockedwebsite.findMany.mockResolvedValue([]);
    prismaMock.blockedwebsite.createMany.mockResolvedValue({ count: 1 });
    prismaMock.contentmoderationpolicy.upsert.mockResolvedValue({
      policyid: 'pol1',
      settingsid: 'set1',
    });
    prismaMock.contentmoderationpolicy.update.mockResolvedValue({
      policyid: 'pol1',
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });

    const result = await UpdatePolicy('usr1', {
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });

    expect(result).toMatchObject({
      sensitivecontentblockingenabled: true,
      sensitivitylevel: 'SFW_STRICT',
    });
  });
});
