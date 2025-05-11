import path from 'path';
import { createTeacher, getTeachersByUser, updateTeacher, getTeacherById, deleteTeacher,getTeacherCount } from '../models/teacherModel.js';
import { deleteAttendanceByTeacherId } from '../models/attendanceModel.js';
import { uploadDir } from '../middlewares/upload.js';
import fs from 'fs';


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

export const getAllTeachers = (req, res) => {
  const user_email = req.user_email; // Get the user's email from the token

  getTeachersByUser(user_email, (err, results) => {
    if (err) {
      console.error('Error fetching teachers:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    // Normalize paths in the results
    const normalizedResults = results.map(teacher => ({
      ...teacher,
      teacher_photo: teacher.teacher_photo ? 
        path.basename(teacher.teacher_photo.replace(/\\/g, '/')) : null,
      qualification_certificate: teacher.qualification_certificate ? 
        path.basename(teacher.qualification_certificate.replace(/\\/g, '/')) : null
    }));

    res.json(normalizedResults);
  });
};

export const updateTeacherDetails = (req, res) => {
  const teacherId = req.params.id;
  const {
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
    qualification_certificate
  } = req.body;

  // Handle photo upload
  let teacherPhoto = req.body.teacher_photo; // Keep existing photo if not updated
  if (req.files && req.files['teacher_photo']) {
    teacherPhoto = path.basename(req.files['teacher_photo'][0].path);
  }

  updateTeacher(teacherId, {
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
    qualification_certificate,
    teacher_photo: teacherPhoto
  }, (err, results) => {
    if (err) {
      console.error('Error updating teacher:', err);
      return res.status(500).json({ error: 'Failed to update teacher' });
    }
    res.status(200).json({ message: 'Teacher updated successfully' });
  });
};

export const deleteTeacherById = (req, res) => {
  const teacherId = req.params.id;

  // Step 1: Log teacherId for debugging
  console.log('Attempting to delete teacher with ID:', teacherId);

  // Step 2: Delete attendance records related to the teacher
  deleteAttendanceByTeacherId(teacherId, (err) => {
    if (err) {
      console.error('Error deleting attendance records:', err);
      return res.status(500).json({ error: 'Failed to delete attendance records' });
    }

    // Step 3: Now, get the teacher's photo path to delete the file
    getTeacherById(teacherId, (err, results) => {
      if (err) {
        console.error('Error fetching teacher:', err);
        return res.status(500).json({ error: 'Failed to fetch teacher details' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'Teacher not found' });
      }

      const teacherPhoto = results[0].teacher_photo;

      // Step 4: Delete the teacher from the database
      deleteTeacher(teacherId, (err, results) => {
        if (err) {
          console.error('Error deleting teacher:', err);
          return res.status(500).json({ error: 'Failed to delete teacher' });
        }

        // Step 5: If teacher had a photo, delete the file
        if (teacherPhoto) {
          const photoPath = path.join(uploadDir, teacherPhoto);
          fs.unlink(photoPath, (err) => {
            if (err) {
              console.error('Error deleting photo file:', err);
              // Don't send error response here as the teacher is already deleted
            }
          });
        }

        res.status(200).json({ message: 'Teacher deleted successfully' });
      });
    });
  });
};

export const getTotalTeacherCount = (req, res) => {
  const user_email = req.user_email; // Get the user's email from the token

  // console.log('User email from token:', user_email);  // Add this line for debugging

  getTeacherCount(user_email, (err, results) => {
    if (err) {
      console.error('Error fetching teacher count:', err);
      return res.status(500).json({ error: 'Failed to fetch teacher count' });
    }
    // console.log('Teacher count from DB:', results);  // Add this line for debugging
    res.json({ totalTeachers: results[0].totalTeachers });
  });
};
