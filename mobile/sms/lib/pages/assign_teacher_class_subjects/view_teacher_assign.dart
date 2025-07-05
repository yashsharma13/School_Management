import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';

class ViewTeacherAssignmentsPage extends StatefulWidget {
  const ViewTeacherAssignmentsPage({super.key});

  @override
  State<ViewTeacherAssignmentsPage> createState() =>
      _ViewTeacherAssignmentsPageState();
}

class _ViewTeacherAssignmentsPageState
    extends State<ViewTeacherAssignmentsPage> {
  bool isLoading = true;
  String? token;
  List<TeacherAssignment> assignments = [];

  static final String baseUrl =
      dotenv.env['NEXT_PUBLIC_API_BASE_URL']?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchAssignments();
  }

  Future<void> _loadTokenAndFetchAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      await fetchAssignments();
    } else {
      _showError('No token found. Please login again.');
    }
  }

  Future<void> fetchAssignments() async {
    setState(() => isLoading = true);
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/api/teacher-assignments'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (resp.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(resp.body);
        final List<dynamic> rawData = decoded['data'] ?? [];

        Map<String, TeacherAssignment> grouped = {};

        for (var e in rawData) {
          final teacherId = e['teacher_id'].toString();
          final teacherName = e['teacher_name'] ?? 'Unknown';
          final classId = e['class_id'].toString();
          final className = e['class_name'] ?? 'Unknown';
          final section = e['section'] ?? 'Unknown';
          final subjectName = e['subject_name'] ?? '';
          final assignmentId = e['id'].toString();

          final key = '$teacherId|$classId|$section';

          if (!grouped.containsKey(key)) {
            grouped[key] = TeacherAssignment(
              id: assignmentId,
              teacherId: teacherId,
              teacherName: teacherName,
              classId: classId,
              className: className,
              section: section,
              subjects: [],
            );
          }

          grouped[key]!.subjects.add(subjectName);
        }

        setState(() {
          assignments = grouped.values.toList();
        });
      } else {
        _showError('Failed to load assignments. (${resp.statusCode})');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteAssignment(TeacherAssignment assignment) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete ${assignment.teacherName}\'s assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final resp = await http.delete(
        Uri.parse('$baseUrl/api/teacher-assignment/${assignment.id}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (resp.statusCode == 200) {
        _showSuccess('Deleted successfully.');
        await fetchAssignments();
      } else {
        _showError('Failed to delete. (${resp.statusCode})');
      }
    } catch (e) {
      _showError('Delete error: $e');
    }
  }

  void _editAssignment(TeacherAssignment assignment) {
    final teacherController =
        TextEditingController(text: assignment.teacherName);
    final classController = TextEditingController(text: assignment.className);
    final sectionController = TextEditingController(text: assignment.section);
    final subjectController =
        TextEditingController(text: assignment.subjects.join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Assignment'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(labelText: 'Teacher')),
              TextField(
                  controller: classController,
                  decoration: const InputDecoration(labelText: 'Class')),
              TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section')),
              TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                      labelText: 'Subjects (comma separated)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // For now, just show message. To enable update, add a PUT endpoint.
              Navigator.pop(context);
              _showSuccess(
                  'Edit saved (dummy action). Implement update logic if needed.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) =>
      showCustomSnackBar(context, msg, backgroundColor: Colors.red);
  void _showSuccess(String msg) =>
      showCustomSnackBar(context, msg, backgroundColor: Colors.green);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'View Assigned Teachers'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text('No assignments found.'))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(assignment.teacherName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Class: ${assignment.className} - ${assignment.section}'),
                            Text('Subjects: ${assignment.subjects.join(', ')}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editAssignment(assignment);
                            } else if (value == 'delete') {
                              deleteAssignment(assignment);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class TeacherAssignment {
  final String id;
  final String teacherId;
  final String teacherName;
  final String classId;
  final String className;
  final String section;
  final List<String> subjects;

  TeacherAssignment({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.className,
    required this.section,
    required this.subjects,
  });
}
