// models/userModel.js
import connection from '../config/mysqlconnectivity.js';

export const findUserByEmail = (email, callback) => {
  const query = 'SELECT * FROM signup WHERE email = ?';
  connection.query(query, [email], callback);
};

export const findUserByCredentials = (email, password, callback) => {
  const query = 'SELECT * FROM signup WHERE email = ? AND password = ?';
  connection.query(query, [email, password], callback);
};

// New function to find user by credentials and role
export const findUserByCredentialsAndRole = (email, password, role, callback) => {
  const query = 'SELECT * FROM signup WHERE email = ? AND password = ? AND role = ?';
  connection.query(query, [email, password, role], callback);
};

export const createUser = (userData, callback) => {
  const { email, phone, password, confirmpassword, role } = userData;
  const query = 'INSERT INTO signup (email, phone, password, confirmpassword, role) VALUES (?, ?, ?, ?, ?)';
  connection.query(query, [email, phone, password, confirmpassword, role], callback);
};

// Add to userModel.js
export const findStudentByCredentials = (username, password, callback) => {
  const query = 'SELECT * FROM students WHERE username = ? AND password = ?';
  connection.query(query, [username, password], callback);
};

