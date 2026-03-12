import { Router } from 'express';
import { NoteController } from '../controllers/NoteController.js';

const router = Router();

// Create a note
router.post('/', NoteController.create);

// Get all notes for a user
router.get('/user/:userid', NoteController.getAll);

// Get one note by ID
router.get('/:noteid', NoteController.getById);

// Update a note
router.put('/:noteid', NoteController.update);

// Delete a note
router.delete('/:noteid', NoteController.remove);

export default router;