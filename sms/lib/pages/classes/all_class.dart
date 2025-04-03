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
      setState(() => isLoading = true);

      // Fetch classes first
      final fetchedClasses = await ApiService.fetchClasses();
      print('Fetched ${fetchedClasses.length} classes');

      // Then fetch student counts
      final studentCounts = await ApiService.modelgetStudentCountByClass();
      print('Fetched ${studentCounts.length} student count records');

      // Create case-insensitive count map
      final Map<String, int> countMap = {};

      for (final item in studentCounts) {
        try {
          final className =
              (item['class_name'] ?? '').toString().toLowerCase().trim();
          final count = _parseCount(item['student_count'] ?? 0);

          if (className.isNotEmpty) {
            countMap[className] = count;
            print('Count for $className: $count');
          }
        } catch (e) {
          print('Error processing count item: $e');
        }
      }

      // Build final class list with counts
      final classesWithCounts = fetchedClasses
          .map((classData) {
            final className =
                classData['class_name']?.toString() ?? 'Unassigned';
            final lowerClassName = className.toLowerCase().trim();
            final studentCount = countMap[lowerClassName] ?? 0;

            print('Class: $className, Students: $studentCount');

            // Handle case where teacher might be deleted
            final teacherName =
                classData['teacher_name']?.toString() ?? 'No Teacher Assigned';

            return Class.fromJson({
              ...classData,
              'student_count': studentCount,
              'teacher_name': teacherName,
            });
          })
          .where((c) => c.id.isNotEmpty)
          .toList();

      setState(() => classes = classesWithCounts);
    } catch (error) {
      print('Error in _loadClasses: $error');
      _showErrorSnackBar('Failed to load classes. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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

    // Check if the current teacher exists in the list
    String? selectedTeacherName =
        teachers.any((t) => t.name == classItem.teacherName)
            ? classItem.teacherName
            : null;

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
                      items: [
                        // Add a null item if no teacher is selected
                        if (selectedTeacherName == null)
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select a teacher'),
                          ),
                        ...teachers
                            .map((teacher) => DropdownMenuItem<String>(
                                  value: teacher.name,
                                  child: Text(teacher.name),
                                ))
                            .toList(),
                      ],
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
                    if (selectedTeacherName == null) {
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
    required this.studentCount,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? 'Unknown Class',
      tuitionFees: json['tuition_fees']?.toString() ?? '0',
      teacherName: json['teacher_name']?.toString() ?? 'No Teacher Assigned',
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
