// controllers/authController.js
import jwt from 'jsonwebtoken';
// import { findUserByCredentials, findUserByEmail, createUser, findUserByCredentialsAndRole } from '../models/userModel.js';
import { findUserByCredentials, findUserByEmail, createUser, findUserByCredentialsAndRole, findStudentByCredentials } from '../models/userModel.js';
import { JWT_SECRET_KEY } from '../middlewares/auth.js';
export const login = (req, res) => {
  const { email, password } = req.body;
  
  // First try regular user login (for operators/admins/teachers)
  findUserByCredentials(email, password, (err, userResults) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ success: false, message: 'Server error' });
    }
    
    if (userResults.length > 0) {
      // Generate a JWT token with user role
      const token = jwt.sign(
        { 
          email: userResults[0].email,
          role: userResults[0].role
        },
        JWT_SECRET_KEY,
        { expiresIn: '1h' }
      );
    
      return res.json({
        success: true,
        message: 'Login successful',
        token: token,
        role: userResults[0].role
      });
    }
    
    // If no regular user found and doesn't look like an email, try student login
    if (typeof email === 'string' && !email.includes('@')) {
      findStudentByCredentials(email, password, (err, studentResults) => {
        if (err) {
          console.error('Error during student login:', err);
          return res.status(500).json({ success: false, message: 'Server error' });
        }
        
        if (studentResults.length > 0) {
          const student = studentResults[0];
          const token = jwt.sign(
            {
              id: student.id,
              username: student.username,
              user_email: student.user_email,
              role: 'student'
            },
            JWT_SECRET_KEY,
            { expiresIn: '1h' }
          );
          
          return res.json({
            success: true,
            message: 'Login successful',
            token: token,
            role: 'student'
          });
        }
        
        // If neither found
        return res.status(400).json({ 
          success: false, 
          message: 'Invalid credentials' 
        });
      });
    } else {
      // If it was an email but no user found
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid credentials' 
      });
    }
  });
};
export const register = (req, res) => {
  const { email, phone, password, confirmpassword, role } = req.body;

  // Validate inputs
  if (!email || !phone || !password || !confirmpassword || !role) {
    return res.status(400).json({ success: false, message: 'Invalid Credentials' });
  }

  // Check if email already exists
  findUserByEmail(email, (err, results) => {
    if (err) {
      console.error('Error checking email:', err);
      return res.status(500).json({ success: false, message: 'Server error' });
    }
    
    if (results.length > 0) {
      // Email already exists
      return res.status(400).json({
        success: false,
        message: 'Email already exists'
      });
    }
    
    // Insert new user with role
    createUser({ email, phone, password, confirmpassword, role }, (err, results) => {
      if (err) {
        console.error('Error inserting user:', err);
        return res.status(500).json({ success: false, message: 'Server error' });
      }
      
      res.status(200).json({
        success: true,
        message: 'User registered successfully'
      });
    });
  });
};
