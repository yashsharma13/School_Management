import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sms/pages/services/subject_service.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';
import 'package:sms/widgets/class_section_selector.dart';
import 'package:sms/models/teacher_model.dart';
import 'package:sms/pages/services/teacher_service.dart';

class AssignTeacherPage extends StatefulWidget {
  const AssignTeacherPage({super.key});

  @override
  State<AssignTeacherPage> createState() => _AssignTeacherPageState();
}

class _AssignTeacherPageState extends State<AssignTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  String? token;
  bool isLoading = true;
  bool isFetchingTeachers = false;
  bool isFetchingSubjects = false;

  List<Teacher> teachers = [];
  List<Subject> subjects = [];

  Teacher? selectedTeacher;
  ClassModel? selectedClass;
  String? selectedSection;
  List<String> selectedSubjectIds = [];

  static final String baseUrl =
      dotenv.env['NEXT_PUBLIC_API_BASE_URL']?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      await fetchTeachers();
    } else {
      _showError('No token, please login.');
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchTeachers() async {
    setState(() => isFetchingTeachers = true);
    try {
      teachers = await TeacherService.fetchTeachers();
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => isFetchingTeachers = false);
    }
  }

  Future<void> fetchSubjects(int classId, String section) async {
    setState(() {
      isFetchingSubjects = true;
      subjects = [];
      selectedSubjectIds = [];
    });

    try {
      final data = await SubjectService.fetchClassesWithSubjects();

      final cls = data.firstWhere(
        (e) => int.tryParse(e['id'].toString()) == classId,
        orElse: () => {},
      );

      if (cls.isNotEmpty && cls['subjects'] is List) {
        final List<dynamic> subjectList = cls['subjects'];
        for (var subJson in subjectList) {
          final id = subJson['id'].toString();
          final names = subJson['subject_name'];
          final splitted = names is String ? names.split(',') : ['Unknown'];

          for (var sub in splitted) {
            final trimmed = sub.trim();
            if (trimmed.isNotEmpty) {
              subjects.add(Subject(id: id, subjectName: trimmed));
            }
          }
        }
      }

      if (subjects.isEmpty) {
        _showWarning('No subjects for this class/section.');
      }
    } catch (e) {
      _showError('Error fetching subjects: $e');
    } finally {
      setState(() => isFetchingSubjects = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTeacher == null ||
        selectedClass == null ||
        selectedSection == null ||
        selectedSubjectIds.isEmpty) {
      _showError('Please complete all fields.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/api/assign-teacher'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teacher_id': selectedTeacher!.id,
          'class_id': selectedClass!.id,
          'section': selectedSection,
          'subject_ids': selectedSubjectIds,
        }),
      );

      if (!mounted) return;

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        showCustomSnackBar(
          context,
          'Teacher assigned successfully!',
          backgroundColor: Colors.green,
        );

        setState(() {
          selectedTeacher = null;
          selectedClass = null;
          selectedSection = null;
          selectedSubjectIds = [];
          subjects = [];
        });
      } else {
        // ✅ Try to extract message from backend response
        String errorMessage = 'Failed to assign teacher (${resp.statusCode})';
        try {
          final data = json.decode(resp.body);
          if (data != null && data['message'] != null) {
            errorMessage = data['message'];
          }
        } catch (_) {
          // Use default error message if parsing fails
          'Already assigned this subject to another teacher';
        }

        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String msg) =>
      showCustomSnackBar(context, msg, backgroundColor: Colors.red);
  void _showWarning(String msg) =>
      showCustomSnackBar(context, msg, backgroundColor: Colors.orange);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Assign Teacher to Class'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isFetchingTeachers)
                        const CircularProgressIndicator()
                      else
                        DropdownButtonFormField<Teacher>(
                          decoration: const InputDecoration(
                            labelText: 'Select Teacher',
                          ),
                          items: teachers
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name),
                                ),
                              )
                              .toList(),
                          value: selectedTeacher,
                          onChanged: (v) => setState(() => selectedTeacher = v),
                          validator: (v) => v == null ? 'Select Teacher' : null,
                        ),
                      const SizedBox(height: 16),
                      ClassSectionSelector(
                        onSelectionChanged: (ClassModel? cls, String? sec) {
                          setState(() {
                            selectedClass = cls;
                            selectedSection = sec;
                            if (cls != null && sec != null) {
                              fetchSubjects(cls.id, sec);
                            } else {
                              subjects = [];
                              selectedSubjectIds = [];
                            }
                          });
                        },
                        initialClass: selectedClass,
                        initialSection: selectedSection,
                      ),
                      const SizedBox(height: 24),
                      if (isFetchingSubjects)
                        const CircularProgressIndicator()
                      else if (subjects.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subjects
                              .map(
                                (sub) => CheckboxListTile(
                                  title: Text(sub.subjectName),
                                  value: selectedSubjectIds.contains(sub.id),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        selectedSubjectIds.add(sub.id);
                                      } else {
                                        selectedSubjectIds.remove(sub.id);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Assign Teacher',
                        isLoading: isLoading,
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class Subject {
  final String id;
  final String subjectName;

  Subject({required this.id, required this.subjectName});
}
