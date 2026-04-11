import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import { MailService } from '../../infrastructure/email/MailService.js';
import { UserRepository } from '../../interfaces/repositories/UserRepository.js';
import { CreateNotification } from './CreateNotification.js';
import { NotificationType } from '../../entities/Notification.js';
import type  { CreateNotificationDTO } from '../../interfaces/dtos/Notification.dto.js';

export const sendEmailNotification = async (userid: string, subject: string, message: string, type: NotificationType = NotificationType.SYSTEM)=> {
        if (!userid) throw new Error("User ID is required");
        if (!subject) throw new Error("Subject is required");
        if (!message) throw new Error("Message is required");

        const user = await UserRepository.findById(userid);
        if (!user?.email) throw new Error("Recipient email not found");

        const data: CreateNotificationDTO = {
            userid,
            type,
            title: subject,
            message,
        };

        const settings = await NotificationRepository.getSettings(userid);
    if (settings && !settings.emailenabled) return ;

        await MailService.sendNotification(user.email, data.title, data.message);
    return await CreateNotification(data);
};