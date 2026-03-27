import type { Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { CreateStudyRoom } from "../../usecases/StudyRoom/CreatRoom.js";
import { JoinStudyRoom } from "../../usecases/StudyRoom/JoinStudyRoom.js";
import { LeaveStudyRoom } from "../../usecases/StudyRoom/LeaveStudyRoom.js";
import { SendMessage } from "../../usecases/StudyRoom/SendMessage.js";

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
        starttime: req.body.starttime ? new Date(req.body.starttime) : undefined,
        endtime: req.body.endtime ? new Date(req.body.endtime) : undefined
      };

      const result = await CreateStudyRoom(data);
      const io = req.app.get("io");
      
      io.emit("room_created", {
        message: "A new study room has been created!",
        room: result,
      });
      
      return res.status(201).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  // Join Room
  static join = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomid } = req.params;

      if (!userid) return res.status(401).json({ message: "User not authenticated" });

      if (typeof roomid !== 'string') {
        return res.status(400).json({ message: "Invalid Room ID" });
      }

      const result = await JoinStudyRoom({
        roomid: roomid, 
        userid: userid,
      });

      const io = req.app.get("io");
      io.to(roomid).emit("user_joined_notice", {
        userid: userid,
        message: "Has joined the study group!",
      });

      return res.status(200).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  // Send Message
  static sendMessage = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomid } = req.params;

      if (!userid) return res.status(401).json({ message: "User not authenticated" });

 
      if (typeof roomid !== 'string') {
        return res.status(400).json({ message: "Invalid Room ID" });
      }

      const validatedMsg = await SendMessage(userid, { 
        ...req.body, 
        roomid: roomid 
      });

      const io = req.app.get("io");
      io.to(roomid).emit("new_chat_message", validatedMsg);
      
      return res.status(200).json(validatedMsg);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };

  // Leave Room
  static leave = async (req: AuthRequest, res: Response) => {
    try {
      const userid = req.user?.userid;
      const { roomid } = req.params;

      if (!userid) return res.status(401).json({ message: "User not authenticated" });

    
      if (typeof roomid !== 'string') {
        return res.status(400).json({ message: "Invalid Room ID" });
      }

      const result = await LeaveStudyRoom({
        roomid: roomid,
        userid: userid,
      });

      const io = req.app.get("io");
      io.to(roomid).emit("user_left_notice", { userid: userid });

      if (result.wasOwner) {
        io.to(roomid).emit("session_terminated", {
          reason: "The owner has ended the session.",
        });
      }

      return res.status(200).json(result);
    } catch (error: any) {
      return res.status(400).json({ message: error.message });
    }
  };
}