import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/widgets/custom_appbar.dart';

import 'package:sms/widgets/report_components.dart';
import 'package:sms/widgets/date_picker.dart';

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

  List<Map<String, dynamic>> attendanceRecords = [];
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';
  bool attendanceExists = false;
  bool isInitialLoading = true;

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
    setState(() => isInitialLoading = false);
  }

  Future<void> _loadAssignedClass() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/assigned-class'),
        headers: {'Authorization': 'Bearer $token'},
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
        _handleError('Failed to load assigned class.');
      }
    } catch (e) {
      _handleError('Error loading class info: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAttendanceReport() async {
    if (selectedClassId == null || selectedSection == null || token == null) {
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
      attendanceExists = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/attendance/$selectedClassId/$selectedSection/${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List records = data['students'] ?? data['data'] ?? [];

        setState(() {
          attendanceRecords = records.cast<Map<String, dynamic>>();
          attendanceExists = attendanceRecords.isNotEmpty;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _handleError('Failed to fetch attendance report.');
      }
    } catch (e) {
      _handleError('Error fetching attendance: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _handleError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentCount =
        attendanceRecords.where((s) => s['is_present'] == true).length;
    final absentCount =
        attendanceRecords.where((s) => s['is_present'] == false).length;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Attendance Report', style: TextStyle(color: Colors.white)),
      //   backgroundColor: Colors.blue.shade900,
      // ),
      appBar: CustomAppBar(title: 'Attendance Report'),
      body: isInitialLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ReportFilterCard(
                    title: 'Class & Date',
                    children: [
                      Text('Class: ${selectedClass ?? "N/A"}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Section: ${selectedSection ?? "N/A"}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 12),
                      CustomDatePicker(
                        selectedDate: selectedDate,
                        onDateSelected: (DateTime newDate) {
                          setState(() => selectedDate = newDate);
                          _fetchAttendanceReport();
                        },
                        isExpanded: true,
                        lastDate: DateTime.now(), // 👈 only allow up to today
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (isLoading)
                    Expanded(child: Center(child: CircularProgressIndicator())),
                  if (isError) _buildErrorState(),
                  if (!isLoading && !isError)
                    attendanceExists
                        ? _buildAttendanceList(presentCount, absentCount)
                        : _buildNoDataMessage(),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAttendanceReport,
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Expanded(
      child: Center(
        child: Text(
          'No attendance records found for ${DateFormat.yMMMd().format(selectedDate)}.\n\nAttendance may not have been taken.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(int presentCount, int absentCount) {
    return Expanded(
      child: Column(
        children: [
          AttendanceListHeader(
            title: 'Attendance for $selectedClass - $selectedSection',
            date: selectedDate,
          ),
          AttendanceListHeaderRow(
            leftText: 'Student Name',
            rightText: 'Status',
          ),
          Expanded(
            child: ListView.separated(
              itemCount: attendanceRecords.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.blue[100]),
              itemBuilder: (_, index) {
                final student = attendanceRecords[index];
                return AttendanceListItem(
                  name: student['student_name'] ?? 'Unknown',
                  isPresent: student['is_present'] ?? false,
                );
              },
            ),
          ),
          AttendanceSummary(
            presentCount: presentCount,
            absentCount: absentCount,
            totalCount: attendanceRecords.length,
          ),
        ],
      ),
    );
  }
}
