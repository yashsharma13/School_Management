// import express from 'express';
// import bodyParser from 'body-parser';
// import cors from 'cors';
// import connection from './mysqlconnectivity.js'; // Assuming this is correctly set up to connect to your MySQL
// import multer from 'multer';
// import path from 'path';
// import fs from 'fs';
// import { fileURLToPath } from 'url';
// import { dirname } from 'path';

// // Setup for file path management
// const __filename = fileURLToPath(import.meta.url);
// const __dirname = dirname(__filename);

// // Initialize Express app
// const app = express();
// const port = 1000;

// // Middleware
// app.use(cors());
// app.use(bodyParser.json());

// // Serve static files from the uploads directory - Fix the path to be absolute
// app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// // File filter for validating uploaded files
// const fileFilter = (req, file, cb) => {
//     console.log('File details:', {
//         fieldname: file.fieldname,
//         mimetype: file.mimetype,
//         originalname: file.originalname,
//         size: file.size
//     });

//     if (file.fieldname === 'student_photo') {
//         const allowedExtensions = ['.jpg', '.jpeg', '.png'];
//         const fileExtension = path.extname(file.originalname).toLowerCase();
//         if (allowedExtensions.includes(fileExtension)) {
//             cb(null, true);
//         } else {
//             cb(new Error('Only JPG, JPEG, and PNG files are allowed for student photo.'), false);
//         }
//     } else if (file.fieldname === 'birth_certificate') {
//         const fileExtension = path.extname(file.originalname).toLowerCase();
//         if (fileExtension === '.pdf') {
//             cb(null, true);
//         } else {
//             cb(new Error('Only PDF files are allowed for birth certificate.'), false);
//         }
//     } else {
//         cb(new Error('Unexpected field'), false);
//     }
// };

// // Multer setup with storage and file filter
// const upload = multer({
//     storage: multer.diskStorage({
//         destination: (req, file, cb) => {
//             const uploadDir = path.join(__dirname, 'uploads');
//             if (!fs.existsSync(uploadDir)) {
//                 fs.mkdirSync(uploadDir, { recursive: true });
//             }
//             cb(null, uploadDir);
//         },
//         filename: (req, file, cb) => {
//             const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
//             cb(null, uniqueSuffix + '-' + file.originalname);
//         }
//     }),
//     limits: { fileSize: 5 * 1024 * 1024 }, // 5MB file size limit
//     fileFilter: fileFilter
// }).fields([
//     { name: 'student_photo', maxCount: 1 },
//     { name: 'birth_certificate', maxCount: 1 }
// ]);

// // Error handling for multer file upload errors
// app.use((err, req, res, next) => {
//     if (err instanceof multer.MulterError) {
//         return res.status(400).send(`Multer error: ${err.message}`);
//     }
//     if (err) {
//         return res.status(500).send(`Error: ${err.message}`);
//     }
//     next();
// });

// // POST API for student registration
// app.post('/registerstudent', upload, async (req, res) => {
//     console.log('Uploaded files:', req.files);

//     const { student_name, registration_number, date_of_birth, gender, address, father_name, mother_name, email, phone, assigned_class, assigned_section } = req.body;

//     // Initialize file paths as null
//     let studentPhotoPath = null;
//     let birthCertificatePath = null;

//     try {
//         // If student photo is uploaded
//         if (req.files['student_photo']) {
//             // Store only the filename without 'uploads' prefix
//             studentPhotoPath = path.basename(req.files['student_photo'][0].path);
//         }

//         // If birth certificate is uploaded
//         if (req.files['birth_certificate']) {
//             // Store only the filename without 'uploads' prefix
//             birthCertificatePath = path.basename(req.files['birth_certificate'][0].path);
//         }

//         // SQL query to insert student data with file paths
//         const sql = `INSERT INTO students (
//             student_name,
//             registration_number,
//             date_of_birth,
//             gender,
//             address,
//             father_name,
//             mother_name,
//             email,
//             phone,
//             assigned_class,
//             assigned_section,
//             birth_certificate,
//             student_photo
//         ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

//         connection.query(sql, [
//             student_name,
//             registration_number,
//             date_of_birth,
//             gender,
//             address,
//             father_name,
//             mother_name,
//             email,
//             phone,
//             assigned_class,
//             assigned_section,
//             birthCertificatePath,
//             studentPhotoPath
//         ], (err, results) => {
//             if (err) {
//                 console.error('Error registering student:', err);
//                 return res.status(500).send('Error registering student');
//             }

