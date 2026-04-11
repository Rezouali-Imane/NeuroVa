import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js';

export const getNotificationSettings = async (userId: string) => {
    if (!userId) throw new Error("User ID is required");

    return await NotificationRepository.getSettings(userId);
};
