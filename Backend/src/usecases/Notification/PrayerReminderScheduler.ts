import prisma from '../../infrastructure/database/prisma.client.js';
import { getPrayerTimes } from '../../infrastructure/external/prayertime.client.js';
import { NotificationType } from '../../entities/Notification.js';
import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';

const DEFAULT_CITY = 'Bejaia';
const DEFAULT_COUNTRY = 'Algeria';
const PRAYER_REMINDER_MINUTES = 2;
const CHECK_INTERVAL_MS = 60_000;
const PRAYER_NAMES = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'] as const;

type PrayerName = (typeof PRAYER_NAMES)[number];

let sweepTimer: ReturnType<typeof setInterval> | null = null;
let isSweepRunning = false;

const parsePrayerTime = (time: string, baseDate: Date): Date | null => {
  const normalized = time.trim().split(' ')[0] ?? '';
  const match = normalized.match(/^(\d{1,2}):(\d{2})$/);
  if (!match) return null;

  const hour = Number(match[1]);
  const minute = Number(match[2]);
  if (!Number.isFinite(hour) || !Number.isFinite(minute)) return null;

  return new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate(), hour, minute, 0, 0);
};

const buildPrayerMap = (prayerTimes: Awaited<ReturnType<typeof getPrayerTimes>>['times']) => {
  const map = new Map<string, string>();
  for (const prayer of prayerTimes ?? []) {
    map.set(prayer.name, prayer.time);
  }
  return map;
};

const hasExistingReminder = async (userid: string, title: string, scheduledtime: Date) => {
  const existing = await prisma.notification.findFirst({
    where: {
      userid,
      title,
      scheduledtime,
    },
    select: { notificationid: true },
  });

  return Boolean(existing);
};

const createPrayerReminder = async (userid: string, prayerName: PrayerName, reminderTime: Date) => {
  const title = `Prayer time: ${prayerName}`;
  const message = `${prayerName} starts in ${PRAYER_REMINDER_MINUTES} minutes.`;

  if (await hasExistingReminder(userid, title, reminderTime)) {
    return;
  }

  await NotificationRepository.createNotification({
    userid,
    type: NotificationType.SYSTEM,
    title,
    message,
    scheduledtime: reminderTime,
  });
};

export const sweepPrayerReminders = async (now = new Date()) => {
  if (isSweepRunning) return;
  isSweepRunning = true;

  try {
    const enabledUsers = await prisma.digitaldisciplinesettings.findMany({
      where: { faithmodeenabled: true },
      select: { userid: true },
    });

    if (enabledUsers.length === 0) return;

    const prayerTimes = await getPrayerTimes(DEFAULT_CITY, DEFAULT_COUNTRY, now);
    const prayerMap = buildPrayerMap(prayerTimes?.times ?? []);

    for (const user of enabledUsers) {
      for (const prayerName of PRAYER_NAMES) {
        const prayerTime = prayerMap.get(prayerName);
        if (!prayerTime) continue;

        const prayerDate = parsePrayerTime(prayerTime, now);
        if (!prayerDate) continue;

        const reminderTime = new Date(prayerDate.getTime() - PRAYER_REMINDER_MINUTES * 60_000);
        const diff = now.getTime() - reminderTime.getTime();
        if (diff < 0 || diff >= CHECK_INTERVAL_MS) continue;

        await createPrayerReminder(user.userid, prayerName, reminderTime);
      }
    }
  } catch (error) {
    console.error('[PrayerReminders] Failed to sweep reminders:', error);
  } finally {
    isSweepRunning = false;
  }
};

export const startPrayerReminderScheduler = () => {
  if (sweepTimer) return;

  void sweepPrayerReminders();
  sweepTimer = setInterval(() => {
    void sweepPrayerReminders();
  }, CHECK_INTERVAL_MS);
};

export const stopPrayerReminderScheduler = () => {
  if (!sweepTimer) return;
  clearInterval(sweepTimer);
  sweepTimer = null;
};