// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:sms/pages/student/student_details/student_service.dart';

// class FeesCollectionPage extends StatefulWidget {
//   @override
//   _FeesCollectionPageState createState() => _FeesCollectionPageState();
// }

// class _FeesCollectionPageState extends State<FeesCollectionPage> {
//   List<Class> classes = [];
//   List<Student> students = [];
//   List<Student> filteredStudents = [];
//   bool isLoadingClasses = true;
//   bool isLoadingStudents = false;
//   String? token;
//   String? selectedClassId;
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//     searchController.addListener(_filterStudents);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
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

//       // Using the ApiService pattern from your all_classes.dart file
//       final response = await http.get(
//         Uri.parse('http://localhost:1000/api/classes'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
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
//                     tuitionFees: data['tuition_fees']?.toString() ?? '0',
//                   ))
//               .where((classItem) => classItem.id.isNotEmpty)
//               .toList();
//         });
//       } else {
//         _showErrorSnackBar('Failed to load classes: ${response.reasonPhrase}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error loading classes: $error');
//     } finally {
//       setState(() => isLoadingClasses = false);
//     }
//   }

//   Future<void> _fetchStudentsByClass(String classId) async {
//     if (token == null) return;

//     setState(() {
//       isLoadingStudents = true;
//       filteredStudents = [];
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:1000/api/students'),
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
//                         data['registration_number']?.toString() ?? '',
//                     assignedClass: data['assigned_class']?.toString() ?? '',
//                     assignedSection: data['assigned_section']?.toString() ?? '',
//                     studentPhoto: data['student_photo']?.toString() ?? '',
//                   ))
//               .where((student) => student.id.isNotEmpty)
//               .toList();

//           _filterStudents();
//         });
//       } else {
//         _showErrorSnackBar('Failed to load students: ${response.reasonPhrase}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error loading students: $error');
//     } finally {
//       setState(() {
//         isLoadingStudents = false;
//       });
//     }
//   }

//   void _filterStudents() {
//     if (searchController.text.isEmpty) {
//       setState(() {
//         filteredStudents = List.from(students);
//       });
//     } else {
//       setState(() {
//         filteredStudents = students
//             .where((student) => student.name
//                 .toLowerCase()
//                 .contains(searchController.text.toLowerCase()))
//             .toList();
//       });
//     }
//   }

//   void _openFeesCollectPage(Student student) {
//     // Navigate to fees collection page with student data
//     // This is a placeholder for now as mentioned in your requirements
//     _showInfoSnackBar('Opening fees collection for ${student.name}');

//     // You would typically do something like:
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) => FeesCollectPage(student: student),
//     //   ),
//     // );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showInfoSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   Widget _buildStudentPhoto(String photoPath) {
//     if (photoPath.isEmpty) {
//       return CircleAvatar(
//         child: Icon(Icons.person),
//       );
//     }

//     if (photoPath.startsWith('http')) {
//       return CircleAvatar(
//         backgroundImage: NetworkImage(photoPath),
//       );
//     } else {
//       return CircleAvatar(
//         backgroundImage:
//             NetworkImage('http://localhost:1000/uploads/$photoPath'),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fees Collection'),
//         backgroundColor: Colors.blue.shade900,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Class Selection Dropdown
//             isLoadingClasses
//                 ? Center(child: CircularProgressIndicator())
//                 : classes.isEmpty
//                     ? Center(child: Text('No classes available'))
//                     : DropdownButtonFormField<String>(
//                         decoration: InputDecoration(
//                           labelText: 'Select Class',
//                           border: OutlineInputBorder(),
//                         ),
//                         value: selectedClassId,
//                         items: [
//                           DropdownMenuItem<String>(
//                             value: null,
//                             child: Text('-- Select a Class --'),
//                           ),
//                           ...classes
//                               .map((classItem) => DropdownMenuItem<String>(
//                                     value: classItem.id,
//                                     child: Text(classItem.className),
//                                   )),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             selectedClassId = value;
//                             if (value != null) {
//                               _fetchStudentsByClass(value);
//                             } else {
//                               students = [];
//                               filteredStudents = [];
//                             }
//                           });
//                         },
//                       ),

//             SizedBox(height: 16),

//             // Search Field - Only visible when a class is selected
//             if (selectedClassId != null)
//               TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   labelText: 'Search Student by Name',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(),
//                 ),
//               ),

//             SizedBox(height: 16),

