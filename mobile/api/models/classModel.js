// // classModel.js
import connection from '../config/mysqlconnectivity.js';

export const createClass = (classData, callback) => {
  const { class_name, tuition_fees, teacher_name, user_email } = classData;
  const sql = `
    INSERT INTO classes (class_name, tuition_fees, teacher_name, user_email)
    VALUES (?, ?, ?, ?)
  `;
  connection.query(sql, [class_name, tuition_fees, teacher_name, user_email], (err, results) => {
    if (err) {
      console.error('MySQL Error in createClass:', err);
      return callback(err, null);
    }
    callback(null, results);
  });
};

export const getClassesByUser = (user_email, callback) => {
  const query = 'SELECT * FROM classes WHERE user_email = ?';
  connection.query(query, [user_email], (err, results) => {
    if (err) {
      console.error('MySQL Error in getClassesByUser:', err);
      return callback(err, null);
    }
    callback(null, results);
  });
};

export const updateClass = (classId, classData, callback) => {
  const { class_name, tuition_fees, teacher_name } = classData;
  const query = `
    UPDATE classes 
    SET class_name = ?, tuition_fees = ?, teacher_name = ? 
    WHERE id = ?
  `;
  connection.query(query, [class_name, tuition_fees, teacher_name, classId], (err, results) => {
    if (err) {
      console.error('MySQL Error in updateClass:', err);
      return callback(err, null);
    }
    callback(null, results);
  });
};

export const deleteClass = (classId, callback) => {
  const query = 'DELETE FROM classes WHERE id = ?';
  connection.query(query, [classId], (err, results) => {
    if (err) {
      console.error('MySQL Error in deleteClass:', err);
      return callback(err, null);
    }
    callback(null, results);
  });
};