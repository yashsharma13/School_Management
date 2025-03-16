// routes/studentRoutes.js
import express from 'express';
import { verifyToken } from '../middlewares/auth.js';
import upload from '../middlewares/upload.js';
import { 
  registerTeacher,
  getTotalTeacherCount 
} from '../controllers/teacherController.js';

const router = express.Router();
// Student routes (all protected by JWT authentication)
router.post('/registerteacher', verifyToken, upload, registerTeacher);
router.get('/api/teachers/count', getTotalTeacherCount);

export default router;