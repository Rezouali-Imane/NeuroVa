import { FocusSessionRepository} from "../../interfaces/repositories/FocusSessionRepository.js";

export  const GetSessions = async  (userId: string) => {
    return await FocusSessionRepository.findAllByUser(userId);
}