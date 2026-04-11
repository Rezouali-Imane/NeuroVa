import { Router } from 'express';
import { ContentModerationController } from '../controllers/ContentModerationController.js';

const router = Router();

router.get('/policy', ContentModerationController.getPolicy);
router.put('/policy', ContentModerationController.updatePolicy);
router.post('/analyze/text', ContentModerationController.analyzeText);
router.post('/analyze/image', ContentModerationController.analyzeImage);
router.post('/filter', ContentModerationController.filterContent);

export default router;
