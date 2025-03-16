// models/studentModel.js
import connection from '../config/mysqlconnectivity.js';

export const createTeacher = (teacherData, callback) => {
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
            qualification_certificate, 
            teacher_photo,
            user_email
  } = teacherData;

  const sql = `INSERT INTO teacher (
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
    teacher_photo,
    user_email )
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`;

connection.query(sql, [
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
    teacher_photo,
    user_email // Add the user's email from the token
], callback);
};

export const getTeacherCount = (callback) => {
  const query = 'SELECT COUNT(*) as totalTeachers FROM teacher';
  connection.query(query, callback);
};