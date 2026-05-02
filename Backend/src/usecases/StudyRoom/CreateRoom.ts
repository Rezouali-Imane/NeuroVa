import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { CreateRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const CreateStudyRoom = async (data: CreateRoomDTO) => {

    const room = await StudyRoomRepository.create(data);

    return {
        success: true,
        message: "Study room created successfully",
        data: room,
    };
};