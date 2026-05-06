import { BrevoClient } from '@getbrevo/brevo';
import 'dotenv/config';

const brevo = new BrevoClient({ apiKey: process.env.BREVO_API_KEY! });

export const sendEmail = async (
  to: string,
  subject: string,
  htmlContent: string
): Promise<void> => {
  await brevo.transactionalEmails.sendTransacEmail({
    sender: { name: 'Neurova', email: 'yassde2006@gmail.com' },
    to: [{ email: to }],
    subject,
    htmlContent,
  });
};

export const emailTemplates = {

  taskReminder: (taskTitle: string, deadline: string) => ({
    subject: `⏰ Reminder: "${taskTitle}" is due soon`,
    html: `
      <div style="font-family:sans-serif;max-width:600px;margin:0 auto;">
        <h2 style="color:#7B2FBE;">Task Reminder</h2>
        <p>Your task <strong>"${taskTitle}"</strong> is due on <strong>${deadline}</strong>.</p>
        <p>Open Neurova to review and complete it before the deadline.</p>
        <a href="#" style="background:linear-gradient(135deg,#7B2FBE,#E040FB);color:white;padding:12px 24px;border-radius:24px;text-decoration:none;display:inline-block;margin-top:16px;">
          Open Neurova →
        </a>
        <p style="color:#999;margin-top:24px;font-size:12px;">Neurova — Focus. Learn. Thrive.</p>
      </div>`,
  }),

  studyPlanReady: (planSummary: string) => ({
    subject: '📚 Your Neurova Study Plan is Ready',
    html: `
      <div style="font-family:sans-serif;max-width:600px;margin:0 auto;">
        <h2 style="color:#7B2FBE;">Your Study Plan</h2>
        <div style="background:#1A1A2E;color:#fff;padding:16px;border-radius:12px;white-space:pre-line;">${planSummary}</div>
        <p style="color:#999;margin-top:24px;font-size:12px;">Neurova — Focus. Learn. Thrive.</p>
      </div>`,
  }),

  focusSessionComplete: (duration: number, taskTitle?: string) => ({
    subject: '✅ Focus Session Complete!',
    html: `
      <div style="font-family:sans-serif;max-width:600px;margin:0 auto;">
        <h2 style="color:#7B2FBE;">Great Work! 🎉</h2>
        <p>You completed a <strong>${duration} minute</strong> focus session${taskTitle ? ` on <strong>"${taskTitle}"</strong>` : ''}.</p>
        <p>Keep up the momentum — consistency is the key to success.</p>
        <p style="color:#999;margin-top:24px;font-size:12px;">Neurova — Focus. Learn. Thrive.</p>
      </div>`,
  }),
};