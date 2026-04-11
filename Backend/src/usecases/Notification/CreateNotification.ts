import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import type { CreateNotificationDTO } from '../../interfaces/dtos/Notification.dto.js';

export const CreateNotification = async (data: CreateNotificationDTO) => {
    if (!data.userid) throw new Error('User ID is required');
    if (!data.title || data.title.trim() === '') throw new Error('Title is required');
    if (!data.message || data.message.trim() === '') throw new Error('Message is required');
    if (!data.type) throw new Error('Notification type is required');

        return await NotificationRepository.createNotification({
            ...data,
            isread: data.isread ?? false,
            createdat: data.createdat ?? new Date(),
        });
};