//             res.status(200).send('Student registered successfully');
//         });
//     } catch (error) {
//         console.error('Error processing files:', error);
//         res.status(500).send('Error processing files');
//     }
// });

// // Get all students
// app.get('/students', (req, res) => {
//     const query = 'SELECT * FROM students';
//     connection.query(query, (err, results) => {
//         if (err) {
//             console.error('Error fetching students:', err);
//             return res.status(500).json({ message: 'Internal server error' });
//         }

//         // Normalize paths in the results
//         const normalizedResults = results.map(student => ({
//             ...student,
//             student_photo: student.student_photo ? 
//                 path.basename(student.student_photo.replace(/\\/g, '/')) : null,
//             birth_certificate: student.birth_certificate ? 
//                 path.basename(student.birth_certificate.replace(/\\/g, '/')) : null
//         }));

//         res.json(normalizedResults);
//     });
// });

// // Login Endpoint
// app.post('/login', (req, res) => {
//     const { email, password } = req.body;

//     const query = 'SELECT * FROM signup WHERE email = ? AND password = ?';
//     connection.query(query, [email, password], (err, results) => {
//         if (err) {
//             console.error(err);
//             return res.status(500).json({ success: false, message: 'Server error' });
//         }
//         if (results.length > 0) {
//             return res.json({ success: true, message: 'Login successful' });
//         } else {
//             return res.status(400).json({ success: false, message: 'Invalid Credentials' });
//         }
//     });
// });

// // // Register Endpoint
// // app.post('/register', (req, res) => {
// //     const { email, phone, password, confirmpassword } = req.body;

// //     // Validate inputs
// //     if (!email || !phone || !password || !confirmpassword) {
// //         return res.status(400).json({ success: false, message: 'Invalid Credentials' });
// //     }

// //     // Check if email already exists
// //     const checkEmailQuery = 'SELECT * FROM signup WHERE email = ?';
// //     connection.query(checkEmailQuery, [email], (err, results) => {
// //         if (err) {
// //             console.error('Error checking email:', err);
// //             return res.status(500).json({ success: false, message: 'Server error' });
// //         }

// //         if (results.length > 0) {
// //             // Email already exists
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'Email already exists'
// //             });
// //         }

// //         // Insert new user
// //         const query = 'INSERT INTO signup (email, phone, password, confirmpassword) VALUES (?, ?, ?, ?)';
// //         connection.query(query, [email, phone, password, confirmpassword], (err, results) => {
// //             if (err) {
// //                 console.error('Error inserting user:', err);
// //                 return res.status(500).json({ success: false, message: 'Server error' });
// //             }

// //             res.status(200).json({
// //                 success: true,
// //                 message: 'User registered successfully'
// //             });
// //         });
// //     });
// // });


// // Register Endpoint
// app.post('/register', (req, res) => {
//     const { email, phone, password, confirmpassword, role } = req.body;

//     // Validate inputs
//     if (!email || !phone || !password || !confirmpassword || !role) {
//         return res.status(400).json({ success: false, message: 'Invalid Credentials' });
//     }

//     // Check if email already exists
//     const checkEmailQuery = 'SELECT * FROM signup WHERE email = ?';
//     connection.query(checkEmailQuery, [email], (err, results) => {
//         if (err) {
//             console.error('Error checking email:', err);
//             return res.status(500).json({ success: false, message: 'Server error' });
//         }

//         if (results.length > 0) {
//             // Email already exists
//             return res.status(400).json({
//                 success: false,
//                 message: 'Email already exists'
//             });
//         }

//         // Insert new user with role
//         const query = 'INSERT INTO signup (email, phone, password, confirmpassword, role) VALUES (?, ?, ?, ?, ?)';
//         connection.query(query, [email, phone, password, confirmpassword, role], (err, results) => {
//             if (err) {
//                 console.error('Error inserting user:', err);
//                 return res.status(500).json({ success: false, message: 'Server error' });
//             }

//             res.status(200).json({
//                 success: true,
//                 message: 'User registered successfully'
//             });
//         });
//     });
// });


