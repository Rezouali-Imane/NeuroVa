import { Router } from 'express';
import { TaskController } from '../controllers/TaskController.js';

const router = Router();

router.post('/', TaskController.create);

router.get('/user/:userid', TaskController.getAll);

router.get('/:taskid', TaskController.getById);

router.put('/:taskid', TaskController.update);

router.patch('/:taskid/status', TaskController.updateStatus);

router.delete('/:taskid', TaskController.remove);

export default router;