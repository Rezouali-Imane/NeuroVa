import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";

export const GetActiveRooms = async () => {
  const rooms = await StudyRoomRepository.findAllActive();
  return rooms;
};