// // API to update student details
// app.put('/students/:id', upload, (req, res) => {
//     const studentId = req.params.id;
//     const {
//       student_name,
//       registration_number,
//       date_of_birth,
//       gender,
//       address,
//       father_name,
//       mother_name,
//       email,
//       phone,
//       assigned_class,
//       assigned_section,
//       birth_certificate,
//     } = req.body;

//     // Handle photo upload
//     let studentPhoto = req.body.student_photo; // Keep existing photo if not updated
//     if (req.files && req.files['student_photo']) {
//       studentPhoto = path.basename(req.files['student_photo'][0].path);
//     }
  
//     const updateQuery = `
//       UPDATE students SET
//         student_name = ?, 
//         registration_number = ?, 
//         date_of_birth = ?, 
//         gender = ?, 
//         address = ?, 
//         father_name = ?, 
//         mother_name = ?, 
//         email = ?, 
//         phone = ?, 
//         assigned_class = ?, 
//         assigned_section = ?, 
//         birth_certificate = ?, 
//         student_photo = ?
//       WHERE id = ?
//     `;
  
//     connection.query(updateQuery, [
//       student_name,
//       registration_number,
//       date_of_birth,
//       gender,
//       address,
//       father_name,
//       mother_name,
//       email,
//       phone,
//       assigned_class,
//       assigned_section,
//       birth_certificate,
//       studentPhoto,
//       studentId,
//     ], (err, results) => {
//       if (err) {
//         console.error('Error updating student:', err);
//         return res.status(500).json({ error: 'Failed to update student' });
//       }
//       res.status(200).json({ message: 'Student updated successfully' });
//     });
//   });
  
// // API to delete student
// app.delete('/students/:id', (req, res) => {
//     const studentId = req.params.id;

//     // Step 1: Log studentId for debugging
//     console.log('Attempting to delete student with ID:', studentId);

//     // Step 2: Delete attendance records related to the student
//     const deleteAttendanceQuery = 'DELETE FROM attendance WHERE student_id = ?';
//     connection.query(deleteAttendanceQuery, [studentId], (err) => {
//         if (err) {
//             console.error('Error deleting attendance records:', err);
//             return res.status(500).json({ error: 'Failed to delete attendance records' });
//         }

//         // Step 3: Now, get the student's photo path to delete the file
//         const getStudentQuery = 'SELECT student_photo FROM students WHERE id = ?';
//         connection.query(getStudentQuery, [studentId], (err, results) => {
//             if (err) {
//                 console.error('Error fetching student:', err);
//                 return res.status(500).json({ error: 'Failed to fetch student details' });
//             }

//             if (results.length === 0) {
//                 return res.status(404).json({ error: 'Student not found' });
//             }

//             const studentPhoto = results[0].student_photo;

//             // Step 4: Delete the student from the database
//             const deleteStudentQuery = 'DELETE FROM students WHERE id = ?';
//             connection.query(deleteStudentQuery, [studentId], (err, results) => {
//                 if (err) {
//                     console.error('Error deleting student:', err);
//                     return res.status(500).json({ error: 'Failed to delete student' });
//                 }

//                 // Step 5: If student had a photo, delete the file
//                 if (studentPhoto) {
//                     const photoPath = path.join(__dirname, 'uploads', studentPhoto);
//                     fs.unlink(photoPath, (err) => {
//                         if (err) {
//                             console.error('Error deleting photo file:', err);
//                             // Don't send error response here as the student is already deleted
//                         }
//                     });
//                 }

//                 res.status(200).json({ message: 'Student deleted successfully' });
//             });
//         });
//     });
// });

//   // API to save attendance
// // API to save attendance

// // Get all students in a particular class
// app.get('/students/:class', (req, res) => {
//     const className = decodeURIComponent(req.params.class);  // Decode if there are spaces or special characters
//     const query = 'SELECT * FROM students WHERE assigned_class = ?';

//     connection.query(query, [className], (err, results) => {
//         if (err) {
//             console.error('Error fetching students:', err);
//             return res.status(500).json({ message: 'Internal server error' });
//         }

//         res.json(results);  // Send the list of students in the selected class
//     });
// });

// app.post('/attendance', (req, res) => {
//     const { date, students } = req.body; // { date: '2025-03-08', students: [...] }

