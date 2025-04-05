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

export const getTeachersByUser = (user_email, callback) => {
  const query = 'SELECT * FROM teacher WHERE user_email = ?';
  connection.query(query, [user_email], callback);
};

export const getTeacherById = (teacherId, callback) => {
  const query = 'SELECT * FROM teacher WHERE id = ?';
  connection.query(query, [teacherId], callback);
};

export const updateTeacher = (teacherId, teacherData, callback) => {
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
    teacher_photo
  } = teacherData;

  const updateQuery = `
    UPDATE teacher SET
    teacher_name = ?,
    email = ?,
    date_of_birth = ?,
    date_of_joining = ?,
    gender = ?,
    guardian_name = ?,
    qualification = ?,
    experience = ?,
    salary = ?,
    address = ?,
    phone = ?, 
    qualification_certificate = ?, 
    teacher_photo = ?
    WHERE id = ?
  `;

  connection.query(updateQuery, [
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
    teacherId
  ], callback);
};

export const deleteTeacher = (teacherId, callback) => {
  const deleteTeacherQuery = 'DELETE FROM teacher WHERE id = ?';
  connection.query(deleteTeacherQuery, [teacherId], callback);
};


export const getTeacherCount = (callback) => {
  const query = 'SELECT COUNT(*) as totalTeachers FROM teacher';
  connection.query(query, callback);
};