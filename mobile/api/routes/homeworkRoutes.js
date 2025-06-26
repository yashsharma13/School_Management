// routes/studentRoutes.js
import express from 'express';
import { verifyToken } from '../middlewares/auth.js';
import { 
  assignHomework,
  getTeacherHomework,
  deleteTeacherHomework
} from '../controllers/homeworkController.js';

const router = express.Router();

// Student routes (all protected by JWT authentication)
router.post('/homework', verifyToken,assignHomework);
router.get('/gethomework', verifyToken,getTeacherHomework);
router.delete('/deletehomework/:id',verifyToken, deleteTeacherHomework);


export default router;