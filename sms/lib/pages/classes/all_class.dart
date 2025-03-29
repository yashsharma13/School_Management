// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/classes/new_class.dart';
// import 'package:sms/pages/services/api_service.dart';
// // import 'edit_class.dart'; // Edit class page import

// class AllClassesPage extends StatefulWidget {
//   @override
//   _AllClassesPageState createState() => _AllClassesPageState();
// }

// class _AllClassesPageState extends State<AllClassesPage> {
//   List<Class> classes = [];
//   bool isLoading = true;
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//     _fetchClasses();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }

//   Future<void> _fetchClasses() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final classes =
//           await ApiService.fetchClasses(); // Call fetchClasses method

//       setState(() {
//         this.classes = classes.map((data) {
//           return Class(
//             id: data['_id'],
//             className: data['class_name'],
//             tuitionFees: data['tuition_fees'],
//             teacherName: data['teacher_name'],
//           );
//         }).toList();
//       });
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching classes: $error')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteClass(String classId) async {
//     if (token == null) return;

//     try {
//       final response = await http.delete(
//         Uri.parse('http://localhost:1000/api/classes/$classId'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           classes.removeWhere((element) => element.id == classId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Class deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete class')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting class')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('All Classes'),
//         backgroundColor: Colors.blue.shade900,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : classes.isEmpty
//               ? Center(child: Text('No classes available.'))
//               : ListView.builder(
//                   itemCount: classes.length,
//                   itemBuilder: (context, index) {
//                     final classItem = classes[index];
//                     return Card(
//                       margin:
//                           EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                       child: ListTile(
//                         title: Text(classItem.className),
//                         subtitle: Text(
//                             'Teacher: ${classItem.teacherName}\nFees: ${classItem.tuitionFees}'),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () async {
//                                 final updatedClass = await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => AddClassPage()),
//                                 );
//                                 if (updatedClass != null) {
//                                   _fetchClasses(); // Reload the classes
//                                 }
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _deleteClass(classItem.id),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// class Class {
//   final String id;
//   final String className;
//   final String tuitionFees;
//   final String teacherName;

//   Class({
//     required this.id,
//     required this.className,
//     required this.tuitionFees,
//     required this.teacherName,
//   });
// }
// import 'package:flutter/material.dart';
// import 'package:sms/pages/classes/new_class.dart';
// import 'package:sms/pages/services/api_service.dart';

// class AllClassesPage extends StatefulWidget {
//   @override
//   _AllClassesPageState createState() => _AllClassesPageState();
// }

// class _AllClassesPageState extends State<AllClassesPage> {
//   List<Class> classes = [];
//   bool isLoading = true;
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _loadClasses();
//   }

//   // Load classes from API
//   Future<void> _loadClasses() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       final fetchedClasses = await ApiService.fetchClasses();

//       setState(() {
//         classes = fetchedClasses.map((data) {
//           return Class(
//             id: data['_id'] ?? '',
//             className: data['class_name'] ?? 'Unknown Class',
//             tuitionFees: data['tuition_fees']?.toString() ?? '0',
//             teacherName: data['teacher_name'] ?? 'Unknown Teacher',
//           );
//         }).toList();
//       });
//     } catch (error) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching classes: $error')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Delete a class
//   Future<void> _deleteClass(String classId) async {
//     try {
//       final success = await ApiService.deleteClass(classId);

//       if (success) {
//         setState(() {
//           classes.removeWhere((element) => element.id == classId);
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Class deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete class')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting class: $error')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('All Classes'),
//         backgroundColor: Colors.blue.shade900,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddClassPage()),
//               );

