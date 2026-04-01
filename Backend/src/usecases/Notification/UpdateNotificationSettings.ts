import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';
import type { UpdateNotificationSettingsDTO } from '../../interfaces/dtos/Notification.dto.js';

export const UpdateNotificationSettings = async (userid: string, data: UpdateNotificationSettingsDTO) => {
    if (!userid) throw new Error('User ID is required');
    return await NotificationRepository.updateSettings(userid, data);
};