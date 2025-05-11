import connection from '../config/mysqlconnectivity.js';
import { createSubject,getSubjectsByUser,updateSubjectById } from '../models/subjectModel.js';

export const registerSubject = (req, res) => {
  const { class_name, subject_name, marks } = req.body;
  const user_email = req.user_email;

  console.log('Received request body:', req.body);

  if (!class_name || !subject_name || !marks || !user_email) {
    return res.status(400).json({ 
      success: false,
      message: 'Missing required fields' 
    });
  }

  // First check if the class already exists for this user
  const checkQuery = 'SELECT id FROM subjects WHERE class_name = ? AND user_email = ?';
  
  connection.query(checkQuery, [class_name, user_email], (checkErr, checkResults) => {
    if (checkErr) {
      console.error('Error checking existing subjects:', checkErr);
      return res.status(500).json({ 
        success: false,
        message: 'Error checking existing subjects' 
      });
    }

    if (checkResults.length > 0) {
      return res.status(409).json({ 
        success: false,
        message: 'This class already has subjects assigned. Please use update instead.',
        existingClass: class_name
      });
    }

    // If class doesn't exist, proceed with registration
    createSubject({ class_name, subject_name, marks, user_email }, (err, results) => {
      if (err) {
        console.error('Error registering subjects:', err);
        return res.status(500).json({ 
          success: false,
          message: 'Error registering subjects' 
        });
      }

      res.status(201).json({
        success: true,
        message: 'Subjects registered successfully',
        data: {
          class_name,
          subject_name,
          marks
        }
      });
    });
  });
};
export const getAllSubjects = (req, res) => {
  const user_email = req.user_email;

  if (!user_email) {
    return res.status(400).json({ message: 'User email is required' });
  }

  // First get all valid classes for this user
  const getClassesQuery = 'SELECT class_name FROM classes WHERE user_email = ?';
  
  connection.query(getClassesQuery, [user_email], (classErr, classResults) => {
    if (classErr) {
      console.error('Error fetching classes:', classErr);
      return res.status(500).json({ message: 'Error fetching classes' });
    }

    const validClasses = classResults.map(c => c.class_name);

    // Now get subjects only for valid classes
    getSubjectsByUser(user_email, (err, results) => {
      if (err) {
        console.error('Error fetching subjects:', err);
        return res.status(500).json({ message: 'Error fetching subjects' });
      }

      // Filter subjects to only include those for valid classes
      const filteredResults = results.filter(subject => 
        validClasses.includes(subject.class_name)
      );

      // Group subjects by class
      const classSubjectsMap = {};
      filteredResults.forEach(subject => {
        if (!classSubjectsMap[subject.class_name]) {
          classSubjectsMap[subject.class_name] = {
            _id: subject.id,
            class_name: subject.class_name,
            user_email: subject.user_email,
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
  });
};
// Update a specific subject by its ID

export const updateSubject = async (req, res) => {
  try {
    const { subject_id, subjects } = req.body;
    const user_email = req.user_email;

    if (!subject_id || !subjects || !user_email) {
      return res.status(400).json({ 
        success: false,
        message: 'Missing required fields'
      });
    }

    // Combine all subjects into comma-separated strings
    const combinedSubjectNames = subjects.map(s => s.subject_name).join(', ');
    const combinedMarks = subjects.map(s => s.marks).join(', ');
    const class_name = subjects[0].class_name; // All should have same class

    // Update the single record with all subjects
    const updateQuery = `
      UPDATE subjects 
      SET 
        class_name = ?,
        subject_name = ?,
        marks = ?
      WHERE id = ? AND user_email = ?
    `;

    connection.query(
      updateQuery,
      [class_name, combinedSubjectNames, combinedMarks, subject_id, user_email],
      (error, results) => {
        if (error) {
          console.error('Database error:', error);
          return res.status(500).json({
            success: false,
            message: 'Database operation failed'
          });
        }

        if (results.affectedRows === 0) {
          return res.status(404).json({
            success: false,
            message: 'No subject found with that ID for this user'
          });
        }

        res.status(200).json({
          success: true,
          message: 'Subjects updated successfully',
          data: {
            id: subject_id,
            class_name,
            subject_name: combinedSubjectNames,
            marks: combinedMarks,
            user_email
          }
        });
      }
    );

  } catch (error) {
    console.error('Error updating subjects:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

