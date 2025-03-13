// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'student_model.dart';
// import 'student_service.dart';
// import 'student_photo_widget.dart';
// import 'pdf_viewer_widget.dart';

// class StudentProfileManagementPage extends StatefulWidget {
//   @override
//   _StudentProfileManagementPageState createState() =>
//       _StudentProfileManagementPageState();
// }

// class _StudentProfileManagementPageState
//     extends State<StudentProfileManagementPage> {
//   List<Student> students = [];
//   final StudentService _studentService = StudentService();

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudents();
//   }

//   Future<void> _fetchStudents() async {
//     try {
//       final fetchedStudents = await _studentService.fetchStudents();
//       setState(() {
//         students = fetchedStudents;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading students: $e')),
//       );
//     }
//   }

//   // Edit Student Functionality
//   Future<void> _editStudent(Student student) async {
//     final _nameController = TextEditingController(text: student.name);
//     final _registrationController =
//         TextEditingController(text: student.registrationNumber);
//     final _dobController = TextEditingController(text: student.dateOfBirth);
//     final _genderController = TextEditingController(text: student.gender);
//     final _addressController = TextEditingController(text: student.address);
//     final _fatherNameController =
//         TextEditingController(text: student.fatherName);
//     final _motherNameController =
//         TextEditingController(text: student.motherName);
//     final _emailController = TextEditingController(text: student.email);
//     final _phoneController = TextEditingController(text: student.phone);
//     final _classController = TextEditingController(text: student.assignedClass);
//     final _sectionController =
//         TextEditingController(text: student.assignedSection);

//     String? _profilePhoto;
//     Uint8List? _photoBytes;

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Edit Student Details'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _nameController,
//                   decoration: InputDecoration(labelText: 'Name'),
//                 ),
//                 TextField(
//                   controller: _registrationController,
//                   decoration: InputDecoration(labelText: 'Registration Number'),
//                 ),
//                 TextField(
//                   controller: _dobController,
//                   decoration: InputDecoration(labelText: 'Date of Birth'),
//                 ),
//                 TextField(
//                   controller: _genderController,
//                   decoration: InputDecoration(labelText: 'Gender'),
//                 ),
//                 TextField(
//                   controller: _addressController,
//                   decoration: InputDecoration(labelText: 'Address'),
//                 ),
//                 TextField(
//                   controller: _fatherNameController,
//                   decoration: InputDecoration(labelText: 'Father Name'),
//                 ),
//                 TextField(
//                   controller: _motherNameController,
//                   decoration: InputDecoration(labelText: 'Mother Name'),
//                 ),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(labelText: 'Email'),
//                 ),
//                 TextField(
//                   controller: _phoneController,
//                   decoration: InputDecoration(labelText: 'Phone'),
//                 ),
//                 TextField(
//                   controller: _classController,
//                   decoration: InputDecoration(labelText: 'Assigned Class'),
//                 ),
//                 TextField(
//                   controller: _sectionController,
//                   decoration: InputDecoration(labelText: 'Assigned Section'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final pickedFile = await ImagePicker()
//                         .pickImage(source: ImageSource.gallery);
//                     if (pickedFile != null) {
//                       if (kIsWeb) {
//                         // For web: read bytes immediately
//                         final bytes = await pickedFile.readAsBytes();
//                         setState(() {
//                           _photoBytes = bytes;
//                           _profilePhoto = base64Encode(bytes);
//                         });
//                       } else {
//                         // For mobile: store the path
//                         setState(() {
//                           _profilePhoto = pickedFile.path;
//                         });
//                       }
//                     }
//                   },
//                   child: Text('Edit Profile Photo'),
//                 ),
//                 if (_profilePhoto != null)
//                   Padding(
//                     padding: EdgeInsets.only(top: 10),
//                     child: kIsWeb
//                         ? Image.memory(_photoBytes!, width: 100, height: 100)
//                         : Image.file(File(_profilePhoto!),
//                             width: 100, height: 100),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 try {
//                   // Prepare updated data
//                   final updatedStudent = {
//                     'student_name': _nameController.text,
//                     'registration_number': _registrationController.text,
//                     'date_of_birth': _dobController.text,
//                     'gender': _genderController.text,
//                     'address': _addressController.text,
//                     'father_name': _fatherNameController.text,
//                     'mother_name': _motherNameController.text,
//                     'email': _emailController.text,
//                     'phone': _phoneController.text,
//                     'assigned_class': _classController.text,
//                     'assigned_section': _sectionController.text,
//                     'birth_certificate': student.birthCertificate,
//                   };