//     // Loop through the students and insert attendance
//     students.forEach((student) => {
//         const query = 'INSERT INTO attendance (student_id, date, is_present, class_name) VALUES (?, ?, ?, ?)';
//         connection.query(query, [student.student_id, date, student.is_present, student.class_name], (err, results) => {
//             if (err) {
//                 return res.status(500).json({ error: err.message });
//             }
//         });
//     });

//     // Send success message after processing
//     res.status(200).json({ message: 'Attendance recorded successfully' });
// });

// // Backend: API to get attendance based on class and date student report wala ke liye
// app.get('/attendance/:class/:date', (req, res) => {
//     const className = decodeURIComponent(req.params.class);  // Decode class name
//     const date = req.params.date;  // Date in the format 'yyyy-mm-dd'

//     const query = `
//         SELECT students.student_name, attendance.is_present 
//         FROM attendance 
//         JOIN students ON attendance.student_id = students.id
//         WHERE attendance.class_name = ? AND attendance.date = ?
//     `;

//     connection.query(query, [className, date], (err, results) => {
//         if (err) {
//             console.error('Error fetching attendance:', err);
//             return res.status(500).json({ message: 'Internal server error' });
//         }

//         res.json(results);  // Send the attendance records for the given class and date
//     });
// });



// // Start the server
// app.listen(port, () => {
//     console.log(`Server is running on http://localhost:${port}`);
// });



import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import connection from './mysqlconnectivity.js'; // Assuming this is correctly set up to connect to your MySQL
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import jwt from 'jsonwebtoken'; // Import JWT library

// Setup for file path management
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Initialize Express app
const app = express();
const port = 1000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Serve static files from the uploads directory - Fix the path to be absolute
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// File filter for validating uploaded files
const fileFilter = (req, file, cb) => {
    console.log('File details:', {
        fieldname: file.fieldname,
        mimetype: file.mimetype,
        originalname: file.originalname,
        size: file.size
    });

    if (file.fieldname === 'student_photo') {
        const allowedExtensions = ['.jpg', '.jpeg', '.png'];
        const fileExtension = path.extname(file.originalname).toLowerCase();
        if (allowedExtensions.includes(fileExtension)) {
            cb(null, true);
        } else {
            cb(new Error('Only JPG, JPEG, and PNG files are allowed for student photo.'), false);
        }
    } else if (file.fieldname === 'birth_certificate') {
        const fileExtension = path.extname(file.originalname).toLowerCase();
        if (fileExtension === '.pdf') {
            cb(null, true);
        } else {
            cb(new Error('Only PDF files are allowed for birth certificate.'), false);
        }
    } else {
        cb(new Error('Unexpected field'), false);
    }
};

// Multer setup with storage and file filter
const upload = multer({
    storage: multer.diskStorage({
        destination: (req, file, cb) => {
            const uploadDir = path.join(__dirname, 'uploads');
            if (!fs.existsSync(uploadDir)) {
                fs.mkdirSync(uploadDir, { recursive: true });
            }
            cb(null, uploadDir);
        },
        filename: (req, file, cb) => {
            const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
            cb(null, uniqueSuffix + '-' + file.originalname);
        }
    }),
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB file size limit
    fileFilter: fileFilter
}).fields([
    { name: 'student_photo', maxCount: 1 },
    { name: 'birth_certificate', maxCount: 1 }
]);

// Error handling for multer file upload errors
app.use((err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        return res.status(400).send(`Multer error: ${err.message}`);
    }
    if (err) {
        return res.status(500).send(`Error: ${err.message}`);
    }
    next();
});

// JWT Secret Key (store this securely in environment variables in production)
const JWT_SECRET = 'Pass1212';

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']; // Get the token from the request header

    if (!token) {
        return res.status(403).json({ success: false, message: 'No token provided' });
    }

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ success: false, message: 'Invalid or expired token' });
        }

        req.user_email = decoded.email; // Attach the user's email to the request object
        next(); // Proceed to the next middleware or route handler
    });
};

// Login Endpoint
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    const query = 'SELECT * FROM signup WHERE email = ? AND password = ?';
    connection.query(query, [email, password], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ success: false, message: 'Server error' });
        }
        if (results.length > 0) {
            // Generate a JWT token
            const token = jwt.sign(
                { email: results[0].email }, // Payload (store the user's email in the token)
                JWT_SECRET, // Secret key
                { expiresIn: '1h' } // Token expiration time
            );

            return res.json({ 
                success: true, 
                message: 'Login successful', 
                token: token // Send the token to the client
            });
        } else {
            return res.status(400).json({ success: false, message: 'Invalid Credentials' });
        }
    });
});

