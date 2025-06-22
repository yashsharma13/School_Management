import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'student_model.dart';
import 'student_service.dart';
import 'student_photo_widget.dart';
import 'pdf_viewer_widget.dart';
import 'package:sms/pages/services/api_service.dart';

// const String baseUrl = 'http://localhost:1000/uploads';
final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
final String uploadBaseUrl = '$baseeUrl/uploads';

class StudentProfileManagementPage extends StatefulWidget {
  const StudentProfileManagementPage({super.key});

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
  List<Class> classes = [];
  List<String> availableSections = [];
  bool _isLoading = true;
  String? token;

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
      await _fetchInitialData();
    }
  }

  Future<void> _loadClasses() async {
    try {
      setState(() => _isLoading = true);
      final fetchedClasses = await ApiService.fetchClasses();

      final Map<String, Set<String>> classSectionMap = {};
      final List<Class> tempClasses = [];

      for (final data in fetchedClasses) {
        final className =
            (data['class_name'] ?? data['className'] ?? '').toString().trim();
        final section = (data['section'] ?? '').toString().trim();

        if (className.isEmpty) continue;

        if (!classSectionMap.containsKey(className)) {
          classSectionMap[className] = {};
        }

        classSectionMap[className]!.add(section);
      }

      classSectionMap.forEach((className, sections) {
        tempClasses.add(Class(
          id: className,
          className: className,
          sections: sections.toList(),
        ));
      });

      setState(() {
        classes = tempClasses;
      });
    } catch (error) {
      _showErrorSnackBar('Error fetching classes: ${error.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateAvailableSections(String? className) {
    setState(() {
      if (className != null) {
        final selectedClassObj =
            classes.firstWhere((c) => c.className == className);
        availableSections = selectedClassObj.sections;
      } else {
        availableSections = [];
      }
      selectedSection = null;
    });
    _filterStudents();
  }

  Future<void> _fetchInitialData() async {
    await _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final fetchedStudents = await _studentService.fetchStudents();
      setState(() {
        students = fetchedStudents;
        filteredStudents = fetchedStudents;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
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

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _editStudent(Student student) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: student.name);
    final registrationController =
        TextEditingController(text: student.registrationNumber);
    final dobController =
        TextEditingController(text: formatDate(student.dateOfBirth));
    final genderController = TextEditingController(text: student.gender);
    final addressController = TextEditingController(text: student.address);
    final fatherNameController =
        TextEditingController(text: student.fatherName);
    final motherNameController =
        TextEditingController(text: student.motherName);
    final emailController = TextEditingController(text: student.email);
    final phoneController = TextEditingController(text: student.phone);

    String? newClass = student.assignedClass;
    String? newSection = student.assignedSection;
    String? profilePhoto = student.studentPhoto;
    Uint8List? photoBytes;
    File? selectedImage;

    String parseDate(String formattedDate) {
      try {
        if (formattedDate.isEmpty) return '';
        List<String> parts = formattedDate.split('-');
        if (parts.length != 3) return formattedDate;
        DateTime date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } catch (e) {
        return formattedDate;
      }
    }

    Future<void> selectDate() async {
      DateTime initialDate = DateTime.now();
      try {
        if (student.dateOfBirth.isNotEmpty) {
          List<String> parts = student.dateOfBirth.split('-');
          if (parts.length == 3) {
            initialDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
      }

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        dobController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Get sections for the selected class
            List<String> editSections = [];
            if (newClass != null) {
              final classObj = classes.firstWhere(
                (c) => c.className == newClass,
                orElse: () => Class(id: '', className: '', sections: []),
              );
              editSections = classObj.sections;
            }

            return Theme(
              data: Theme.of(context).copyWith(
                dialogBackgroundColor: Colors.white,
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
                  ),
                ),
              ),
              child: Dialog(
                insetPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Edit Student',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 20),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Current Photo',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.blue[100]!,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: buildStudentPhoto(
                                              student.studentPhoto,
                                              uploadBaseUrl),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (selectedImage != null ||
                                      photoBytes != null)
                                    Column(
                                      children: [
                                        Text(
                                          'New Photo',
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.green[100]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: kIsWeb
                                                ? Image.memory(photoBytes!,
                                                    fit: BoxFit.cover)
                                                : Image.file(selectedImage!,
                                                    fit: BoxFit.cover),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: Icon(Icons.camera_alt, size: 20),
                                label: Text('Update Photo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    if (kIsWeb) {
                                      final bytes =
                                          await pickedFile.readAsBytes();
                                      setState(() {
                                        photoBytes = bytes;
                                        profilePhoto = base64Encode(bytes);
                                      });
                                    } else {
                                      setState(() {
                                        selectedImage = File(pickedFile.path);
                                        profilePhoto = pickedFile.path;
                                      });
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              _buildEditField(nameController, 'Name', true),
                              // _buildEditField(registrationController,
                              //     'Registration Number', false),
                              TextFormField(
                                controller: dobController,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth (DD-MM-YYYY)',
                                  labelStyle:
                                      TextStyle(color: Colors.blue[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.blue[800]!, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue[50],
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today,
                                        color: Colors.blue[800]),
                                    onPressed: selectDate,
                                  ),
                                ),
                                readOnly: true,
                                validator: (value) => value!.isEmpty
                                    ? 'Date of Birth is required'
                                    : null,
                              ),
                              SizedBox(height: 16),
                              _buildEditField(genderController, 'Gender', true),
                              _buildEditField(
                                  addressController, 'Address', true),
                              _buildEditField(
                                  fatherNameController, 'Father Name', true),
                              _buildEditField(
                                  motherNameController, 'Mother Name', true),
                              // _buildEditField(emailController, 'Email', true),
                              // _buildEditField(phoneController, 'Phone', true),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: newClass,
                                decoration: InputDecoration(
                                  labelText: 'Class',
                                  labelStyle:
                                      TextStyle(color: Colors.blue[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[800]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue[50],
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Select Class',
                                        style:
                                            TextStyle(color: Colors.blue[900])),
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
                                onChanged: (value) {
                                  setState(() {
                                    newClass = value;
                                    newSection = null;
                                    if (value != null) {
                                      final selectedClassObj =
                                          classes.firstWhere(
                                              (c) => c.className == value);
                                      editSections = selectedClassObj.sections;
                                    } else {
                                      editSections = [];
                                    }
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: newSection,
                                decoration: InputDecoration(
                                  labelText: 'Section',
                                  labelStyle:
                                      TextStyle(color: Colors.blue[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[800]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue[50],
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Select Section',
                                        style:
                                            TextStyle(color: Colors.blue[900])),
                                  ),
                                  ...editSections.map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    newSection = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    final updatedStudent = {
                                      'student_name': nameController.text,
                                      'registration_number':
                                          registrationController.text,
                                      'date_of_birth':
                                          parseDate(dobController.text),
                                      'gender': genderController.text,
                                      'address': addressController.text,
                                      'father_name': fatherNameController.text,
                                      'mother_name': motherNameController.text,
                                      'email': emailController.text,
                                      'phone': phoneController.text,
                                      'assigned_class': newClass,
                                      'assigned_section': newSection,
                                      'birth_certificate':
                                          student.birthCertificate,
                                    };

                                    if (profilePhoto != null &&
                                        profilePhoto != student.studentPhoto) {
                                      updatedStudent['student_photo'] =
                                          profilePhoto!;
                                    } else {
                                      updatedStudent['student_photo'] =
                                          student.studentPhoto;
                                    }

                                    await _studentService.updateStudent(
                                        student, updatedStudent);
                                    _showSuccessSnackBar(
                                        'Student updated successfully');
                                    Navigator.of(context).pop();
                                    _fetchInitialData();
                                  } catch (e) {
                                    _showErrorSnackBar(
                                        'Failed to update student: ${e.toString()}');
                                  }
                                }
                              },
                              child: Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditField(
      TextEditingController controller, String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.blue[50],
        ),
        validator: required
            ? (value) => value!.isEmpty ? '$label is required' : null
            : null,
      ),
    );
  }

  Future<void> _deleteStudent(int index) async {
    final student = filteredStudents[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete',
            style: TextStyle(
                color: Colors.blue[800], fontWeight: FontWeight.bold)),
        content: Text('Delete ${student.name} permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _studentService.deleteStudent(student.id);
        setState(() {
          students.removeWhere((s) => s.id == student.id);
          filteredStudents.removeAt(index);
        });
        _showSuccessSnackBar('Student deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Failed to delete student: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Student Profile Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Students',
                              labelStyle: TextStyle(color: Colors.blue[800]),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.blue[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.blue[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.blue[800]!, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.blue[800]),
                                onPressed: () {
                                  searchController.clear();
                                  _filterStudents();
                                },
                              ),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            onChanged: (value) => _filterStudents(),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedClass,
                                  decoration: InputDecoration(
                                    labelText: 'Filter by Class',
                                    labelStyle:
                                        TextStyle(color: Colors.blue[800]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.blue[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.blue[800]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[50],
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('All Classes',
                                          style: TextStyle(
                                              color: Colors.blue[900])),
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
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedClass = newValue;
                                      _updateAvailableSections(newValue);
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedSection,
                                  decoration: InputDecoration(
                                    labelText: 'Filter by Section',
                                    labelStyle:
                                        TextStyle(color: Colors.blue[800]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.blue[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.blue[800]!, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.blue[50],
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('All Sections',
                                          style: TextStyle(
                                              color: Colors.blue[900])),
                                    ),
                                    ...availableSections.map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: TextStyle(
                                                color: Colors.blue[900])),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedSection = newValue;
                                      _filterStudents();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  selectedClass == null &&
                                          selectedSection == null &&
                                          searchController.text.isEmpty
                                      ? 'No students found'
                                      : 'No students match your filters',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (selectedClass != null ||
                                    selectedSection != null ||
                                    searchController.text.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedClass = null;
                                        selectedSection = null;
                                        searchController.clear();
                                        filteredStudents = students;
                                      });
                                    },
                                    child: Text('Clear Filters',
                                        style:
                                            TextStyle(color: Colors.blue[800])),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(12),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blue[100]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: buildStudentPhoto(
                                          student.studentPhoto, uploadBaseUrl),
                                    ),
                                  ),
                                  title: Text(
                                    student.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'registration'
                                        ':-'
                                        '${student.registrationNumber}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${student.assignedClass} - ${student.assignedSection}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.blue[800]),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit,
                                                color: Colors.blue[800]),
                                            SizedBox(width: 8),
                                            Text('Edit',
                                                style: TextStyle(
                                                    color: Colors.blue[900])),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: Colors.red[400]),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red[600])),
                                          ],
                                        ),
                                      ),
                                      if (student.birthCertificate.isNotEmpty)
                                        PopupMenuItem(
                                          value: 'view_certificate',
                                          child: Row(
                                            children: [
                                              Icon(Icons.picture_as_pdf,
                                                  color: Colors.green[600]),
                                              SizedBox(width: 8),
                                              Text('View Certificate',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.green[800])),
                                            ],
                                          ),
                                        ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editStudent(student);
                                      } else if (value == 'delete') {
                                        _deleteStudent(index);
                                      } else if (value == 'view_certificate') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PDFViewerScreen(
                                              pdfData: student.birthCertificate,
                                              baseUrl: uploadBaseUrl,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
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
}
