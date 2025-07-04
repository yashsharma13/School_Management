import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/report_components.dart';
import 'package:sms/pages/services/report_service.dart';

class TeacherReportPage extends StatefulWidget {
  const TeacherReportPage({super.key});

  @override
  _TeacherReportPageState createState() => _TeacherReportPageState();
}

class TeacherAttendance {
  final String teacherId;
  final String teacherName;
  final bool isPresent;

  TeacherAttendance({
    required this.teacherId,
    required this.teacherName,
    required this.isPresent,
  });

  factory TeacherAttendance.fromJson(Map<String, dynamic> json) {
    return TeacherAttendance(
      teacherId: (json['teacher_id'] ?? '').toString().trim(),
      teacherName:
          (json['teacher_name'] ?? 'Unknown Teacher').toString().trim(),
      isPresent: _parseAttendanceStatus(json['is_present']),
    );
  }
}

bool _parseAttendanceStatus(dynamic status) {
  if (status == null) return false;
  if (status is bool) return status;
  if (status is int) return status == 1;
  if (status is String) {
    return status.toLowerCase() == 'true' || status == '1';
  }
  return false;
}

class _TeacherReportPageState extends State<TeacherReportPage> {
  DateTime selectedDate = DateTime.now();
  List<TeacherAttendance> attendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';
  bool attendanceExists = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      await fetchAttendance();
    } else {
      _handleError('Please login to continue');
    }
  }

  Future<void> fetchAttendance() async {
    if (token == null) {
      _handleError('Please login to continue');
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
          attendanceRecords = (result['data']['teachers'] ?? [])
              .map<TeacherAttendance>(
                (item) => TeacherAttendance.fromJson(item),
              )
              .toList();
        }
      } else {
        _handleError(result['message']);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      await fetchAttendance();
    }
  }

  void _handleUnauthorized() async {
    await ReportService.handleUnauthorized();
    setState(() => token = null);
    _showErrorSnackBar('Session expired. Please login again.');
  }

  void _handleError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
      isLoading = false;
    });
    _showErrorSnackBar(message);
  }

  void _showErrorSnackBar(String message) {
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
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Teacher Attendance Report',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterCard(),
            const SizedBox(height: 16),
            if (token == null)
              _buildLoginPrompt()
            else if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (isError)
              _buildErrorState()
            else if (!attendanceExists)
              _buildNoRecordsFound()
            else
              _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return ReportFilterCard(
      title: 'Select Date',
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[50],
              foregroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
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

  Widget _buildNoRecordsFound() {
    return Expanded(
      child: Center(
        child: Text(
          'No attendance records found for teachers on ${DateFormat.yMd().format(selectedDate)}.\n\n'
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
            title: 'Attendance for Teachers',
            date: selectedDate,
          ),
          const AttendanceListHeaderRow(
            leftText: 'Teacher Name',
            rightText: 'Status',
          ),
          Expanded(
            child: ListView.separated(
              itemCount: attendanceRecords.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.deepPurple[100]),
              itemBuilder: (_, index) => AttendanceListItem(
                name: attendanceRecords[index].teacherName,
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
