import pool from '../config/db.js';

// Create new homework entry
export const createHomework = async (homeworkData) => {
  const { class_id, homework, start_date, end_date, signup_id, session_id } = homeworkData;

  const sql = `
    INSERT INTO homework (class_id, homework, start_date, end_date, signup_id, session_id)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *
  `;

  try {
    const result = await pool.query(sql, [
      class_id,
      homework,
      start_date,
      end_date,
      signup_id,
      session_id,
    ]);
    return result.rows[0];
  } catch (err) {
    console.error('PostgreSQL Error in createHomework:', err);
    throw err;
  }
};

// Fetch all homework assigned by a teacher (signup_id) where end_date >= today
export const getHomeworkByTeacher = async (signup_id) => {
  const sql = `
    SELECT *
    FROM homework
    WHERE signup_id = $1
      AND end_date >= CURRENT_DATE
    ORDER BY start_date DESC, created_at DESC
  `;

  try {
    const result = await pool.query(sql, [signup_id]);
    return result.rows;
  } catch (err) {
    console.error('PostgreSQL Error in getHomeworkByTeacher:', err);
    throw err;
  }
};

// Delete a homework entry only if it belongs to the user (teacher)
export const deleteHomework = async (id, signup_id) => {
  const sql = `
    DELETE FROM homework 
    WHERE id = $1 AND signup_id = $2
  `;

  try {
    const result = await pool.query(sql, [id, signup_id]);
    return { rowCount: result.rowCount };  // rowCount = number of deleted rows
  } catch (err) {
    console.error('PostgreSQL Error in deleteHomework:', err);
    throw err;
  }
};
