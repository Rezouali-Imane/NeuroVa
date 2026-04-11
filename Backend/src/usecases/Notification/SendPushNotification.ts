import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import { NotificationType } from '../../entities/Notification.js';
import type { CreateNotificationDTO } from '../../interfaces/dtos/Notification.dto.js';

export const SendPushNotification = async (userid: string, title: string, message: string, type: NotificationType = NotificationType.SYSTEM) => {
    if (!userid) throw new Error('User ID is required');
        if (!title) throw new Error('Title is required');
        if (!message) throw new Error('Message is required');

        const data: CreateNotificationDTO = {
            userid,
            type,
            title,
            message,
        };

    const settings = await NotificationRepository.getSettings(userid);
    if (settings && !settings.pushenabled) return;

        // TODO: implement FCM push notification once Flutter integration is ready.

        return await NotificationRepository.createNotification(data);
};