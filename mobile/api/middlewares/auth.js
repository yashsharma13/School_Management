// middlewares/auth.js
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config(); // Load .env variables


// JWT Secret Key (store this securely in environment variables in production)
const JWT_SECRET = process.env.JWT_SECRET;

// Middleware to verify JWT token
export const verifyToken = (req, res, next) => {
  const token = req.headers['authorization']; // Get the token from the request header

  if (!token) {
    return res.status(403).json({ success: false, message: 'No token provided' });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ success: false, message: 'Invalid or expired token' });
    }

    req.user_email = decoded.email || decoded.user_email; // Attach the user's email to the request object
    // console.log("Authenticated user email:", req.user_email); // Debug log
    next(); // Proceed to the next middleware or route handler
  });
};

export const JWT_SECRET_KEY = JWT_SECRET;