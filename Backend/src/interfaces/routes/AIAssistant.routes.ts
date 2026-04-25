import { Router } from 'express';
import {
	AIAssistantController,
	imageUpload,
	upload,
	voiceUpload,
} from '../controllers/AIAssistantController.js';

const router = Router();

router.post('/message', AIAssistantController.sendMessage);
router.post('/message/image', imageUpload.single('image'), AIAssistantController.sendImageMessage);
router.post('/message/voice', voiceUpload.single('audio'), AIAssistantController.sendVoiceMessage);
router.get('/history/:userid', AIAssistantController.getChatHistory);
router.delete('/history/:userid', AIAssistantController.clearChatHistory);

router.get('/insights/:userid', AIAssistantController.getInsights);

router.post('/study-plan/:userid', AIAssistantController.generateStudyPlan);
router.post('/weakness/:userid', AIAssistantController.analyzeWeakness);

router.get('/memory/:userid', AIAssistantController.getMemory);
router.put('/memory/:userid', AIAssistantController.updateMemory);

router.post('/knowledge', upload.single('file'), AIAssistantController.uploadDocument);
router.get('/knowledge/:userid', AIAssistantController.getKnowledgeBase);
router.delete('/knowledge/:id', AIAssistantController.deleteDocument);

router.post('/schedule-session/:userid', AIAssistantController.scheduleFocusSession);
router.post('/reminders/:userid', AIAssistantController.sendReminders);
router.post('/reminders', AIAssistantController.sendReminders); // Broadcast reminders for all users

export default router;