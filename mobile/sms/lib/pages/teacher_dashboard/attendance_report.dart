import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  String? token;
  String? selectedClass;
  String? selectedClassId;
  String? selectedSection;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> attendanceRecords = [];

  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      _handleUnauthorized();
      return;
    }

    await _loadAssignedClass();
  }

  Future<void> _loadAssignedClass() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/api/assigned-class'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        selectedClass = data['class_name']?.toString();
        selectedClassId = data['class_id']?.toString();
        selectedSection = data['section']?.toString();

        await _fetchAttendanceReport();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showError('Failed to load assigned class.');
      }
    } catch (e) {
      _showError('Error loading class info: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAttendanceReport() async {
    if (selectedClassId == null || selectedSection == null || token == null) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      attendanceRecords = [];
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/attendance/$selectedClassId/$selectedSection/${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          attendanceRecords = (data['students'] ?? data['data'] ?? [])
              .cast<Map<String, dynamic>>();
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showError('Failed to fetch attendance report.');
      }
    } catch (e) {
      _showError('Error fetching report: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _fetchAttendanceReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : token == null
              ? Center(child: Text("Not logged in"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Class: ${selectedClass ?? "N/A"}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Section: ${selectedSection ?? "N/A"}',
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _selectDate(context),
                                icon: Icon(Icons.calendar_today),
                                label: Text(DateFormat('dd MMM yyyy')
                                    .format(selectedDate)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue.shade900),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(errorMessage!,
                              style: TextStyle(color: Colors.red.shade700)),
                        ),
                      SizedBox(height: 8),
                      Expanded(
                        child: attendanceRecords.isEmpty
                            ? Center(
                                child: Text(
                                  'No attendance data for selected date.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: attendanceRecords.length,
                                itemBuilder: (context, index) {
                                  final record = attendanceRecords[index];
                                  final studentName =
                                      record['student_name'] ?? 'Unknown';
                                  final isPresent =
                                      record['is_present'] ?? false;

                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      title: Text(studentName),
                                      trailing: Icon(
                                        isPresent
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: isPresent
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
