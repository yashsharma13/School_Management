import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms/pages/teacher/Job_letter/confirm_letter.dart';
import 'dart:convert';

class TeacherAdmissionLetterPage extends StatefulWidget {
  const TeacherAdmissionLetterPage({Key? key}) : super(key: key);

  @override
  State<TeacherAdmissionLetterPage> createState() =>
      _TeacherAdmissionLetterPageState();
}

class _TeacherAdmissionLetterPageState
    extends State<TeacherAdmissionLetterPage> {
  List<Teacher> teachers = [];
  List<Teacher> filteredTeachers = [];
  bool isLoading = true;
  String? token;
  String? searchQuery;

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
      await _fetchTeachers();
    }
  }

  Future<void> _fetchTeachers() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse('http://localhost:1000/api/teachers'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> teacherData = json.decode(response.body);
        setState(() {
          teachers = teacherData
              .map((data) => Teacher(
                    id: data['_id']?.toString() ?? '',
                    name: data['teacher_name']?.toString() ?? 'Unknown Teacher',
                    email: data['email']?.toString() ?? 'N/A',
                    dateOfBirth: data['date_of_birth']?.toString() ?? 'N/A',
                    dateOfJoining: data['date_of_joining']?.toString() ?? 'N/A',
                    gender: data['gender']?.toString() ?? 'N/A',
                    qualification: data['qualification']?.toString() ?? 'N/A',
                    experience: data['experience']?.toString() ?? 'N/A',
                    salary: data['salary']?.toString() ?? 'N/A',
                    address: data['address']?.toString() ?? 'N/A',
                    phone: data['phone']?.toString() ?? 'N/A',
                    teacherPhoto: data['teacher_photo']?.toString() ?? '',
                    qualificationCertificate:
                        data['qualification_certificate']?.toString() ?? '',
                  ))
              .where((teacher) => teacher.id.isNotEmpty)
              .toList();

          filteredTeachers = List.from(teachers);
        });
      } else {
        _showErrorSnackBar('Failed to load teachers: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackBar('Error loading teachers: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterTeachers() {
    setState(() {
      if (searchQuery == null || searchQuery!.isEmpty) {
        filteredTeachers = List.from(teachers);
      } else {
        filteredTeachers = teachers.where((teacher) {
          return teacher.name
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase()) ||
              teacher.email
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase()) ||
              teacher.qualification
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase());
        }).toList();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red[800],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ));
  }

  void _viewAdmissionConfirmation(Teacher teacher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TeacherAdmissionConfirmationPage(teacher: teacher),
      ),
    );
  }

  Widget _buildTeacherPhoto(String photoPath) {
    if (photoPath.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.person, color: Colors.blue[800]),
      );
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(
        photoPath.startsWith('http')
            ? photoPath
            : 'http://localhost:1000/uploads/$photoPath',
      ),
      onBackgroundImageError: (exception, stackTrace) =>
          Icon(Icons.error, color: Colors.red[800]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Admission Letters',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Card
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
                    Text('Search Teachers',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800])),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search by name, email or qualification',
                        labelStyle: TextStyle(color: Colors.blue[800]),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.blue[800]),
                          onPressed: () {
                            setState(() {
                              searchQuery = null;
                              _filterTeachers();
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          _filterTeachers();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Teacher List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue))
                  : filteredTeachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 48, color: Colors.blue[800]),
                              const SizedBox(height: 16),
                              Text(
                                  searchQuery == null || searchQuery!.isEmpty
                                      ? 'No teachers found'
                                      : 'No teachers match your search',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blue[900])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = filteredTeachers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading:
                                    _buildTeacherPhoto(teacher.teacherPhoto),
                                title: Text(teacher.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900])),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${teacher.email}',
                                        style:
                                            TextStyle(color: Colors.blue[800])),
                                    Text(
                                        'Qualification: ${teacher.qualification}',
                                        style:
                                            TextStyle(color: Colors.blue[800])),
                                    Text('Joined: ${teacher.dateOfJoining}',
                                        style:
                                            TextStyle(color: Colors.blue[800])),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.arrow_forward,
                                      color: Colors.blue[800], size: 20),
                                ),
                                onTap: () =>
                                    _viewAdmissionConfirmation(teacher),
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
}

class Teacher {
  final String id;
  final String name;
  final String email;
  final String dateOfBirth;
  final String dateOfJoining;
  final String gender;
  final String qualification;
  final String experience;
  final String salary;
  final String address;
  final String phone;
  final String teacherPhoto;
  final String qualificationCertificate;

  const Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.dateOfJoining,
    required this.gender,
    required this.qualification,
    required this.experience,
    required this.salary,
    required this.address,
    required this.phone,
    required this.teacherPhoto,
    required this.qualificationCertificate,
  });
}
