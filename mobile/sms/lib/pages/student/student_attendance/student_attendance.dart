import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
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

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  List<Student> students = [];
  TextEditingController searchController = TextEditingController();
  String? token;
  bool isLoading = false;

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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> fetchStudents() async {
    if (selectedClass == null) {
      _showErrorSnackBar('Please select a class first');
      return;
    }

    if (token == null) {
      _showErrorSnackBar('Please login to continue');
      return;
    }

    setState(() {
      isLoading = true;
      students = []; // Clear previous students while loading
    });

    try {
      String encodedClassName = Uri.encodeComponent(selectedClass!.className);
      // Use the class ID to fetch students
      final response = await http.get(
        Uri.parse('http://localhost:1000/api/students/$encodedClassName'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> studentData = json.decode(response.body);
        setState(() {
          students = studentData
              .map((data) => Student(
                    data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    data['student_name']?.toString() ?? 'Unknown Student',
                    false,
                  ))
              .toList();
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackBar('Failed to load students: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error connecting to server: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveAttendance() async {
    if (token == null) {
      _showErrorSnackBar('Please login to continue');
      return;
    }

    if (selectedClass == null) {
      _showErrorSnackBar('Please select a class');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final attendanceData = students.map((student) {
      return {
        'student_id': student.id,
        'is_present': student.isPresent,
        'class_name': selectedClass!.className,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:1000/api/attendance'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
        body: json.encode({
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'students': attendanceData,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Attendance saved successfully');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackBar(
            'Failed to save attendance: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error saving attendance: $error');
    } finally {
      setState(() {
        isLoading = false;
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
        fetchStudents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Management',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<Class>(
                                  value: selectedClass,
                                  decoration: InputDecoration(
                                    labelText: 'Select Class',
                                    labelStyle:
                                        TextStyle(color: Colors.blue.shade700),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                  isExpanded: true,
                                  onChanged: (Class? newValue) {
                                    setState(() {
                                      selectedClass = newValue;
                                    });
                                    fetchStudents();
                                  },
                                  items: classes.map<DropdownMenuItem<Class>>(
                                      (Class classItem) {
                                    return DropdownMenuItem<Class>(
                                      value: classItem,
                                      child: Text(classItem.className,
                                          style: TextStyle(
                                              color: Colors.blue.shade900)),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_today, size: 18),
                                      SizedBox(width: 8),
                                      Text(DateFormat('dd/MM/yyyy')
                                          .format(selectedDate)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Student',
                              labelStyle:
                                  TextStyle(color: Colors.blue.shade700),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.blue.shade700),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    )
                  else
                    Expanded(
                      child: students.isEmpty
                          ? Center(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    selectedClass == null
                                        ? 'Please select a class to view students'
                                        : 'No students found for ${selectedClass?.className}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: students
                                  .where((student) => student.name
                                      .toLowerCase()
                                      .contains(
                                          searchController.text.toLowerCase()))
                                  .length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final filteredStudents = students
                                    .where((student) => student.name
                                        .toLowerCase()
                                        .contains(searchController.text
                                            .toLowerCase()))
                                    .toList();
                                final student = filteredStudents[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        student.name.substring(0, 1),
                                        style: TextStyle(
                                            color: Colors.blue.shade800),
                                      ),
                                    ),
                                    title: Text(
                                      student.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue.shade900),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 1.2,
                                      child: Switch(
                                        value: student.isPresent,
                                        onChanged: (bool value) {
                                          setState(() {
                                            student.isPresent = value;
                                          });
                                        },
                                        activeColor: Colors.blue,
                                        activeTrackColor: Colors.blue.shade200,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: students.isEmpty ? null : saveAttendance,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Save Attendance',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
