import prisma from '../../infrastructure/database/prisma.client.js';

export const GetTodayUsage = async (userid: string) => {
  const start = new Date();
  start.setHours(0, 0, 0, 0);

  const end = new Date(start);
  end.setDate(end.getDate() + 1);

  const logs = await prisma.usagelog.findMany({
    where: {
      userid,
      logdate: {
        gte: start,
        lt: end,
      },
    },
    orderBy: { logdate: 'desc' },
  });

  const totalMinutes = logs.reduce((sum, log) => sum + log.usageminutes, 0);
  const blockedCount = logs.filter((log) => log.wasblocked).length;

  return {
    userid,
    totalMinutes,
    blockedCount,
    entries: logs,
  };
};
