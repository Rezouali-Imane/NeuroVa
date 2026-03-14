import {Router} from "express";
import { FocusSessionController} from "../controllers/FocusSessionController.js";

const router = Router();

// Create a focus session
router.post('/', FocusSessionController.create);

// List sessions for a user
router.get('/user/:userid', FocusSessionController.getAll);

// Get one session by ID
router.get('/:sessionid', FocusSessionController.getById);

// Start a session
router.post('/:sessionid/start', FocusSessionController.start);

// Add timer settings to a session
router.post('/:sessionid/timer', FocusSessionController.addTimer);

// Get one timer
router.get('/:timerid/get_timer', FocusSessionController.getTimer);

// List timers for a session
router.get('/:sessionid/get_timers', FocusSessionController.getTimersBySession);

// Update timer settings
router.patch('/:timerid/timer', FocusSessionController.updateTimer);

// Remove one timer
router.delete('/:timerid/timer', FocusSessionController.removeTimer);

// End a session
router.post('/:sessionid/end', FocusSessionController.end);

// Delete a session
router.delete('/:sessionid', FocusSessionController.delete);

// Create audio settings for a session
router.post('/:sessionid/audio', FocusSessionController.addAudio);

// Update audio settings
router.patch('/:settingsid/audio-settings', FocusSessionController.updateAudioSettings);

// Remove one audio settings record
router.delete('/:settingsid/audio-settings', FocusSessionController.removeAudio);

// Get audio settings by ID
router.get('/:settingsid/get_audiosession', FocusSessionController.getAudioById);

// List audio settings by session
router.get('/:sessionid/get_audiosessions', FocusSessionController.getAudioBySession);

// Add an ambient sound
router.post('/audio-settings/:settingsid/ambient-sound', FocusSessionController.addAmbientSound);

// List ambient sounds for one audio settings record
router.get('/audio-settings/:settingsid/get_ambientsounds', FocusSessionController.getAmbientSoundsBySettings);

// Get one ambient sound
router.get('/audio-settings/:soundid/get_ambientsound', FocusSessionController.getAmbientSoundById);

// Update one ambient sound
router.patch('/audio-settings/:soundid/ambient-sound', FocusSessionController.updateAmbientSound);

// Remove an ambient sound
router.delete('/:soundid/ambient-sound', FocusSessionController.deleteAmbientSound);

export default router;