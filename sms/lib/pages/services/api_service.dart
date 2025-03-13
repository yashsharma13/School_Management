// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;

// class ApiService {
//   // API URLs
//   // 192.168.148.213
//   //localhost
//   static const String apiUrlRegister = 'http://localhost:1000/register';
//   static const String apiUrlLogin = 'http://localhost:1000/login';
//   static const String apiUrlRegisterStudent =
//       'http://localhost:1000/registerstudent';

//   // Register user
//   static Future<bool> register(String email, String phone, String password,
//       String confirmpassword, String selectedRole) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrlRegister),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'phone': phone,
//           'password': password,
//           'confirmpassword': confirmpassword,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return responseData['success'] ?? false; // Return success status
//       } else {
//         print('Registration failed with status code: ${response.statusCode}');
//         return false;
//       }
//     } catch (error) {
//       print('Error: $error');
//       return false;
//     }
//   }

//   // User login
//   static Future<bool> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrlLogin),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return responseData['success'] ?? false;
//       } else {
//         return false;
//       }
//     } catch (error) {
//       print('Error: $error');
//       return false;
//     }
//   }

// // Register Student with Files (Student Photo, Birth Certificate)

//   static Future<bool> registerStudent({
//     required String studentName,
//     required String registrationNumber,
//     required String dob,
//     required String gender,
//     required String address,
//     required String fatherName,
//     required String motherName,
//     required String email,
//     required String phone,
//     required String assignedClass,
//     required String assignedSection,
//     required dynamic studentPhoto,
//     required dynamic birthCertificate,
//   }) async {
//     try {
//       var uri = Uri.parse(apiUrlRegisterStudent);
//       var request = http.MultipartRequest('POST', uri);

//       // Debug print
//       print('Sending date of birth: $dob');

//       // Add text fields
//       request.fields['student_name'] = studentName;
//       request.fields['registration_number'] = registrationNumber;
//       request.fields['date_of_birth'] =
//           dob; // Changed from 'dob' to 'date_of_birth' to match backend
//       request.fields['gender'] = gender;
//       request.fields['address'] = address;
//       request.fields['father_name'] = fatherName;
//       request.fields['mother_name'] = motherName;
//       request.fields['email'] = email;
//       request.fields['phone'] = phone;
//       request.fields['assigned_class'] = assignedClass;
//       request.fields['assigned_section'] = assignedSection;

//       // Add files (student photo)
//       if (studentPhoto is File) {
//         var photoStream = http.ByteStream(studentPhoto.openRead());
//         var photoLength = await studentPhoto.length();
//         var photoMultipart = http.MultipartFile(
//             'student_photo', photoStream, photoLength,
//             filename: studentPhoto.path.split('/').last);
//         request.files.add(photoMultipart);
//       } else if (studentPhoto is Uint8List) {
//         var photoMultipart = http.MultipartFile.fromBytes(
//             'student_photo', studentPhoto,
//             filename: 'student_photo.jpg');
//         request.files.add(photoMultipart);
//       }

//       // Add files (birth certificate)
//       if (birthCertificate is File) {
//         var birthCertStream = http.ByteStream(birthCertificate.openRead());
//         var birthCertLength = await birthCertificate.length();
//         var birthCertMultipart = http.MultipartFile(
//             'birth_certificate', birthCertStream, birthCertLength,
//             filename: birthCertificate.path.split('/').last);
//         request.files.add(birthCertMultipart);
//       } else if (birthCertificate is Uint8List) {
//         var birthCertMultipart = http.MultipartFile.fromBytes(
//             'birth_certificate', birthCertificate,
//             filename: 'birth_certificate.pdf');
//         request.files.add(birthCertMultipart);
//       }

