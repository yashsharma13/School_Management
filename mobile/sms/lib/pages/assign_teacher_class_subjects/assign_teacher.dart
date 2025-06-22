import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sms/pages/services/api_service.dart';
import 'package:sms/widgets/button.dart';

class AssignTeacherPage extends StatefulWidget {
  const AssignTeacherPage({super.key});

  @override
  _AssignTeacherPageState createState() => _AssignTeacherPageState();
}

class _AssignTeacherPageState extends State<AssignTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  String? token;
  bool isLoading = true;
  bool isFetchingTeachers = false;
  bool isFetchingClasses = false;
  bool isFetchingSubjects = false;

  List<Teacher> teachers = [];
  List<ClassModel> classes = [];
  List<Subject> subjects = [];

  Teacher? selectedTeacher;
  ClassModel? selectedClass;
  String? selectedSection;
  List<String> selectedSubjectIds = [];
  List<String> availableSections = [];

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
      await Future.wait([fetchTeachers(), fetchClasses()]);
    } else {
      _showError('No token, please login.');
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchTeachers() async {
    setState(() => isFetchingTeachers = true);
    try {
      final resp = await http.get(
        Uri.parse('$baseUrl/api/teachers'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List;
        teachers = data
            .map((e) => Teacher(
                  id: e['id'].toString(),
                  name: e['teacher_name'] ?? 'Unknown',
                ))
            .toList();
      } else if (resp.statusCode == 401) {
        _signOut();
        _showError('Session expired.');
      } else {
        _showError('Failed to fetch teachers.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => isFetchingTeachers = false);
    }
  }

  Future<void> fetchClasses() async {
    setState(() => isFetchingClasses = true);
    try {
      final data = await ApiService.fetchClasses();

      final Map<String, ClassModel> map = {};

      for (var e in data) {
        final name = (e['class_name'] ?? '').toString();
        final section = (e['section'] ?? '').toString();
        final id = int.tryParse(e['id'].toString()) ?? 0;

        // Use class name as key to avoid duplicates
        if (!map.containsKey(name)) {
          map[name] = ClassModel(id: id, className: name, sections: []);
        }

        if (section.isNotEmpty && !map[name]!.sections.contains(section)) {
          map[name]!.sections.add(section);
        }
      }

      setState(() {
        classes = map.values.toList();
      });
    } catch (e) {
      _showError('Error fetching classes: $e');
    } finally {
      setState(() => isFetchingClasses = false);
    }
  }

  Future<void> fetchSubjects(int classId, String section) async {
    setState(() {
      isFetchingSubjects = true;
      subjects = [];
      selectedSubjectIds = [];
    });

    try {
      final data = await ApiService.fetchClassesWithSubjects();

      final cls = data.firstWhere(
        (e) =>
            int.tryParse(e['id'].toString()) == classId &&
            (e['section']?.toString() ?? '').toLowerCase() ==
                section.toLowerCase(),
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

  void _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() => token = null);
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
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showError('Fail to assign teacher. ${resp.statusCode}');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Teacher Assigned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Teacher: ${selectedTeacher!.name}'),
            Text('Class: ${selectedClass!.className} - $selectedSection'),
            Text(
              'Subjects: ${subjects.where((s) => selectedSubjectIds.contains(s.id)).map((s) => s.subjectName).join(', ')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedTeacher = null;
                selectedClass = null;
                selectedSection = null;
                selectedSubjectIds = [];
                subjects = [];
                availableSections = [];
              });
            },
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  void _showError(String msg) => _showSnack(msg, Colors.red);
  void _showWarning(String msg) => _showSnack(msg, Colors.orange);

  void _showSnack(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: col),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Teacher to Class'),
        backgroundColor: Colors.blue.shade900,
      ),
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
                      if (isFetchingClasses)
                        const CircularProgressIndicator()
                      else
                        DropdownButtonFormField<ClassModel>(
                          decoration: const InputDecoration(
                            labelText: 'Select Class',
                          ),
                          items: classes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.className),
                                ),
                              )
                              .toList(),
                          value: selectedClass,
                          onChanged: (v) {
                            selectedClass = v;
                            selectedSection = null;
                            availableSections = v?.sections ?? [];
                            subjects = [];
                            selectedSubjectIds = [];
                            setState(() {});
                          },
                          validator: (v) => v == null ? 'Select Class' : null,
                        ),
                      const SizedBox(height: 16),
                      if (selectedClass != null)
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Select Section'),
                          items: availableSections
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ))
                              .toList(),
                          value: selectedSection,
                          onChanged: (v) {
                            selectedSection = v;
                            if (selectedClass != null && v != null) {
                              fetchSubjects(selectedClass!.id, v);
                            }
                            setState(() {});
                          },
                          validator: (v) => v == null ? 'Select Section' : null,
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
                        color: Colors.blue.shade900,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class Teacher {
  final String id, name;
  Teacher({required this.id, required this.name});
}

class ClassModel {
  final int id;
  final String className;
  final List<String> sections;
  ClassModel({
    required this.id,
    required this.className,
    required this.sections,
  });
}

class Subject {
  final String id;
  final String subjectName;

  Subject({required this.id, required this.subjectName});
}
