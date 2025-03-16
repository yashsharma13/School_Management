// controllers/authController.js
import jwt from 'jsonwebtoken';
import { findUserByCredentials, findUserByEmail, createUser } from '../models/userModel.js';
import { JWT_SECRET_KEY } from '../middlewares/auth.js';

export const login = (req, res) => {
  const { email, password } = req.body;

  findUserByCredentials(email, password, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ success: false, message: 'Server error' });
    }
    
    if (results.length > 0) {
      // Generate a JWT token
      const token = jwt.sign(
        { email: results[0].email }, // Payload (store the user's email in the token)
        JWT_SECRET_KEY, // Secret key
        { expiresIn: '1h' } // Token expiration time
      );

      return res.json({ 
        success: true, 
        message: 'Login successful', 
        token: token // Send the token to the client
      });
    } else {
      return res.status(400).json({ success: false, message: 'Invalid Credentials' });
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