// Register Endpoint
app.post('/register', (req, res) => {
    const { email, phone, password, confirmpassword, role } = req.body;

    // Validate inputs
    if (!email || !phone || !password || !confirmpassword || !role) {
        return res.status(400).json({ success: false, message: 'Invalid Credentials' });
    }

    // Check if email already exists
    const checkEmailQuery = 'SELECT * FROM signup WHERE email = ?';
    connection.query(checkEmailQuery, [email], (err, results) => {
        if (err) {
            console.error('Error checking email:', err);
            return res.status(500).json({ success: false, message: 'Server error' });
        }

        if (results.length > 0) {
            // Email already exists
            return res.status(400).json({
                success: false,
                message: 'Email already exists'
            });
        }

        // Insert new user with role
        const query = 'INSERT INTO signup (email, phone, password, confirmpassword, role) VALUES (?, ?, ?, ?, ?)';
        connection.query(query, [email, phone, password, confirmpassword, role], (err, results) => {
            if (err) {
                console.error('Error inserting user:', err);
                return res.status(500).json({ success: false, message: 'Server error' });
            }

            res.status(200).json({
                success: true,
                message: 'User registered successfully'
            });
        });
    });
});

// POST API for student registration (protected route)
app.post('/registerstudent', verifyToken, upload, async (req, res) => {
    console.log('Uploaded files:', req.files);

    const { student_name, registration_number, date_of_birth, gender, address, father_name, mother_name, email, phone, assigned_class, assigned_section } = req.body;
    const user_email = req.user_email; // Get the user's email from the token

    // Initialize file paths as null
    let studentPhotoPath = null;
    let birthCertificatePath = null;

    try {
        // If student photo is uploaded
        if (req.files['student_photo']) {
            // Store only the filename without 'uploads' prefix
            studentPhotoPath = path.basename(req.files['student_photo'][0].path);
        }

        // If birth certificate is uploaded
        if (req.files['birth_certificate']) {
            // Store only the filename without 'uploads' prefix
            birthCertificatePath = path.basename(req.files['birth_certificate'][0].path);
        }

        // SQL query to insert student data with file paths
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
            user_email // Add the user's email from the token
        ], (err, results) => {
            if (err) {
                console.error('Error registering student:', err);
                return res.status(500).send('Error registering student');
            }

            res.status(200).send('Student registered successfully');
        });
    } catch (error) {
        console.error('Error processing files:', error);
        res.status(500).send('Error processing files');
    }
});

// Get all students (protected route)
app.get('/students', verifyToken, (req, res) => {
    const user_email = req.user_email; // Get the user's email from the token

    const query = 'SELECT * FROM students WHERE user_email = ?';
    connection.query(query, [user_email], (err, results) => {
        if (err) {
            console.error('Error fetching students:', err);
            return res.status(500).json({ message: 'Internal server error' });
        }

        // Normalize paths in the results
        const normalizedResults = results.map(student => ({
            ...student,
            student_photo: student.student_photo ? 
                path.basename(student.student_photo.replace(/\\/g, '/')) : null,
            birth_certificate: student.birth_certificate ? 
                path.basename(student.birth_certificate.replace(/\\/g, '/')) : null
        }));

        res.json(normalizedResults);
    });
});
// API to update student details
app.put('/students/:id',verifyToken, upload, (req, res) => {
    const studentId = req.params.id;
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
    } = req.body;

    // Handle photo upload
    let studentPhoto = req.body.student_photo; // Keep existing photo if not updated
    if (req.files && req.files['student_photo']) {
      studentPhoto = path.basename(req.files['student_photo'][0].path);
    }
  
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
      studentPhoto,
      studentId,
    ], (err, results) => {
      if (err) {
        console.error('Error updating student:', err);
        return res.status(500).json({ error: 'Failed to update student' });
      }
      res.status(200).json({ message: 'Student updated successfully' });
    });
  });
  
