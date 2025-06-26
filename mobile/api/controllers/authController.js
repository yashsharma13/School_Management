// controllers/authController.js
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import {
  findUsersByEmailPG ,
  createUserPG,
  findStudentByCredentialsPG
} from '../models/userModel.js';
import { JWT_SECRET_KEY } from '../middlewares/auth.js';

export const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email and password are required' });
  }

  try {
    const users = await findUsersByEmailPG(email); // returns all accounts with this email

    if (!users || users.length === 0) {
      return res.status(400).json({ success: false, message: 'User not found' });
    }

    // Now try matching password with each user
    const matchedUser = await Promise.any(users.map(async user => {
      const isMatch = await bcrypt.compare(password, user.password);
      return isMatch ? user : Promise.reject(); // reject if password doesn't match
    })).catch(() => null);

    if (!matchedUser) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    // ✅ login successful with matched user
    const token = jwt.sign(
      {
        id: matchedUser.id,
        email: matchedUser.email,
        role: matchedUser.role,
        school_id: matchedUser.school_id
      },
      JWT_SECRET_KEY,
      { expiresIn: '6h' }
    );

    return res.json({
      success: true,
      message: 'Login successful',
      token,
      role: matchedUser.role,
      school_id: matchedUser.school_id, // Optional: show which school user logged into
    });

  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};
export const register = async (req, res) => {
  const { email, phone, password, confirmpassword, role, school_id } = req.body;

  if (!email || !phone || !password || !confirmpassword || !role || !school_id) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }

  if (password !== confirmpassword) {
    return res.status(400).json({ success: false, message: 'Passwords do not match' });
  }

  try {
    const existingUser = await findUserByEmailPG(email);
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'Email already exists' });
    }

    const user = await createUserPG({ email, phone, password, role, school_id });

    return res.status(200).json({
      success: true,
      message: 'User registered successfully',
      userId: user.id
    });

  } catch (err) {
    console.error('Register error:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};
