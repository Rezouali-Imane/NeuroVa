import { StudyRoomRepository } from "../../interfaces/repositories/StudyRoomRepository.js";
import type { SendMessageDTO } from "../../interfaces/dtos/StudyRoom.dto.js";

export const SendMessage = async (userid: string, data: SendMessageDTO) => {

  if (!data.content || data.content.trim().length === 0) {
    throw new Error("Message content cannot be empty.");
  }

  if (data.content.length > 500) {
    throw new Error("Message is too long (limit: 500 characters).");
  }

  const room = await StudyRoomRepository.findById(data.roomid);

  if (!room) {
    throw new Error("Target study room does not exist.");
  }

  const roomuser = room.studyroommember.find((m) => m.userid === userid);

  if (!roomuser) {
    throw new Error("You are not authorized to send messages to this room.");
  }

  return {
    roomid: data.roomid,
    content: data.content,
    senderid: userid,
    senderName: roomuser.users.username, 
    sentat: new Date(), 
  };
};