import {Router} from "express";
import { FocusSessionController} from "../controllers/FocusSessionController.js";

const router = Router();

router.post('/', FocusSessionController.create);

router.get('/user/:userid', FocusSessionController.getAll);

router.get('/:sessionid', FocusSessionController.getById);

router.post('/:sessionid/start', FocusSessionController.start);

router.post('/:sessionid/timer', FocusSessionController.addTimer);

router.get('/:timerid/get_timer', FocusSessionController.getTimer);

router.get('/:sessionid/get_timers', FocusSessionController.getTimersBySession);

router.patch('/:timerid/timer', FocusSessionController.updateTimer);

router.delete('/:timerid/timer', FocusSessionController.removeTimer);

router.post('/:sessionid/end', FocusSessionController.end);

router.delete('/:sessionid', FocusSessionController.delete);

router.post('/:sessionid/audio', FocusSessionController.addAudio);

router.patch('/:settingsid/audio-settings', FocusSessionController.updateAudioSettings);

router.delete('/:settingsid/audio-settings', FocusSessionController.removeAudio);

router.get('/:settingsid/get_audiosession', FocusSessionController.getAudioById);

router.get('/:sessionid/get_audiosessions', FocusSessionController.getAudioBySession);

router.post('/audio-settings/:settingsid/ambient-sound', FocusSessionController.addAmbientSound);

router.get('/audio-settings/:settingsid/get_ambientsounds', FocusSessionController.getAmbientSoundsBySettings);

router.get('/audio-settings/:soundid/get_ambientsound', FocusSessionController.getAmbientSoundById);

router.patch('/audio-settings/:soundid/ambient-sound', FocusSessionController.updateAmbientSound);

router.delete('/:soundid/ambient-sound', FocusSessionController.deleteAmbientSound);

export default router;