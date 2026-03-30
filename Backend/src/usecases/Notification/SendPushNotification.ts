import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import type { CreateNotificationDTO } from '../../../interfaces/dtos/Notification.dto.js';

export const SendPushNotification = async (userid: string, data: CreateNotificationDTO) => {
    if (!userid) throw new Error('User ID is required');

    const settings = await NotificationRepository.getSettings(userid);
    if (settings && !settings.pushenabled) return;

    // TODO: implement FCM push notification once Flutter integration is ready
    console.log(`[PushNotification] → userid: ${userid} | title: ${data.title} | message: ${data.message}`);

    return await NotificationRepository.create(data);
};