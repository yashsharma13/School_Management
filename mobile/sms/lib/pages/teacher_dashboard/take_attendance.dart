import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/teacher_dashboard/t_dashboard.dart';
import 'package:sms/widgets/button.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  _TakeAttendancePageState createState() => _TakeAttendancePageState();
}

class Student {
  final String id;
  final String name;
  final String assignedClass;
  final String assignedSection;
  bool isPresent;

  Student(this.id, this.name, this.assignedClass, this.assignedSection,
      this.isPresent);
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  DateTime selectedDate = DateTime.now();
  List<Student> students = [];
  List<Student> filteredStudents = [];
  TextEditingController searchController = TextEditingController();
  String? token;
  bool isLoading = false;
  bool isInitialLoading = true;
  String? selectedClass;
  String? selectedClassId;
  String? selectedSection;
  String? errorMessage;
  String? successMessage;
  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    if (token != null) {
      await _loadAssignedClass();
    }
    setState(() {
      isInitialLoading = false;
    });
  }

  Future<void> _loadAssignedClass() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(
        Uri.parse('$baseUrl/api/assigned-class'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          selectedClass = data['class_name']?.toString() ?? 'Not assigned';
          selectedClassId = data['class_id']?.toString();
          selectedSection = data['section']?.toString() ?? 'Not assigned';
        });
        await _fetchStudents();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        _showError('No class assigned to this teacher');
      } else {
        _showError('Failed to fetch assigned class');
      }
    } catch (error) {
      _showError('Error fetching class info: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchStudents() async {
    if (token == null || selectedClass == null || selectedSection == null)
      return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getstudents/teacher-class'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final studentsArray =
            (data['students'] ?? data['data'] ?? []) as List<dynamic>;

        setState(() {
          students = studentsArray.map<Student>((item) {
            final itemMap = item as Map<String, dynamic>;
            return Student(
              itemMap['student_id']?.toString() ??
                  itemMap['id']?.toString() ??
                  '',
              itemMap['student_name']?.toString() ?? 'Unknown',
              itemMap['assigned_class']?.toString() ?? selectedClass!,
              itemMap['assigned_section']?.toString() ?? selectedSection!,
              false,
            );
          }).toList();
          _filterStudents();
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showError('Failed to fetch students: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showError('Error fetching students: $error');
    }
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      token = null;
    });
    _showError('Session expired. Please login again.');
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  void _showSuccess(String message) {
    setState(() {
      successMessage = message;
    });
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          successMessage = null;
        });
      }
    });
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        final nameMatch = student.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        return nameMatch;
      }).toList();
    });
  }

  void _toggleStudentAttendance(int index) {
    setState(() {
      filteredStudents[index].isPresent = !filteredStudents[index].isPresent;
    });
  }

  Future<void> _saveAttendance() async {
    if (token == null ||
        selectedClass == null ||
        selectedSection == null ||
        selectedClassId == null) {
      _showError('Incomplete data. Please reload the page.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final attendanceData = filteredStudents
        .map((student) => {
              'student_id': student.id,
              'is_present': student.isPresent,
              'class_id': selectedClassId,
              'section': selectedSection,
            })
        .toList();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'students': attendanceData,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Attendance saved successfully');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeacherDashboard()),
          );
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showError('Failed to save attendance: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showError('Error saving attendance: $error');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Attendance', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isInitialLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : token == null
              ? Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'You are not logged in.',
                            style: TextStyle(
                                fontSize: 16, color: Colors.red.shade600),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Class: ${selectedClass ?? "Not assigned"}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.shade900)),
                              SizedBox(height: 8),
                              Text(
                                  'Section: ${selectedSection ?? "Not assigned"}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.shade900)),
                              SizedBox(height: 8),
                              Text(
                                  'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.shade900)),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _selectDate(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade50,
                                        foregroundColor: Colors.blue.shade700,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.calendar_today, size: 18),
                                          SizedBox(width: 8),
                                          Text(DateFormat('dd/MM/yyyy')
                                              .format(selectedDate)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        labelText: 'Search Student',
                                        labelStyle: TextStyle(
                                            color: Colors.blue.shade700),
                                        prefixIcon: Icon(Icons.search,
                                            color: Colors.blue.shade700),
                                        border: OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.blue.shade50,
                                      ),
                                      onChanged: (value) => _filterStudents(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(errorMessage!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      if (successMessage != null) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(successMessage!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      SizedBox(height: 16),
                      Expanded(
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Colors.blue))
                            : filteredStudents.isEmpty
                                ? Center(
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'No students found.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade700),
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filteredStudents.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final student = filteredStudents[index];
                                      return Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Colors.blue.shade100,
                                            child: Text(
                                              student.name.isNotEmpty
                                                  ? student.name.substring(0, 1)
                                                  : '?',
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
                                          subtitle: Text(
                                            '${student.assignedClass} - ${student.assignedSection}',
                                            style: TextStyle(
                                                color: Colors.grey.shade600),
                                          ),
                                          trailing: Transform.scale(
                                            scale: 1.2,
                                            child: Switch(
                                              value: student.isPresent,
                                              onChanged: (value) =>
                                                  _toggleStudentAttendance(
                                                      index),
                                              activeColor: Colors.blue,
                                              activeTrackColor:
                                                  Colors.blue.shade200,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      SizedBox(height: 16),
                      CustomButton(
                        text: isLoading ? 'Saving...' : 'Save Attendance',
                        width: double.infinity,
                        onPressed: students.isEmpty || isLoading
                            ? null
                            : _saveAttendance,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
    );
  }
}
