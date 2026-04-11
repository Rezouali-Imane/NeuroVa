import { Router } from 'express';
import { DigitalDisciplineController } from '../controllers/DigitalDisciplineController.js';

const router = Router();

router.get('/settings', DigitalDisciplineController.getSettings);
router.put('/settings', DigitalDisciplineController.updateSettings);
router.post('/blocked-apps', DigitalDisciplineController.addBlockedApp);
router.delete('/blocked-apps/:appid', DigitalDisciplineController.removeBlockedApp);
router.post('/blocked-websites', DigitalDisciplineController.addBlockedWebsite);
router.delete('/blocked-websites/:websiteid', DigitalDisciplineController.removeBlockedWebsite);
router.post('/usage-limits', DigitalDisciplineController.createUsageLimit);
router.post('/usage-logs', DigitalDisciplineController.logUsage);
router.get('/usage-today', DigitalDisciplineController.getTodayUsage);
router.post('/alerts', DigitalDisciplineController.triggerAlert);
router.get('/score', DigitalDisciplineController.calculateScore);

export default router;
