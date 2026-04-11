import { NotificationRepository } from "../../interfaces/repositories/NotificationRepository.js";

export const GetUserNotifications = async (userId: string) => {
    if (!userId) throw new Error("User ID is required");

    return await NotificationRepository.findAllByUser(userId);
};
