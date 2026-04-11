import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js'
export const MarkAllNotificationsRead = async (userid: string) => {
    if (!userid) throw new Error("User ID is required");

    return await NotificationRepository.markAllAsRead(userid);
}