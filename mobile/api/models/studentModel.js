import pool from '../config/db.js';

export const createStudent = async (studentData) => {
  const {
    student_name,
    registration_number,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    assigned_class,
    assigned_section,
    birthCertificatePath,
    studentPhotoPath,
    signup_id,
    session_id
  } = studentData;

  const sql = `
    INSERT INTO students (
      student_name,
      registration_number,
      date_of_birth,
      gender,
      address,
      father_name,
      mother_name,
      assigned_class,
      assigned_section,
      birth_certificate,
      student_photo,
      signup_id,
      session_id
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    RETURNING *
  `;

  try {
    const result = await pool.query(sql, [
      student_name,
      registration_number,
      date_of_birth,
      gender,
      address,
      father_name,
      mother_name,
      assigned_class,
      assigned_section,
      birthCertificatePath,
      studentPhotoPath,
      signup_id,
      session_id
    ]);
    return result.rows[0];
  } catch (err) {
    console.error('Error creating student:', err);
    throw err;
  }
};

// Parent ko email se find karo signup table me
export const findSignupByEmail = async (email) => {
  const res = await pool.query('SELECT * FROM signup WHERE email = $1', [email]);
  return res.rows[0];
};

// Parent-Student link insert karo
export const linkParentStudent = async (parentSignupId, studentId) => {
  const sql = `INSERT INTO parent_student_link (parent_signup_id, student_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`;
  await pool.query(sql, [parentSignupId, studentId]);
};

export const getStudentsByUser = async (signup_id) => {
  const query = `
    SELECT s.*
    FROM students s
    JOIN signup u ON s.signup_id = u.id
    WHERE u.school_id = (
      SELECT school_id FROM signup WHERE id = $1
    )
  `;

  try {
    const result = await pool.query(query, [signup_id]);
    return result.rows;
  } catch (err) {
    console.error('Error fetching students by user (school):', err);
    throw err;
  }
};

export const getStudentById = async (studentId, signup_id) => {
  const query = `
    SELECT s.*
    FROM students s
    JOIN signup u ON s.signup_id = u.id
    WHERE s.id = $1
      AND u.school_id = (
        SELECT school_id FROM signup WHERE id = $2
      )
    LIMIT 1
  `;

  try {
    const result = await pool.query(query, [studentId, signup_id]);
    return result.rows[0];
  } catch (err) {
    console.error('Error fetching student by id:', err);
    throw err;
  }
};


export const updateStudent = async (studentId, studentData) => {
  const {
    student_name,
    date_of_birth,
    gender,
    address,
    father_name,
    mother_name,
    assigned_class,
    assigned_section,
    birth_certificate,
    student_photo
  } = studentData;

  const updateQuery = `
    UPDATE students SET
      student_name = $1, 
      date_of_birth = $2, 
      gender = $3, 
      address = $4, 
      father_name = $5, 
      mother_name = $6,
      assigned_class = $7, 
      assigned_section = $8, 
      birth_certificate = $9, 
      student_photo = $10
    WHERE id = $11
    RETURNING *
  `;

  try {
    const result = await pool.query(updateQuery, [
      student_name,
      date_of_birth,
      gender,
      address,
      father_name,
      mother_name,
      assigned_class,
      assigned_section,
      birth_certificate,
      student_photo,
      studentId
    ]);
    return result;
  } catch (err) {
    console.error('Error updating student:', err);
    throw err;
  }
};
export const deleteStudent = async (studentId) => {
  const deleteStudentQuery = 'DELETE FROM students WHERE id = $1 RETURNING *';
  try {
    const result = await pool.query(deleteStudentQuery, [studentId]);
    if (result.rowCount === 0) {
      // Koi student nahi mila delete karne ke liye
      return null;
    }
    return result.rows[0];  // deleted student ka record return karo
  } catch (err) {
    console.error('Error deleting student:', err);
    throw err;
  }
};


