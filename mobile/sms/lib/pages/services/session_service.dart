import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  /// Create a new session
  static Future<Map<String, dynamic>> createSession({
    required String sessionName,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      final url = Uri.parse('$baseUrl/api/create');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'session_name': sessionName,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Session created successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Fetch all sessions for the current school (based on token)
  static Future<Map<String, dynamic>> getSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }

      final url =
          Uri.parse('$baseUrl/api/getsession'); // 👈 Make sure this is correct
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'], // List of sessions
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch sessions',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// 🔄 Update existing session
  static Future<Map<String, dynamic>> updateSession({
    required int id,
    required String sessionName,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('No token found. Please log in.');

      final url = Uri.parse('$baseUrl/api/updatesession');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': id,
          'session_name': sessionName,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Session updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update session',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<bool> deleteSession(String sessionId) async {
    try {
      // print('[DEBUG] Starting deleteClass with ID: $classId'); // Add this

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is not available.');
      }

      if (sessionId.isEmpty) {
        throw Exception('Session ID cannot be empty');
      }

      // const String baseUrl = 'http://localhost:1000/api';
      final url = '$baseUrl/api/session/$sessionId';

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
      // print('[ERROR] in deleteSession: $error');
      rethrow;
    }
  }
}
