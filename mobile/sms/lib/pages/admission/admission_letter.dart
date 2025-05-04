// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:sms/pages/admission/admission_confirm.dart';
// import 'dart:convert';

// class AdmissionLetterPage extends StatefulWidget {
//   const AdmissionLetterPage({Key? key}) : super(key: key);

//   @override
//   State<AdmissionLetterPage> createState() => _AdmissionLetterPageState();
// }

// class _AdmissionLetterPageState extends State<AdmissionLetterPage> {
//   List<Class> classes = [];
//   List<Student> students = [];
//   bool isLoadingClasses = true;
//   bool isLoadingStudents = false;
//   String? token;
//   String? selectedClassId;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });

//     if (token != null) {
//       await _fetchClasses();
//     }
//   }

//   Future<void> _fetchClasses() async {
//     try {
//       setState(() => isLoadingClasses = true);

//       final response = await http.get(
//         Uri.parse('http://localhost:1000/api/classes'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token ?? '',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> classData = json.decode(response.body);
//         setState(() {
//           classes = classData
//               .map((data) => Class(
//                     id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
//                     className:
//                         data['class_name']?.toString() ?? 'Unknown Class',
//                   ))
//               .where((classItem) => classItem.id.isNotEmpty)
//               .toList();
//         });
//       } else {
//         _showErrorSnackBar('Failed to load classes: ${response.statusCode}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error loading classes: $error');
//     } finally {
//       setState(() => isLoadingClasses = false);
//     }
//   }

//   Future<void> _fetchStudentsByClass(String classId) async {
//     if (token == null || classId.isEmpty) return;

//     setState(() {
//       isLoadingStudents = true;
//       students = [];
//     });

//     try {
//       final selectedClass = classes.firstWhere(
//         (c) => c.id == classId,
//         orElse: () => Class(id: '', className: 'Unknown'),
//       );

//       final response = await http.get(
//         Uri.parse(
//             'http://localhost:1000/api/students/${Uri.encodeComponent(selectedClass.className)}'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> studentData = json.decode(response.body);
//         setState(() {
//           students = studentData
//               .map((data) => Student(
//                     id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
//                     name: data['student_name']?.toString() ?? 'Unknown Student',
//                     registrationNumber:
//                         data['registration_number']?.toString() ?? 'N/A',
//                     className: selectedClass.className,
//                     assignedSection:
//                         data['assigned_section']?.toString() ?? 'N/A',
//                     studentPhoto: data['student_photo']?.toString() ?? '',
//                     admissionDate: data['created_at'] != null
//                         ? DateTime.parse(data['created_at'].toString())
//                         : DateTime.now(),
//                     username: data['username']?.toString() ?? 'N/A',
//                     password: data['password']?.toString() ?? 'N/A',
//                   ))
//               .where((student) => student.id.isNotEmpty)
//               .toList();
//         });
//       } else {
//         _showErrorSnackBar('Failed to load students: ${response.statusCode}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error loading students: $error');
//     } finally {
//       setState(() => isLoadingStudents = false);
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _viewAdmissionConfirmation(Student student) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AdmissionConfirmationPage(student: student),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admission Letter'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Class Selection Dropdown
//             isLoadingClasses
//                 ? const Center(child: CircularProgressIndicator())
//                 : classes.isEmpty
//                     ? const Center(child: Text('No classes available'))
//                     : DropdownButtonFormField<String>(
//                         decoration: const InputDecoration(
//                           labelText: 'Select Class',
//                           border: OutlineInputBorder(),
//                         ),
//                         value: selectedClassId,
//                         items: [
//                           const DropdownMenuItem<String>(
//                             value: null,
//                             child: Text('-- Select a Class --'),
//                           ),
//                           ...classes.map(
//                             (classItem) => DropdownMenuItem<String>(
//                               value: classItem.id,
//                               child: Text(classItem.className),
//                             ),
//                           ),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             selectedClassId = value;
//                             if (value != null && value.isNotEmpty) {
//                               _fetchStudentsByClass(value);
//                             } else {
//                               students = [];
//                             }
//                           });
//                         },
//                       ),

//             const SizedBox(height: 16),

//             Expanded(
//               child: isLoadingStudents
//                   ? const Center(child: CircularProgressIndicator())
//                   : selectedClassId == null
//                       ? const Center(
//                           child: Text('Please select a class to view students'))
//                       : students.isEmpty
//                           ? const Center(
//                               child: Text('No students found in this class'))
//                           : ListView.builder(
//                               itemCount: students.length,
//                               itemBuilder: (context, index) {
//                                 final student = students[index];
//                                 return Card(
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 8),
//                                   child: ListTile(
//                                     leading: _buildStudentPhoto(
//                                         student.studentPhoto),
//                                     title: Text(student.name),
//                                     subtitle: Text(
//                                       'Reg: ${student.registrationNumber}\n'
//                                       'Section: ${student.assignedSection}\n'
//                                       'Class: ${student.className}',
//                                     ),
//                                     trailing:
//                                         const Icon(Icons.arrow_forward_ios),
//                                     onTap: () =>
//                                         _viewAdmissionConfirmation(student),
//                                   ),
//                                 );
//                               },
//                             ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentPhoto(String photoPath) {
//     if (photoPath.isEmpty) {
//       return const CircleAvatar(child: Icon(Icons.person));
//     }
//     return CircleAvatar(
//       backgroundImage: NetworkImage(
//         photoPath.startsWith('http')
//             ? photoPath
//             : 'http://localhost:1000/uploads/$photoPath',
//       ),
//       onBackgroundImageError: (exception, stackTrace) =>
//           const Icon(Icons.error),
//     );
//   }
// }

// class Class {
//   final String id;
//   final String className;

//   const Class({
//     required this.id,
//     required this.className,
//   });
// }

// class Student {
//   final String id;
//   final String name;
//   final String registrationNumber;
//   final String className;
//   final String assignedSection;
//   final String studentPhoto;
//   final DateTime admissionDate;
//   final String username;
//   final String password;

//   const Student({
//     required this.id,
//     required this.name,
//     required this.registrationNumber,
//     required this.className,
//     required this.assignedSection,
//     required this.studentPhoto,
//     required this.admissionDate,
//     required this.username,
//     required this.password,
//   });
// }

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
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
        title: const Text('Admission Letters',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Selection Card
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
                    Text('Select Class',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800])),
                    const SizedBox(height: 12),
                    isLoadingClasses
                        ? const Center(child: CircularProgressIndicator())
                        : classes.isEmpty
                            ? const Center(child: Text('No classes available'))
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                value: selectedClassId,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('-- Select a Class --',
                                        style: TextStyle(color: Colors.grey)),
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
                                    if (value != null && value.isNotEmpty) {
                                      _fetchStudentsByClass(value);
                                    } else {
                                      students = [];
                                    }
                                  });
                                },
                              ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Student List
            Expanded(
              child: isLoadingStudents
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue))
                  : selectedClassId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school,
                                  size: 48, color: Colors.blue[800]),
                              const SizedBox(height: 16),
                              Text('Please select a class to view students',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blue[900])),
                            ],
                          ),
                        )
                      : students.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 48, color: Colors.blue[800]),
                                  const SizedBox(height: 16),
                                  Text('No students found in this class',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue[900])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    leading: _buildStudentPhoto(
                                        student.studentPhoto),
                                    title: Text(student.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900])),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Reg: ${student.registrationNumber}',
                                            style: TextStyle(
                                                color: Colors.blue[800])),
                                        Text(
                                            'Class: ${student.className} • Section: ${student.assignedSection}',
                                            style: TextStyle(
                                                color: Colors.blue[800])),
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
