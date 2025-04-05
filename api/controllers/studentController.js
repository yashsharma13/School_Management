// // controllers/studentController.js
// import path from 'path';
// import fs from 'fs';
// import { createStudent, getStudentsByUser, updateStudent, getStudentById, deleteStudent, getStudentsByClass, getStudentCount, getStudentCountByClass } from '../models/studentModel.js';
// import { deleteAttendanceByStudentId } from '../models/attendanceModel.js';
// import { uploadDir } from '../middlewares/upload.js';


// // Helper function to generate random credentials
// const generateCredentials = (studentName, registrationNumber) => {
//   // Generate username based on student name and registration
//   let username = studentName.toLowerCase().replace(/\s+/g, '');
//   if (username.length > 5) {
//     username = username.substring(0, 5);
//   }
  
//   // Add last 4 chars of registration number
//   let regSuffix = registrationNumber;
//   if (registrationNumber.length > 4) {
//     regSuffix = registrationNumber.substring(registrationNumber.length - 4);
//   }
  
//   username = `${username}${regSuffix}`;
  
//   // Generate random password (8 characters)
//   let password = '';
//   const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
//   for (let i = 0; i < 8; i++) {
//     password += chars.charAt(Math.floor(Math.random() * chars.length));
//   }
  
//   return {
//     username,
//     password,
//   };
// };


// export const registerStudent = (req, res) => {
//   console.log('Uploaded files:', req.files);

//   const { student_name, registration_number, date_of_birth, gender, address, father_name, mother_name, email, phone, assigned_class, assigned_section } = req.body;
//   const user_email = req.user_email; // Get the user's email from the token

//   // Initialize file paths as null
//   let studentPhotoPath = null;
//   let birthCertificatePath = null;

//   try {
//     // If student photo is uploaded
//     if (req.files['student_photo']) {
//       // Store only the filename without 'uploads' prefix
//       studentPhotoPath = path.basename(req.files['student_photo'][0].path);
//     }

//     // If birth certificate is uploaded
//     if (req.files['birth_certificate']) {
//       // Store only the filename without 'uploads' prefix
//       birthCertificatePath = path.basename(req.files['birth_certificate'][0].path);
//     }

//     // Create student in database
//     createStudent({
//       student_name,
//       registration_number,
//       date_of_birth,
//       gender,
//       address,
//       father_name,
//       mother_name,
//       email,
//       phone,
//       assigned_class,
//       assigned_section,
//       birthCertificatePath,
//       studentPhotoPath,
//       username,
//       password,
//       user_email
//     }, (err, results) => {
//       if (err) {
//         console.error('Error registering student:', err);
//         return res.status(500).send('Error registering student');
//       }

//       res.status(200).send('Student registered successfully');
//     });
//   } catch (error) {
//     console.error('Error processing files:', error);
//     res.status(500).send('Error processing files');
//   }
// };

// export const getAllStudents = (req, res) => {
//   const user_email = req.user_email; // Get the user's email from the token

//   getStudentsByUser(user_email, (err, results) => {
//     if (err) {
//       console.error('Error fetching students:', err);
//       return res.status(500).json({ message: 'Internal server error' });
//     }

//     // Normalize paths in the results
//     const normalizedResults = results.map(student => ({
//       ...student,
//       student_photo: student.student_photo ? 
//         path.basename(student.student_photo.replace(/\\/g, '/')) : null,
//       birth_certificate: student.birth_certificate ? 
//         path.basename(student.birth_certificate.replace(/\\/g, '/')) : null
//     }));

//     res.json(normalizedResults);
//   });
// };

// export const updateStudentDetails = (req, res) => {
//   const studentId = req.params.id;
//   const {
//     student_name,
//     registration_number,
//     date_of_birth,
//     gender,
//     address,
//     father_name,
//     mother_name,
//     email,
//     phone,
//     assigned_class,
//     assigned_section,
//     birth_certificate,
//   } = req.body;

//   // Handle photo upload
//   let studentPhoto = req.body.student_photo; // Keep existing photo if not updated
//   if (req.files && req.files['student_photo']) {
//     studentPhoto = path.basename(req.files['student_photo'][0].path);
//   }

//   updateStudent(studentId, {
//     student_name,
//     registration_number,
//     date_of_birth,
//     gender,
//     address,
//     father_name,
//     mother_name,
//     email,
//     phone,
//     assigned_class,
//     assigned_section,
//     birth_certificate,
//     student_photo: studentPhoto
//   }, (err, results) => {
//     if (err) {
//       console.error('Error updating student:', err);
//       return res.status(500).json({ error: 'Failed to update student' });
//     }
//     res.status(200).json({ message: 'Student updated successfully' });
//   });
// };

// export const deleteStudentById = (req, res) => {
//   const studentId = req.params.id;

//   // Step 1: Log studentId for debugging
//   console.log('Attempting to delete student with ID:', studentId);

//   // Step 2: Delete attendance records related to the student
//   deleteAttendanceByStudentId(studentId, (err) => {
//     if (err) {
//       console.error('Error deleting attendance records:', err);
//       return res.status(500).json({ error: 'Failed to delete attendance records' });
//     }