//             // Student List
//             Expanded(
//               child: isLoadingStudents
//                   ? Center(child: CircularProgressIndicator())
//                   : selectedClassId == null
//                       ? Center(
//                           child: Text('Please select a class to view students'))
//                       : filteredStudents.isEmpty
//                           ? Center(
//                               child: Text('No students found in this class'))
//                           : ListView.builder(
//                               itemCount: filteredStudents.length,
//                               itemBuilder: (context, index) {
//                                 final student = filteredStudents[index];
//                                 return Card(
//                                   margin: EdgeInsets.symmetric(vertical: 8),
//                                   child: ListTile(
//                                     leading: _buildStudentPhoto(
//                                         student.studentPhoto),
//                                     title: Text(student.name),
//                                     subtitle: Text(
//                                         'Reg: ${student.registrationNumber}\nSection: ${student.assignedSection}'),
//                                     onTap: () => _openFeesCollectPage(student),
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
// }

// // Models
// class Class {
//   final String id;
//   final String className;
//   final String tuitionFees;

//   Class({
//     required this.id,
//     required this.className,
//     required this.tuitionFees,
//   });
// }

// class Student {
//   final String id;
//   final String name;
//   final String registrationNumber;
//   final String assignedClass;
//   final String assignedSection;
//   final String studentPhoto;

//   Student({
//     required this.id,
//     required this.name,
//     required this.registrationNumber,
//     required this.assignedClass,
//     required this.assignedSection,
//     required this.studentPhoto,
//   });
// }
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
          'Authorization': token!,
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
                    tuitionFees: data['tuition_fees']?.toString() ?? '0',
                  ))
              .where((classItem) => classItem.id.isNotEmpty)
              .toList();
        });
      } else {
        _showErrorSnackBar('Failed to load classes: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error loading classes: $error');
    } finally {
      setState(() => isLoadingClasses = false);
    }
  }

  Future<void> _fetchStudentsByClass(String classId) async {
    if (token == null) return;

    setState(() {
      isLoadingStudents = true;
      filteredStudents = [];
    });

    try {
      // Get the selected class details
      Class selectedClass = classes.firstWhere(
        (c) => c.id == classId,
        orElse: () => Class(id: '', className: 'Unknown', tuitionFees: '0'),
      );

      // Encode the class name for URL
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
                    assignedClassId: classId, // Store the selected class ID
                    className: selectedClass.className, // Store class name
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
    if (searchController.text.isEmpty) {
      setState(() {
        filteredStudents = List.from(students);
      });
    } else {
      setState(() {
        filteredStudents = students
            .where((student) => student.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  void _openFeesCollectPage(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeesCollectionPage(
          studentId: student.id,
          studentName: student.name,
          studentClass: student.className, // Use the stored class name
          monthlyFee: classes
              .firstWhere(
                (c) => c.id == student.assignedClassId,
                orElse: () =>
                    Class(id: '', className: 'Unknown', tuitionFees: '0'),
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
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fees Collection - Select Student'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Selection Dropdown
            isLoadingClasses
                ? Center(child: CircularProgressIndicator())
                : classes.isEmpty
                    ? Center(child: Text('No classes available'))
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Class',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedClassId,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('-- Select a Class --'),
                          ),
                          ...classes
                              .map((classItem) => DropdownMenuItem<String>(
                                    value: classItem.id,
                                    child: Text(classItem.className),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedClassId = value;
                            if (value != null) {
                              _fetchStudentsByClass(value);
                            } else {
                              students = [];
                              filteredStudents = [];
                            }
                          });
                        },
                      ),

            SizedBox(height: 16),

            if (selectedClassId != null)
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search Student by Name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),

            SizedBox(height: 16),

            Expanded(
              child: isLoadingStudents
                  ? Center(child: CircularProgressIndicator())
                  : selectedClassId == null
                      ? Center(
                          child: Text('Please select a class to view students'))
                      : filteredStudents.isEmpty
                          ? Center(
                              child: Text('No students found in this class'))
                          : ListView.builder(
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: _buildStudentPhoto(
                                        student.studentPhoto),
                                    title: Text(student.name),
                                    subtitle: Text(
                                        'Reg: ${student.registrationNumber}\nSection: ${student.assignedSection}\nClass: ${student.className}'),
                                    trailing: Icon(Icons.arrow_forward_ios),
                                    onTap: () => _openFeesCollectPage(student),
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
      return CircleAvatar(child: Icon(Icons.person));
    }
    if (photoPath.startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(photoPath));
    } else {
      return CircleAvatar(
          backgroundImage:
              NetworkImage('http://localhost:1000/uploads/$photoPath'));
    }
  }
}

class Class {
  final String id;
  final String className;
  final String tuitionFees;

  Class({
    required this.id,
    required this.className,
    required this.tuitionFees,
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
