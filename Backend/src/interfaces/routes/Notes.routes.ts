import { Router } from 'express';
import { NoteController } from '../controllers/NoteController.js';

const router = Router();

// Add a new note.
router.post('/', NoteController.create);

// Get every note for one user.
router.get('/user/:userid', NoteController.getAll);

// Fetch a single note by ID.
router.get('/:noteid', NoteController.getById);

// Update note content.
router.put('/:noteid', NoteController.update);

// Remove a note.
router.delete('/:noteid', NoteController.remove);

export default router;