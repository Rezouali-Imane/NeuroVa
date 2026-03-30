import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { CreateNotification } from './CreatNotification.js';
import type  { CreateNotificationDTO } from '../../interfaces/dtos/Notification.dto.js';

export const sendEmailNotification = async (email: string, data: CreateNotificationDTO)=> {
    if (!email) throw new Error("Email is required");
    if (!data.userid) throw new Error("User ID is required");

    const settings = await NotificationRepository.getSettings(data.userid);
    if (settings && !settings.emailenabled) return ;

    await MailService.sendNotification(email, data.title, data.message);
    return await CreateNotification(data);
};