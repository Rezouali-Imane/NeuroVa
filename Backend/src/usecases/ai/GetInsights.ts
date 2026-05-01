import prisma from '../../infrastructure/database/prisma.client.js';
import { StudentMemoryRepository } from '../../interfaces/repositories/AIRepositories.js';

export const GetInsights = async (userid: string) => {
  if (!userid) throw new Error('User ID is required');

  const [tasks, focusSessions, memory] = await Promise.all([
    prisma.task.findMany({ where: { userid } }),
    prisma.focussession.findMany({ where: { userid }, orderBy: { starttime: 'desc' } }),
    StudentMemoryRepository.findByUser(userid),
  ]);

  const taskSummary = tasks.reduce(
    (summary, task) => {
      summary.total += 1;
      if (task.status === 'COMPLETED') summary.completed += 1;
      else if (task.status === 'OVERDUE') summary.overdue += 1;
      else if (task.status === 'IN_PROGRESS') summary.inProgress += 1;
      else summary.pending += 1;
      return summary;
    },
    { total: 0, completed: 0, overdue: 0, inProgress: 0, pending: 0 }
  );

  const averageFocusScore = focusSessions.length > 0
    ? Math.round((focusSessions.reduce((sum, session) => sum + Number(session.focusscore ?? 0), 0) / focusSessions.length) * 10) / 10
    : 0;

  const recentSessions = focusSessions.slice(0, 5).map(session => ({
    sessionid: session.sessionid,
    starttime: session.starttime,
    endtime: session.endtime,
    status: session.status,
    focusscore: session.focusscore,
  }));

  const insightBullets = [
    taskSummary.completed > 0
      ? `You have completed ${taskSummary.completed} task${taskSummary.completed === 1 ? '' : 's'} so far.`
      : 'You have not completed any tasks yet.',
    taskSummary.overdue > 0
      ? `${taskSummary.overdue} task${taskSummary.overdue === 1 ? ' is' : 's are'} currently overdue.`
      : 'No overdue tasks are currently recorded.',
    focusSessions.length > 0
      ? `Average focus score across ${focusSessions.length} session${focusSessions.length === 1 ? '' : 's'} is ${averageFocusScore}.`
      : 'No focus sessions have been recorded yet.',
    memory['weak_subjects'] ? `Weak subjects noted in memory: ${memory['weak_subjects']}.` : 'No weak subjects have been stored yet.',
  ];

  return {
    taskSummary,
    focusSummary: {
      totalSessions: focusSessions.length,
      averageFocusScore,
      recentSessions,
    },
    memory,
    insights: insightBullets,
  };
};