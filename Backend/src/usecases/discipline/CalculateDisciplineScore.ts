import prisma from '../../infrastructure/database/prisma.client.js';

const normalizeDate = (date: Date) => {
  const normalized = new Date(date);
  normalized.setHours(0, 0, 0, 0);
  return normalized;
};

export const CalculateDisciplineScore = async (userid: string) => {
  const logs = await prisma.usagelog.findMany({
    where: { userid },
    orderBy: { logdate: 'desc' },
    take: 30,
  });

  const alerts = await prisma.disciplinealert.findMany({
    where: { userid, isread: false },
  });

  const blockedCount = logs.filter((log) => log.wasblocked).length;
  const minutes = logs.reduce((sum, log) => sum + log.usageminutes, 0);
  const totalPenalty = Math.min(50, blockedCount * 10 + Math.floor(minutes / 180) + alerts.length * 4);
  const score = Math.max(0, 100 - totalPenalty);
  const violationcount = blockedCount + alerts.length;
  const streak = Math.max(0, Math.floor((100 - totalPenalty) / 10));
  const scoredate = normalizeDate(new Date());

  return prisma.disciplinescore.upsert({
    where: {
      userid_scoredate: {
        userid,
        scoredate,
      },
    },
    update: {
      score,
      violationcount,
      streak,
    },
    create: {
      userid,
      score,
      violationcount,
      streak,
      scoredate,
    },
  });
};
