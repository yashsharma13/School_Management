import connection from '../config/mysqlconnectivity.js';

export const createSubject = (classData, callback) => {
  const { class_name, subject_name, marks, user_email } = classData;
  const sql = `
    INSERT INTO subjects (class_name, subject_name, marks, user_email)
    VALUES (?, ?, ?, ?)
  `;
  connection.query(sql, [class_name, subject_name, marks, user_email], (err, results) => {
    if (err) {
      console.error('MySQL Error in createSubjects:', err);
      return callback(err, null);
    }
    callback(null, results);
  });
};

export const getSubjectsByUser = (user_email, callback) => {
  const query = 'SELECT * FROM subjects WHERE user_email = ?';
  connection.query(query, [user_email], (err, results) => {
    if (err) {
      console.error('MySQL Error in getSubjectsByUser:', err);
      return callback(err, null);
    }
    callback(null, results);
  });
};
// Assuming you are using a database like MySQL or MongoDB, adapt the query accordingly

// Update subject by ID in the database
export const updateSubjectById = (subjectId, updatedData, userEmail, callback) => {
  // Assuming you're using a MySQL-like database
  const { subject_name, marks } = updatedData;

  // Your database update query, adapting the syntax to your setup
  const query = `
    UPDATE subjects 
    SET subject_name = ?, marks = ?
    WHERE _id = ? AND user_email = ?
  `;

  // Execute the update query
  connection.query(query, [subject_name, marks, subjectId, userEmail], (err, result) => {
    if (err) {
      return callback(err, null);
    }

    if (result.affectedRows === 0) {
      // No subject was found with the given ID
      return callback(null, null);
    }

    callback(null, result);
  });
};

