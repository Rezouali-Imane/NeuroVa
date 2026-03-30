import { NotificationRepository } from "../../interfaces/repositories/NotificationRepositoryjs";

export const GetUSerNotification = async (userId: string) => {
    if (!userId) throw new Error("User ID is required");

    return await NotificationRepository.findAllByUser(userId);
};
