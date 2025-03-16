// controllers/attendanceController.js
import { recordAttendance, getAttendanceByClassAndDate } from '../models/attendanceModel.js';

export const saveAttendance = (req, res) => {
  const { date, students } = req.body; // { date: '2025-03-08', students: [...] }

  // Counter to track completion of all operations
  let completedOperations = 0;
  let hasError = false;

  // If there are no students, return immediately
  if (!students || students.length === 0) {
    return res.status(200).json({ message: 'No attendance records to save' });
  }

  // Loop through the students and insert attendance
  students.forEach((student) => {
    recordAttendance({
      student_id: student.student_id,
      date: date,
      is_present: student.is_present,
      class_name: student.class_name
    }, (err, results) => {
      completedOperations++;
      
      if (err && !hasError) {
        hasError = true;
        console.error('Error recording attendance:', err);
        return res.status(500).json({ error: err.message });
      }

      // Check if all operations are completed
      if (completedOperations === students.length && !hasError) {
        res.status(200).json({ message: 'Attendance recorded successfully' });
      }
    });
  });
};

export const getAttendanceReport = (req, res) => {
  const className = decodeURIComponent(req.params.class);  // Decode class name
  const date = req.params.date;  // Date in the format 'yyyy-mm-dd'
  const user_email = req.user_email; // Get the user's email from the token

  getAttendanceByClassAndDate(className, date, user_email, (err, results) => {
    if (err) {
      console.error('Error fetching attendance:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    res.json(results);  // Send the attendance records for the given class, date, and user
  });
};