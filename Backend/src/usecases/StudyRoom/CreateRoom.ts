import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { CreateRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const CreateStudyRoom = async (data: CreateRoomDTO) => {
    if (data.sessionduration <= 15 || data.sessionduration > 240) {
        throw new Error("Session duration must be between 15 and 240 minutes.");
    }

    const room = await StudyRoomRepository.create(data);

    return {
        success: true,
        message: "Study room created successfully",
        data: room,
    };
};