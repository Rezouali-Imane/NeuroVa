import {Router} from "express";
import { FocusSessionController} from "../controllers/FocusSessionController.js";

const router = Router();

// Create a new focus session
router.post('/', FocusSessionController.create);

// Get all sessions for a user
router.get('/user/:userid', FocusSessionController.getAll);

// Get a specific session by ID
router.get('/:sessionid', FocusSessionController.getById);

// Start a session
router.post('/:sessionid/start', FocusSessionController.start);

//get time information
router.get('/:sessionid/get_timer', FocusSessionController.getTimer);

// update timer(type,status ....)
router.patch('/:sessionid/timer', FocusSessionController.updateTimer);

// End a session
router.post('/:sessionid/end', FocusSessionController.end);

// Delete a session
router.delete('/:sessionid', FocusSessionController.delete);

// manage the audio settings (Volume, Mixage)
router.patch('/:sessionid/audio-settings', FocusSessionController.updateAudioSettings);

// manage ambient sound
router.post('/:sessionid/ambient-sound', FocusSessionController.handleAmbientSound);

// Delete an ambient sound
router.delete('/ambient-sound/:soundid', FocusSessionController.deleteAmbientSound);

export default router;