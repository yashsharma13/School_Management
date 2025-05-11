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

class Class {
  final String id;
  final String className;

  Class({required this.id, required this.className});

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
    );
  }
}

class _StudentReportPageState extends State<StudentReportPage> {
  DateTime selectedDate = DateTime.now();
  List<StudentAttendance> studentAttendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';

  // For dynamic class
  List<Class> classes = [];
  Class? selectedClass;
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
      await _loadClasses();
    }
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadClasses() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('http://localhost:1000/api/classes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> classData = json.decode(response.body);
        setState(() {
          classes = classData.map((data) => Class.fromJson(data)).toList();
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackBar('Failed to load classes: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error fetching classes: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

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
      final response = await http.get(
        Uri.parse(
            'http://localhost:1000/api/attendance/${selectedClass!.className}/$formattedDate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> studentsData = data['students'];

        setState(() {
          studentAttendanceRecords = studentsData.map((item) {
            return StudentAttendance(
              item['student_name'],
              item['is_present'] == 1,
            );
          }).toList();
          isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      } else {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = 'Failed to load attendance data';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Error connecting to server';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
      if (selectedClass != null) {
        fetchAttendance();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Attendance Report',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: selectedClass != null ? fetchAttendance : null,
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
                          Text('Select Class and Date',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800])),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<Class>(
                                  value: selectedClass,
                                  decoration: InputDecoration(
                                    labelText: 'Class',
                                    labelStyle:
                                        TextStyle(color: Colors.blue[800]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[50],
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (Class? newValue) {
                                    setState(() {
                                      selectedClass = newValue;
                                    });
                                    fetchAttendance();
                                  },
                                  items: classes.map<DropdownMenuItem<Class>>(
                                      (Class classItem) {
                                    return DropdownMenuItem<Class>(
                                      value: classItem,
                                      child: Text(classItem.className,
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton.icon(
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (token == null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, size: 48, color: Colors.orange),
                            SizedBox(height: 16),
                            Text(
                                'You are not logged in. Please login to continue.',
                                style: TextStyle(fontSize: 16)),
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
                    )
                  else if (isLoading)
                    Center(child: CircularProgressIndicator(color: Colors.blue))
                  else if (isError)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(errorMessage,
                              style: TextStyle(color: Colors.red[800])),
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
                    )
                  else
                    Expanded(
                      child: studentAttendanceRecords.isEmpty
                          ? Center(
                              child: Text(
                                selectedClass == null
                                    ? 'Please select a class to view attendance'
                                    : 'No attendance records found for ${selectedClass?.className} on ${DateFormat.yMd().format(selectedDate)}',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Attendance for ${selectedClass?.className}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800]),
                                      ),
                                      Text(
                                        DateFormat.yMMMMd()
                                            .format(selectedDate),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[800]),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Student Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800])),
                                      Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800])),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: studentAttendanceRecords.length,
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                      height: 1,
                                      color: Colors.blue[100],
                                    ),
                                    itemBuilder: (context, index) {
                                      final attendance =
                                          studentAttendanceRecords[index];
                                      return ListTile(
                                        title: Text(attendance.studentName,
                                            style: TextStyle(
                                                color: Colors.blue[900])),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800]),
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
