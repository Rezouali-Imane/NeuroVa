import type { Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { CreateStudyRoom } from "../../usecases/StudyRoom/CreateRoom.js";
import { JoinStudyRoom } from "../../usecases/StudyRoom/JoinStudyRoom.js";
import { LeaveStudyRoom } from "../../usecases/StudyRoom/LeaveStudyRoom.js";
import { StartGroupSession } from "../../usecases/StudyRoom/StartGroupSession.js";
import { EndGroupSession } from "../../usecases/StudyRoom/EndGroupSession.js";

export class StudyRoomController {
  // Create Room
  static create = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;

      if (!userid) {
        return res.status(401).json({ message: "User not authenticated" });
      }

      const data = {
        ...req.body,
        ownerid: userid,
      };

      const result = await CreateStudyRoom(data);

      return res.status(201).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  // Join Room
  static join = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomcode } = req.params;

      if (!userid)
        return res.status(401).json({ message: "User not authenticated" });

      if (!roomcode) {
        return res.status(400).json({ message: "Room code is required." });
      }

      const result = await JoinStudyRoom({
        roomcode,
        userid,
      });

      const io = req.app.get("io");
      io.to(result.roomid).emit("room:member-joined", {
        userName: result.userName,
        message: `${result.username} has joined the room`,
      });

      return res.status(200).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  // Leave Room
  static leave = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomid } = req.params;

      if (!userid) return res.status(401).json({ message: "User not authenticated." });
      if (!roomid) return res.status(400).json({ message: "Room ID is required." });

      const result = await LeaveStudyRoom({ roomid, userid });

      const io = req.app.get("io");
      io.to(roomid).emit("room:member-left", {
        username: result.username,
        message: `${result.username} has left the room.`,
      });

      if (result.isOwner) {
        io.to(roomid).emit("room:closed", {
          message: "Owner closed the room.",
        });
      }

      return res.status(200).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  static startSession = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomid } = req.params;

      if (!userid) return res.status(401).json({ message: "User not authenticated." });
      if (!roomid) return res.status(400).json({ message: "Room ID is required." });

      const result = await StartGroupSession({ roomid, userid });

      const io = req.app.get("io");
      io.to(roomid).emit("session:start", {
        message: "Session has started. Focus!",
        startedat: result.startedat,
      });

      return res.status(200).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  static endSession = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomid } = req.params;

      if (!userid) return res.status(401).json({ message: "User not authenticated." });
      if (!roomid) return res.status(400).json({ message: "Room ID is required." });

      const result = await EndGroupSession({ roomid, userid });

      const io = req.app.get("io");
      io.to(roomid).emit("session:end", {
        message: "Session has ended. Room is now closed.",
        endedat: result.endedat,
      });

      return res.status(200).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };
}
