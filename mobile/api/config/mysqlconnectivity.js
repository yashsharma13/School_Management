import mysql from 'mysql';
import dotenv from 'dotenv';

// .env file load karne ke liye
dotenv.config();

var connection = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306, // Default 3306
});

export default connection;
