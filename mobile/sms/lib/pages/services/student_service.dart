// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/student/student_registration/student_registration_controller.dart';
// import 'api_base.dart';

// class StudentService {
//   static final String apiUrlRegisterStudent =
//       '${ApiBase.baseUrl}/api/registerstudent';

//   static Future<Map<String, dynamic>> registerStudent({
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
//       final token = await ApiBase.getToken();
//       if (token == null) throw Exception('No token found. Please log in.');

//       final credentials = StudentRegistrationController()
//           .generateCredentials(studentName, registrationNumber);
//       final username = credentials['username'];
//       final password = credentials['password'];

//       var request =
//           http.MultipartRequest('POST', Uri.parse(apiUrlRegisterStudent));
//       request.headers['Authorization'] = token;

//       request.fields['student_name'] = studentName;
//       request.fields['registration_number'] = registrationNumber;
//       request.fields['date_of_birth'] = dob;
//       request.fields['gender'] = gender;
//       request.fields['address'] = address;
//       request.fields['father_name'] = fatherName;
//       request.fields['mother_name'] = motherName;
//       request.fields['email'] = email;
//       request.fields['phone'] = phone;
//       request.fields['assigned_class'] = assignedClass;
//       request.fields['assigned_section'] = assignedSection;
//       request.fields['username'] = username!;
//       request.fields['password'] = password!;

//       if (studentPhoto is File) {
//         var photoStream = http.ByteStream(studentPhoto.openRead());
//         var photoLength = await studentPhoto.length();
//         request.files.add(http.MultipartFile(
//           'student_photo',
//           photoStream,
//           photoLength,
//           filename: studentPhoto.path.split('/').last,
//         ));
//       } else if (studentPhoto is Uint8List) {
//         request.files.add(http.MultipartFile.fromBytes(
//           'student_photo',
//           studentPhoto,
//           filename: 'student_photo.jpg',
//         ));
//       }

//       if (birthCertificate is File) {
//         var certStream = http.ByteStream(birthCertificate.openRead());
//         var certLength = await birthCertificate.length();
//         request.files.add(http.MultipartFile(
//           'birth_certificate',
//           certStream,
//           certLength,
//           filename: birthCertificate.path.split('/').last,
//         ));
//       } else if (birthCertificate is Uint8List) {
//         request.files.add(http.MultipartFile.fromBytes(
//           'birth_certificate',
//           birthCertificate,
//           filename: 'birth_certificate.pdf',
//         ));
//       }

//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final jsonResponse = jsonDecode(responseBody);
//         return {
//           'success': true,
//           'data': jsonResponse['data'],
//           'message': jsonResponse['message'],
//         };
//       } else {
//         final errorResponse = jsonDecode(responseBody);
//         throw Exception(
//             errorResponse['message'] ?? 'Failed to register student');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   static Future<String?> getLastRegistrationNumber() async {
//     try {
//       final token = await ApiBase.getToken();
//       if (token == null) return null;