//       // Send request
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print('Error during student registration: $e');
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // API URLs
  static const String apiUrlRegister = 'http://localhost:1000/register';
  static const String apiUrlLogin = 'http://localhost:1000/login';
  static const String apiUrlRegisterStudent =
      'http://localhost:1000/registerstudent';

  // Register user with role
  static Future<bool> register(String email, String phone, String password,
      String confirmpassword, String selectedRole) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlRegister),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'password': password,
          'confirmpassword': confirmpassword,
          'role': selectedRole, // Include role here
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? false; // Return success status
      } else {
        print('Registration failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  // User login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'token': responseData['token'], // Return the token
          };
        } else {
          return {'success': false, 'message': 'Invalid Credentials'};
        }
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (error) {
      print('Error: $error');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // Register Student with Files (Student Photo, Birth Certificate)
//   static Future<bool> registerStudent({
//     required String studentName,
//     required String registrationNumber,
//     required String dob,
//     required String gender,
//     required String address,
//     required String fatherName,
//     required String motherName,
//     required String email,
//     required String phone,
//     required String assignedClass,
//     required String assignedSection,
//     required dynamic studentPhoto,
//     required dynamic birthCertificate,
//   }) async {
//     try {
//       var uri = Uri.parse(apiUrlRegisterStudent);
//       var request = http.MultipartRequest('POST', uri);

//       // Add text fields
//       request.fields['student_name'] = studentName;
//       request.fields['registration_number'] = registrationNumber;
//       request.fields['date_of_birth'] =
//           dob; // Changed from 'dob' to 'date_of_birth' to match backend
//       request.fields['gender'] = gender;
//       request.fields['address'] = address;
//       request.fields['father_name'] = fatherName;
//       request.fields['mother_name'] = motherName;
//       request.fields['email'] = email;
//       request.fields['phone'] = phone;
//       request.fields['assigned_class'] = assignedClass;
//       request.fields['assigned_section'] = assignedSection;

//       // Add files (student photo)
//       if (studentPhoto is File) {
//         var photoStream = http.ByteStream(studentPhoto.openRead());
//         var photoLength = await studentPhoto.length();
//         var photoMultipart = http.MultipartFile(
//             'student_photo', photoStream, photoLength,
//             filename: studentPhoto.path.split('/').last);
//         request.files.add(photoMultipart);
//       } else if (studentPhoto is Uint8List) {
//         var photoMultipart = http.MultipartFile.fromBytes(
//             'student_photo', studentPhoto,
//             filename: 'student_photo.jpg');
//         request.files.add(photoMultipart);
//       }

//       // Add files (birth certificate)
//       if (birthCertificate is File) {
//         var birthCertStream = http.ByteStream(birthCertificate.openRead());
//         var birthCertLength = await birthCertificate.length();
//         var birthCertMultipart = http.MultipartFile(
//             'birth_certificate', birthCertStream, birthCertLength,
//             filename: birthCertificate.path.split('/').last);
//         request.files.add(birthCertMultipart);
//       } else if (birthCertificate is Uint8List) {
//         var birthCertMultipart = http.MultipartFile.fromBytes(
//             'birth_certificate', birthCertificate,
//             filename: 'birth_certificate.pdf');
//         request.files.add(birthCertMultipart);
//       }

//       // Send request
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       print('Error during student registration: $e');
//       return false;
//     }
//   }
// }
  static Future<bool> registerStudent({
    required String studentName,
    required String registrationNumber,
    required String dob,
    required String gender,
    required String address,
    required String fatherName,
    required String motherName,
    required String email,
    required String phone,
    required String assignedClass,
    required String assignedSection,
    required dynamic studentPhoto,
    required dynamic birthCertificate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Retrieve the token

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      var uri = Uri.parse('http://localhost:1000/registerstudent');
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] =
          token; // Include the token in the header

      // Add text fields
      request.fields['student_name'] = studentName;
      request.fields['registration_number'] = registrationNumber;
      request.fields['date_of_birth'] = dob;
      request.fields['gender'] = gender;
      request.fields['address'] = address;
      request.fields['father_name'] = fatherName;
      request.fields['mother_name'] = motherName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['assigned_class'] = assignedClass;
      request.fields['assigned_section'] = assignedSection;

      // Add files (student photo)
      if (studentPhoto is File) {
        var photoStream = http.ByteStream(studentPhoto.openRead());
        var photoLength = await studentPhoto.length();
        var photoMultipart = http.MultipartFile(
          'student_photo',
          photoStream,
          photoLength,
          filename: studentPhoto.path.split('/').last,
        );
        request.files.add(photoMultipart);
      } else if (studentPhoto is Uint8List) {
        var photoMultipart = http.MultipartFile.fromBytes(
          'student_photo',
          studentPhoto,
          filename: 'student_photo.jpg',
        );
        request.files.add(photoMultipart);
      }

      // Add files (birth certificate)
      if (birthCertificate is File) {
        var birthCertStream = http.ByteStream(birthCertificate.openRead());
        var birthCertLength = await birthCertificate.length();
        var birthCertMultipart = http.MultipartFile(
          'birth_certificate',
          birthCertStream,
          birthCertLength,
          filename: birthCertificate.path.split('/').last,
        );
        request.files.add(birthCertMultipart);
      } else if (birthCertificate is Uint8List) {
        var birthCertMultipart = http.MultipartFile.fromBytes(
          'birth_certificate',
          birthCertificate,
          filename: 'birth_certificate.pdf',
        );
        request.files.add(birthCertMultipart);
      }

      // Send request
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to register student: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during student registration: $e');
      rethrow;
    }
  }
}
