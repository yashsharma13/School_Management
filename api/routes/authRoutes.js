// routes/authRoutes.js
import express from 'express';
import { login, register , studentLogin } from '../controllers/authController.js';

const router = express.Router();

// Authentication routes
router.post('/login', login);
router.post('/register', register);
router.post('/student-login', studentLogin);

export default router;