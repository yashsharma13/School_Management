// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/widgets/report_components.dart';
// import 'package:sms/pages/services/report_service.dart';
// import 'package:sms/widgets/date_picker.dart';

// class StudentReportPage extends StatefulWidget {
//   const StudentReportPage({super.key});

//   @override
//   _StudentReportPageState createState() => _StudentReportPageState();
// }

// class StudentAttendance {
//   final String studentId;
//   final String studentName;
//   final String? className;
//   final String? section;
//   final bool isPresent;

//   StudentAttendance({
//     required this.studentId,
//     required this.studentName,
//     this.className,
//     this.section,
//     required this.isPresent,
//   });

//   factory StudentAttendance.fromJson(Map<String, dynamic> json) {
//     return StudentAttendance(
//       studentId: (json['student_id'] ?? '').toString().trim(),
//       studentName:
//           (json['student_name'] ?? 'Unknown Student').toString().trim(),
//       className: json['class_name']?.toString().trim(),
//       section: json['section']?.toString().trim(),
//       isPresent: _parseAttendanceStatus(json['is_present']),
//     );
//   }

//   static bool _parseAttendanceStatus(dynamic status) {
//     if (status == null) return false;
//     if (status is bool) return status;
//     if (status is int) return status == 1;
//     if (status is String) {
//       return status.toLowerCase() == 'true' || status == '1';
//     }
//     return false;
//   }
// }

// class _StudentReportPageState extends State<StudentReportPage> {
//   DateTime selectedDate = DateTime.now();
//   List<StudentAttendance> attendanceRecords = [];
//   String? token;
//   bool isLoading = false;
//   bool isError = false;
//   String errorMessage = '';
//   bool attendanceExists = false;
//   bool _isInitialLoading = true;

//   // Class selection
//   List<Map<String, dynamic>> classes = [];
//   String? selectedClass;
//   String? selectedClassId;
//   String? selectedSection;
//   List<String> availableSections = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() => token = prefs.getString('token'));
//     if (token != null) {
//       await _loadClasses();
//     }
//     setState(() => _isInitialLoading = false);
//   }

//   Future<void> _loadClasses() async {
//     setState(() {
//       isLoading = true;
//       isError = false;
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('${ReportService.baseUrl}/api/classes'),
//         headers: _buildHeaders(),
//       );

//       if (response.statusCode == 200) {
//         final dynamic data = json.decode(response.body);
//         final List<dynamic> classData =
//             data is List ? data : data['data'] ?? [];

//         // Process class data
//         final Map<String, Map<String, dynamic>> classMap = {};
//         for (final item in classData) {
//           final className = (item['class_name'] ?? '').toString().trim();
//           final classId =
//               (item['class_id'] ?? item['id'] ?? '').toString().trim();
//           final section = (item['section'] ?? '').toString().trim();

//           if (className.isEmpty || classId.isEmpty) continue;

//           if (!classMap.containsKey(className)) {
//             classMap[className] = {
//               'id': classId,
//               'sections': <String>{},
//             };
//           }

//           if (section.isNotEmpty) {
//             classMap[className]!['sections'].add(section);
//           }
//         }

//         setState(() {
//           classes = classMap.entries
//               .map((e) => {
//                     'name': e.key,
//                     'id': e.value['id'],
//                     'sections': (e.value['sections'] as Set<String>).toList()
//                       ..sort(),
//                   })
//               .toList();
//         });
//       } else {
//         _handleResponseError(response);
//       }
//     } catch (error) {
//       _handleError('Error fetching classes: $error');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> fetchAttendance() async {
//     if (selectedClassId == null || selectedSection == null) {
//       _handleError('Please select both class and section');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       isError = false;
//       attendanceExists = false;
//     });

//     final result = await ReportService.fetchReport(
//       token: token!,
//       endpoint: 'attendance',
//       date: selectedDate,
//       classId: selectedClassId,
//       section: selectedSection!,
//     );

//     if (!mounted) return;

//     setState(() {
//       isLoading = false;

//       if (result['success'] == true) {
//         if (result['unauthorized'] == true) {
//           _handleUnauthorized();
//           return;
//         }

