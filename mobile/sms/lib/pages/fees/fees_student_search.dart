import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sms/pages/fees/fees_collection_detail_page.dart';

class FeesStudentSearchPage extends StatefulWidget {
  @override
  _FeesStudentSearchPageState createState() => _FeesStudentSearchPageState();
}

class _FeesStudentSearchPageState extends State<FeesStudentSearchPage> {
  List<Class> classes = [];
  List<Student> students = [];
  List<Student> filteredStudents = [];
  bool isLoadingClasses = true;
  bool isLoadingStudents = false;
  String? token;
  String? selectedClassId;
  String? selectedClassName;
  String? selectedSection;
  List<String> availableSections = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken();
    searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        final Map<String, Class> classMap = {};

        for (final data in classData) {
          if (data is! Map<String, dynamic>) continue;

          final rawClassName =
              (data['class_name'] ?? data['className'] ?? '').toString().trim();

          if (rawClassName.isEmpty) continue;

          // Normalize className (lowercase) as key for grouping
          final classNameKey = rawClassName.toLowerCase();

          final section = (data['section'] ?? '').toString().trim();

          // If class already exists, add section if not present
          if (classMap.containsKey(classNameKey)) {
            if (section.isNotEmpty &&
                !classMap[classNameKey]!.sections.contains(section)) {
              classMap[classNameKey]!.sections.add(section);
            }
          } else {
            // Create new Class object; id can be classNameKey or empty string
            classMap[classNameKey] = Class(
              id: classNameKey,
              className: rawClassName,
              sections: section.isNotEmpty ? [section] : [],
              tuitionFees: data['tuition_fees']?.toString() ?? '0',
            );
          }
        }

        // Sort sections inside each class
        for (final classObj in classMap.values) {
          classObj.sections.sort();
        }

        final classesList = classMap.values.toList()
          ..sort((a, b) => a.className.compareTo(b.className));

        setState(() {
          classes = classesList;
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

  void _updateAvailableSections(String? classId) {
    setState(() {
      if (classId != null) {
        final selectedClass = classes.firstWhere(
          (c) => c.id == classId,
          orElse: () =>
              Class(id: '', className: '', tuitionFees: '0', sections: []),
        );
        availableSections = selectedClass.sections;
        selectedClassName = selectedClass.className;
      } else {
        availableSections = [];
        selectedClassName = null;
      }
      selectedSection = null;
      _filterStudents();
    });
  }

  Future<void> _fetchStudentsByClass(String classId) async {
    if (token == null) return;

    setState(() {
      isLoadingStudents = true;
      filteredStudents = [];
    });

    try {
      Class selectedClass = classes.firstWhere(
        (c) => c.id == classId,
        orElse: () =>
            Class(id: '', className: 'Unknown', tuitionFees: '0', sections: []),
      );

      String encodedClassName = Uri.encodeComponent(selectedClass.className);

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
                    id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    name: data['student_name']?.toString() ?? 'Unknown Student',
                    registrationNumber:
                        data['registration_number']?.toString() ?? '',
                    assignedClassId: classId,
                    className: selectedClass.className,
                    assignedSection: data['assigned_section']?.toString() ?? '',
                    studentPhoto: data['student_photo']?.toString() ?? '',
                  ))
              .where((student) => student.id.isNotEmpty)
              .toList();

          _filterStudents();
        });
      } else {
        _showErrorSnackBar('Failed to load students: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error loading students: $error');
    } finally {
      setState(() {
        isLoadingStudents = false;
      });
    }
  }

  void _filterStudents() {
    String searchText = searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        final nameMatch = student.name.toLowerCase().contains(searchText);
        final sectionMatch = selectedSection == null ||
            student.assignedSection == selectedSection;
        return nameMatch && sectionMatch;
      }).toList();
    });
  }

  void _openFeesCollectPage(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeesCollectionPage(
          studentId: student.id,
          studentName: student.name,
          studentClass: student.className,
          studentSection: student.assignedSection,
          monthlyFee: classes
              .firstWhere(
                (c) => c.id == student.assignedClassId,
                orElse: () => Class(
                    id: '',
                    className: 'Unknown',
                    tuitionFees: '0',
                    sections: []),
              )
              .tuitionFees,
          isNewAdmission: false,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Fees Collection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class and Section Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter Students',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800])),
                    const SizedBox(height: 12),

                    // Class Dropdown
                    isLoadingClasses
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[800]!),
                            ),
                          )
                        : classes.isEmpty
                            ? Center(child: Text('No classes available'))
                            : DropdownButtonFormField<String>(
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
                                value: selectedClassId,
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('-- Select a Class --',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ),
                                  ...classes.map(
                                    (classItem) => DropdownMenuItem<String>(
                                      value: classItem.id,
                                      child: Text(classItem.className,
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedClassId = value;
                                    _updateAvailableSections(value);
                                    if (value != null) {
                                      _fetchStudentsByClass(value);
                                    } else {
                                      students = [];
                                      filteredStudents = [];
                                    }
                                  });
                                },
                              ),

                    // Section Dropdown (only visible when a class is selected)
                    // if (selectedClassId != null && selectedClassId!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Section',
                          labelStyle: TextStyle(color: Colors.blue[800]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.blue[50],
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: selectedSection,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('-- All Sections --',
                                style: TextStyle(color: Colors.grey[600])),
                          ),
                          ...availableSections.map(
                            (section) => DropdownMenuItem<String>(
                              value: section,
                              child: Text(section,
                                  style: TextStyle(color: Colors.blue[900])),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSection = value;
                            _filterStudents();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Search Field
            if (selectedClassId != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Student',
                    labelStyle: TextStyle(color: Colors.blue[800]),
                    prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

            SizedBox(height: 16),

            if (selectedClassId != null)
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),

            SizedBox(height: 8),

            Expanded(
              child: isLoadingStudents
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                      ),
                    )
                  : selectedClassId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school,
                                color: Colors.blue[800],
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Please select a class to view students',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredStudents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    selectedSection == null
                                        ? Icons.people_outline
                                        : Icons.filter_alt_outlined,
                                    color: Colors.blue[800],
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    selectedSection == null
                                        ? 'No students found in this class'
                                        : 'No students found in this section',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: _buildStudentPhoto(
                                        student.studentPhoto),
                                    title: Text(
                                      student.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reg: ${student.registrationNumber}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        Text(
                                          'Class: ${student.className} • Section: ${student.assignedSection}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.blue[800],
                                        size: 20,
                                      ),
                                    ),
                                    onTap: () => _openFeesCollectPage(student),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
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
      return CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(
          Icons.person,
          color: Colors.blue[800],
        ),
      );
    }
    if (photoPath.startsWith('http')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(photoPath),
      );
    } else {
      return CircleAvatar(
        backgroundImage:
            NetworkImage('http://localhost:1000/uploads/$photoPath'),
      );
    }
  }
}

class Class {
  final String id;
  final String className;
  final String tuitionFees;
  List<String> sections;

  Class({
    required this.id,
    required this.className,
    required this.tuitionFees,
    required this.sections,
  });
}

class Student {
  final String id;
  final String name;
  final String registrationNumber;
  final String assignedClassId;
  final String className;
  final String assignedSection;
  final String studentPhoto;

  Student({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.assignedClassId,
    required this.className,
    required this.assignedSection,
    required this.studentPhoto,
  });
}
