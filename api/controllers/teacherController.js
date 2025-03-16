// // controllers/studentController.js
// import path from 'path';
// // import fs from 'fs';
// import { createTeacher } from '../models/teacherModel.js';
// // import { uploadDir } from '../middlewares/upload.js';

// export const registerTeacher = (req, res) => {
//   console.log('Uploaded files:', req.files);

  
//   const { teacher_name, email, date_of_birth,date_of_joining , gender,guardian_name,qualification,experience,salary,address,phone} = req.body;
//   const user_email = req.user_email; // Get the user's email from the token

//   // Initialize file paths as null
//   let teacherPhotoPath = null;
//     let QualificationCertificatePath = null;

//     try {
//         // If teacher photo is uploaded
//         if (req.files['teacher_photo']) {
//             // Store only the filename without 'uploads' prefix
//             teacherPhotoPath = path.basename(req.files['teacher_photo'][0].path);
//         }
  
//         // If qualification certificate is uploaded
//         if (req.files['Qualification_certificate']) {
//             // Store only the filename without 'uploads' prefix
//             QualificationCertificatePath = path.basename(req.files['Qualification_certificate'][0].path);
//         }
  
  
//     // Create student in database
//     createTeacher({
//         teacher_name,
//         email,
//         date_of_birth,
//         date_of_joining,
//         gender,
//         guardian_name,
//         qualification,
//         experience,
//         salary,
//         address,
//         phone,
//         QualificationCertificatePath,
//         teacherPhotoPath,
//         user_email
//     }, (err, results) => {
//       if (err) {
//         console.error('Error registering teacher:', err);
//         return res.status(500).send('Error registering teacher');
//       }

//       res.status(200).send('Teacher registered successfully');
//     });
//   } catch (error) {
//     console.error('Error processing files:', error);
//     res.status(500).send('Error processing files');
//   }
// };

import path from 'path';
import { createTeacher ,getTeacherCount } from '../models/teacherModel.js';

export const registerTeacher = (req, res) => {
  console.log('Uploaded files:', req.files);

  const { 
    teacher_name, email, date_of_birth, date_of_joining, 
    gender, guardian_name, qualification, experience, 
    salary, address, phone 
  } = req.body;
  
  const user_email = req.user_email; // Get the user's email from the token

  // Initialize file paths as null
  let teacherPhotoPath = null;
  let qualificationCertificatePath = null;

  try {
    // If teacher photo is uploaded
    if (req.files && req.files['teacher_photo']) {
      teacherPhotoPath = path.basename(req.files['teacher_photo'][0].path);
    }

    // If qualification certificate is uploaded
    if (req.files && req.files['qualification_certificate']) {  // Ensure field name matches exactly
      qualificationCertificatePath = path.basename(req.files['qualification_certificate'][0].path);
    }

    // Create teacher in database
    createTeacher({
      teacher_name,
      email,
      date_of_birth,
      date_of_joining,
      gender,
      guardian_name,
      qualification,
      experience,
      salary,
      address,
      phone,
      qualification_certificate: qualificationCertificatePath, // Ensure correct field name
      teacher_photo: teacherPhotoPath, // Ensure correct field name
      user_email
    }, (err, results) => {
      if (err) {
        console.error('Error registering teacher:', err);
        return res.status(500).json({ message: 'Error registering teacher', error: err.message });
      }
      res.status(200).json({ message: 'Teacher registered successfully' });
    });
  } catch (error) {
    console.error('Error processing files:', error);
    res.status(500).json({ message: 'Error processing files', error: error.message });
  }
};
export const getTotalTeacherCount = (req, res) => {
  getTeacherCount((err, results) => {
    if (err) {
      console.error('Error fetching teacher count:', err);
      return res.status(500).json({ error: 'Failed to fetch teacher count' });
    }
    res.json({ totalTeachers: results[0].totalTeachers });
  });
};