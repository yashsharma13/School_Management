import { createHomework, getHomeworkByTeacher, deleteHomework } from '../models/homeworkModel.js';
import { getActiveSessionFromDB } from '../models/sessionModel.js';

// Controller to assign homework
export const assignHomework = async (req, res) => {
  try {
    const { class_id, homework, start_date, end_date } = req.body;
    const signup_id = req.signup_id;

    if (!class_id || !homework || !start_date || !end_date || !signup_id) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    if (new Date(end_date) < new Date(start_date)) {
      return res.status(400).json({ success: false, message: 'End date cannot be before start date' });
    }

    const activeSession = await getActiveSessionFromDB(signup_id);
    if (!activeSession) {
      return res.status(400).json({ success: false, message: 'No active session found for this school' });
    }

    const newHomework = await createHomework({
      class_id,
      homework,
      start_date,
      end_date,
      signup_id,
      session_id: activeSession.id,
    });

    return res.status(201).json({
      success: true,
      message: 'Homework assigned successfully',
      data: newHomework,
    });

  } catch (err) {
    console.error('Error assigning homework:', err);
    return res.status(500).json({ success: false, message: 'Error assigning homework' });
  }
};

// Controller to get homework assigned by the logged-in teacher (only active homework)
export const getTeacherHomework = async (req, res) => {
  try {
    const signup_id = req.signup_id;

    if (!signup_id) {
      return res.status(401).json({ success: false, message: 'Unauthorized: missing teacher ID' });
    }

    const homeworkList = await getHomeworkByTeacher(signup_id);

    return res.status(200).json({ success: true, data: homeworkList });

  } catch (err) {
    console.error('Error fetching teacher homework:', err);
    return res.status(500).json({ success: false, message: 'Error fetching homework' });
  }
};

// Controller to delete homework by id
export const deleteTeacherHomework = async (req, res) => {
  try {
    const id = req.params.id;
    const signup_id = req.signup_id;

    if (!id || !signup_id) {
      return res.status(400).json({ success: false, message: 'Invalid request parameters' });
    }

    const result = await deleteHomework(id, signup_id);

    if (result.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'Homework not found or unauthorized' });
    }

    return res.json({ success: true, message: 'Homework deleted successfully' });

  } catch (err) {
    console.error('Error deleting homework:', err);
    return res.status(500).json({ success: false, message: 'Error deleting homework' });
  }
};
