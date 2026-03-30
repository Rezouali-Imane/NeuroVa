import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import { UpdateNotificationSettingsDTO } from '../../interfaces/dtos/Notification.dto.js';

export const UpdateNotificationSettings = async (userId: string, data: UpdateNotificationSettingsDTO)=> {
    if (!userId) throw new Error("User ID is required");

    const  settings = await NotificationRepository.getSettings(userId);
    if (!settings) throw new Error("Notification settings not found");

    return await NotificationRepository.updateSettings(userId, data);
}