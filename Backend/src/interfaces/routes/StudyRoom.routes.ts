import { Router } from 'express';
import { StudyRoomController } from '../controllers/StudyRoomController.js';

const router = Router();

// Create the room session 
router.post('/', StudyRoomController.create);

// Join a session 
router.post('/:roomid/join', StudyRoomController.join);

// Send a message 
router.post('/:roomid/message', StudyRoomController.sendMessage);

// Leave the session
router.post('/:roomid/leave', StudyRoomController.leave);

export default router;