//         attendanceExists = result['exists'] ?? false;

//         if (attendanceExists) {
//           attendanceRecords = (result['data']['students'] ?? [])
//               .map<StudentAttendance>(
//                 (item) => StudentAttendance.fromJson(item),
//               )
//               .toList();
//         }
//       } else {
//         _handleError(result['message']);
//       }
//     });
//   }

//   void _updateAvailableSections(String? className) {
//     setState(() {
//       if (className != null) {
//         final classInfo = classes.firstWhere(
//           (c) => c['name'] == className,
//           orElse: () => {'sections': []},
//         );
//         availableSections =
//             (classInfo['sections'] as List<dynamic>).cast<String>();
//         selectedClassId = classInfo['id'];
//       } else {
//         availableSections = [];
//         selectedClassId = null;
//       }
//       selectedSection = null;
//     });
//   }

//   Map<String, String> _buildHeaders() {
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'Authorization': token!,
//     };
//   }

//   void _handleResponseError(http.Response response) {
//     if (response.statusCode == 401) {
//       _handleUnauthorized();
//     } else {
//       _handleError(
//           'Failed to load data: ${response.statusCode} ${response.reasonPhrase}');
//     }
//   }

//   void _handleUnauthorized() async {
//     await ReportService.handleUnauthorized();
//     setState(() => token = null);
//     _showErrorSnackBar('Session expired. Please login again.');
//   }

//   void _handleError(String message) {
//     setState(() {
//       isError = true;
//       errorMessage = message;
//       isLoading = false;
//     });
//     _showErrorSnackBar(message);
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red[800],
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Student Attendance Report',
//       ),
//       body:
//           _isInitialLoading ? _buildLoadingIndicator() : _buildReportContent(),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Center(child: CircularProgressIndicator());
//   }

//   Widget _buildReportContent() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           _buildFilterCard(),
//           SizedBox(height: 16),
//           if (token == null) _buildLoginPrompt(),
//           if (token != null) _buildReportBody(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterCard() {
//     return ReportFilterCard(
//       title: 'Select Class, Section and Date',
//       children: [
//         _buildClassDropdown(),
//         SizedBox(height: 12),
//         _buildSectionDropdown(),
//         SizedBox(height: 12),
//         CustomDatePicker(
//           selectedDate: selectedDate,
//           onDateSelected: (DateTime newDate) {
//             setState(() => selectedDate = newDate);
//             if (selectedClassId != null && selectedSection != null) {
//               fetchAttendance();
//             }
//           },
//           isExpanded: true,
//           backgroundColor: Colors.deepPurple[50],
//           foregroundColor: Colors.deepPurple,
//         ),
//       ],
//     );
//   }

//   Widget _buildClassDropdown() {
//     return DropdownButtonFormField<String>(
//       value: selectedClass,
//       decoration: _buildDropdownDecoration('Class'),
//       hint: Text('Select Class', style: TextStyle(color: Colors.grey[600])),
//       items: classes.map<DropdownMenuItem<String>>((classInfo) {
//         return DropdownMenuItem<String>(
//           value: classInfo['name'],
//           child: Text(
//             classInfo['name'],
//             style: TextStyle(color: Colors.deepPurple[900]),
//           ),
//         );
//       }).toList(),
//       onChanged: (String? value) {
//         setState(() {
//           selectedClass = value;
//           _updateAvailableSections(value);
//         });
//       },
//     );
//   }

//   Widget _buildSectionDropdown() {
//     return DropdownButtonFormField<String>(
//       value: selectedSection,
//       decoration: _buildDropdownDecoration('Section'),
//       items: [
//         DropdownMenuItem(
//           value: null,
//           child: Text(
//             availableSections.isEmpty ? 'Select class first' : 'Select Section',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//         ),
//         ...availableSections.map(
//           (section) => DropdownMenuItem(
//             value: section,
//             child: Text(section, style: TextStyle(color: Colors.deepPurple[900])),
//           ),
//         ),
//       ],
//       onChanged: availableSections.isEmpty
//           ? null
//           : (String? value) {
//               setState(() => selectedSection = value);
//               if (value != null) fetchAttendance();
//             },
//     );
//   }

