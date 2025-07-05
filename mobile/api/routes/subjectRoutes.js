// routes/studentRoutes.js
import express from 'express';
import { verifyToken } from '../middlewares/auth.js';
import { 
  registerSubject,
  getAllSubjects,
  updateSubject,
  deleteSubject,
  deleteSubjectsByClass,
} from '../controllers/subjectController.js';

const router = express.Router();

// Student routes (all protected by JWT authentication)
router.post('/registersubject', verifyToken,registerSubject);
router.get('/getallsubjects', verifyToken, getAllSubjects);
router.put('/updatesubject',verifyToken,updateSubject);
router.delete('/deletesubject/:subject_id', verifyToken, deleteSubject);
router.delete('/delete-by-class/:class_id', verifyToken, deleteSubjectsByClass);
export default router;