//                   // Add photo data only if a new photo is selected
//                   if (_profilePhoto != null &&
//                       _profilePhoto != student.studentPhoto) {
//                     updatedStudent['student_photo'] = _profilePhoto!;
//                   } else {
//                     updatedStudent['student_photo'] = student.studentPhoto;
//                   }

//                   print('Updating student with data: $updatedStudent');

//                   // Update student
//                   await _studentService.updateStudent(student, updatedStudent);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Student updated successfully')),
//                   );
//                   Navigator.of(context).pop();
//                   _fetchStudents(); // Refresh the list
//                 } catch (e) {
//                   print('Error updating student: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to update student: $e')),
//                   );
//                 }
//               },
//               child: Text('Save'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Delete Student Functionality
//   Future<void> _deleteStudent(int index) async {
//     final student = students[index];

//     bool? confirmed = await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Delete Student'),
//           content: Text('Are you sure you want to delete ${student.name}?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text('Yes'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text('No'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed == true) {
//       try {
//         await _studentService.deleteStudent(student.id);
//         setState(() {
//           students.removeAt(index);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Student deleted successfully')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete student: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Profile Management'),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         itemCount: students.length,
//         itemBuilder: (context, index) {
//           final student = students[index];
//           return Card(
//             margin: EdgeInsets.all(8.0),
//             child: ListTile(
//               title: Text(student.name),
//               subtitle: Text(
//                   'Reg: ${student.registrationNumber}\nClass: ${student.assignedClass} - ${student.assignedSection}'),
//               leading: buildStudentPhoto(student.studentPhoto, baseUrl),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.edit),
//                     onPressed: () => _editStudent(student),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () => _deleteStudent(index),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.picture_as_pdf),
//                     onPressed: () {
//                       if (student.birthCertificate.isNotEmpty) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PDFViewerScreen(
//                               pdfData: student.birthCertificate,
//                               baseUrl: baseUrl,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'student_model.dart';
import 'student_service.dart';
import 'student_photo_widget.dart';
import 'pdf_viewer_widget.dart';

class StudentProfileManagementPage extends StatefulWidget {
  @override
  _StudentProfileManagementPageState createState() =>
      _StudentProfileManagementPageState();
}

