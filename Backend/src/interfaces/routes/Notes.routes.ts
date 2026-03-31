import { Router } from 'express';
import { NoteController } from '../controllers/NoteController.js';

const router = Router();

router.post('/', NoteController.create);

router.get('/user/:userid', NoteController.getAll);

router.get('/:noteid', NoteController.getById);

router.put('/:noteid', NoteController.update);

router.delete('/:noteid', NoteController.remove);

export default router;