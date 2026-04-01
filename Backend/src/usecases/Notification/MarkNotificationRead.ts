import { NotificationRepository } from '../../interfaces/repositories/NotificationRepository.js'
export const MarkNotificationRead = async (notificationId: string, userid: string) => {
    if (!notificationId) throw new Error("Notification ID is required");
    if (!userid) throw new Error("User ID is required");

    const notification = await NotificationRepository.findById(notificationId);
    if (!notification) throw new Error("Notification non found");
    if (notification.userid !== userid) throw new Error("Unauthorized");

    return await NotificationRepository.markAsRead(notificationId);
}