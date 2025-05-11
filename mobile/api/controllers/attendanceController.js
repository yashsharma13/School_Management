// // controllers/attendanceController.js
import { 
  recordStudentAttendance,
  recordTeacherAttendance,
  getStudentAttendanceByClassAndDate,
  getTeacherAttendanceByDate 
} from '../models/attendanceModel.js';

// Helper function to record student attendance
const recordAttendanceForStudents = async (students, date) => {
  const studentPromises = students.map((student) => {
    return new Promise((resolve, reject) => {
      recordStudentAttendance(
        {
          student_id: student.student_id,
          date: date,
          is_present: student.is_present,
          class_name: student.class_name
        },
        (err, results) => {
          if (err) {
            return reject(new Error(`Error recording student attendance for student ${student.student_id}: ${err.message}`));
          }
          resolve(results);
        }
      );
    });
  });
  return Promise.all(studentPromises);
};

// Helper function to record teacher attendance
const recordAttendanceForTeachers = async (teachers, date) => {
  const teacherPromises = teachers.map((teacher) => {
    return new Promise((resolve, reject) => {
      recordTeacherAttendance(
        {
          teacher_id: teacher.teacher_id,
          date: date,
          is_present: teacher.is_present
        },
        (err, results) => {
          if (err) {
            return reject(new Error(`Error recording teacher attendance for teacher ${teacher.teacher_id}: ${err.message}`));
          }
          resolve(results);
        }
      );
    });
  });
  return Promise.all(teacherPromises);
};

export const saveAttendance = async (req, res) => {
  const { date, students, teachers } = req.body;

  // If there are no students or teachers, return immediately
  if ((!students || students.length === 0) && (!teachers || teachers.length === 0)) {
    return res.status(200).json({ message: 'No attendance records to save' });
  }

  try {
    // Create an array of promises for student and teacher attendance
    const attendancePromises = [];

    if (students && students.length > 0) {
      attendancePromises.push(recordAttendanceForStudents(students, date));
    }

    if (teachers && teachers.length > 0) {
      attendancePromises.push(recordAttendanceForTeachers(teachers, date));
    }

    // Wait for all attendance promises to resolve
    await Promise.all(attendancePromises);

    // If all operations were successful
    res.status(200).json({ message: 'Attendance recorded successfully' });
  } catch (err) {
    // If any operation fails, return an error response
    console.error('Error saving attendance:', err);
    res.status(500).json({ error: err.message });
  }
};

// This function retrieves the attendance report for a specific class and date
export const getAttendanceReport = (req, res) => {
  const className = decodeURIComponent(req.params.class);  // Decode class name
  const date = req.params.date;  // Date in the format 'yyyy-mm-dd'
  const user_email = req.user_email; // Get the user's email from the token

  // Get student attendance by class and date
  getStudentAttendanceByClassAndDate(className, date, user_email, (err, studentResults) => {
    if (err) {
      console.error('Error fetching student attendance:', err);
      return res.status(500).json({ message: 'Internal server error' });
    }

    // Get teacher attendance by date
    getTeacherAttendanceByDate(date, user_email, (err, teacherResults) => {
      if (err) {
        console.error('Error fetching teacher attendance:', err);
        return res.status(500).json({ message: 'Internal server error' });
      }

      // Combine student and teacher attendance reports
      res.json({
        students: studentResults,
        teachers: teacherResults
      });
    });
  });
};
