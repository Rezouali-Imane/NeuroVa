import type { Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { CreateStudyRoom } from "../../usecases/StudyRoom/CreateRoom.js";
import { JoinStudyRoom } from "../../usecases/StudyRoom/JoinStudyRoom.js";
import { LeaveStudyRoom } from "../../usecases/StudyRoom/LeaveStudyRoom.js";
import { StartGroupSession } from "../../usecases/StudyRoom/StartGroupSession.js";
import { EndGroupSession } from "../../usecases/StudyRoom/EndGroupSession.js";
import { GetActiveRooms } from "../../usecases/StudyRoom/GetActiveRooms.js";

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

  // Get all active rooms
static getAll = async (req: AuthRequest, res: Response) => {
  try {
    const userid = req.user?.userid;

    if (!userid) {
      return res.status(401).json({ success: false, message: "User not authenticated" });
    }

    const rooms = await GetActiveRooms(); 
    
    return res.status(200).json({ success: true, data: rooms });
  } catch (error: any) {
    return res.status(400).json({ success: false, message: error.message });
  }
};

  // Join Room
static join = async (req: AuthRequest, res: Response) => {
  try {
    const userid = req.user?.userid;
    const roomcode = Array.isArray(req.params.roomcode)
      ? req.params.roomcode[0]
      : req.params.roomcode;

    if (!userid) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    if (!roomcode) {
      return res.status(400).json({ message: "Room code is required." });
    }

    const result = await JoinStudyRoom({
      roomcode,
      userid,
    });

    const io = req.app.get("io");
    if (result.data) {
      io.to(result.data.roomid).emit("room:member-joined", {
        room: result.data, 
        userName: result.data.studyroommember.find((m: any) => m.userid === userid)?.users.username,
        message: `${result.data.studyroommember.find((m: any) => m.userid === userid)?.users.username} has joined the room.`,
      });
    }

    return res.status(200).json(result); 
  } catch (error: any) {
    return res.status(400).json({ message: error.message });
  }
};

  // Leave Room
  static leave = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const roomid = Array.isArray(req.params.roomid)
        ? req.params.roomid[0]
        : req.params.roomid;

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
      const roomid = Array.isArray(req.params.roomid)
        ? req.params.roomid[0]
        : req.params.roomid;

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
    const roomid = Array.isArray(req.params.roomid)
      ? req.params.roomid[0]
      : req.params.roomid;
    const duration = req.body.duration; 

    if (!userid) return res.status(401).json({ message: "User not authenticated." });
    if (!roomid) return res.status(400).json({ message: "Room ID is required." });

    const result = await EndGroupSession({ roomid, userid, duration });

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
