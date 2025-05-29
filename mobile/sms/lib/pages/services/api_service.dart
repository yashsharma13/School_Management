import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/student/student_registration/student_registration_controller.dart';

class ApiService {
  // API URLs
  // use ipconfig to check niche wala jo url hai vo localhost ki jagh use krna hai agar phone mein use krna hai toh
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
        // print('Registration failed with status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      // print('Error: $error');
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      // First try regular user login (for operators/admins/teachers)
      final response = await http.post(
        Uri.parse(apiUrlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Decode the JWT token to get user information
          final token = responseData['token'];
          final decodedToken = _decodeJwt(token);

          return {
            'success': true,
            'token': token,
            'role': responseData['role'],
            'user_email': decodedToken['user_email'] ?? decodedToken['email'],
            'user_id': decodedToken['user_id'],
          };
        }
      }

      // If regular login fails, try student login
      if (!username.contains('@')) {
        final studentResponse = await _attemptStudentLogin(username, password);
        if (studentResponse['success'] == true) {
          // Decode student JWT token
          final token = studentResponse['token'];
          final decodedToken = _decodeJwt(token);

          return {
            'success': true,
            'token': token,
            'role': studentResponse['role'],
            'user_email': decodedToken['user_email'] ?? decodedToken['email'],
            'user_id': decodedToken['user_id'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Invalid username/email or password'
      };
    } catch (error) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

// Helper function to decode JWT token
  static Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded);
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> _attemptStudentLogin(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'token': responseData['token'],
            'role': responseData['role'],
          };
        }
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> registerStudent({
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
// Generate username and password
      final StudentRegistrationController tempController =
          StudentRegistrationController();
      final credentials =
          tempController.generateCredentials(studentName, registrationNumber);
      final username = credentials['username'];
      final password = credentials['password'];
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
      request.fields['username'] = username!;
      request.fields['password'] = password!;

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
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'data': jsonResponse['data'],
          'message': jsonResponse['message'],
        };
      } else {
        final errorResponse = jsonDecode(responseBody);
        throw Exception(
            errorResponse['message'] ?? 'Failed to register student');
      }
    } catch (e) {
      // print('Error during student registration: $e');
      rethrow;
    }
  }

  static Future<String?> getLastRegistrationNumber() async {
    try {
      // print("Fetching last registration number..."); // Debug print

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        // print("No token found");
        return null;
      }

      final uri =
          Uri.parse('http://localhost:1000/api/last-registration-number');
      // print("Request URL: $uri"); // Debug print

      final response = await http.get(
        uri,
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      // // print("Response status: ${response.statusCode}"); // Debug print
      // print("Response body: ${response.body}"); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['lastRegistrationNumber']?.toString();
      } else {
        // print("Error response: ${response.body}");
        return null;
      }
    } catch (e) {
      // print("Error in getLastRegistrationNumber: $e"); // Detailed error print
      return null;
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
      // print('Error during teacher registration: $e');
      rethrow;
    }
  }

  static const String apiUrlRegisterClass = 'http://localhost:1000/api/classes';
  static Future<bool> registerClass({
    required String className,
    required String section,
    required String tuitionFees,
    required String teacherName, // Changed parameter name
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      final response = await http.post(
        Uri.parse(apiUrlRegisterClass),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({
          'class_name': className,
          'section': section,
          'tuition_fees': tuitionFees,
          'teacher_name': teacherName, // Match backend expectation
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to register class');
      }
    } catch (e) {
      // print('Error during class registration: $e');
      rethrow;
    }
  }

  static const String baseUrl = 'http://localhost:1000/api';

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch all classes for the logged-in user
  static Future<List<Map<String, dynamic>>> fetchClasses() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token, // Include the token in the header
        },
      );
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((classData) => classData as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching classes: $e');
    }
  }

  static Future<bool> updateClass({
    required String classId,
    required String className,
    required String tuitionFees,
    required String teacherName,
  }) async {
    try {
      // print('[DEBUG] Starting updateClass with ID: $classId'); // Add this

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is not available.');
      }

      if (classId.isEmpty) {
        throw Exception('Class ID cannot be empty');
      }

      // Use const for baseUrl to prevent accidental modification
      const String baseUrl = 'http://localhost:1000/api';
      final url = '$baseUrl/classes/$classId';

      // print('[DEBUG] Full update URL: $url'); // Add this

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({
          'class_name': className,
          'tuition_fees': tuitionFees,
          'teacher_name': teacherName,
        }),
      );

      // print('[DEBUG] Update response: ${response.statusCode}'); // Add this
      // print('[DEBUG] Response body: ${response.body}'); // Add this

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Update failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // print('[ERROR] in updateClass: $error');
      rethrow;
    }
  }

  static Future<bool> deleteClass(String classId) async {
    try {
      // print('[DEBUG] Starting deleteClass with ID: $classId'); // Add this

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is not available.');
      }

      if (classId.isEmpty) {
        throw Exception('Class ID cannot be empty');
      }

      const String baseUrl = 'http://localhost:1000/api';
      final url = '$baseUrl/classes/$classId';

      // print('[DEBUG] Full delete URL: $url'); // Add this

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      // print('[DEBUG] Delete response: ${response.statusCode}'); // Add this
      // print('[DEBUG] Response body: ${response.body}'); // Add this

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Delete failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // print('[ERROR] in deleteClass: $error');
      rethrow;
    }
  }

  static const String apiUrlRegisterSubject =
      'http://localhost:1000/api/registersubject';

  static Future<bool> registerSubject({
    required String className,
    required String section,
    required List<Map<String, dynamic>> subjectsData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      // Prepare comma-separated subject names and marks
      String subjectNames =
          subjectsData.map((subject) => subject['subject_name']).join(', ');
      String marks = subjectsData.map((subject) => subject['marks']).join(', ');

      final response = await http.post(
        Uri.parse(apiUrlRegisterSubject),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({
          'class_name': className,
          'section': section,
          'subject_name': subjectNames, // Send comma-separated subject names
          'marks': marks, // Send comma-separated marks
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to register subject');
      }
    } catch (e) {
      // print('Error during subject registration: $e');
      rethrow;
    }
  }

  static const String apiUrlgetSubject =
      'http://localhost:1000/api/getallsubjects';
  static Future<List<dynamic>> fetchClassesWithSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      final response = await http.get(
        Uri.parse(apiUrlgetSubject),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Ensure data is a list
        final data = responseBody['data'];
        if (data is List) {
          return data;
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load classes with subjects',
        );
      }
    } catch (e) {
      // print('Error fetching classes with subjects: $e');
      rethrow;
    }
  }

  static const String apiUrlUpdateSubject =
      'http://localhost:1000/api/updatesubject';

  static Future<bool> updateSubject({
    required String subjectId,
    required List<Map<String, dynamic>> subjectsData,
  }) async {
    try {
      // print('[DEBUG] Starting updateSubject with ID: $subjectId');

      // 1. Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      if (subjectId.isEmpty) {
        throw Exception('Subject ID cannot be empty');
      }

      // 2. Prepare the request
      // print('[DEBUG] Full update URL: $apiUrlUpdateSubject');
      // print('[DEBUG] Request payload: ${{
      //   'subject_id': subjectId,
      //   'subjects': subjectsData
      // }}');

      // 3. Make the request
      final response = await http.put(
        Uri.parse(apiUrlUpdateSubject),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, // Important: Add Bearer prefix
        },
        body: json.encode({
          'subject_id': subjectId,
          'subjects': subjectsData,
        }),
      );

      // 4. Handle response
      // print('[DEBUG] Response status: ${response.statusCode}');
      // print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to update subject: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // print('[ERROR] in updateSubject: $e');
      rethrow;
    }
  }

  static const String apiUrlDeleteSubject =
      'http://localhost:1000/api/deletesubject';

  static Future<bool> deleteSubject(String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$apiUrlDeleteSubject/$subjectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, // Add Bearer if required by backend
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete subjects');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>>
      modelgetStudentCountByClass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = '$baseUrl/api/students/count-by-class';
      // print('Fetching counts from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle the response format
        if (responseData is Map && responseData['data'] is List) {
          return (responseData['data'] as List).cast<Map<String, dynamic>>();
        }
        return []; // Return empty list if format unexpected
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (e) {
      // print('Error in modelgetStudentCountByClass: $e');
      return []; // Return empty list on error
    }
  }
}
