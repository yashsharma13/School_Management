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

class _TeacherReportPageState extends State<TeacherReportPage> {
  DateTime selectedDate = DateTime.now();
  List<TeacherAttendance> teacherAttendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Load token from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    print('Token loaded: ${token != null ? 'Yes' : 'No'}');
  }

  // Function to fetch attendance data for teachers
  Future<void> fetchAttendance() async {
    if (token == null) {
      setState(() {
        errorMessage = 'No token found. Please log in.';
        isError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      print('Fetching teacher attendance data for $formattedDate');
      print('Using token: ${token != null ? 'Yes' : 'No'}');

      final response = await http.get(
        Uri.parse('http://localhost:1000/api/attendance/$formattedDate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Now access the 'teachers' list from the response
        final List<dynamic> teacherData =
            data['teachers']; // Get the teachers list

        setState(() {
          teacherAttendanceRecords = teacherData.map((item) {
            return TeacherAttendance(
              item['teacher_name'],
              item['is_present'] == 1, // Convert from 1 or 0 to boolean
            );
          }).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Token is invalid or expired.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
          isLoading = false;
          isError = true;
          errorMessage = 'Session expired. Please login again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        print('Failed to load teacher attendance: ${response.statusCode}');
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = 'Failed to load teacher attendance data';
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Error connecting to server';
      });
    }
  }

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchAttendance(); // Fetch attendance after date selection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Attendance Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAttendance,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_today),
                      label:
                          Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (token == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.orange),
                    Text('You are not logged in. Please login to continue.'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to login page
                      },
                      child: Text('Go to Login'),
                    )
                  ],
                ),
              )
            else if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (isError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(errorMessage),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchAttendance,
                      child: Text('Try Again'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: teacherAttendanceRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No teacher attendance records found for ${DateFormat.yMd().format(selectedDate)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Attendance for Teachers',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat.yMMMMd().format(selectedDate),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Teacher Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('Status',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: teacherAttendanceRecords.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                              itemBuilder: (context, index) {
                                final attendance =
                                    teacherAttendanceRecords[index];
                                return ListTile(
                                  title: Text(attendance.teacherName),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Present: ${teacherAttendanceRecords.where((a) => a.isPresent).length}',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Absent: ${teacherAttendanceRecords.where((a) => !a.isPresent).length}',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Total: ${teacherAttendanceRecords.length}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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

class TeacherAttendance {
  final String teacherName;
  final bool isPresent;

  TeacherAttendance(this.teacherName, this.isPresent);
}
