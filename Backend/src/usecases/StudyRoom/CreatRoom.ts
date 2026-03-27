import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { CreateRoomDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const CreateStudyRoom = async (data: CreateRoomDTO) => {
  // Ensure we are working with Date objects
  const start = new Date(data.starttime);
  const end = new Date(data.endtime);
  const now = new Date();

  if (data.sessionduration <= 15 || data.sessionduration > 240) {
    throw new Error("Please set a valid focus duration.");
  }

  if (start >= end) {
    throw new Error("Start time must be before the end time.");
  }

  if (start < now) {
    throw new Error("Cannot create a study room for a time that has already passed.");
  }
  
  // Pass the sanitized dates to the repository
  const newRoom = await StudyRoomRepository.create({
    ...data,
    starttime: start,
    endtime: end
  });

  return {
    success: true,
    message: "Study room created successfully",
    data: newRoom,
  };
};