//     // Step 3: Now, get the student's photo path to delete the file
//     getStudentById(studentId, (err, results) => {
//       if (err) {
//         console.error('Error fetching student:', err);
//         return res.status(500).json({ error: 'Failed to fetch student details' });
//       }

//       if (results.length === 0) {
//         return res.status(404).json({ error: 'Student not found' });
//       }

//       const studentPhoto = results[0].student_photo;

//       // Step 4: Delete the student from the database
//       deleteStudent(studentId, (err, results) => {
//         if (err) {
//           console.error('Error deleting student:', err);
//           return res.status(500).json({ error: 'Failed to delete student' });
//         }

//         // Step 5: If student had a photo, delete the file
//         if (studentPhoto) {
//           const photoPath = path.join(uploadDir, studentPhoto);
//           fs.unlink(photoPath, (err) => {
//             if (err) {
//               console.error('Error deleting photo file:', err);
//               // Don't send error response here as the student is already deleted
//             }
//           });
//         }

//         res.status(200).json({ message: 'Student deleted successfully' });
//       });
//     });
//   });
// };

// export const getStudentsByClassName = (req, res) => {
//   const className = decodeURIComponent(req.params.class);  // Decode if there are spaces or special characters
//   const user_email = req.user_email; // Get the user's email from the token

//   getStudentsByClass(className, user_email, (err, results) => {
//     if (err) {
//       console.error('Error fetching students:', err);
//       return res.status(500).json({ message: 'Internal server error' });
//     }

//     res.json(results);  // Send the list of students in the selected class for the logged-in user
//   });
// };

// export const getTotalStudentCount = (req, res) => {
//   getStudentCount((err, results) => {
//     if (err) {
//       console.error('Error fetching student count:', err);
//       return res.status(500).json({ error: 'Failed to fetch student count' });
//     }
//     res.json({ totalStudents: results[0].totalStudents });
//   });
// };

// // In your studentController.js
// export const modelgetStudentCountByClass = (req, res) => {
//   // Make sure user_email is properly extracted from JWT
//   const user_email = req.user_email;;
  
//   // if (!user_email) {
//   //   console.error('No user email found in JWT');
//   //   return res.status(400).json({ 
//   //     success: false,
//   //     message: 'Authentication required',
//   //     data: []
//   //   });
//   // }

//   // console.log('Fetching counts for user:', user_email);

//   getStudentCountByClass(user_email, (err, results) => {
//     if (err) {
//       console.error('Database error:', err);
//       return res.status(500).json({
//         success: false,
//         message: 'Database error',
//         data: []
//       });
//     }

//     console.log('Sending response with', results.length, 'records');
//     res.status(200).json({
//       success: true,
//       data: results
//     });
//   });
// };

import path from 'path';
import fs from 'fs';
import { createStudent, getStudentsByUser, updateStudent, getStudentById, deleteStudent, getStudentsByClass, getStudentCount, getStudentCountByClass, getLastRegistrationNumber } from '../models/studentModel.js';
import { deleteAttendanceByStudentId } from '../models/attendanceModel.js';
import { uploadDir } from '../middlewares/upload.js';

const generateCredentials = (studentName, registrationNumber) => {
  const username = `${studentName.toLowerCase().replace(/\s+/g, '').substring(0, 5)}${registrationNumber.slice(-4)}`;
  const email = `${username}@school.edu`;
  const password = Math.random().toString(36).slice(-8);
  return { username, password , email };
};

export const registerStudent = (req, res) => {
  try {
    // console.log('Uploaded files:', req.files);
    // console.log('Request body:', req.body);

    const { 
      student_name, 
      registration_number, 
      date_of_birth, 
      gender, 
      address, 
      father_name, 
      mother_name, 
      email, 
      phone, 
      assigned_class, 
      assigned_section,
      username,
      password
    } = req.body;
    
    const user_email = req.user_email;

    // Initialize file paths as null
    let studentPhotoPath = null;
    let birthCertificatePath = null;

    // If student photo is uploaded
    if (req.files && req.files['student_photo']) {
      studentPhotoPath = req.files['student_photo'][0].filename;
    }

    // If birth certificate is uploaded
    if (req.files && req.files['birth_certificate']) {
      birthCertificatePath = req.files['birth_certificate'][0].filename;
    }

    // Generate credentials if not provided
    const credentials = (username && password)
      ? { username, password }
      : generateCredentials(student_name, registration_number);

    // Create student in database
    createStudent({
      student_name,
      registration_number,
      date_of_birth,
      gender,
      address: address || null,
      father_name: father_name || null,
      mother_name: mother_name || null,
      email: email || null,
      phone: phone || null,
      assigned_class,
      assigned_section,
      birthCertificatePath,  // Correct property name
      studentPhotoPath,          // Correct property name
      username: credentials.username,
      password: credentials.password,
      user_email
    }, (err, results) => {
      if (err) {
        console.error('Error registering student:', err);
        
        // Handle duplicate entry errors
        if (err.code === 'ER_DUP_ENTRY') {
          let errorMessage = 'Duplicate entry found';
          
          if (err.sqlMessage.includes('registration_number')) {
            errorMessage = 'Registration number already exists';
          } else if (err.sqlMessage.includes('username')) {
            errorMessage = 'Username already exists';
          }
          
          return res.status(409).json({
            success: false,
            message: errorMessage,
            error: err.sqlMessage
          });
        }
        
        return res.status(500).json({
          success: false,
          message: 'Failed to register student',
          error: err.message
        });
      }
      
      res.status(201).json({
        success: true,
        message: 'Student registered successfully',
        data: {
          studentId: results.insertId,
          credentials: {
            username: req.body.username,
            password: req.body.password
          }
        }
      });
    });
  } catch (error) {
    console.error('Error processing files:', error);
    res.status(500).json({
      success: false,
      message: 'Error processing files',
      error: error.message
    });
  }
};

