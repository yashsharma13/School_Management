// models/attendanceModel.js
import connection from '../config/mysqlconnectivity.js';

export const recordStudentAttendance = (attendanceData, callback) => {
  const { student_id, date, is_present, class_name } = attendanceData;
  
  const query = `
    INSERT INTO attendance (student_id, date, is_present, class_name) 
    VALUES (?, ?, ?, ?)
  `;
  
  connection.query(query, [student_id, date, is_present, class_name], callback);
};

export const recordTeacherAttendance = (attendanceData, callback) => {
  const { teacher_id, date, is_present } = attendanceData;
  console.log('Teacher Attendance Data:', attendanceData);
  const query = `
    INSERT INTO teacher_attendance (teacher_id, date, is_present) 
    VALUES (?, ?, ?)
  `;
  
  connection.query(query, [teacher_id, date, is_present], callback);
};

export const getStudentAttendanceByClassAndDate = (className, date, user_email, callback) => {
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


export const getTeacherAttendanceByDate = (date, user_email, callback) => {
  const query = `
    SELECT teacher.teacher_name, teacher_attendance.is_present 
    FROM teacher_attendance 
    JOIN teacher ON teacher_attendance.teacher_id = teacher.id
    WHERE  teacher_attendance.date = ?
      AND teacher.user_email = ?
  `;
  
  connection.query(query, [date, user_email], callback);
};

export const deleteAttendanceByStudentId = (studentId, callback) => {
  const deleteAttendanceQuery = 'DELETE FROM attendance WHERE student_id = ?';
  connection.query(deleteAttendanceQuery, [studentId], callback);
};

export const deleteAttendanceByTeacherId = (teacherId, callback) => {
  const deleteAttendanceQuery = 'DELETE FROM teacher_attendance WHERE teacher_id = ?';
  connection.query(deleteAttendanceQuery, [teacherId], callback);
};