class _StudentProfileManagementPageState
    extends State<StudentProfileManagementPage> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  final StudentService _studentService = StudentService();
  TextEditingController searchController = TextEditingController();
  String? selectedClass;
  String? selectedSection;
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
  ]; // Example classes
  List<String> sections = [
    'Section A',
    'Section B',
    'Section C'
  ]; // Example sections

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final fetchedStudents = await _studentService.fetchStudents();
      setState(() {
        students = fetchedStudents;
        filteredStudents = fetchedStudents; // Initialize filtered list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
    }
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        final nameMatch = student.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        final classMatch =
            selectedClass == null || student.assignedClass == selectedClass;
        final sectionMatch = selectedSection == null ||
            student.assignedSection == selectedSection;
        return nameMatch && classMatch && sectionMatch;
      }).toList();
    });
  }

  // Edit Student Functionality
  Future<void> _editStudent(Student student) async {
    final _nameController = TextEditingController(text: student.name);
    final _registrationController =
        TextEditingController(text: student.registrationNumber);
    final _dobController = TextEditingController(text: student.dateOfBirth);
    final _genderController = TextEditingController(text: student.gender);
    final _addressController = TextEditingController(text: student.address);
    final _fatherNameController =
        TextEditingController(text: student.fatherName);
    final _motherNameController =
        TextEditingController(text: student.motherName);
    final _emailController = TextEditingController(text: student.email);
    final _phoneController = TextEditingController(text: student.phone);
    final _classController = TextEditingController(text: student.assignedClass);
    final _sectionController =
        TextEditingController(text: student.assignedSection);

    String? _profilePhoto;
    Uint8List? _photoBytes;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Student Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _registrationController,
                  decoration: InputDecoration(labelText: 'Registration Number'),
                ),
                TextField(
                  controller: _dobController,
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                ),
                TextField(
                  controller: _genderController,
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _fatherNameController,
                  decoration: InputDecoration(labelText: 'Father Name'),
                ),
                TextField(
                  controller: _motherNameController,
                  decoration: InputDecoration(labelText: 'Mother Name'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _classController,
                  decoration: InputDecoration(labelText: 'Assigned Class'),
                ),
                TextField(
                  controller: _sectionController,
                  decoration: InputDecoration(labelText: 'Assigned Section'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      if (kIsWeb) {
                        // For web: read bytes immediately
                        final bytes = await pickedFile.readAsBytes();
                        setState(() {
                          _photoBytes = bytes;
                          _profilePhoto = base64Encode(bytes);
                        });
                      } else {
                        // For mobile: store the path
                        setState(() {
                          _profilePhoto = pickedFile.path;
                        });
                      }
                    }
                  },
                  child: Text('Edit Profile Photo'),
                ),
                if (_profilePhoto != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: kIsWeb
                        ? Image.memory(_photoBytes!, width: 100, height: 100)
                        : Image.file(
                            File(_profilePhoto!),
                          ),
                  )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Prepare updated data
                  final updatedStudent = {
                    'student_name': _nameController.text,
                    'registration_number': _registrationController.text,
                    'date_of_birth': _dobController.text,
                    'gender': _genderController.text,
                    'address': _addressController.text,
                    'father_name': _fatherNameController.text,
                    'mother_name': _motherNameController.text,
                    'email': _emailController.text,
                    'phone': _phoneController.text,
                    'assigned_class': _classController.text,
                    'assigned_section': _sectionController.text,
                    'birth_certificate': student.birthCertificate,
                  };

                  // Add photo data only if a new photo is selected
                  if (_profilePhoto != null &&
                      _profilePhoto != student.studentPhoto) {
                    updatedStudent['student_photo'] = _profilePhoto!;
                  } else {
                    updatedStudent['student_photo'] = student.studentPhoto;
                  }

                  print('Updating student with data: $updatedStudent');

                  // Update student
                  await _studentService.updateStudent(student, updatedStudent);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Student updated successfully')),
                  );
                  Navigator.of(context).pop();
                  _fetchStudents(); // Refresh the list
                } catch (e) {
                  print('Error updating student: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update student: $e')),
                  );
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Delete Student Functionality
  Future<void> _deleteStudent(int index) async {
    final student = filteredStudents[index];

    bool? confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Student'),
          content: Text('Are you sure you want to delete ${student.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _studentService.deleteStudent(student.id);
        setState(() {
          students.removeWhere((s) => s.id == student.id);
          filteredStudents.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete student: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterStudents(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedClass,
                    hint: Text('Select Class'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedClass = newValue;
                        _filterStudents();
                      });
                    },
                    items:
                        classes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedSection,
                    hint: Text('Select Section'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSection = newValue;
                        _filterStudents();
                      });
                    },
                    items:
                        sections.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(
                    child: Text(
                      selectedClass == null && selectedSection == null
                          ? 'No students found.'
                          : 'No students found in ${selectedClass ?? ''} ${selectedSection ?? ''}',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(student.name),
                          subtitle: Text(
                              'Reg: ${student.registrationNumber}\nClass: ${student.assignedClass} - ${student.assignedSection}'),
                          leading:
                              buildStudentPhoto(student.studentPhoto, baseUrl),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editStudent(student),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteStudent(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf),
                                onPressed: () {
                                  if (student.birthCertificate.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFViewerScreen(
                                          pdfData: student.birthCertificate,
                                          baseUrl: baseUrl,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