export const getAllStudents = (req, res) => {
  const user_email = req.user_email; // Get the user's email from the token

  getStudentsByUser(user_email, (err, results) => {
    if (err) {
      console.error('Error fetching students:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    // Normalize paths in the results
    const normalizedResults = results.map(student => ({
      ...student,
      student_photo: student.student_photo ? 
        path.basename(student.student_photo.replace(/\\/g, '/')) : null,
      birth_certificate: student.birth_certificate ? 
        path.basename(student.birth_certificate.replace(/\\/g, '/')) : null
    }));

    res.json(normalizedResults);
  });
};

export const updateStudentDetails = (req, res) => {
  const studentId = req.params.id;
  const {
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birth_certificate,
  } = req.body;

  // Handle photo upload
  let studentPhoto = req.body.student_photo; // Keep existing photo if not updated
  if (req.files && req.files['student_photo']) {
    studentPhoto = path.basename(req.files['student_photo'][0].path);
  }

  updateStudent(studentId, {
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birth_certificate,
    student_photo: studentPhoto
  }, (err, results) => {
    if (err) {
      console.error('Error updating student:', err);
      return res.status(500).json({ error: 'Failed to update student' });
    }
    res.status(200).json({ message: 'Student updated successfully' });
  });
};

export const deleteStudentById = (req, res) => {
  const studentId = req.params.id;

  // Step 1: Log studentId for debugging
  console.log('Attempting to delete student with ID:', studentId);

  // Step 2: Delete attendance records related to the student
  deleteAttendanceByStudentId(studentId, (err) => {
    if (err) {
      console.error('Error deleting attendance records:', err);
      return res.status(500).json({ error: 'Failed to delete attendance records' });
    }

    // Step 3: Now, get the student's photo path to delete the file
    getStudentById(studentId, (err, results) => {
      if (err) {
        console.error('Error fetching student:', err);
        return res.status(500).json({ error: 'Failed to fetch student details' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'Student not found' });
      }

      const studentPhoto = results[0].student_photo;

      // Step 4: Delete the student from the database
      deleteStudent(studentId, (err, results) => {
        if (err) {
          console.error('Error deleting student:', err);
          return res.status(500).json({ error: 'Failed to delete student' });
        }

        // Step 5: If student had a photo, delete the file
        if (studentPhoto) {
          const photoPath = path.join(uploadDir, studentPhoto);
          fs.unlink(photoPath, (err) => {
            if (err) {
              console.error('Error deleting photo file:', err);
              // Don't send error response here as the student is already deleted
            }
          });
        }

        res.status(200).json({ message: 'Student deleted successfully' });
      });
    });
  });
};

export const getStudentsByClassName = (req, res) => {
  const className = decodeURIComponent(req.params.class);  // Decode if there are spaces or special characters
  const user_email = req.user_email; // Get the user's email from the token

  getStudentsByClass(className, user_email, (err, results) => {
    if (err) {
      console.error('Error fetching students:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.json(results);  // Send the list of students in the selected class for the logged-in user
  });
};

export const getTotalStudentCount = (req, res) => {
  getStudentCount((err, results) => {
    if (err) {
      console.error('Error fetching student count:', err);
      return res.status(500).json({ error: 'Failed to fetch student count' });
    }
    res.json({ totalStudents: results[0].totalStudents });
  });
};

export const modelgetStudentCountByClass = (req, res) => {
  // Make sure user_email is properly extracted from JWT
  const user_email = req.user_email;
  
  getStudentCountByClass(user_email, (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return res.status(500).json({
        success: false,
        message: 'Database error',
        data: []
      });
    }

    console.log('Sending response with', results.length, 'records');
    res.status(200).json({
      success: true,
      data: results
    });
  });
};


export const ggetLastRegistrationNumber = async (req, res) => {
  try {
    getLastRegistrationNumber((err, lastRegNumber) => {
      if (err) {
        console.error("Database error:", err);
        return res.status(500).json({
          success: false,
          message: 'Database error',
          error: err.message
        });
      }

      res.status(200).json({
        success: true,
        lastRegistrationNumber: lastRegNumber || null
      });
    });
  } catch (error) {
    console.error("Controller error:", error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};