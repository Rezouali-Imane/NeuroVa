import { Router } from 'express';
import { StudyRoomController } from '../controllers/StudyRoomController.js';

const router = Router();

//  Create the room session
router.post('/', StudyRoomController.create);

//  Join a session 
router.post('/join', StudyRoomController.join);

//  Send a message 
router.post('/message', StudyRoomController.sendMessage);

//  Leave the session
router.post('/leave', StudyRoomController.leave);



export default router;