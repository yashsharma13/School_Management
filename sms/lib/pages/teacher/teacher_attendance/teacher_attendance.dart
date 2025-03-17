// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/admin/admin_dashboard.dart';

// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});

//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {

//   DateTime selectedDate = DateTime.now();

//   List<Teacher> teachers = [];
//   TextEditingController searchController = TextEditingController();
//   String? token;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   // Load token from SharedPreferences
//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//     print('Token loaded: ${token != null ? 'Yes' : 'No'}');
//   }

//   // Fetch teachers from backend
//   Future<void> fetchTeachers() async {
//     if (selectedClass == null) {
//       print('No class selected. Please select a class.');
//       return;
//     }

//     if (token == null) {
//       print('No token found. Please log in.');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please login to continue')),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     print('Using token: $token');

//     // Ensure class name is properly encoded for URL

//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:1000/api/teacher/$encodedClass'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization':
//               token!, // Use token directly without 'Bearer ' prefix
//         },
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final List<dynamic> teacherData = json.decode(response.body);
//         setState(() {
//           teachers = teacherData
//               .map((data) => Teacher(
//                     data['id'].toString(),
//                     data['teacher_name'],
//                     false, // isPresent initialized as false
//                   ))
//               .toList();
//         });
//       } else if (response.statusCode == 401) {
//         print('Token is invalid or expired. Redirecting to login...');
//         // Clear invalid token
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('token');
//         setState(() {
//           token = null;
//         });

//         // Show message to user
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Session expired. Please login again.')),
//         );
//       } else {
//         print('Failed to load teachers. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Failed to load teachers: ${response.reasonPhrase}')),
//         );
//       }
//     } catch (error) {
//       print('Error fetching teachers: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 'Error connecting to server. Please check your connection.')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Function to submit attendance
//   Future<void> saveAttendance() async {
//     if (token == null) {
//       print('No token found. Please log in.');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please login to continue')),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final attendanceData = teachers.map((teacher) {
//       return {
//         'teacher_id': teacher.id,
//         'is_present': teacher.isPresent,
//       };
//     }).toList();

//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:1000/api/attendance'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization':
//               token!, // Use token directly without 'Bearer ' prefix
//         },
//         body: json.encode({
//           'date': DateFormat('yyyy-MM-dd').format(selectedDate),
//           'teachers': attendanceData,
//         }),
//       );

//       print('Save attendance response: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         // Successfully saved attendance
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Teacher attendance record saved successfully')),
//         );
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AdminDashboard()),
//         );
//       } else if (response.statusCode == 401) {
//         print('Token is invalid or expired. Redirecting to login...');
//         // Clear invalid token
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('token');
//         setState(() {
//           token = null;
//         });

//         // Show message to user
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Session expired. Please login again.')),
//         );
//       } else {
//         // Error occurred while saving attendance
//         print('Failed to save attendance. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Failed to save attendance: ${response.reasonPhrase}')),
//         );
//       }
//     } catch (error) {
//       // Handle network errors or other issues
//       print('Error saving attendance: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 'Error connecting to server. Please check your connection.')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Function to select date
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
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
//       appBar: AppBar(title: Text('Attendance Page')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(

//                       fetchTeachers(); // Fetch teachers after selecting class
//                     },
//                     items: classes
//                         .map<DropdownMenuItem<String>>((String classItem) {
//                       return DropdownMenuItem<String>(
//                         value: classItem,
//                         child: Text(classItem),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: () => _selectDate(context),
//                   icon: Icon(Icons.calendar_today),
//                   label: Text(DateFormat.yMd().format(selectedDate)),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search Teacher',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 setState(() {});
//               },
//             ),
//             SizedBox(height: 10),
//             if (token == null)
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.warning, size: 48, color: Colors.orange),
//                     Text('You are not logged in. Please login to continue.'),
//                     SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Navigate to login page
//                       },
//                       child: Text('Go to Login'),
//                     )
//                   ],
//                 ),
//               )
//             else if (isLoading)
//               Center(child: CircularProgressIndicator())
//             else
//               Expanded(
//                 // child: teachers.isEmpty
//                 //     // ? Center(
//                     //     child: selectedClass == null
//                     //         ? Text('Please select a class to view students')
//                     //         : Text('No students found for $selectedClass'),
//                     //   )
//                     : ListView(
//                         children: teachers
//                             .where((teacher) => teacher.name
//                                 .toLowerCase()
//                                 .contains(searchController.text.toLowerCase()))
//                             .map((teacher) {
//                           return Card(
//                             margin: EdgeInsets.symmetric(vertical: 4),
//                             child: ListTile(
//                               title: Text(teacher.name),
//                               trailing: Switch(
//                                 value: teacher.isPresent,
//                                 onChanged: (bool value) {
//                                   setState(() {
//                                     teacher.isPresent = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//               ),
//             SizedBox(height: 10),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: teachers.isEmpty ? null : saveAttendance,
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.blue,
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   child: Text('Save Attendance'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Teacher {
//   final String id;
//   final String name;
//   bool isPresent;

//   Teacher(this.id, this.name, this.isPresent);
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage({super.key});

  @override
  _TeacherAttendancePageState createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  DateTime selectedDate = DateTime.now();
  List<Teacher> teachers = [];
  TextEditingController searchController = TextEditingController();
  String? token;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // Load token from SharedPreferences and then fetch teachers
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    print('Token loaded: ${token != null ? 'Yes' : 'No'}');

    // After loading the token, fetch teachers if the token is available
    if (token != null) {
      fetchTeachers();
    }
  }

  // Fetch teachers from backend
  Future<void> fetchTeachers() async {
    if (token == null) {
      print('No token found. Please log in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    print('Using token: $token');

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1000/api/teachers'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              token!, // Use token directly without 'Bearer ' prefix
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> teacherData = json.decode(response.body);
        setState(() {
          teachers = teacherData
              .map((data) => Teacher(
                    data['id'].toString(),
                    data['teacher_name'],
                    false, // isPresent initialized as false
                  ))
              .toList();
        });
      } else if (response.statusCode == 401) {
        print('Token is invalid or expired. Redirecting to login...');
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
        });

        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        print('Failed to load teachers. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load teachers: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      print('Error fetching teachers: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error connecting to server. Please check your connection.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to submit attendance
  Future<void> saveAttendance() async {
    if (token == null) {
      print('No token found. Please log in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final attendanceData = teachers.map((teacher) {
      return {
        'teacher_id': teacher.id,
        'is_present': teacher.isPresent,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:1000/api/attendance'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              token!, // Use token directly without 'Bearer ' prefix
        },
        body: json.encode({
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'teachers': attendanceData,
        }),
      );

      print('Save attendance response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Successfully saved attendance
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Teacher attendance record saved successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } else if (response.statusCode == 401) {
        print('Token is invalid or expired. Redirecting to login...');
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
        });

        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        print('Failed to save attendance. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to save attendance: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      print('Error saving attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error connecting to server. Please check your connection.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Teacher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
            if (token == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.orange),
                    Text('You are not logged in. Please login to continue.'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to login page
                      },
                      child: Text('Go to Login'),
                    )
                  ],
                ),
              )
            else if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView(
                  children: teachers
                      .where((teacher) => teacher.name
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()))
                      .map((teacher) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(teacher.name),
                        trailing: Switch(
                          value: teacher.isPresent,
                          onChanged: (bool value) {
                            setState(() {
                              teacher.isPresent = value;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: teachers.isEmpty ? null : saveAttendance,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Attendance'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Teacher {
  final String id;
  final String name;
  bool isPresent;

  Teacher(this.id, this.name, this.isPresent);
}