//   InputDecoration _buildDropdownDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: Colors.deepPurple[800]),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.deepPurple[50],
//       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//     );
//   }

//   Widget _buildLoginPrompt() {
//     return Expanded(
//       child: Center(
//         child: Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.warning, size: 48, color: Colors.orange),
//                 SizedBox(height: 16),
//                 Text(
//                   'You are not logged in. Please login to continue.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {/* Navigate to login */},
//                   child: Text('Go to Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReportBody() {
//     if (isLoading) return Expanded(child: _buildLoadingIndicator());
//     if (isError) return _buildErrorState();
//     if (selectedClass == null || selectedSection == null) {
//       return _buildSelectionPrompt();
//     }
//     if (!attendanceExists) return _buildNoRecordsFound();
//     return _buildAttendanceList();
//   }

//   Widget _buildErrorState() {
//     return Expanded(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 48, color: Colors.red),
//             SizedBox(height: 16),
//             Text(errorMessage, textAlign: TextAlign.center),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: fetchAttendance,
//               child: Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSelectionPrompt() {
//     return Expanded(
//       child: Center(
//         child: Text(
//           'Please select both class and section to view attendance',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildNoRecordsFound() {
//     return Expanded(
//       child: Center(
//         child: Text(
//           'No attendance records found for $selectedClass - $selectedSection '
//           'on ${DateFormat.yMd().format(selectedDate)}.\n\n'
//           'Attendance may not have been taken for this date.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceList() {
//     return Expanded(
//       child: Column(
//         children: [
//           AttendanceListHeader(
//             title: 'Attendance for $selectedClass - $selectedSection',
//             date: selectedDate,
//           ),
//           AttendanceListHeaderRow(
//             leftText: 'Student Name',
//             rightText: 'Status',
//           ),
//           Expanded(
//             child: ListView.separated(
//               itemCount: attendanceRecords.length,
//               separatorBuilder: (_, __) =>
//                   Divider(height: 1, color: Colors.deepPurple[100]),
//               itemBuilder: (_, index) => AttendanceListItem(
//                 name: attendanceRecords[index].studentName,
//                 isPresent: attendanceRecords[index].isPresent,
//               ),
//             ),
//           ),
//           AttendanceSummary(
//             presentCount: attendanceRecords.where((a) => a.isPresent).length,
//             absentCount: attendanceRecords.where((a) => !a.isPresent).length,
//             totalCount: attendanceRecords.length,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/report_components.dart';
import 'package:sms/pages/services/report_service.dart';
import 'package:sms/widgets/date_picker.dart';
import 'package:sms/widgets/class_section_selector.dart';
import 'package:sms/widgets/custom_snackbar.dart';

class StudentReportPage extends StatefulWidget {
  const StudentReportPage({super.key});

  @override
  _StudentReportPageState createState() => _StudentReportPageState();
}

class StudentAttendance {
  final String studentId;
  final String studentName;
  final String? className;
  final String? section;
  final bool isPresent;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    this.className,
    this.section,
    required this.isPresent,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: (json['student_id'] ?? '').toString().trim(),
      studentName:
          (json['student_name'] ?? 'Unknown Student').toString().trim(),
      className: json['class_name']?.toString().trim(),
      section: json['section']?.toString().trim(),
      isPresent: _parseAttendanceStatus(json['is_present']),
    );
  }

  static bool _parseAttendanceStatus(dynamic status) {
    if (status == null) return false;
    if (status is bool) return status;
    if (status is int) return status == 1;
    if (status is String) {
      return status.toLowerCase() == 'true' || status == '1';
    }
    return false;
  }
}

