import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
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
  List<Student> students = [];
  TextEditingController searchController = TextEditingController();
  String? token;
  bool isLoading = false;

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

  // Fetch students from backend
  Future<void> fetchStudents() async {
    if (selectedClass == null) {
      print('No class selected. Please select a class.');
      return;
    }

    if (token == null) {
      print('No token found. Please log in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    print('Using token: $token');

    // Ensure class name is properly encoded for URL
    final encodedClass = Uri.encodeComponent(selectedClass!);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1000/api/students/$encodedClass'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              token!, // Use token directly without 'Bearer ' prefix
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> studentData = json.decode(response.body);
        setState(() {
          students = studentData
              .map((data) => Student(
                    data['id'].toString(),
                    data['student_name'],
                    false, // isPresent initialized as false
                  ))
              .toList();
        });
      } else if (response.statusCode == 401) {
        print('Token is invalid or expired. Redirecting to login...');
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
        });

        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        print('Failed to load students. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load students: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      print('Error fetching students: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error connecting to server. Please check your connection.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to submit attendance
  Future<void> saveAttendance() async {
    if (token == null) {
      print('No token found. Please log in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final attendanceData = students.map((student) {
      return {
        'student_id': student.id,
        'is_present': student.isPresent,
        'class_name': selectedClass,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:1000/api/attendance'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              token!, // Use token directly without 'Bearer ' prefix
        },
        body: json.encode({
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'students': attendanceData,
        }),
      );

      print('Save attendance response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Successfully saved attendance
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Student attendance record saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else if (response.statusCode == 401) {
        print('Token is invalid or expired. Redirecting to login...');
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
        });

        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        // Error occurred while saving attendance
        print('Failed to save attendance. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to save attendance: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      // Handle network errors or other issues
      print('Error saving attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error connecting to server. Please check your connection.')),
      );
    } finally {
      setState(() {
        isLoading = false;
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
        fetchStudents(); // Fetch students based on selected date and class
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedClass,
                    hint: Text('Select Class'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedClass = newValue;
                      });
                      fetchStudents(); // Fetch students after selecting class
                    },
                    items: classes
                        .map<DropdownMenuItem<String>>((String classItem) {
                      return DropdownMenuItem<String>(
                        value: classItem,
                        child: Text(classItem),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(DateFormat.yMd().format(selectedDate)),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Student',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
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
            else
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: selectedClass == null
                            ? Text('Please select a class to view students')
                            : Text('No students found for ${selectedClass}'),
                      )
                    : ListView(
                        children: students
                            .where((student) => student.name
                                .toLowerCase()
                                .contains(searchController.text.toLowerCase()))
                            .map((student) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(student.name),
                              trailing: Switch(
                                value: student.isPresent,
                                onChanged: (bool value) {
                                  setState(() {
                                    student.isPresent = value;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: students.isEmpty ? null : saveAttendance,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Attendance'),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String id;
  final String name;
  bool isPresent;

  Student(this.id, this.name, this.isPresent);
}
