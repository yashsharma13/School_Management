import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/report_components.dart';
import 'package:sms/pages/services/report_service.dart';
import 'package:sms/widgets/date_picker.dart';
import 'package:sms/widgets/class_section_selector.dart';
import 'package:sms/widgets/custom_snackbar.dart';

class StudentReportPage extends StatefulWidget {
  const StudentReportPage({super.key});

  @override
  State<StudentReportPage> createState() => _StudentReportPageState();
}

class StudentAttendance {
  final String studentId;
  final String studentName;
  final String? className;
  final String? section;
  final bool isPresent;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    this.className,
    this.section,
    required this.isPresent,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: (json['student_id'] ?? '').toString().trim(),
      studentName:
          (json['student_name'] ?? 'Unknown Student').toString().trim(),
      className: json['class_name']?.toString().trim(),
      section: json['section']?.toString().trim(),
      isPresent: _parseAttendanceStatus(json['is_present']),
    );
  }

  static bool _parseAttendanceStatus(dynamic status) {
    if (status == null) return false;
    if (status is bool) return status;
    if (status is int) return status == 1;
    if (status is String) {
      return status.toLowerCase() == 'true' || status == '1';
    }
    return false;
  }
}

class _StudentReportPageState extends State<StudentReportPage> {
  DateTime selectedDate = DateTime.now();
  List<StudentAttendance> attendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';
  bool attendanceExists = false;
  bool _isInitialLoading = true;

  ClassModel? selectedClass;
  String? selectedSection;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => token = prefs.getString('token'));
    if (token == null) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Please login to continue',
          backgroundColor: Colors.red);
    }
    setState(() => _isInitialLoading = false);
  }

  Future<void> fetchAttendance() async {
    if (selectedClass == null || selectedSection == null) {
      _handleError('Please select both class and section');
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
      attendanceExists = false;
    });

    final result = await ReportService.fetchReport(
      token: token!,
      endpoint: 'attendance',
      date: selectedDate,
      classId: selectedClass!.id.toString(),
      section: selectedSection!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;

      if (result['success'] == true) {
        if (result['unauthorized'] == true) {
          _handleUnauthorized();
          return;
        }

        attendanceExists = result['exists'] ?? false;

        if (attendanceExists) {
          attendanceRecords = (result['data']['students'] ?? [])
              .map<StudentAttendance>(
                (item) => StudentAttendance.fromJson(item),
              )
              .toList();
        }
      } else {
        _handleError(result['message']);
      }
    });
  }

  void _handleUnauthorized() async {
    await ReportService.handleUnauthorized();
    setState(() => token = null);
    if (!mounted) return;
    showCustomSnackBar(context, 'Session expired. Please login again.',
        backgroundColor: Colors.red);
  }

  void _handleError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
      isLoading = false;
    });
    showCustomSnackBar(context, message, backgroundColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Student Attendance Report',
      ),
      body:
          _isInitialLoading ? _buildLoadingIndicator() : _buildReportContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildReportContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFilterCard(),
          const SizedBox(height: 16),
          if (token == null) _buildLoginPrompt(),
          if (token != null) _buildReportBody(),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return ReportFilterCard(
      title: 'Select Class, Section and Date',
      children: [
        ClassSectionSelector(
          onSelectionChanged: (ClassModel? cls, String? sec) {
            setState(() {
              selectedClass = cls;
              selectedSection = sec;
              if (cls != null && sec != null) {
                fetchAttendance();
              } else {
                attendanceRecords = [];
                attendanceExists = false;
              }
            });
          },
          initialClass: selectedClass,
          initialSection: selectedSection,
        ),
        const SizedBox(height: 12),
        CustomDatePicker(
          selectedDate: selectedDate,
          onDateSelected: (DateTime newDate) {
            setState(() => selectedDate = newDate);
            if (selectedClass != null && selectedSection != null) {
              fetchAttendance();
            }
          },
          isExpanded: true,
          backgroundColor: Colors.deepPurple[50],
          foregroundColor: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Expanded(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'You are not logged in. Please login to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {/* Navigate to login */},
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportBody() {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (isError) return _buildErrorState();
    if (selectedClass == null || selectedSection == null) {
      return _buildSelectionPrompt();
    }
    if (!attendanceExists) return _buildNoRecordsFound();
    return _buildAttendanceList();
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchAttendance,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionPrompt() {
    return const Expanded(
      child: Center(
        child: Text(
          'Please select both class and section to view attendance',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildNoRecordsFound() {
    return Expanded(
      child: Center(
        child: Text(
          'No attendance records found for ${selectedClass!.className} - $selectedSection '
          'on ${DateFormat.yMd().format(selectedDate)}.\n\n'
          'Attendance may not have been taken for this date.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Expanded(
      child: Column(
        children: [
          AttendanceListHeader(
            title:
                'Attendance for ${selectedClass!.className} - $selectedSection',
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
                  Divider(height: 1, color: Colors.deepPurple[100]),
              itemBuilder: (_, index) => AttendanceListItem(
                name: attendanceRecords[index].studentName,
                isPresent: attendanceRecords[index].isPresent,
              ),
            ),
          ),
          AttendanceSummary(
            presentCount: attendanceRecords.where((a) => a.isPresent).length,
            absentCount: attendanceRecords.where((a) => !a.isPresent).length,
            totalCount: attendanceRecords.length,
          ),
        ],
      ),
    );
  }
}