//       final response = await http.get(
//         Uri.parse('${ApiBase.baseUrl}/api/last-registration-number'),
//         headers: {
//           'Authorization': token,
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['lastRegistrationNumber']?.toString();
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getStudentCountByClass() async {
//     try {
//       final token = await ApiBase.getToken();
//       if (token == null) throw Exception('Authentication required');

//       final response = await http.get(
//         Uri.parse('${ApiBase.baseUrl}/api/students/count-by-class'),
//         headers: {
//           'Authorization': token,
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData is Map && responseData['data'] is List) {
//           return (responseData['data'] as List).cast<Map<String, dynamic>>();
//         }
//         return [];
//       } else {
//         throw Exception('Failed with status ${response.statusCode}');
//       }
//     } catch (e) {
//       return [];
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sms/pages/student/student_registration/student_registration_controller.dart';
import 'package:sms/pages/services/api_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sms/pages/student/student_details/student_model.dart';

class StudentService {
  static final String baseUrl = ApiBase.baseUrl;
  static final String apiUrlRegisterStudent = '$baseUrl/api/registerstudent';

  /// --------------------------------
  /// 🔑 Get Token from SharedPreferences
  /// --------------------------------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// --------------------------------
  /// 📄 Fetch all Students
  /// --------------------------------
  Future<List<Student>> fetchStudents() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found. Please log in.');

    final response = await http.get(
      Uri.parse('$baseUrl/api/students'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Student.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load students: ${response.statusCode}');
    }
  }

  /// --------------------------------
  /// ✏️ Update Student
  /// --------------------------------
  Future<void> updateStudent(
      Student student, Map<String, dynamic> updatedData) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found. Please log in.');

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/api/students/${student.id}'),
    );

    request.headers['Authorization'] = token;
    request.headers['Accept'] = 'application/json';

    // Add text fields
    updatedData.forEach((key, value) {
      if (key != 'student_photo') {
        request.fields[key] = value.toString();
      }
    });

    // Handle student photo (mobile or web)
    if (updatedData['student_photo'] != null &&
        updatedData['student_photo'] != student.studentPhoto) {
      if (kIsWeb) {
        final bytes = base64Decode(updatedData['student_photo']);
        request.files.add(http.MultipartFile.fromBytes(
          'student_photo',
          bytes,
          filename: 'student_photo.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'student_photo',
          updatedData['student_photo'],
        ));
      }
    } else {
      request.fields['student_photo'] = student.studentPhoto;
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Failed to update student: $responseBody');
    }
  }

  /// --------------------------------
  /// ❌ Delete Student
  /// --------------------------------
  Future<void> deleteStudent(String studentId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found. Please log in.');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/students/$studentId'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete student: ${response.statusCode}');
    }
  }

  /// --------------------------------
  /// 📝 Register Student
  /// --------------------------------
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
      final token = await ApiBase.getToken();
      if (token == null) throw Exception('No token found. Please log in.');

      final credentials = StudentRegistrationController()
          .generateCredentials(studentName, registrationNumber);
      final username = credentials['username'];
      final password = credentials['password'];

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrlRegisterStudent),
      );
      request.headers['Authorization'] = token;

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

      if (studentPhoto is File) {
        var stream = http.ByteStream(studentPhoto.openRead());
        var length = await studentPhoto.length();
        request.files.add(http.MultipartFile(
          'student_photo',
          stream,
          length,
          filename: studentPhoto.path.split('/').last,
        ));
      } else if (studentPhoto is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(
          'student_photo',
          studentPhoto,
          filename: 'student_photo.jpg',
        ));
      }

      if (birthCertificate is File) {
        var stream = http.ByteStream(birthCertificate.openRead());
        var length = await birthCertificate.length();
        request.files.add(http.MultipartFile(
          'birth_certificate',
          stream,
          length,
          filename: birthCertificate.path.split('/').last,
        ));
      } else if (birthCertificate is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(
          'birth_certificate',
          birthCertificate,
          filename: 'birth_certificate.pdf',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(responseBody);
        return {
          'success': true,
          'data': jsonResponse['data'],
          'message': jsonResponse['message'],
        };
      } else {
        final error = jsonDecode(responseBody);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// --------------------------------
  /// 🔢 Get Last Registration Number
  /// --------------------------------
  static Future<String?> getLastRegistrationNumber() async {
    try {
      final token = await ApiBase.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/last-registration-number'),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['lastRegistrationNumber']?.toString();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// --------------------------------
  /// 📊 Get Student Count by Class
  /// --------------------------------
  static Future<List<Map<String, dynamic>>> getStudentCountByClass() async {
    try {
      final token = await ApiBase.getToken();
      if (token == null) throw Exception('Authentication required');

      final response = await http.get(
        Uri.parse('$baseUrl/api/students/count-by-class'),
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          return (responseData['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
}
