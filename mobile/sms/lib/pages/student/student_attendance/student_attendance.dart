import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/principle/principle_dashboard.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/attendance_components.dart';
import 'package:sms/pages/services/attendance_service.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';
import 'package:sms/widgets/date_picker.dart';
import 'package:sms/widgets/class_section_selector.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  DateTime selectedDate = DateTime.now();
  List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  TextEditingController searchController = TextEditingController();
  String? token;
  bool isLoading = false;
  bool _isInitialLoading = true;

  ClassModel? selectedClass;
  String? selectedSection;

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
      await _fetchAllStudents();
    } else {
      if (!mounted) return;
      showCustomSnackBar(context, 'Please login to continue',
          backgroundColor: Colors.red);
    }
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _fetchAllStudents() async {
    if (token == null) {
      return showCustomSnackBar(context, 'Please login to continue',
          backgroundColor: Colors.red);
    }

    setState(() {
      isLoading = true;
      allStudents = [];
    });

    try {
      final response = await http.get(
        Uri.parse('${AttendanceService.baseUrl}/api/students'),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> studentData = json.decode(response.body);
        setState(() {
          allStudents = studentData
              .map((data) => Student(
                    data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    data['student_name']?.toString() ?? 'Unknown Student',
                    data['assigned_class']?.toString() ?? '',
                    data['assigned_section']?.toString() ?? '',
                    false,
                  ))
              .toList();
          _filterStudents();
        });
      } else {
        _handleResponseError(response);
      }
    } catch (error) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Error connecting to server: $error',
          backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': token!,
    };
  }

  void _handleResponseError(http.Response response) {
    if (response.statusCode == 401) {
      _handleUnauthorized();
    } else {
      showCustomSnackBar(context, 'Request failed: ${response.reasonPhrase}',
          backgroundColor: Colors.red);
    }
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = allStudents.where((student) {
        final nameMatch = student.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        final classMatch = selectedClass == null ||
            student.assignedClass == selectedClass!.className;
        final sectionMatch = selectedSection == null ||
            student.assignedSection == selectedSection;
        return nameMatch && classMatch && sectionMatch;
      }).toList();
    });
  }

  Future<void> saveAttendance() async {
    if (token == null) {
      return showCustomSnackBar(context, 'Please login to continue',
          backgroundColor: Colors.red);
    }
    if (selectedClass == null) {
      return showCustomSnackBar(context, 'Please select a class',
          backgroundColor: Colors.red);
    }
    if (selectedSection == null) {
      return showCustomSnackBar(context, 'Please select a section',
          backgroundColor: Colors.red);
    }

    setState(() => isLoading = true);

    final attendanceData = filteredStudents
        .map((student) => {
              'student_id': student.id,
              'is_present': student.isPresent,
              'class_id': selectedClass!.id,
              'section': selectedSection,
            })
        .toList();

    final result = await AttendanceService.saveAttendance(
      token: token!,
      date: selectedDate,
      students: attendanceData,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      showCustomSnackBar(context, result['message'],
          backgroundColor: Colors.green);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PrincipleDashboard()),
      );
    } else {
      showCustomSnackBar(context, result['message'],
          backgroundColor: Colors.red);
    }

    setState(() => isLoading = false);
  }

  void _handleUnauthorized() async {
    await AttendanceService.handleUnauthorized();
    setState(() => token = null);
    if (!mounted) return;
    showCustomSnackBar(context, 'Session expired. Please login again.',
        backgroundColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Attendance Management',
      ),
      body: _isInitialLoading ? _buildLoadingIndicator() : _buildBody(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterCard(),
          const SizedBox(height: 16),
          if (token == null) _buildLoginPrompt(),
          if (token != null && isLoading) _buildLoadingIndicator(),
          if (token != null && !isLoading) _buildStudentList(),
          if (token != null) _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return AttendanceFilterCard(
      child: Column(
        children: [
          ClassSectionSelector(
            onSelectionChanged: (ClassModel? cls, String? sec) {
              setState(() {
                selectedClass = cls;
                selectedSection = sec;
                _filterStudents();
              });
            },
            initialClass: selectedClass,
            initialSection: selectedSection,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDatePicker()),
              const SizedBox(width: 10),
              Expanded(child: _buildSearchField()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return CustomDatePicker(
      selectedDate: selectedDate,
      onDateSelected: (DateTime pickedDate) {
        setState(() => selectedDate = pickedDate);
      },
      labelText: 'Attendance Date',
      isExpanded: true,
    );
  }

  Widget _buildSearchField() {
    return AttendanceSearchField(
      controller: searchController,
      onChanged: (_) => _filterStudents(),
      labelText: 'Search Student',
    );
  }

  Widget _buildLoginPrompt() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.warning, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('You are not logged in. Please login to continue.',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {/* Navigate to login */},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Login'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return Expanded(
      child: filteredStudents.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: filteredStudents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return AttendanceListItem(
                  id: student.id,
                  name: student.name,
                  subtitle:
                      '${student.assignedClass} - ${student.assignedSection}',
                  isPresent: student.isPresent,
                  onChanged: (bool value) {
                    setState(() => student.isPresent = value);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            selectedClass == null && selectedSection == null
                ? 'Please select a class and section to view students'
                : selectedClass == null
                    ? 'Please select a class to view students'
                    : selectedSection == null
                        ? 'Please select a section to view students'
                        : 'No students found for ${selectedClass!.className} - $selectedSection',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      text: 'Save',
      icon: Icons.save_alt,
      width: 150,
      onPressed: filteredStudents.isEmpty ? null : saveAttendance,
      isLoading: isLoading,
    );
  }
}

class Student {
  final String id;
  final String name;
  final String assignedClass;
  final String assignedSection;
  bool isPresent;

  Student(this.id, this.name, this.assignedClass, this.assignedSection,
      this.isPresent);
}
