// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/principle/principle_dashboard.dart';
// import 'package:sms/widgets/button.dart';

// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});

//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }

// class Class {
//   final String id;
//   final String className;
//   final List<String> sections;

//   Class({
//     required this.id,
//     required this.className,
//     required this.sections,
//   });

//   factory Class.fromJson(Map<String, dynamic> json) {
//     final sections = (json['sections'] as List<dynamic>? ?? [])
//         .map((e) => e.toString())
//         .toList();

//     return Class(
//       id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
//       className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
//           .toString()
//           .trim(),
//       sections: sections,
//     );
//   }
// }

// class _AttendancePageState extends State<AttendancePage> {
//   DateTime selectedDate = DateTime.now();
//   List<Student> allStudents = []; // All students fetched from API
//   List<Student> filteredStudents =
//       []; // Students filtered by class/section/search
//   TextEditingController searchController = TextEditingController();
//   String? token;
//   bool isLoading = false;
//   static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   // For dynamic class and section
//   List<Class> classes = [];
//   String? selectedClass;
//   String? selectedClassId; // Add this to store class_id
//   String? selectedSection;
//   List<String> availableSections = [];
//   bool _isInitialLoading = true;

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
//       await _fetchAllStudents(); // Fetch all students initially
//     }
//     setState(() {
//       _isInitialLoading = false;
//     });
//   }

//   Future<void> _loadClasses() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });

//       final response = await http.get(
//         Uri.parse('$baseeUrl/api/classes'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> classData = json.decode(response.body);

//         // Create a map to group sections by class and store class_id
//         final Map<String, Map<String, dynamic>> classSectionMap = {};
//         final List<Class> tempClasses = [];

//         for (final data in classData) {
//           final className =
//               (data['class_name'] ?? data['className'] ?? '').toString().trim();
//           final section = (data['section'] ?? '').toString().trim();
//           final classId = (data['_id'] ?? data['id'] ?? '').toString().trim();

//           if (className.isEmpty) continue;

//           if (!classSectionMap.containsKey(className)) {
//             classSectionMap[className] = {
//               'id': classId,
//               'sections': <String>{},
//             };
//           }

//           if (section.isNotEmpty) {
//             classSectionMap[className]!['sections'].add(section);
//           }
//         }

//         classSectionMap.forEach((className, classInfo) {
//           tempClasses.add(Class(
//             id: classInfo['id'],
//             className: className,
//             sections: (classInfo['sections'] as Set<String>).toList(),
//           ));
//         });

//         setState(() {
//           classes = tempClasses;
//         });
//       } else if (response.statusCode == 401) {
//         _handleUnauthorized();
//       } else {
//         _showErrorSnackBar('Failed to load classes: ${response.reasonPhrase}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error fetching classes: $error');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchAllStudents() async {
//     if (token == null) {
//       _showErrorSnackBar('Please login to continue');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       allStudents = [];
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseeUrl/api/students'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> studentData = json.decode(response.body);
//         setState(() {
//           allStudents = studentData
//               .map((data) => Student(
//                     data['_id']?.toString() ?? data['id']?.toString() ?? '',
//                     data['student_name']?.toString() ?? 'Unknown Student',
//                     data['assigned_class']?.toString() ?? '',
//                     data['assigned_section']?.toString() ?? '',
//                     false,
//                   ))
//               .toList();
//           _filterStudents(); // Apply initial filter
//         });
//       } else if (response.statusCode == 401) {
//         _handleUnauthorized();
//       } else {
//         _showErrorSnackBar('Failed to load students: ${response.reasonPhrase}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error connecting to server: $error');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _updateAvailableSections(String? className) {
//     setState(() {
//       if (className != null) {
//         final selectedClassObj =
//             classes.firstWhere((c) => c.className == className);
//         availableSections = selectedClassObj.sections;
//         selectedClassId = selectedClassObj.id; // Store the class_id
//       } else {
//         availableSections = [];
//         selectedClassId = null;
//       }
//       selectedSection = null;
//       _filterStudents(); // Filter students when class changes
//     });
//   }

//   void _filterStudents() {
//     setState(() {
//       filteredStudents = allStudents.where((student) {
//         final nameMatch = student.name
//             .toLowerCase()
//             .contains(searchController.text.toLowerCase());
//         final classMatch =
//             selectedClass == null || student.assignedClass == selectedClass;
//         final sectionMatch = selectedSection == null ||
//             student.assignedSection == selectedSection;
//         return nameMatch && classMatch && sectionMatch;
//       }).toList();
//     });
//   }

//   void _handleUnauthorized() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     setState(() {
//       token = null;
//     });
//     _showErrorSnackBar('Session expired. Please login again.');
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red[800],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green[800],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }

//   Future<void> saveAttendance() async {
//     if (token == null) {
//       _showErrorSnackBar('Please login to continue');
//       return;
//     }

//     if (selectedClass == null) {
//       _showErrorSnackBar('Please select a class');
//       return;
//     }

//     if (selectedSection == null) {
//       _showErrorSnackBar('Please select a section');
//       return;
//     }

//     if (selectedClassId == null) {
//       _showErrorSnackBar('Class ID not found. Please reselect the class.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final attendanceData = filteredStudents.map((student) {
//       return {
//         'student_id': student.id,
//         'is_present': student.isPresent,
//         'class_id': selectedClassId, // Send class_id instead of class_name
//         'section': selectedSection,
//       };
//     }).toList();

//     try {
//       final response = await http.post(
//         Uri.parse('$baseeUrl/api/attendance'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//         body: json.encode({
//           'date': DateFormat('yyyy-MM-dd').format(selectedDate),
//           'students': attendanceData,
//         }),
//       );

//       if (response.statusCode == 200) {
//         _showSuccessSnackBar('Attendance saved successfully');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => PrincipleDashboard()),
//         );
//       } else if (response.statusCode == 401) {
//         _handleUnauthorized();
//       } else {
//         _showErrorSnackBar(
//             'Failed to save attendance: ${response.reasonPhrase}');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error saving attendance: $error');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.blue,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//             dialogBackgroundColor: Colors.white,
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Attendance Management',
//             style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: Colors.blue.shade900,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: _isInitialLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: DropdownButtonFormField<String>(
//                                   value: selectedClass,
//                                   decoration: InputDecoration(
//                                     labelText: 'Select Class',
//                                     labelStyle:
//                                         TextStyle(color: Colors.blue.shade700),
//                                     border: OutlineInputBorder(),
//                                     filled: true,
//                                     fillColor: Colors.blue.shade50,
//                                   ),
//                                   isExpanded: true,
//                                   onChanged: (String? newValue) {
//                                     setState(() {
//                                       selectedClass = newValue;
//                                       _updateAvailableSections(newValue);
//                                     });
//                                   },
//                                   items: [
//                                     DropdownMenuItem(
//                                       value: null,
//                                       child: Text('All Classes',
//                                           style: TextStyle(
//                                               color: Colors.blue.shade900)),
//                                     ),
//                                     ...classes.map((classItem) {
//                                       return DropdownMenuItem<String>(
//                                         value: classItem.className,
//                                         child: Text(classItem.className,
//                                             style: TextStyle(
//                                                 color: Colors.blue.shade900)),
//                                       );
//                                     }).toList(),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: DropdownButtonFormField<String>(
//                                   value: selectedSection,
//                                   decoration: InputDecoration(
//                                     labelText: 'Select Section',
//                                     labelStyle:
//                                         TextStyle(color: Colors.blue.shade700),
//                                     border: OutlineInputBorder(),
//                                     filled: true,
//                                     fillColor: Colors.blue.shade50,
//                                   ),
//                                   isExpanded: true,
//                                   onChanged: (String? newValue) {
//                                     setState(() {
//                                       selectedSection = newValue;
//                                       _filterStudents();
//                                     });
//                                   },
//                                   items: [
//                                     DropdownMenuItem(
//                                       value: null,
//                                       child: Text('All Sections',
//                                           style: TextStyle(
//                                               color: Colors.blue.shade900)),
//                                     ),
//                                     ...availableSections.map((section) {
//                                       return DropdownMenuItem<String>(
//                                         value: section,
//                                         child: Text(section,
//                                             style: TextStyle(
//                                                 color: Colors.blue.shade900)),
//                                       );
//                                     }).toList(),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () => _selectDate(context),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.blue.shade50,
//                                     foregroundColor: Colors.blue,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: EdgeInsets.symmetric(vertical: 16),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.calendar_today, size: 18),
//                                       SizedBox(width: 8),
//                                       Text(DateFormat('dd/MM/yyyy')
//                                           .format(selectedDate)),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: TextField(
//                                   controller: searchController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Search Student',
//                                     labelStyle:
//                                         TextStyle(color: Colors.blue.shade700),
//                                     prefixIcon: Icon(Icons.search,
//                                         color: Colors.blue.shade700),
//                                     border: OutlineInputBorder(),
//                                     filled: true,
//                                     fillColor: Colors.blue.shade50,
//                                   ),
//                                   onChanged: (value) {
//                                     _filterStudents();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   if (token == null)
//                     Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.warning, size: 48, color: Colors.orange),
//                             SizedBox(height: 16),
//                             Text(
//                                 'You are not logged in. Please login to continue.',
//                                 style: TextStyle(fontSize: 16)),
//                             SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: () {
//                                 // Navigate to login page
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 24, vertical: 12),
//                               ),
//                               child: Text('Go to Login'),
//                             )
//                           ],
//                         ),
//                       ),
//                     )
//                   else if (isLoading)
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: CircularProgressIndicator(color: Colors.blue),
//                       ),
//                     )
//                   else
//                     Expanded(
//                       child: filteredStudents.isEmpty
//                           ? Center(
//                               child: Card(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Text(
//                                     selectedClass == null &&
//                                             selectedSection == null
//                                         ? 'Please select a class and section to view students'
//                                         : selectedClass == null
//                                             ? 'Please select a class to view students'
//                                             : selectedSection == null
//                                                 ? 'Please select a section to view students'
//                                                 : 'No students found for ${selectedClass!} - $selectedSection',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : ListView.separated(
//                               itemCount: filteredStudents.length,
//                               separatorBuilder: (context, index) =>
//                                   SizedBox(height: 8),
//                               itemBuilder: (context, index) {
//                                 final student = filteredStudents[index];
//                                 return Card(
//                                   elevation: 2,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: ListTile(
//                                     contentPadding: EdgeInsets.symmetric(
//                                         horizontal: 16, vertical: 8),
//                                     leading: CircleAvatar(
//                                       backgroundColor: Colors.blue.shade100,
//                                       child: Text(
//                                         student.name.substring(0, 1),
//                                         style: TextStyle(
//                                             color: Colors.blue.shade800),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       student.name,
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.blue.shade900),
//                                     ),
//                                     subtitle: Text(
//                                       '${student.assignedClass} - ${student.assignedSection}',
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     trailing: Transform.scale(
//                                       scale: 1.2,
//                                       child: Switch(
//                                         value: student.isPresent,
//                                         onChanged: (bool value) {
//                                           setState(() {
//                                             student.isPresent = value;
//                                           });
//                                         },
//                                         activeColor: Colors.blue,
//                                         activeTrackColor: Colors.blue.shade200,
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                   const SizedBox(height: 16),
//                   CustomButton(
//                     text: 'Save',
//                     width: 150,
//                     onPressed: filteredStudents.isEmpty ? null : saveAttendance,
//                     isLoading: isLoading,
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// class Student {
//   final String id;
//   final String name;
//   final String assignedClass;
//   final String assignedSection;
//   bool isPresent;

//   Student(this.id, this.name, this.assignedClass, this.assignedSection,
//       this.isPresent);
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/principle/principle_dashboard.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/date_picker.dart'; // Import your custom date picker

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
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

  factory Class.fromJson(Map<String, dynamic> json) {
    final sections = (json['sections'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Class(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
      sections: sections,
    );
  }
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  List<Student> allStudents = []; // All students fetched from API
  List<Student> filteredStudents =
      []; // Students filtered by class/section/search
  TextEditingController searchController = TextEditingController();
  String? token;
  bool isLoading = false;
  static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  // For dynamic class and section
  List<Class> classes = [];
  String? selectedClass;
  String? selectedClassId; // Add this to store class_id
  String? selectedSection;
  List<String> availableSections = [];
  bool _isInitialLoading = true;

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
      await _fetchAllStudents(); // Fetch all students initially
    }
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadClasses() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse('$baseeUrl/api/classes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> classData = json.decode(response.body);

        // Create a map to group sections by class and store class_id
        final Map<String, Map<String, dynamic>> classSectionMap = {};
        final List<Class> tempClasses = [];

        for (final data in classData) {
          final className =
              (data['class_name'] ?? data['className'] ?? '').toString().trim();
          final section = (data['section'] ?? '').toString().trim();
          final classId = (data['_id'] ?? data['id'] ?? '').toString().trim();

          if (className.isEmpty) continue;

          if (!classSectionMap.containsKey(className)) {
            classSectionMap[className] = {
              'id': classId,
              'sections': <String>{},
            };
          }

          if (section.isNotEmpty) {
            classSectionMap[className]!['sections'].add(section);
          }
        }

        classSectionMap.forEach((className, classInfo) {
          tempClasses.add(Class(
            id: classInfo['id'],
            className: className,
            sections: (classInfo['sections'] as Set<String>).toList(),
          ));
        });

        setState(() {
          classes = tempClasses;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackBar('Failed to load classes: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error fetching classes: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAllStudents() async {
    if (token == null) {
      _showErrorSnackBar('Please login to continue');
      return;
    }

    setState(() {
      isLoading = true;
      allStudents = [];
    });

    try {
      final response = await http.get(
        Uri.parse('$baseeUrl/api/students'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
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
          _filterStudents(); // Apply initial filter
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackBar('Failed to load students: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error connecting to server: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateAvailableSections(String? className) {
    setState(() {
      if (className != null) {
        final selectedClassObj =
            classes.firstWhere((c) => c.className == className);
        availableSections = selectedClassObj.sections;
        selectedClassId = selectedClassObj.id; // Store the class_id
      } else {
        availableSections = [];
        selectedClassId = null;
      }
      selectedSection = null;
      _filterStudents(); // Filter students when class changes
    });
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = allStudents.where((student) {
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

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      token = null;
    });
    _showErrorSnackBar('Session expired. Please login again.');
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

  Future<void> saveAttendance() async {
    if (token == null) {
      _showErrorSnackBar('Please login to continue');
      return;
    }

    if (selectedClass == null) {
      _showErrorSnackBar('Please select a class');
      return;
    }

    if (selectedSection == null) {
      _showErrorSnackBar('Please select a section');
      return;
    }

    if (selectedClassId == null) {
      _showErrorSnackBar('Class ID not found. Please reselect the class.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final attendanceData = filteredStudents.map((student) {
      return {
        'student_id': student.id,
        'is_present': student.isPresent,
        'class_id': selectedClassId, // Send class_id instead of class_name
        'section': selectedSection,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('$baseeUrl/api/attendance'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
        body: json.encode({
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'students': attendanceData,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Attendance saved successfully');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrincipleDashboard()),
        );
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showErrorSnackBar(
            'Failed to save attendance: ${response.reasonPhrase}');
      }
    } catch (error) {
      _showErrorSnackBar('Error saving attendance: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Management',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isInitialLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedClass,
                                  decoration: InputDecoration(
                                    labelText: 'Select Class',
                                    labelStyle:
                                        TextStyle(color: Colors.blue.shade700),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                  isExpanded: true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedClass = newValue;
                                      _updateAvailableSections(newValue);
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('All Classes',
                                          style: TextStyle(
                                              color: Colors.blue.shade900)),
                                    ),
                                    ...classes.map((classItem) {
                                      return DropdownMenuItem<String>(
                                        value: classItem.className,
                                        child: Text(classItem.className,
                                            style: TextStyle(
                                                color: Colors.blue.shade900)),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedSection,
                                  decoration: InputDecoration(
                                    labelText: 'Select Section',
                                    labelStyle:
                                        TextStyle(color: Colors.blue.shade700),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                  isExpanded: true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedSection = newValue;
                                      _filterStudents();
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('All Sections',
                                          style: TextStyle(
                                              color: Colors.blue.shade900)),
                                    ),
                                    ...availableSections.map((section) {
                                      return DropdownMenuItem<String>(
                                        value: section,
                                        child: Text(section,
                                            style: TextStyle(
                                                color: Colors.blue.shade900)),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomDatePicker(
                                  selectedDate: selectedDate,
                                  onDateSelected: (DateTime pickedDate) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  },
                                  labelText: 'Attendance Date',
                                  firstDate: DateTime(2020),
                                  lastDate:
                                      DateTime.now().add(Duration(days: 365)),
                                  isExpanded: true,
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: Colors.blue,
                                  icon: Icons.date_range,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    labelText: 'Search Student',
                                    labelStyle:
                                        TextStyle(color: Colors.blue.shade700),
                                    prefixIcon: Icon(Icons.search,
                                        color: Colors.blue.shade700),
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                  ),
                                  onChanged: (value) {
                                    _filterStudents();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (token == null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning, size: 48, color: Colors.orange),
                            SizedBox(height: 16),
                            Text(
                                'You are not logged in. Please login to continue.',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to login page
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: Text('Go to Login'),
                            )
                          ],
                        ),
                      ),
                    )
                  else if (isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    )
                  else
                    Expanded(
                      child: filteredStudents.isEmpty
                          ? Center(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    selectedClass == null &&
                                            selectedSection == null
                                        ? 'Please select a class and section to view students'
                                        : selectedClass == null
                                            ? 'Please select a class to view students'
                                            : selectedSection == null
                                                ? 'Please select a section to view students'
                                                : 'No students found for ${selectedClass!} - $selectedSection',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredStudents.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        student.name.substring(0, 1),
                                        style: TextStyle(
                                            color: Colors.blue.shade800),
                                      ),
                                    ),
                                    title: Text(
                                      student.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue.shade900),
                                    ),
                                    subtitle: Text(
                                      '${student.assignedClass} - ${student.assignedSection}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 1.2,
                                      child: Switch(
                                        value: student.isPresent,
                                        onChanged: (bool value) {
                                          setState(() {
                                            student.isPresent = value;
                                          });
                                        },
                                        activeColor: Colors.blue,
                                        activeTrackColor: Colors.blue.shade200,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Save',
                    width: 150,
                    onPressed: filteredStudents.isEmpty ? null : saveAttendance,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
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