// API to delete student
app.delete('/students/:id',verifyToken, (req, res) => {
    const studentId = req.params.id;

    // Step 1: Log studentId for debugging
    console.log('Attempting to delete student with ID:', studentId);

    // Step 2: Delete attendance records related to the student
    const deleteAttendanceQuery = 'DELETE FROM attendance WHERE student_id = ?';
    connection.query(deleteAttendanceQuery, [studentId], (err) => {
        if (err) {
            console.error('Error deleting attendance records:', err);
            return res.status(500).json({ error: 'Failed to delete attendance records' });
        }

        // Step 3: Now, get the student's photo path to delete the file
        const getStudentQuery = 'SELECT student_photo FROM students WHERE id = ?';
        connection.query(getStudentQuery, [studentId], (err, results) => {
            if (err) {
                console.error('Error fetching student:', err);
                return res.status(500).json({ error: 'Failed to fetch student details' });
            }

            if (results.length === 0) {
                return res.status(404).json({ error: 'Student not found' });
            }

            const studentPhoto = results[0].student_photo;

            // Step 4: Delete the student from the database
            const deleteStudentQuery = 'DELETE FROM students WHERE id = ?';
            connection.query(deleteStudentQuery, [studentId], (err, results) => {
                if (err) {
                    console.error('Error deleting student:', err);
                    return res.status(500).json({ error: 'Failed to delete student' });
                }

                // Step 5: If student had a photo, delete the file
                if (studentPhoto) {
                    const photoPath = path.join(__dirname, 'uploads', studentPhoto);
                    fs.unlink(photoPath, (err) => {
                        if (err) {
                            console.error('Error deleting photo file:', err);
                            // Don't send error response here as the student is already deleted
                        }
                    });
                }

                res.status(200).json({ message: 'Student deleted successfully' });
            });
        });
    });
});

  // API to save attendance
// API to save attendance

// Get all students in a particular class
// Get all students in a particular class for the logged-in user
app.get('/students/:class', verifyToken, (req, res) => {
    const className = decodeURIComponent(req.params.class);  // Decode if there are spaces or special characters
    const user_email = req.user_email; // Get the user's email from the token

    const query = 'SELECT * FROM students WHERE assigned_class = ? AND user_email = ?';

    connection.query(query, [className, user_email], (err, results) => {
        if (err) {
            console.error('Error fetching students:', err);
            return res.status(500).json({ message: 'Internal server error' });
        }

        res.json(results);  // Send the list of students in the selected class for the logged-in user
    });
});
app.post('/attendance', verifyToken, (req, res) => {
    const { date, students } = req.body; // { date: '2025-03-08', students: [...] }

    // Loop through the students and insert attendance
    students.forEach((student) => {
        const query = `
            INSERT INTO attendance (student_id, date, is_present, class_name) 
            VALUES (?, ?, ?, ?)
        `;
        connection.query(query, [student.student_id, date, student.is_present, student.class_name], (err, results) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
        });
    });

    // Send success message after processing
    res.status(200).json({ message: 'Attendance recorded successfully' });
});
// Backend: API to get attendance based on class and date student report wala ke liye
app.get('/attendance/:class/:date', verifyToken, (req, res) => {
    const className = decodeURIComponent(req.params.class);  // Decode class name
    const date = req.params.date;  // Date in the format 'yyyy-mm-dd'
    const user_email = req.user_email; // Get the user's email from the token

    const query = `
        SELECT students.student_name, attendance.is_present 
        FROM attendance 
        JOIN students ON attendance.student_id = students.id
        WHERE attendance.class_name = ? 
          AND attendance.date = ?
          AND students.user_email = ?
    `;

    connection.query(query, [className, date, user_email], (err, results) => {
        if (err) {
            console.error('Error fetching attendance:', err);
            return res.status(500).json({ message: 'Internal server error' });
        }

        res.json(results);  // Send the attendance records for the given class, date, and user
    });
});

app.get('/api/students/count', async (req, res) => {
    try {
      const query = 'SELECT COUNT(*) as totalStudents FROM students';
      connection.query(query, (err, results) => {
        if (err) {
          console.error('Error fetching student count:', err);
          return res.status(500).json({ error: 'Failed to fetch student count' });
        }
        res.json({ totalStudents: results[0].totalStudents });
      });
    } catch (error) {
      console.error('Error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });
// Start the server
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});