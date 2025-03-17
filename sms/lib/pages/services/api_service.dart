import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // API URLs
  // API URLs
  // 192.168.148.213
  static const String apiUrlRegister =
      'http://localhost:1000/api/auth/register';
  static const String apiUrlLogin = 'http://localhost:1000/api/auth/login';
  static const String apiUrlRegisterStudent =
      'http://localhost:1000/api/registerstudent';
  static const String apiUrlRegisterTeacher =
      'http://localhost:1000/api/registerteacher';

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

      var uri = Uri.parse('http://localhost:1000/api/registerstudent');
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

  static Future<bool> registerTeacher({
    required String teacherName,
    required String email,
    required String dob,
    required String doj,
    required String gender,
    required String guardian_name,
    required String qualification,
    required String experience,
    required String salary,
    required String address,
    required String phone,
    required dynamic teacherPhoto,
    required dynamic qualificationCertificate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Retrieve the token

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      var uri = Uri.parse(apiUrlRegisterTeacher);
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = token;

      // Add text fields
      request.fields['teacher_name'] = teacherName;
      request.fields['email'] = email;
      request.fields['date_of_birth'] = dob; // Use formatted DOB
      request.fields['date_of_joining'] = doj; // Use formatted DOJ
      request.fields['gender'] = gender;
      request.fields['guardian_name'] = guardian_name;
      request.fields['qualification'] = qualification;
      request.fields['experience'] = experience;
      request.fields['salary'] = salary;
      request.fields['address'] = address;
      request.fields['phone'] = phone;

      // Add files (teacher photo)
      if (teacherPhoto is File) {
        var photoStream = http.ByteStream(teacherPhoto.openRead());
        var photoLength = await teacherPhoto.length();
        var photoMultipart = http.MultipartFile(
          'teacher_photo',
          photoStream,
          photoLength,
          filename: teacherPhoto.path.split('/').last,
        );
        request.files.add(photoMultipart);
      } else if (teacherPhoto is Uint8List) {
        var photoMultipart = http.MultipartFile.fromBytes(
          'teacher_photo',
          teacherPhoto,
          filename: 'teacher_photo.jpg',
        );
        request.files.add(photoMultipart);
      }

      // Add files (qualification certificate)
      if (qualificationCertificate is File) {
        var qualificationCertStream =
            http.ByteStream(qualificationCertificate.openRead());
        var qualificationCertLength = await qualificationCertificate.length();
        var qualificationCertMultipart = http.MultipartFile(
          'qualification_certificate',
          qualificationCertStream,
          qualificationCertLength,
          filename: qualificationCertificate.path.split('/').last,
        );
        request.files.add(qualificationCertMultipart);
      } else if (qualificationCertificate is Uint8List) {
        var qualificationCertMultipart = http.MultipartFile.fromBytes(
          'qualification_certificate',
          qualificationCertificate,
          filename: 'qualification_certificate.pdf',
        );
        request.files.add(qualificationCertMultipart);
      }

      // Send request
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to register teacher: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during teacher registration: $e');
      rethrow;
    }
  }
}