//               if (result == true) {
//                 // Refresh classes if a new class was added
//                 _loadClasses();
//               }
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : classes.isEmpty
//               ? Center(child: Text('No classes available.'))
//               : ListView.builder(
//                   itemCount: classes.length,
//                   itemBuilder: (context, index) {
//                     final classItem = classes[index];
//                     return Card(
//                       margin:
//                           EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                       child: ListTile(
//                         title: Text(classItem.className),
//                         subtitle: Text(
//                           'Teacher: ${classItem.teacherName}\nFees: ${classItem.tuitionFees}',
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () async {
//                                 final result = await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => AddClassPage(),
//                                   ),
//                                 );

//                                 if (result == true) {
//                                   // Refresh classes if updated
//                                   _loadClasses();
//                                 }
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _deleteClass(classItem.id),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// // Class model
// class Class {
//   final String id;
//   final String className;
//   final String tuitionFees;
//   final String teacherName;

//   Class({
//     required this.id,
//     required this.className,
//     required this.tuitionFees,
//     required this.teacherName,
//   });
// }
// import 'package:flutter/material.dart';
// import 'package:sms/pages/classes/new_class.dart'; // Import AddClassPage and Teacher model
// import 'package:sms/pages/services/api_service.dart'; // Import ApiService
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class AllClassesPage extends StatefulWidget {
//   @override
//   _AllClassesPageState createState() => _AllClassesPageState();
// }

// class _AllClassesPageState extends State<AllClassesPage> {
//   List<Class> classes = [];
//   List<Teacher> teachers = [];
//   bool isLoading = true;
//   bool isFetchingTeachers = false;
//   String? token;

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
//       await _loadClasses();
//       await _fetchTeachers();
//     }
//   }

//   // Load classes from API
//   Future<void> _loadClasses() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       final fetchedClasses = await ApiService.fetchClasses();

//       setState(() {
//         classes = fetchedClasses.map((data) {
//           return Class(
//             id: data['_id'] ?? '',
//             className: data['class_name'] ?? 'Unknown Class',
//             tuitionFees: data['tuition_fees']?.toString() ?? '0',
//             teacherName: data['teacher_name'] ?? 'Unknown Teacher',
//             studentCount: data['student_count'] ?? 0,
//           );
//         }).toList();
//       });
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching classes: $error')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Fetch teachers from API
//   Future<void> _fetchTeachers() async {
//     if (token == null) return;

//     setState(() {
//       isFetchingTeachers = true;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:1000/api/teachers'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> teacherData = json.decode(response.body);
//         setState(() {
//           teachers = teacherData
//               .map((data) => Teacher(
//                     id: data['id'].toString(),
//                     name: data['teacher_name'],
//                   ))
//               .toList();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Failed to load teachers: ${response.reasonPhrase}')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 'Error connecting to server. Please check your connection.')),
//       );
//     } finally {
//       setState(() {
//         isFetchingTeachers = false;
//       });
//     }
//   }

//   // Delete a class
//   Future<void> _deleteClass(String classId) async {
//     try {
//       final success = await ApiService.deleteClass(classId);

//       if (success) {
//         setState(() {
//           classes.removeWhere((element) => element.id == classId);
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Class deleted successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete class')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting class: $error')),
//       );
//     }
//   }

//   // Open dialog to edit class
//   void _openEditDialog(Class classItem) {
//     final TextEditingController classNameController =
//         TextEditingController(text: classItem.className);
//     final TextEditingController tuitionFeesController =
//         TextEditingController(text: classItem.tuitionFees);

//     // Initialize with the current teacher name
//     String? selectedTeacherName = classItem.teacherName;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Edit Class'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: classNameController,
//                     decoration: InputDecoration(labelText: 'Class Name'),
//                   ),
//                   TextField(
//                     controller: tuitionFeesController,
//                     decoration: InputDecoration(labelText: 'Tuition Fees'),
//                     keyboardType: TextInputType.number,
//                   ),
//                   DropdownButtonFormField<String>(
//                     decoration: InputDecoration(labelText: 'Select Teacher'),
//                     value: selectedTeacherName,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedTeacherName = newValue;
//                       });
//                     },
//                     items: teachers
//                         .map((teacher) => DropdownMenuItem<String>(
//                               value: teacher.name,
//                               child: Text(teacher.name),
//                             ))
//                         .toList(),
//                     validator: (value) =>
//                         value == null ? 'Please select a teacher' : null,
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context); // Close the dialog
//                   },
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     // Call the API to update the class
//                     try {
//                       final success = await ApiService.updateClass(
//                         classId: classItem.id,
//                         className: classNameController.text,
//                         tuitionFees: tuitionFeesController.text,
//                         teacherName: selectedTeacherName!,
//                       );

//                       if (success) {
//                         // Reload classes after successful update
//                         await _loadClasses();
//                         Navigator.pop(context); // Close the dialog
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Failed to update class')),
//                         );
//                       }
//                     } catch (error) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error updating class: $error')),
//                       );
//                     }
//                   },
//                   child: Text('Save'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('All Classes'),
//         backgroundColor: Colors.blue.shade900,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddClassPage()),
//               );

//               if (result == true) {
//                 _loadClasses();
//               }
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : classes.isEmpty
//               ? Center(child: Text('No classes available.'))
//               : ListView.builder(
//                   itemCount: classes.length,
//                   itemBuilder: (context, index) {
//                     final classItem = classes[index];
//                     return Card(
//                       margin:
//                           EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                       child: ListTile(
//                         title: Text(classItem.className),
//                         subtitle: Text(
//                           'Teacher: ${classItem.teacherName}\nFees: ${classItem.tuitionFees}\nStudents: ${classItem.studentCount}',
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () => _openEditDialog(classItem),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.delete, color: Colors.red),
//                               onPressed: () => _deleteClass(classItem.id),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// // Class model remains the same
// class Class {
//   final String id;
//   final String className;
//   final String tuitionFees;
//   final String teacherName;
//   int studentCount;

//   Class({
//     required this.id,
//     required this.className,
//     required this.tuitionFees,
//     required this.teacherName,
//     this.studentCount = 0,
//   });
// }

import 'package:flutter/material.dart';
import 'package:sms/pages/classes/new_class.dart';
import 'package:sms/pages/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AllClassesPage extends StatefulWidget {
  @override
  _AllClassesPageState createState() => _AllClassesPageState();
}

