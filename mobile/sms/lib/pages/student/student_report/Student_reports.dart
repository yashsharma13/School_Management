import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentReportPage extends StatefulWidget {
  const StudentReportPage({super.key});

  @override
  _StudentReportPageState createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage> {
  String? selectedClass;
  DateTime selectedDate = DateTime.now();
  List<String> classes = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12'
  ];
  List<StudentAttendance> studentAttendanceRecords = [];
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
    // print('Token loaded: ${token != null ? 'Yes' : 'No'}');
  }

  // Function to fetch attendance data from the backend
  Future<void> fetchAttendance() async {
    if (selectedClass == null) {
      setState(() {
        errorMessage = 'Please select a class';
        isError = true;
      });
      return;
    }

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
      // print('Fetching attendance data for $selectedClass on $formattedDate');
      // print('Using token: ${token != null ? 'Yes' : 'No'}');

      final response = await http.get(
        Uri.parse(
            'http://localhost:1000/api/attendance/${Uri.encodeComponent(selectedClass!)}/$formattedDate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!, // Include the token without 'Bearer ' prefix
        },
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body); // Decode as a Map
        final List<dynamic> studentsData =
            data['students']; // Access the students list

        setState(() {
          studentAttendanceRecords = studentsData.map((item) {
            return StudentAttendance(
              item['student_name'],
              item['is_present'] == 1, // Convert from 1 or 0 to boolean
            );
          }).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Token is invalid or expired.');
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
          isLoading = false;
          isError = true;
          errorMessage = 'Session expired. Please login again.';
        });

        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        // print('Failed to load attendance: ${response.statusCode}');
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = 'Failed to load attendance data';
        });
      }
    } catch (error) {
      // print('Error: $error');
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
      if (selectedClass != null) {
        fetchAttendance(); // Fetch attendance after date selection
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: selectedClass != null ? fetchAttendance : null,
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
                    Text('Select Class and Date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedClass,
                            decoration: InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedClass = newValue;
                              });
                              fetchAttendance(); // Fetch attendance after class selection
                            },
                            items: classes.map<DropdownMenuItem<String>>(
                                (String classItem) {
                              return DropdownMenuItem<String>(
                                value: classItem,
                                child: Text(classItem),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
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
                child: studentAttendanceRecords.isEmpty
                    ? Center(
                        child: Text(
                          selectedClass == null
                              ? 'Please select a class to view attendance'
                              : 'No attendance records found for $selectedClass on ${DateFormat.yMd().format(selectedDate)}',
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
                                  'Attendance for $selectedClass',
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
                                Text('Student Name',
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
                              itemCount: studentAttendanceRecords.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                              itemBuilder: (context, index) {
                                final attendance =
                                    studentAttendanceRecords[index];
                                return ListTile(
                                  title: Text(attendance.studentName),
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
                                  'Present: ${studentAttendanceRecords.where((a) => a.isPresent).length}',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Absent: ${studentAttendanceRecords.where((a) => !a.isPresent).length}',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Total: ${studentAttendanceRecords.length}',
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

class StudentAttendance {
  final String studentName;
  final bool isPresent;

  StudentAttendance(this.studentName, this.isPresent);
}
