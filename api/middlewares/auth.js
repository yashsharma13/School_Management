// middlewares/auth.js
import jwt from 'jsonwebtoken';

// JWT Secret Key (store this securely in environment variables in production)
const JWT_SECRET = 'Pass1212';

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

    req.user_email = decoded.email; // Attach the user's email to the request object
    next(); // Proceed to the next middleware or route handler
  });
};

export const JWT_SECRET_KEY = JWT_SECRET;