import prisma from '../../infrastructure/database/prisma.client.js';
import { sendEmail, emailTemplates } from '../../infrastructure/resend.client.js';

// Send email reminders for tasks due in the next 24 hours
// Can be called for one user or all users

export const SendTaskReminders = async (userid?: string) => {
  const now = new Date();
  const in24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

  // Find tasks due within next 24 hours
  const upcomingTasks = await prisma.task.findMany({
    where: {
      ...(userid ? { userid } : {}),
      deadline: { gte: now, lte: in24Hours },
      status: { in: ['PENDING', 'IN_PROGRESS'] },
    },
    include: { users: true },
  });

  const results = [];

  for (const task of upcomingTasks) {
    try {
      const userEmail = (task.users as any)?.email;
      if (!userEmail) continue;

      const deadline = task.deadline
        ? new Date(task.deadline).toLocaleDateString('en-US', {
            weekday: 'long', month: 'long', day: 'numeric',
            hour: '2-digit', minute: '2-digit',
          })
        : 'soon';

      const { subject, html } = emailTemplates.taskReminder(task.title, deadline);
      await sendEmail(userEmail, subject, html);

      results.push({ taskid: task.taskid, title: task.title, status: 'sent' });
    } catch {
      results.push({ taskid: task.taskid, title: task.title, status: 'failed' });
    }
  }

  return {
    remindersChecked: upcomingTasks.length,
    remindersSent: results.filter(r => r.status === 'sent').length,
    results,
  };
};