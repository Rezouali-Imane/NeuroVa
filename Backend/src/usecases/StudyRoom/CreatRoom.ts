import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { CreateRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const CreateStudyRoom = async (data: CreateRoomDTO) => {
  if (data.sessionduration <= 15 || data.sessionduration > 240) //time in minute
  {
    throw new Error("Please set a valid focus duration.");
  }

  if (data.starttime >= data.endtime) {
    throw new Error("Start time must be before the end time.");
  }

 
  // Prevents scheduling a session for time that has already passed.
  const now = new Date();
  if (data.starttime < now) {
    throw new Error(
      "Cannot create a study room for a time that has already passed.",
    );
  }

  const newRoom = await StudyRoomRepository.create(data);

  return {
    success: true,
    message: "Study room created successfully",
    data: newRoom,
  };
};
