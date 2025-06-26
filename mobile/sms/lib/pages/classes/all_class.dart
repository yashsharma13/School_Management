import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms/pages/classes/edit_class.dart';
import 'package:sms/pages/classes/new_class.dart';
import 'package:sms/pages/services/class_service.dart';
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
  static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

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
      final fetchedClasses = await ClassService.fetchClasses();
      debugPrint('Fetched ${fetchedClasses.length} classes');

      // Then fetch student counts
      final studentCounts = await ClassService.modelgetStudentCountByClass();
      debugPrint('Fetched ${studentCounts.length} student count records');

      // Create case-insensitive count map
      final Map<String, int> countMap = {};

      for (final item in studentCounts) {
        try {
          final className =
              (item['class_name'] ?? '').toString().toLowerCase().trim();
          final section =
              (item['section'] ?? '').toString().toLowerCase().trim();
          final key = '$className|$section'; // Composite key
          final count = _parseCount(item['student_count'] ?? 0);

          if (className.isNotEmpty && section.isNotEmpty) {
            countMap[key] = count;
          }
        } catch (e) {
          debugPrint('Error processing count item: $e');
        }
      }

      // Build final class list with counts
      final classesWithCounts = fetchedClasses
          .map((classData) {
            final className =
                classData['class_name']?.toString() ?? 'Unassigned';
            final section = classData['section']?.toString() ?? '';
            final key =
                '${className.toLowerCase().trim()}|${section.toLowerCase().trim()}';
            final studentCount = countMap[key] ?? 0;

            debugPrint('Class: $className, Students: $studentCount');

            // Handle case where teacher might be deleted
            final teacherId =
                classData['teacher_id']?.toString() ?? 'No Teacher Assigned';

            return Class.fromJson({
              ...classData,
              'student_count': studentCount,
              'teacher_id': teacherId,
              'section': classData['section'] ?? '',
            });
          })
          .where((c) => c.id.isNotEmpty)
          .toList();

      setState(() => classes = classesWithCounts);
    } catch (error) {
      debugPrint('Error in _loadClasses: $error');
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
        Uri.parse('$baseeUrl/api/teachers'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Classes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadClasses,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.blue[900]),
      );
    }

    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_,
                size: 48, color: Colors.blue[900]!.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(
              'No Classes Available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add a new class',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClasses,
      color: Colors.blue[900],
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: classes.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final classItem = classes[index];
          return _buildClassCard(classItem);
        },
      ),
    );
  }

  // Widget _buildClassCard(Class classItem) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(12),
  //       onTap: () => _openEditDialog(classItem),
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   '${classItem.className} (${classItem.section})',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.blue[900],
  //                   ),
  //                 ),
  //                 _buildStudentCountBadge(classItem.studentCount),
  //               ],
  //             ),
  //             SizedBox(height: 12),
  //             _buildInfoRow(Icons.person, classItem.teacherId),
  //             SizedBox(height: 8),
  //             _buildInfoRow(
  //                 Icons.attach_money, 'Fees: ${classItem.tuitionFees}'),
  //             SizedBox(height: 12),
  //             _buildActionButtons(classItem),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildClassCard(Class classItem) {
    // Find teacher name from teachers list by teacherId
    final teacherName = teachers
        .firstWhere(
          (teacher) => teacher.id == classItem.teacherId,
          orElse: () => Teacher(id: '', name: 'No Teacher Assigned'),
        )
        .name;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openEditDialog(classItem),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${classItem.className} (${classItem.section})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  _buildStudentCountBadge(classItem.studentCount),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoRow(
                  Icons.person, teacherName), // <-- Show teacherName here
              SizedBox(height: 8),
              _buildInfoRow(
                  Icons.attach_money, 'Fees: ${classItem.tuitionFees}'),
              SizedBox(height: 12),
              _buildActionButtons(classItem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCountBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people, size: 16, color: Colors.blue[900]),
          SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[900]!.withOpacity(0.7)),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Class classItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildIconButton(
          icon: Icons.edit,
          color: Colors.blue[600]!,
          onPressed: () => _openEditDialog(classItem),
        ),
        SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.delete,
          color: Colors.red[400]!,
          onPressed: () => _deleteClass(classItem),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onPressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
      ),
    );
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
          title: Text('Confirm Deletion',
              style: TextStyle(color: Colors.blue[900])),
          content:
              Text('Are you sure you want to delete "${classItem.className}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.blue[900])),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final success = await ClassService.deleteClass(classItem.id);

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

  // Inside your class, replace _openEditDialog with:
  void _openEditDialog(Class classItem) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClassPage(
          classItem: classItem,
          teachers: teachers,
        ),
      ),
    );

    if (updated == true) {
      await _loadClasses();
      _showSuccessSnackBar('Class updated successfully');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
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
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class Class {
  final String id;
  final String className;
  final String tuitionFees;
  final String teacherId;
  final int studentCount;
  final String section;

  Class({
    required this.id,
    required this.className,
    required this.tuitionFees,
    required this.teacherId,
    required this.studentCount,
    required this.section,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? 'Unknown Class',
      tuitionFees: json['tuition_fees']?.toString() ?? '0',
      teacherId: json['teacher_id']?.toString() ?? 'No Teacher Assigned',
      studentCount: json['student_count'] ?? 0,
      section: json['section']?.toString() ?? '',
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
