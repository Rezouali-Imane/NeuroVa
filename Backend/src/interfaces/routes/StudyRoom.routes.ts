import { Router } from "express";
import { StudyRoomController } from "../controllers/StudyRoomController.js";
import { authMiddleware } from "../../infrastructure/middleware/authMiddleware.js"

const router = Router();

// Create the room session
router.post("/", authMiddleware, StudyRoomController.create);

// Join a session
router.post("/join/:roomcode", authMiddleware, StudyRoomController.join);

// Start Session
router.post("/:roomid/start", authMiddleware, StudyRoomController.startSession);

//  End Session
router.post("/:roomid/end", authMiddleware, StudyRoomController.endSession);

// Leave the session
router.delete("/:roomid/leave", authMiddleware, StudyRoomController.leave);

export default router;
