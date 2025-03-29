import { createSubject,getSubjectsByUser,updateSubjectById } from '../models/subjectModel.js';

export const registerSubject = (req, res) => {
  const { class_name, subject_name, marks } = req.body;
  const user_email = req.user_email;

  console.log('Received request body:', req.body);  // Log incoming data for debugging

  if (!class_name || !subject_name || !marks || !user_email) {
    return res.status(400).json({ message: 'Missing required fields' });
  }
  // Insert the data into the database
  createSubject({ class_name, subject_name, marks, user_email }, (err, results) => {
    if (err) {
      console.error('Error registering subjects:', err);
      return res.status(500).json({ message: 'Error registering subjects' });
    }

    res.status(201).json({
      success: true,
      message: 'Subjects registered successfully',
    });
  });
};
export const getAllSubjects = (req, res) => {
  const user_email = req.user_email;

  if (!user_email) {
    return res.status(400).json({ message: 'User email is required' });
  }

  getSubjectsByUser(user_email, (err, results) => {
    if (err) {
      console.error('Error fetching subjects:', err);
      return res.status(500).json({ message: 'Error fetching subjects' });
    }

    // Group subjects by class
    const classSubjectsMap = {};
    results.forEach(subject => {
      if (!classSubjectsMap[subject.class_name]) {
        classSubjectsMap[subject.class_name] = {
          _id: '', // You might want to generate a unique ID
          class_name: subject.class_name,
          subjects: []
        };
      }
      classSubjectsMap[subject.class_name].subjects.push({
        subject_name: subject.subject_name,
        marks: subject.marks
      });
    });

    // Convert map to array
    const classSubjectsArray = Object.values(classSubjectsMap);

    res.status(200).json({
      data: classSubjectsArray
    });
  });
};

// // Update a specific subject by its ID
// export const updateSubject = (req, res) => {
//   const { subject_id, subject_name, marks } = req.body;
//   const user_email = req.user_email;

//   // Ensure subject_id, subject_name, and marks are provided
//   if (!subject_id || !subject_name || !marks || !user_email) {
//     return res.status(400).json({ message: 'Missing required fields' });
//   }

//   // Call the model function to update the subject
//   updateSubjectById(subject_id, { subject_name, marks }, user_email, (err, result) => {
//     if (err) {
//       console.error('Error updating subject:', err);
//       return res.status(500).json({ message: 'Error updating subject' });
//     }

//     if (!result) {
//       return res.status(404).json({ message: 'Subject not found' });
//     }

//     res.status(200).json({
//       success: true,
//       message: 'Subject updated successfully',
//     });
//   });
// };
// Subject Update Debugging Strategy

// Enhanced debugging middleware
export const updateSubject = (req, res) => {
  // Extensive logging for debugging
  console.log('Full Request Headers:', req.headers);
  console.log('Full Request Body:', req.body);
  console.log('User Email from Request:', req.user_email);

  // Destructure with additional checks
  const subject_id = req.body?.subject_id;
  const subject_name = req.body?.subject_name;
  const marks = req.body?.marks;
  const user_email = req.user_email;

  // Detailed field validation logging
  console.log('Extracted Fields:');
  console.log('Subject ID:', subject_id);
  console.log('Subject Name:', subject_name);
  console.log('Marks:', marks);
  console.log('User Email:', user_email);

  // Comprehensive field validation
  const missingFields = [];
  if (!subject_id) missingFields.push('subject_id');
  if (!subject_name) missingFields.push('subject_name');
  if (!marks && marks !== 0) missingFields.push('marks');
  if (!user_email) missingFields.push('user_email');

  // Detailed error response if fields are missing
  if (missingFields.length > 0) {
    return res.status(400).json({
      message: 'Missing required fields',
      missingFields: missingFields,
      receivedBody: req.body
    });
  }

  // Proceed with update if all fields are present
  updateSubjectById(subject_id, { subject_name, marks }, user_email, (err, result) => {
    if (err) {
      console.error('Detailed Error updating subject:', err);
      return res.status(500).json({ 
        message: 'Error updating subject',
        errorDetails: err 
      });
    }

    if (!result) {
      return res.status(404).json({ 
        message: 'Subject not found',
        subject_id: subject_id 
      });
    }

    res.status(200).json({
      success: true,
      message: 'Subject updated successfully',
      updatedSubject: { subject_id, subject_name, marks }
    });
  });
};

// Example of how to set up middleware to ensure user_email
export const ensureUserEmail = (req, res, next) => {
  // If using authentication middleware
  if (req.user && req.user.email) {
    req.user_email = req.user.email;
  } else {
    // Fallback or error handling
    console.error('No user email found in request');
    return res.status(401).json({ message: 'Authentication required' });
  }
  next();
};