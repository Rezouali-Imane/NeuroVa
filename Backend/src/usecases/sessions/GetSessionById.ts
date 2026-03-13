import { FocusSessionRepository } from "../../interfaces/repositories/FocusSessionRepository.js";

export const GetSessionById = async (sessionid: string) => {
    const session = await FocusSessionRepository.findById(sessionid);
    if (!session) {
        throw new Error("Session not found");
    }
    return session;
};