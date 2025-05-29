import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    String teacherId = '';
    if (json['teacher_id'] != null) {
      teacherId = json['teacher_id'].toString().trim();
    }

    String teacherName =
        (json['teacher_name'] ?? 'Unknown Teacher').toString().trim();

    bool isPresent = false;
    if (json['is_present'] != null) {
      if (json['is_present'] is bool) {
        isPresent = json['is_present'];
      } else if (json['is_present'] is int) {
        isPresent = json['is_present'] == 1;
      } else if (json['is_present'] is String) {
        isPresent = json['is_present'].toLowerCase() == 'true' ||
            json['is_present'] == '1';
      }
    }

    return TeacherAttendance(
      teacherId: teacherId,
      teacherName: teacherName,
      isPresent: isPresent,
    );
  }
}

class _TeacherReportPageState extends State<TeacherReportPage> {
  DateTime selectedDate = DateTime.now();
  List<TeacherAttendance> teacherAttendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';
  bool attendanceExists = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    if (token != null) {
      await fetchAttendance();
    }
    setState(() {
      _isInitialLoading = false;
    });
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      token = null;
    });
    _showErrorSnackBar('Session expired. Please login again.');
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red[800],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ));
  }

  Future<void> fetchAttendance() async {
    if (token == null) {
      setState(() {
        errorMessage = 'No token found. Please log in.';
        isError = true;
      });
      _showErrorSnackBar('Please login to continue');
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
      teacherAttendanceRecords = [];
      attendanceExists = false;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1000/api/attendance/$formattedDate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> teachersData = data['teachers'] ?? [];

        if (teachersData.isEmpty) {
          setState(() {
            attendanceExists = false;
            isLoading = false;
            isError = false;
          });
          return;
        }

        List<TeacherAttendance> attendanceRecords = [];
        for (var item in teachersData) {
          if (item is Map<String, dynamic>) {
            try {
              attendanceRecords.add(TeacherAttendance.fromJson(item));
            } catch (e) {
              print('Error parsing teacher attendance record: $e');
            }
          }
        }

        setState(() {
          teacherAttendanceRecords = attendanceRecords;
          attendanceExists = true;
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        setState(() {
          attendanceExists = false;
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage =
              'Failed to load attendance data: ${response.statusCode} ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      print('Error fetching teacher attendance: $error');
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Error connecting to server: $error';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Attendance Report',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchAttendance,
          ),
        ],
      ),
      body: _isInitialLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _selectDate(context),
                              icon: Icon(Icons.calendar_today, size: 18),
                              label: Text(DateFormat('dd/MM/yyyy')
                                  .format(selectedDate)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                foregroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (token == null)
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning,
                                  size: 48, color: Colors.orange),
                              SizedBox(height: 16),
                              Text(
                                'You are not logged in. Please login to continue.',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to login page
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                child: Text('Go to Login'),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (isLoading)
                    Expanded(
                        child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.blue)))
                  else if (isError)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red[800]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: fetchAttendance,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!attendanceExists)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No attendance records found for teachers on ${DateFormat.yMd().format(selectedDate)}.\n\nAttendance may not have been taken for this date.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Attendance for Teachers',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat.yMMMMd().format(selectedDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Teacher Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: teacherAttendanceRecords.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.blue[100],
                              ),
                              itemBuilder: (context, index) {
                                final attendance =
                                    teacherAttendanceRecords[index];
                                return ListTile(
                                  title: Text(
                                    attendance.teacherName,
                                    style: TextStyle(color: Colors.blue[900]),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        attendance.isPresent
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: attendance.isPresent
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        attendance.isPresent
                                            ? 'Present'
                                            : 'Absent',
                                        style: TextStyle(
                                          color: attendance.isPresent
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Present: ${teacherAttendanceRecords.where((a) => a.isPresent).length}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Absent: ${teacherAttendanceRecords.where((a) => !a.isPresent).length}',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Total: ${teacherAttendanceRecords.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
