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
// Make sure this exactly matches your frontend request
// In your studentRoutes.js
// router.get('/api/students/count-by-class', verifyToken, async (req, res) => {
//   try {
//     console.log('User email from token:', req.user_email); // Debug log
    
//     const results = await new Promise((resolve, reject) => {
//       modelgetStudentCountByClass(req.user_email, (err, results) => {
//         if (err) return reject(err);
//         resolve(results);
//       });
//     });

//     console.log('Database results:', results); // Debug log
    
//     res.status(200).json({
//       success: true,
//       data: results
//     });
//   } catch (error) {
//     console.error('Error in count-by-class route:', error);
//     res.status(500).json({ 
//       success: false,
//       message: 'Failed to fetch student counts',
//       error: error.message 
//     });
//   }
// });
export default router;