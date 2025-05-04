// // controllers/authController.js
// import jwt from 'jsonwebtoken';
// import { findUserByCredentials, findUserByEmail, createUser } from '../models/userModel.js';
// import { JWT_SECRET_KEY } from '../middlewares/auth.js';

// export const login = (req, res) => {
//   const { email, password } = req.body;

//   findUserByCredentials(email, password, (err, results) => {
//     if (err) {
//       console.error(err);
//       return res.status(500).json({ success: false, message: 'Server error' });
//     }
    
//     if (results.length > 0) {
//       // Generate a JWT token
//       const token = jwt.sign(
//         { email: results[0].email }, // Payload (store the user's email in the token)
//         JWT_SECRET_KEY, // Secret key
//         { expiresIn: '1h' } // Token expiration time
//       );

//       return res.json({ 
//         success: true, 
//         message: 'Login successful', 
//         token: token // Send the token to the client
//       });
//     } else {
//       return res.status(400).json({ success: false, message: 'Invalid Credentials' });
//     }
//   });
// };

// export const register = (req, res) => {
//   const { email, phone, password, confirmpassword, role } = req.body;

//   // Validate inputs
//   if (!email || !phone || !password || !confirmpassword || !role) {
//     return res.status(400).json({ success: false, message: 'Invalid Credentials' });
//   }

//   // Check if email already exists
//   findUserByEmail(email, (err, results) => {
//     if (err) {
//       console.error('Error checking email:', err);
//       return res.status(500).json({ success: false, message: 'Server error' });
//     }

//     if (results.length > 0) {
//       // Email already exists
//       return res.status(400).json({
//         success: false,
//         message: 'Email already exists'
//       });
//     }

//     // Insert new user with role
//     createUser({ email, phone, password, confirmpassword, role }, (err, results) => {
//       if (err) {
//         console.error('Error inserting user:', err);
//         return res.status(500).json({ success: false, message: 'Server error' });
//       }

//       res.status(200).json({
//         success: true,
//         message: 'User registered successfully'
//       });
//     });
//   });
// };

// controllers/authController.js
import jwt from 'jsonwebtoken';
// import { findUserByCredentials, findUserByEmail, createUser, findUserByCredentialsAndRole } from '../models/userModel.js';
import { findUserByCredentials, findUserByEmail, createUser, findUserByCredentialsAndRole, findStudentByCredentials } from '../models/userModel.js';
import { JWT_SECRET_KEY } from '../middlewares/auth.js';

// export const login = (req, res) => {
//   const { email, password, role } = req.body;
  
//   // If role is provided, use role-based login
//   if (role) {
//     findUserByCredentialsAndRole(email, password, role, (err, results) => {
//       if (err) {
//         console.error(err);
//         return res.status(500).json({ success: false, message: 'Server error' });
//       }
      
//       if (results.length > 0) {
//         // Generate a JWT token with user role
//         const token = jwt.sign(
//           { 
//             email: results[0].email,
//             role: results[0].role
//           },
//           JWT_SECRET_KEY,
//           { expiresIn: '1h' }
//         );
      
//         return res.json({
//           success: true,
//           message: 'Login successful',
//           token: token,
//           role: results[0].role
//         });
//       } else {
//         return res.status(400).json({ 
//           success: false, 
//           message: 'Invalid credentials or incorrect role selected' 
//         });
//       }
//     });
//   } else {
//     // Original login without role check
//     findUserByCredentials(email, password, (err, results) => {
//       if (err) {
//         console.error(err);
//         return res.status(500).json({ success: false, message: 'Server error' });
//       }
      
//       if (results.length > 0) {
//         // Generate a JWT token
//         const token = jwt.sign(
//           { 
//             email: results[0].email,
//             role: results[0].role
//           },
//           JWT_SECRET_KEY,
//           { expiresIn: '1h' }
//         );
      
//         return res.json({
//           success: true,
//           message: 'Login successful',
//           token: token,
//           role: results[0].role
//         });
//       } else {
//         return res.status(400).json({ success: false, message: 'Invalid Credentials' });
//       }
//     });
//   }
// };
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
    if (!email.includes('@')) {
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

// Add to authController.js
// Modified studentLogin in authController.js
// export const studentLogin = (req, res) => {
//   const { username, password } = req.body;
  
//   // Use the function from userModel instead of directly using connection
//   findStudentByCredentials(username, password, (err, results) => {
//     if (err) {
//       console.error('Error during student login:', err);
//       return res.status(500).json({ success: false, message: 'Server error' });
//     }
    
//     if (results.length === 0) {
//       return res.status(401).json({ 
//         success: false, 
//         message: 'Invalid username or password' 
//       });
//     }
    
//     // Generate JWT token for student
//     const student = results[0];
//     const token = jwt.sign(
//       {
//         id: student.id,
//         username: student.username,
//         user_email: student.user_email,
//         role: student.role || 'student'  // Use stored role or default to 'student'
//       },
//       JWT_SECRET_KEY,
//       { expiresIn: '1h' }
//     );
    
//     return res.json({
//       success: true,
//       message: 'Student login successful',
//       token: token,
//       role: student.role || 'student'
//     });
//   });
// };