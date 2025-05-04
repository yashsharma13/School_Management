// routes/studentRoutes.js
import express from 'express';
import { verifyToken } from '../middlewares/auth.js';
import upload from '../middlewares/upload.js';
import { 
  registerStudent, 
  getAllStudents, 
  updateStudentDetails, 
  deleteStudentById, 
  getStudentsByClassName,
  getTotalStudentCount,
  modelgetStudentCountByClass,
  ggetLastRegistrationNumber
} from '../controllers/studentController.js';

const router = express.Router();

// Student routes (all protected by JWT authentication)
router.post('/registerstudent', verifyToken, upload, registerStudent);
router.get('/students', verifyToken, getAllStudents);
router.put('/students/:id', verifyToken, upload, updateStudentDetails);
router.delete('/students/:id', verifyToken, deleteStudentById);
router.get('/students/:class', verifyToken, getStudentsByClassName);
router.get('/api/students/count', getTotalStudentCount);
router.get('/api/students/count-by-class', verifyToken,modelgetStudentCountByClass);
router.get('/last-registration-number', verifyToken, ggetLastRegistrationNumber);


export default router;