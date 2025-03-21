// models/studentModel.js
import connection from '../config/mysqlconnectivity.js';

export const createStudent = (studentData, callback) => {
  const {
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birthCertificatePath,
    studentPhotoPath,
    user_email
  } = studentData;

  const sql = `INSERT INTO students (
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birth_certificate,
    student_photo,
    user_email
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  connection.query(sql, [
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birthCertificatePath,
    studentPhotoPath,
    user_email
  ], callback);
};

export const getStudentsByUser = (user_email, callback) => {
  const query = 'SELECT * FROM students WHERE user_email = ?';
  connection.query(query, [user_email], callback);
};

export const getStudentById = (studentId, callback) => {
  const query = 'SELECT * FROM students WHERE id = ?';
  connection.query(query, [studentId], callback);
};

export const updateStudent = (studentId, studentData, callback) => {
  const {
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birth_certificate,
    student_photo
  } = studentData;

  const updateQuery = `
    UPDATE students SET
      student_name = ?, 
      registration_number = ?, 
      date_of_birth = ?, 
      gender = ?, 
      address = ?, 
      father_name = ?, 
      mother_name = ?, 
      email = ?, 
      phone = ?, 
      assigned_class = ?, 
      assigned_section = ?, 
      birth_certificate = ?, 
      student_photo = ?
    WHERE id = ?
  `;

  connection.query(updateQuery, [
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    email,
    phone,
    assigned_class,
    assigned_section,
    birth_certificate,
    student_photo,
    studentId
  ], callback);
};

export const deleteStudent = (studentId, callback) => {
  const deleteStudentQuery = 'DELETE FROM students WHERE id = ?';
  connection.query(deleteStudentQuery, [studentId], callback);
};

export const getStudentsByClass = (className, user_email, callback) => {
  const query = 'SELECT * FROM students WHERE assigned_class = ? AND user_email = ?';
  connection.query(query, [className, user_email], callback);
};

export const getStudentCount = (callback) => {
  const query = 'SELECT COUNT(*) as totalStudents FROM students';
  connection.query(query, callback);
};