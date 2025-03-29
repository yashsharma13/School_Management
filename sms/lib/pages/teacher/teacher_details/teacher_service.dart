import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'teacher_model.dart';

const String baseUrl = 'http://localhost:1000/api';

class TeacherService {
  // Helper method to get the JWT token from shared_preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Retrieve the token
  }

  // Fetch all students for the logged-in user
  Future<List<Teacher>> fetchTeachers() async {
    final token = await _getToken(); // Get the token

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/teachers'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token, // Include the token in the header
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((teacherData) => Teacher.fromJson(teacherData)).toList();
    } else {
      throw Exception('Failed to load teachers: ${response.statusCode}');
    }
  }

  // Update a student's details
  Future<void> updateTeacher(
      Teacher teacher, Map<String, dynamic> updatedData) async {
    final token = await _getToken(); // Get the token

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    try {
      // Create a multipart request for the update
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/teachers/${teacher.id}'),
      );

      // Add headers
      request.headers['Authorization'] =
          token; // Include the token in the header
      request.headers['Accept'] = 'application/json';

      // Add all text fields
      updatedData.forEach((key, value) {
        if (key != 'teacher_photo') {
          request.fields[key] = value.toString();
        }
      });

      // Add photo if it exists and is different from current photo
      if (updatedData['teacher_photo'] != null &&
          updatedData['teacher_photo'] != teacher.teacherPhoto) {
        if (kIsWeb) {
          // For Web: Convert base64 to bytes and send as file
          final bytes = base64Decode(updatedData['teacher_photo']);
          request.files.add(
            http.MultipartFile.fromBytes(
              'teacher_photo',
              bytes,
              filename: 'teacher_photo.jpg',
            ),
          );
        } else {
          // For Mobile: Send file
          request.files.add(await http.MultipartFile.fromPath(
              'teacher_photo', updatedData['teacher_photo']));
        }
      } else {
        // Keep existing photo if no new photo is selected
        request.fields['teacher_photo'] = teacher.teacherPhoto;
      }

      //print('Sending request to: ${request.url}');
      // print('Fields: ${request.fields}');
      // print('Files: ${request.files.length}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // print('Response status: ${response.statusCode}');
      // print('Response body: $responseBody');

      if (response.statusCode != 200) {
        throw Exception('Failed to update student: $responseBody');
      }
    } catch (e) {
      //print('Error updating student: $e');
      throw Exception('Failed to update student: $e');
    }
  }

  // Delete a student
  Future<void> deleteTeacher(String teacherId) async {
    final token = await _getToken(); // Get the token

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/teachers/$teacherId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token, // Include the token in the header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete student: ${response.statusCode}');
    }
  }
}
