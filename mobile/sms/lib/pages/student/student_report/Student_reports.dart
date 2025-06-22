import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final List<String> sections;

  Class({
    required this.id,
    required this.className,
    required this.sections,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
      sections: (json['sections'] ?? [])
          .map<String>((s) => s.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}

class Student {
  final String id;
  final String name;
  final String assignedClass;
  final String assignedSection;

  Student(this.id, this.name, this.assignedClass, this.assignedSection);

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      (json['_id'] ?? json['id'] ?? '').toString().trim(),
      (json['student_name'] ?? 'Unknown Student').toString().trim(),
      (json['assigned_class'] ?? '').toString().trim(),
      (json['assigned_section'] ?? '').toString().trim(),
    );
  }
}

class StudentAttendance {
  final String studentId;
  final String studentName;
  final bool isPresent;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.isPresent,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    String studentId = '';
    if (json['student_id'] != null) {
      studentId = json['student_id'].toString().trim();
    }

    String studentName =
        (json['student_name'] ?? 'Unknown Student').toString().trim();

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

    return StudentAttendance(
      studentId: studentId,
      studentName: studentName,
      isPresent: isPresent,
    );
  }
}

class _StudentReportPageState extends State<StudentReportPage> {
  DateTime selectedDate = DateTime.now();
  List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  List<StudentAttendance> studentAttendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';
  bool attendanceExists = false; // New flag to track if attendance exists
  final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  // For dynamic class and section
  List<Class> classes = [];
  String? selectedClass;
  String? selectedSection;
  List<String> availableSections = [];
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
      await _fetchAllStudents();
    }
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadClasses() async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      final response = await http.get(
        Uri.parse('$baseeUrl/api/classes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        List<dynamic> classData = [];
        if (responseBody is List) {
          classData = responseBody;
        } else if (responseBody is Map && responseBody['data'] is List) {
          classData = responseBody['data'];
        } else {
          throw Exception('Unexpected response format for classes');
        }

        final Map<String, Set<String>> classSectionMap = {};
        final List<Class> tempClasses = [];

        for (final data in classData) {
          if (data is! Map<String, dynamic>) continue;

          final className =
              (data['class_name'] ?? data['className'] ?? '').toString().trim();
          final section = (data['section'] ?? '').toString().trim();

          if (className.isEmpty) continue;

          if (!classSectionMap.containsKey(className)) {
            classSectionMap[className] = <String>{};
          }

          if (section.isNotEmpty) {
            classSectionMap[className]!.add(section);
          }
        }

        classSectionMap.forEach((className, sections) {
          tempClasses.add(Class(
            id: className,
            className: className,
            sections: sections.toList()..sort(),
          ));
        });

        setState(() {
          classes = tempClasses;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        throw Exception(
            'Failed to load classes: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        isError = true;
        errorMessage = 'Error fetching classes: $error';
      });
      _showErrorSnackBar('Error fetching classes: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAllStudents() async {
    if (token == null) {
      _showErrorSnackBar('Please login to continue');
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseeUrl/api/students'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        List<dynamic> studentData = [];
        if (responseBody is List) {
          studentData = responseBody;
        } else if (responseBody is Map && responseBody['data'] is List) {
          studentData = responseBody['data'];
        } else {
          throw Exception('Unexpected response format for students');
        }

        setState(() {
          allStudents = studentData
              .where((data) => data is Map<String, dynamic>)
              .map((data) => Student.fromJson(data as Map<String, dynamic>))
              .toList();
          _filterStudents();
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        throw Exception(
            'Failed to load students: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        isError = true;
        errorMessage = 'Error connecting to server: $error';
      });
      _showErrorSnackBar('Error connecting to server: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateAvailableSections(String? className) {
    setState(() {
      if (className != null) {
        final selectedClassObj = classes.firstWhere(
          (c) => c.className == className,
          orElse: () => Class(id: '', className: '', sections: []),
        );
        availableSections = selectedClassObj.sections;
      } else {
        availableSections = [];
      }
      selectedSection = null;
      _filterStudents();
    });
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = allStudents.where((student) {
        final classMatch =
            selectedClass == null || student.assignedClass == selectedClass;
        final sectionMatch = selectedSection == null ||
            student.assignedSection == selectedSection;
        return classMatch && sectionMatch;
      }).toList();
    });

    if (selectedClass != null && selectedSection != null) {
      fetchAttendance();
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
    if (selectedClass == null) {
      setState(() {
        errorMessage = 'Please select a class';
        isError = true;
      });
      return;
    }

    if (selectedSection == null) {
      setState(() {
        errorMessage = 'Please select a section';
        isError = true;
      });
      return;
    }

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
      studentAttendanceRecords = [];
      attendanceExists = false; // Reset attendance exists flag
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final encodedClass = Uri.encodeComponent(selectedClass!);
    final encodedSection = Uri.encodeComponent(selectedSection!);

    final uri = Uri.parse(
      '$baseeUrl/api/attendance/$encodedClass/$encodedSection/$formattedDate',
    );

    try {
      // print('Fetching attendance from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> studentsData = data['students'] ?? [];

        // Check if attendance was taken for this date
        if (studentsData.isEmpty) {
          // No attendance records found
          setState(() {
            attendanceExists = false;
            isLoading = false;
            isError = false;
          });
          return;
        }

        // Attendance exists - process the records
        List<StudentAttendance> attendanceRecords = [];
        for (var item in studentsData) {
          if (item is Map<String, dynamic>) {
            try {
              attendanceRecords.add(StudentAttendance.fromJson(item));
            } catch (e) {
              print('Error parsing attendance record: $e');
            }
          }
        }

        setState(() {
          studentAttendanceRecords = attendanceRecords;
          attendanceExists = true; // Mark that attendance exists
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        // No attendance records found for this date
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
      print('Error fetching attendance: $error');
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
      if (selectedClass != null && selectedSection != null) {
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
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: (selectedClass != null && selectedSection != null)
                ? fetchAttendance
                : null,
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
                            'Select Class, Section and Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          Column(
                            children: [
                              DropdownButtonFormField<String>(
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
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedClass = newValue;
                                    _updateAvailableSections(newValue);
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Select Class',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ),
                                  ...classes.map((classItem) {
                                    return DropdownMenuItem<String>(
                                      value: classItem.className,
                                      child: Text(classItem.className,
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    );
                                  }).toList(),
                                ],
                              ),
                              SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: selectedSection,
                                decoration: InputDecoration(
                                  labelText: 'Section',
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
                                isExpanded: true,
                                onChanged: availableSections.isEmpty
                                    ? null
                                    : (String? newValue) {
                                        setState(() {
                                          selectedSection = newValue;
                                        });
                                        _filterStudents();
                                      },
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      availableSections.isEmpty
                                          ? 'Select class first'
                                          : 'Select Section',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  ...availableSections.map((section) {
                                    return DropdownMenuItem<String>(
                                      value: section,
                                      child: Text(section,
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
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
                              onPressed: (selectedClass != null &&
                                      selectedSection != null)
                                  ? fetchAttendance
                                  : null,
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
                  else if (selectedClass == null || selectedSection == null)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Please select both class and section to view attendance',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (!attendanceExists)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No attendance records found for $selectedClass - $selectedSection on ${DateFormat.yMd().format(selectedDate)}.\n\nAttendance may not have been taken for this date.',
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
                                    'Attendance for $selectedClass - $selectedSection',
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
                                  'Student Name',
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
                              itemCount: studentAttendanceRecords.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.blue[100],
                              ),
                              itemBuilder: (context, index) {
                                final attendance =
                                    studentAttendanceRecords[index];
                                return ListTile(
                                  title: Text(
                                    attendance.studentName,
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
                                    'Present: ${studentAttendanceRecords.where((a) => a.isPresent).length}',
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
                                    'Absent: ${studentAttendanceRecords.where((a) => !a.isPresent).length}',
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
                                    'Total: ${studentAttendanceRecords.length}',
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
