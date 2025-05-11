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
    username,
    password,
    user_email,
    role
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
    username,
    password,
    user_email,
    role
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?)`;

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
    username,
    password,
    user_email,
    'student' // Always set this to 'student'
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

// studentModel.js

export const getStudentCount = (user_email, callback) => {
  const query = 'SELECT COUNT(*) AS totalStudents FROM students WHERE user_email = ?';
  connection.query(query, [user_email], (err, results) => {
    if (err) {
      return callback(err);
    }
    callback(null, results);
  });
};


export const getStudentCountByClass = (user_email, callback) => {
  // Use the exact same query that works in your direct SQL
  const query = `
    SELECT 
      LOWER(TRIM(assigned_class)) as class_name, 
      COUNT(*) as student_count
    FROM 
      students
    WHERE 
      user_email = ?
      AND assigned_class IS NOT NULL
      AND assigned_class != ''
    GROUP BY 
      LOWER(TRIM(assigned_class))
    ORDER BY 
      LOWER(TRIM(assigned_class))
  `;
  
  console.log('Executing count query with email:', user_email);
  console.log('Full query:', query);

  connection.query(query, [user_email], (err, results) => {
    if (err) {
      console.error('Database error:', err);
      return callback(err, null);
    }
    
    console.log('Query results:', results);
    callback(null, results);
  });
};
export const getLastRegistrationNumber = (userEmail, callback) => {
  const query = `
    SELECT MAX(registration_number) AS lastRegNumber
    FROM students
    WHERE user_email = ?
  `;

  connection.query(query, [userEmail], (err, results) => {
    if (err) return callback(err);

    const lastRegNumber = results[0]?.lastRegNumber;
    callback(null, lastRegNumber);
  });
};

