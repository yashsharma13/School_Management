// models/attendanceModel.js
import connection from '../config/mysqlconnectivity.js';

export const recordAttendance = (attendanceData, callback) => {
  const { student_id, date, is_present, class_name } = attendanceData;
  
  const query = `
    INSERT INTO attendance (student_id, date, is_present, class_name) 
    VALUES (?, ?, ?, ?)
  `;
  
  connection.query(query, [student_id, date, is_present, class_name], callback);
};

export const getAttendanceByClassAndDate = (className, date, user_email, callback) => {
  const query = `
    SELECT students.student_name, attendance.is_present 
    FROM attendance 
    JOIN students ON attendance.student_id = students.id
    WHERE attendance.class_name = ? 
      AND attendance.date = ?
      AND students.user_email = ?
  `;
  
  connection.query(query, [className, date, user_email], callback);
};

export const deleteAttendanceByStudentId = (studentId, callback) => {
  const deleteAttendanceQuery = 'DELETE FROM attendance WHERE student_id = ?';
  connection.query(deleteAttendanceQuery, [studentId], callback);
};