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

export const createUser = (userData, callback) => {
  const { email, phone, password, confirmpassword, role } = userData;
  const query = 'INSERT INTO signup (email, phone, password, confirmpassword, role) VALUES (?, ?, ?, ?, ?)';
  connection.query(query, [email, phone, password, confirmpassword, role], callback);
};