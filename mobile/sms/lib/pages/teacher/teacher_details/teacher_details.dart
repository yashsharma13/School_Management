import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'teacher_model.dart';
import 'teacher_service.dart';
import 'teacher_photo_widget.dart';
import 'pdf_viewer_widget.dart';

const String baseUrl =
    'http://localhost:1000/uploads'; // Base URL for serving static files

class TeacherProfileManagementPage extends StatefulWidget {
  const TeacherProfileManagementPage({super.key});

  @override
  _TeacherProfileManagementPageState createState() =>
      _TeacherProfileManagementPageState();
}

class _TeacherProfileManagementPageState
    extends State<TeacherProfileManagementPage> {
  List<Teacher> teachers = [];
  List<Teacher> filteredTeachers = [];
  final TeacherService _teacherService = TeacherService();
  TextEditingController searchController = TextEditingController();
  // String? selectedClass;
  // String? selectedSection;
  // List<String> classes = [
  //   'Class 1',
  //   'Class 2',
  //   'Class 3',
  //   'Class 4',
  //   'Class 5',
  //   'Class 6',
  //   'Class 7',
  //   'Class 8',
  //   'Class 9',
  //   'Class 10',
  //   'Class 11',
  //   'Class 12'
  // ]; // Example classes
  // List<String> sections = [
  //   'Section A',
  //   'Section B',
  //   'Section C'
  // ]; // Example sections

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      final fetchedTeachers = await _teacherService.fetchTeachers();
      setState(() {
        teachers = fetchedTeachers;
        filteredTeachers = fetchedTeachers; // Initialize filtered list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading teachers: $e')),
      );
    }
  }

  void _filterTeachers() {
    setState(() {
      filteredTeachers = teachers.where((teacher) {
        final nameMatch = teacher.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        // final classMatch =
        //     selectedClass == null || student.assignedClass == selectedClass;
        // final sectionMatch = selectedSection == null ||
        //     student.assignedSection == selectedSection;
        // return nameMatch && classMatch && sectionMatch;
        return nameMatch;
      }).toList();
    });
  }

  // Edit Student Functionality
  Future<void> _editTeacher(Teacher teacher) async {
    final nameController = TextEditingController(text: teacher.name);
    final emailController = TextEditingController(text: teacher.email);
    final dobController = TextEditingController(text: teacher.dateOfBirth);
    final dojController = TextEditingController(text: teacher.dateOfJoining);
    final genderController = TextEditingController(text: teacher.gender);
    final guardianController =
        TextEditingController(text: teacher.guardian_name);
    final qualificationController =
        TextEditingController(text: teacher.qualification);
    final experienceController =
        TextEditingController(text: teacher.experience);
    final salaryController = TextEditingController(text: teacher.salary);
    final addressController = TextEditingController(text: teacher.address);
    final phoneController = TextEditingController(text: teacher.phone);

    String? profilePhoto;
    Uint8List? photoBytes;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Teacher Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: dobController,
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                ),
                TextField(
                  controller: dojController,
                  decoration: InputDecoration(labelText: 'Date of Joining'),
                ),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: guardianController,
                  decoration: InputDecoration(labelText: 'Guardian Name'),
                ),
                TextField(
                  controller: qualificationController,
                  decoration: InputDecoration(labelText: 'Qualification'),
                ),
                TextField(
                  controller: experienceController,
                  decoration: InputDecoration(labelText: 'Experience'),
                ),
                TextField(
                  controller: salaryController,
                  decoration: InputDecoration(labelText: 'Salary'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
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
                          photoBytes = bytes;
                          profilePhoto = base64Encode(bytes);
                        });
                      } else {
                        // For mobile: store the path
                        setState(() {
                          profilePhoto = pickedFile.path;
                        });
                      }
                    }
                  },
                  child: Text('Edit Profile Photo'),
                ),
                if (profilePhoto != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: kIsWeb
                        ? Image.memory(photoBytes!, width: 100, height: 100)
                        : Image.file(
                            File(profilePhoto!),
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
                  final updatedTeacher = {
                    'teacher_name': nameController.text,
                    'email': emailController.text,
                    'date_of_birth': dobController.text,
                    'date_of_joining': dojController.text,
                    'gender': genderController.text,
                    'guardian_name': guardianController.text,
                    'qualification': qualificationController.text,
                    'experience': experienceController.text,
                    'salary': salaryController.text,
                    'address': addressController.text,
                    'phone': phoneController.text,
                    'qualification_certificate':
                        teacher.qualificationCertificate,
                  };

                  // Add photo data only if a new photo is selected
                  if (profilePhoto != null &&
                      profilePhoto != teacher.teacherPhoto) {
                    updatedTeacher['teacher_photo'] = profilePhoto!;
                  } else {
                    updatedTeacher['teacher_photo'] = teacher.teacherPhoto;
                  }

                  // print('Updating teacher with data: $updatedTeacher');

                  // Update student
                  await _teacherService.updateTeacher(teacher, updatedTeacher);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Teacher updated successfully')),
                  );
                  Navigator.of(context).pop();
                  _fetchTeachers(); // Refresh the list
                } catch (e) {
                  // print('Error updating teacher: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update teacher: $e')),
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
  Future<void> _deleteTeacher(int index) async {
    final teacher = filteredTeachers[index];

    bool? confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete teacher'),
          content: Text('Are you sure you want to delete ${teacher.name}?'),
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
        await _teacherService.deleteTeacher(teacher.id);
        setState(() {
          teachers.removeWhere((t) => t.id == teacher.id);
          filteredTeachers.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete teacher: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Profile Management'),
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
              onChanged: (value) => _filterTeachers(),
            ),
          ),
          Expanded(
            child: filteredTeachers.isEmpty
                ? Center(
                    child: Text('No teachers found'),
                  )
                : ListView.builder(
                    itemCount: filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = filteredTeachers[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(teacher.name),
                          leading:
                              buildTeacherPhoto(teacher.teacherPhoto, baseUrl),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editTeacher(teacher),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteTeacher(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf),
                                onPressed: () {
                                  if (teacher
                                      .qualificationCertificate.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFViewerScreen(
                                          pdfData:
                                              teacher.qualificationCertificate,
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
