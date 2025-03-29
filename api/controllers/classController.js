import { createClass, getClassesByUser, updateClass, deleteClass } from '../models/classModel.js';

// Register class
export const registerClass = (req, res) => {
  const { class_name, tuition_fees, teacher_name } = req.body;
  const user_email = req.user_email;

  if (!class_name || !tuition_fees || !teacher_name || !user_email) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  createClass({ class_name, tuition_fees, teacher_name, user_email }, (err, results) => {
    if (err) {
      console.error('Error registering class:', err);
      return res.status(500).json({ message: 'Error registering class' });
    }
    res.status(201).json({ 
      success: true,
      message: 'Class registered successfully',
      classId: results.insertId
    });
  });
};

// Fetch classes by user
export const getAllClasses = (req, res) => {
  const user_email = req.user_email;

  if (!user_email) {
    return res.status(400).json({ message: 'User email is required' });
  }

  getClassesByUser(user_email, (err, results) => {
    if (err) {
      console.error('Error fetching classes:', err);
      return res.status(500).json({ message: 'Error fetching classes' });
    }
    res.status(200).json(results);
  });
};

// Update class details
export const updateClassDetails = (req, res) => {
  const classId = req.params.id;
  const { class_name, tuition_fees, teacher_name } = req.body;

  if (!classId || !class_name || !tuition_fees || !teacher_name) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  updateClass(classId, { class_name, tuition_fees, teacher_name }, (err, results) => {
    if (err) {
      console.error('Error updating class:', err);
      return res.status(500).json({ message: 'Error updating class' });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    res.status(200).json({ 
      success: true,
      message: 'Class updated successfully'
    });
  });
};

// Delete class
export const deleteClassById = (req, res) => {
  const classId = req.params.id;

  if (!classId) {
    return res.status(400).json({ message: 'Class ID is required' });
  }

  deleteClass(classId, (err, results) => {
    if (err) {
      console.error('Error deleting class:', err);
      return res.status(500).json({ message: 'Error deleting class' });
    }
    
    if (results.affectedRows === 0) {
      return res.status(404).json({ message: 'Class not found' });
    }
    
    res.status(200).json({ 
      success: true,
      message: 'Class deleted successfully'
    });
  });
};