class _StudentReportPageState extends State<StudentReportPage> {
  DateTime selectedDate = DateTime.now();
  List<StudentAttendance> attendanceRecords = [];
  String? token;
  bool isLoading = false;
  bool isError = false;
  String errorMessage = '';
  bool attendanceExists = false;
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
    setState(() => token = prefs.getString('token'));
    if (token == null) {
      showCustomSnackBar(context, 'Please login to continue',
          backgroundColor: Colors.red);
    }
    setState(() => _isInitialLoading = false);
  }

  Future<void> fetchAttendance() async {
    if (selectedClass == null || selectedSection == null) {
      _handleError('Please select both class and section');
      return;
    }

    setState(() {
      isLoading = true;
      isError = false;
      attendanceExists = false;
    });

    final result = await ReportService.fetchReport(
      token: token!,
      endpoint: 'attendance',
      date: selectedDate,
      classId: selectedClass!.id.toString(),
      section: selectedSection!,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;

      if (result['success'] == true) {
        if (result['unauthorized'] == true) {
          _handleUnauthorized();
          return;
        }

        attendanceExists = result['exists'] ?? false;

        if (attendanceExists) {
          attendanceRecords = (result['data']['students'] ?? [])
              .map<StudentAttendance>(
                (item) => StudentAttendance.fromJson(item),
              )
              .toList();
        }
      } else {
        _handleError(result['message']);
      }
    });
  }

  void _handleUnauthorized() async {
    await ReportService.handleUnauthorized();
    setState(() => token = null);
    showCustomSnackBar(context, 'Session expired. Please login again.',
        backgroundColor: Colors.red);
  }

  void _handleError(String message) {
    setState(() {
      isError = true;
      errorMessage = message;
      isLoading = false;
    });
    showCustomSnackBar(context, message, backgroundColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Student Attendance Report',
      ),
      body:
          _isInitialLoading ? _buildLoadingIndicator() : _buildReportContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildReportContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFilterCard(),
          const SizedBox(height: 16),
          if (token == null) _buildLoginPrompt(),
          if (token != null) _buildReportBody(),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return ReportFilterCard(
      title: 'Select Class, Section and Date',
      children: [
        ClassSectionSelector(
          onSelectionChanged: (ClassModel? cls, String? sec) {
            setState(() {
              selectedClass = cls;
              selectedSection = sec;
              if (cls != null && sec != null) {
                fetchAttendance();
              } else {
                attendanceRecords = [];
                attendanceExists = false;
              }
            });
          },
          initialClass: selectedClass,
          initialSection: selectedSection,
        ),
        const SizedBox(height: 12),
        CustomDatePicker(
          selectedDate: selectedDate,
          onDateSelected: (DateTime newDate) {
            setState(() => selectedDate = newDate);
            if (selectedClass != null && selectedSection != null) {
              fetchAttendance();
            }
          },
          isExpanded: true,
          backgroundColor: Colors.deepPurple[50],
          foregroundColor: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Expanded(
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'You are not logged in. Please login to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {/* Navigate to login */},
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportBody() {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (isError) return _buildErrorState();
    if (selectedClass == null || selectedSection == null) {
      return _buildSelectionPrompt();
    }
    if (!attendanceExists) return _buildNoRecordsFound();
    return _buildAttendanceList();
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchAttendance,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionPrompt() {
    return const Expanded(
      child: Center(
        child: Text(
          'Please select both class and section to view attendance',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildNoRecordsFound() {
    return Expanded(
      child: Center(
        child: Text(
          'No attendance records found for ${selectedClass!.className} - $selectedSection '
          'on ${DateFormat.yMd().format(selectedDate)}.\n\n'
          'Attendance may not have been taken for this date.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Expanded(
      child: Column(
        children: [
          AttendanceListHeader(
            title:
                'Attendance for ${selectedClass!.className} - $selectedSection',
            date: selectedDate,
          ),
          AttendanceListHeaderRow(
            leftText: 'Student Name',
            rightText: 'Status',
          ),
          Expanded(
            child: ListView.separated(
              itemCount: attendanceRecords.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.deepPurple[100]),
              itemBuilder: (_, index) => AttendanceListItem(
                name: attendanceRecords[index].studentName,
                isPresent: attendanceRecords[index].isPresent,
              ),
            ),
          ),
          AttendanceSummary(
            presentCount: attendanceRecords.where((a) => a.isPresent).length,
            absentCount: attendanceRecords.where((a) => !a.isPresent).length,
            totalCount: attendanceRecords.length,
          ),
        ],
      ),
    );
  }
}
