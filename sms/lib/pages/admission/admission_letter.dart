import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms/pages/admission/admission_confirm.dart';
import 'dart:convert';

class AdmissionLetterPage extends StatefulWidget {
  const AdmissionLetterPage({Key? key}) : super(key: key);

  @override
  State<AdmissionLetterPage> createState() => _AdmissionLetterPageState();
}

class _AdmissionLetterPageState extends State<AdmissionLetterPage> {
  List<Class> classes = [];
  List<Student> students = [];
  bool isLoadingClasses = true;
  bool isLoadingStudents = false;
  String? token;
  String? selectedClassId;

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
      await _fetchClasses();
    }
  }

  Future<void> _fetchClasses() async {
    try {
      setState(() => isLoadingClasses = true);

      final response = await http.get(
        Uri.parse('http://localhost:1000/api/classes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> classData = json.decode(response.body);
        setState(() {
          classes = classData
              .map((data) => Class(
                    id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    className:
                        data['class_name']?.toString() ?? 'Unknown Class',
                  ))
              .where((classItem) => classItem.id.isNotEmpty)
              .toList();
        });
      } else {
        _showErrorSnackBar('Failed to load classes: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackBar('Error loading classes: $error');
    } finally {
      setState(() => isLoadingClasses = false);
    }
  }

  Future<void> _fetchStudentsByClass(String classId) async {
    if (token == null || classId.isEmpty) return;

    setState(() {
      isLoadingStudents = true;
      students = [];
    });

    try {
      final selectedClass = classes.firstWhere(
        (c) => c.id == classId,
        orElse: () => Class(id: '', className: 'Unknown'),
      );

      final response = await http.get(
        Uri.parse(
            'http://localhost:1000/api/students/${Uri.encodeComponent(selectedClass.className)}'),
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
                    id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    name: data['student_name']?.toString() ?? 'Unknown Student',
                    registrationNumber:
                        data['registration_number']?.toString() ?? 'N/A',
                    className: selectedClass.className,
                    assignedSection:
                        data['assigned_section']?.toString() ?? 'N/A',
                    studentPhoto: data['student_photo']?.toString() ?? '',
                    admissionDate: data['created_at'] != null
                        ? DateTime.parse(data['created_at'].toString())
                        : DateTime.now(),
                    username: data['username']?.toString() ?? 'N/A',
                    password: data['password']?.toString() ?? 'N/A',
                  ))
              .where((student) => student.id.isNotEmpty)
              .toList();
        });
      } else {
        _showErrorSnackBar('Failed to load students: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackBar('Error loading students: $error');
    } finally {
      setState(() => isLoadingStudents = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _viewAdmissionConfirmation(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdmissionConfirmationPage(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission Letter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Selection Dropdown
            isLoadingClasses
                ? const Center(child: CircularProgressIndicator())
                : classes.isEmpty
                    ? const Center(child: Text('No classes available'))
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Class',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedClassId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('-- Select a Class --'),
                          ),
                          ...classes.map(
                            (classItem) => DropdownMenuItem<String>(
                              value: classItem.id,
                              child: Text(classItem.className),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedClassId = value;
                            if (value != null && value.isNotEmpty) {
                              _fetchStudentsByClass(value);
                            } else {
                              students = [];
                            }
                          });
                        },
                      ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoadingStudents
                  ? const Center(child: CircularProgressIndicator())
                  : selectedClassId == null
                      ? const Center(
                          child: Text('Please select a class to view students'))
                      : students.isEmpty
                          ? const Center(
                              child: Text('No students found in this class'))
                          : ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: _buildStudentPhoto(
                                        student.studentPhoto),
                                    title: Text(student.name),
                                    subtitle: Text(
                                      'Reg: ${student.registrationNumber}\n'
                                      'Section: ${student.assignedSection}\n'
                                      'Class: ${student.className}',
                                    ),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                    onTap: () =>
                                        _viewAdmissionConfirmation(student),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentPhoto(String photoPath) {
    if (photoPath.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(
        photoPath.startsWith('http')
            ? photoPath
            : 'http://localhost:1000/uploads/$photoPath',
      ),
      onBackgroundImageError: (exception, stackTrace) =>
          const Icon(Icons.error),
    );
  }
}

class Class {
  final String id;
  final String className;

  const Class({
    required this.id,
    required this.className,
  });
}

class Student {
  final String id;
  final String name;
  final String registrationNumber;
  final String className;
  final String assignedSection;
  final String studentPhoto;
  final DateTime admissionDate;
  final String username;
  final String password;

  const Student({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.className,
    required this.assignedSection,
    required this.studentPhoto,
    required this.admissionDate,
    required this.username,
    required this.password,
  });
}