// export const getStudentsByClass = async (className, signup_id) => {
//   const query = 'SELECT * FROM students WHERE assigned_class = $1 AND signup_id = $2';
//   try {
//     const result = await pool.query(query, [className, signup_id]);
//     return result.rows;
//   } catch (err) {
//     console.error('Error fetching students by class:', err);
//     throw err;
//   }
// };

// export const getStudentsByClassInSchool = async (className, signup_id) => {
//   const query = `
//     SELECT s.*
//     FROM students s
//     JOIN signup u ON s.signup_id = u.id
//     WHERE u.school_id = (
//       SELECT school_id FROM signup WHERE id = $1
//     )
//     AND LOWER(TRIM(s.assigned_class)) = LOWER(TRIM($2))
//   `;
//   try {
//     const result = await pool.query(query, [signup_id, className]);
//     return result.rows;
//   } catch (err) {
//     console.error('Error fetching students by class in school:', err);
//     throw err;
//   }
// };


export const getStudentsByClassInSchool = async (className, signup_id) => {
  const query = `
    SELECT 
      s.*,
      u.email AS username,
      u.password
    FROM students s
    JOIN signup u ON s.signup_id = u.id
    WHERE u.school_id = (
      SELECT school_id FROM signup WHERE id = $1
    )
    AND LOWER(TRIM(s.assigned_class)) = LOWER(TRIM($2))
  `;
  try {
    const result = await pool.query(query, [signup_id, className]);
    return result.rows;
  } catch (err) {
    console.error('Error fetching students by class in school:', err);
    throw err;
  }
};


export const getStudentsBySchoolId = async (signup_id) => {
  const query = `
    SELECT s.*
    FROM students s
    JOIN signup u ON s.signup_id = u.id
    WHERE u.school_id = (
      SELECT school_id FROM signup WHERE id = $1
    )
  `;
  try {
    const result = await pool.query(query, [signup_id]);
    return result.rows;
  } catch (err) {
    console.error('Error fetching students by school_id:', err);
    throw err;
  }
};


export const getStudentCount = async (signup_id) => {
  // const query = 'SELECT COUNT(*) AS totalstudents FROM students WHERE signup_id = $1';
  const query = `
  SELECT COUNT(*) AS totalstudents 
  FROM students 
  WHERE signup_id IN (
    SELECT id FROM signup WHERE school_id = (
      SELECT school_id FROM signup WHERE id = $1
    )
  )
`;

  const values = [signup_id];

  try {
    const result = await pool.query(query, values);
    return result.rows; // returns array like: [{ totalstudents: '3' }]
  } catch (err) {
    console.error('Database error in getStudentCount:', err);
    throw err;
  }
};
export const getStudentCountByClass = async (signup_id) => {
  const query = `
    SELECT
      LOWER(TRIM(assigned_class)) AS class_name,
      LOWER(TRIM(assigned_section)) AS section,
      COUNT(*) AS student_count
    FROM
      students
    WHERE signup_id IN (
  SELECT id FROM signup WHERE school_id = (
    SELECT school_id FROM signup WHERE id = $1
  )
)

      AND assigned_class IS NOT NULL
      AND assigned_class != ''
      AND assigned_section IS NOT NULL
      AND assigned_section != ''
    GROUP BY
      LOWER(TRIM(assigned_class)),
      LOWER(TRIM(assigned_section))
    ORDER BY
      LOWER(TRIM(assigned_class)),
      LOWER(TRIM(assigned_section))
  `;
  
  try {
    const result = await pool.query(query, [signup_id]);
    return result.rows;
  } catch (err) {
    console.error('Error getting student count by class:', err);
    throw err;
  }
};

export const getLastRegistrationNumber = async (signup_id) => {
  const query = `
    SELECT MAX(registration_number) AS lastregnumber
    FROM students
    WHERE signup_id IN (
  SELECT id FROM signup WHERE school_id = (
    SELECT school_id FROM signup WHERE id = $1
  )
)
  `;

  try {
    const result = await pool.query(query, [signup_id]);
    return result.rows[0]?.lastregnumber;
  } catch (err) {
    console.error('Error getting last registration number:', err);
    throw err;
  }
};