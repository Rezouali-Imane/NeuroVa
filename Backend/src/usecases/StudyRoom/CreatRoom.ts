import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import { UserRepository } from "../../interfaces/repositories/UserRepository.js";
import type { CreateRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const CreateStudyRoom = async (data: CreateRoomDTO) => {

    if (data.sessionduration <= 15 || data.sessionduration > 240) {
        throw new Error("Please set a valid focus duration.");
    }
    
   
    const newRoom = await StudyRoomRepository.create({
        ...data,
    });

   
    const adminUser = await UserRepository.findById(data.ownerid);

  
    return {
        success: true,
        message: "Study room created successfully",
        userName: adminUser?.username ,
        data: newRoom,
    };
};