class _AllClassesPageState extends State<AllClassesPage> {
  List<Class> classes = [];
  List<Teacher> teachers = [];
  bool isLoading = true;
  bool isFetchingTeachers = false;
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
      await _fetchTeachers();
    }
  }

  Future<void> _loadClasses() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedClasses = await ApiService.fetchClasses();

      setState(() {
        classes = fetchedClasses
            .map((data) => Class.fromJson(data))
            .where((classObj) {
          if (classObj.id.isEmpty) {
            print('[WARNING] Found class with empty ID: ${classObj.className}');
            return false; // Skip classes with empty IDs
          }
          return true;
        }).toList();
      });
    } catch (error) {
      _showErrorSnackBar('Error fetching classes: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTeachers() async {
    if (token == null) return;

    setState(() {
      isFetchingTeachers = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1000/api/teachers'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> teacherData = json.decode(response.body);
        setState(() {
          teachers = teacherData
              .map((data) => Teacher(
                    id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    name: data['teacher_name']?.toString() ?? 'Unknown Teacher',
                  ))
              .where((teacher) => teacher.id.isNotEmpty)
              .toList();
        });
      } else {
        _showErrorSnackBar('Failed to load teachers: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar(
          'Error connecting to server. Please check your connection.');
    } finally {
      setState(() {
        isFetchingTeachers = false;
      });
    }
  }

  Future<void> _deleteClass(Class classItem) async {
    // Double-check ID validity
    if (classItem.id.isEmpty) {
      _showErrorSnackBar('Cannot delete class - invalid ID');
      return;
    }

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Delete class "${classItem.className}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        print('[DEBUG] Attempting to delete class with ID: ${classItem.id}');

        final success = await ApiService.deleteClass(classItem.id);

        if (success) {
          setState(() {
            classes.removeWhere((c) => c.id == classItem.id);
          });
          _showSuccessSnackBar('Class deleted successfully');
        } else {
          _showErrorSnackBar('Failed to delete class');
        }
      } catch (error) {
        _showErrorSnackBar('Error deleting class: $error');
        print('[ERROR] Delete failed: $error');
      }
    }
  }

  void _openEditDialog(Class classItem) {
    if (classItem.id.isEmpty) {
      _showErrorSnackBar('Cannot edit - invalid class ID');
      return;
    }

    final classNameController =
        TextEditingController(text: classItem.className);
    final tuitionFeesController =
        TextEditingController(text: classItem.tuitionFees);
    String? selectedTeacherName = classItem.teacherName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: classNameController,
                    decoration: InputDecoration(labelText: 'Class Name'),
                  ),
                  TextField(
                    controller: tuitionFeesController,
                    decoration: InputDecoration(labelText: 'Tuition Fees'),
                    keyboardType: TextInputType.number,
                  ),
                  if (teachers.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: selectedTeacherName,
                      items: teachers
                          .map((teacher) => DropdownMenuItem<String>(
                                value: teacher.name,
                                child: Text(teacher.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedTeacherName = value),
                      decoration: InputDecoration(labelText: 'Teacher'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedTeacherName == null ||
                        selectedTeacherName!.isEmpty) {
                      _showErrorSnackBar('Please select a teacher');
                      return;
                    }

                    try {
                      final success = await ApiService.updateClass(
                        classId: classItem.id,
                        className: classNameController.text,
                        tuitionFees: tuitionFeesController.text,
                        teacherName: selectedTeacherName!,
                      );

                      if (success) {
                        await _loadClasses();
                        Navigator.pop(context);
                        _showSuccessSnackBar('Class updated successfully');
                      } else {
                        _showErrorSnackBar('Failed to update class');
                      }
                    } catch (error) {
                      _showErrorSnackBar('Error updating class: $error');
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Classes'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClassPage()),
              );

              if (result == true) {
                await _loadClasses();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : classes.isEmpty
              ? Center(child: Text('No classes available'))
              : RefreshIndicator(
                  onRefresh: _loadClasses,
                  child: ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classItem = classes[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(classItem.className),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Teacher: ${classItem.teacherName}'),
                              Text('Fees: ${classItem.tuitionFees}'),
                              Text('Students: ${classItem.studentCount}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openEditDialog(classItem),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteClass(classItem),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class Class {
  final String id;
  final String className;
  final String tuitionFees;
  final String teacherName;
  final int studentCount;

  Class({
    required this.id,
    required this.className,
    required this.tuitionFees,
    required this.teacherName,
    this.studentCount = 0,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? 'Unknown Class',
      tuitionFees: json['tuition_fees']?.toString() ?? '0',
      teacherName: json['teacher_name']?.toString() ?? 'Unknown Teacher',
      studentCount: json['student_count'] ?? 0,
    );
  }
}

class Teacher {
  final String id;
  final String name;

  Teacher({
    required this.id,
    required this.name,
  });
}
