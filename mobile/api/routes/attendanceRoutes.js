// routes/attendanceRoutes.js
import express from 'express';
import { verifyToken } from '../middlewares/auth.js';
import { saveAttendance, getAttendanceReport  } from '../controllers/attendanceController.js';

const router = express.Router();

// Attendance routes (all protected by JWT authentication)
router.post('/attendance', verifyToken, saveAttendance);
router.get('/attendance/:class/:date', verifyToken, getAttendanceReport);
router.get('/attendance/:date', verifyToken,getAttendanceReport);
export default router;