// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:sms/pages/auth/login.dart';
// import 'package:sms/pages/parents_dashboard/event_gallery.dart';
// import 'package:sms/pages/parents_dashboard/receive_message.dart';
// import 'package:sms/pages/parents_dashboard/sent_message.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/pages/parents_dashboard/view_attendance.dart';
// import 'package:sms/pages/parents_dashboard/view_homework.dart'; // Import new page
// import 'package:url_launcher/url_launcher.dart';

// class ParentDashboard extends StatefulWidget {
//   const ParentDashboard({super.key});

//   @override
//   _ParentDashboardState createState() => _ParentDashboardState();
// }

// class _ParentDashboardState extends State<ParentDashboard> {
//   bool isLoading = true;
//   String? errorMessage;
//   List<Map<String, dynamic>> studentData = [];

//   final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   @override
//   void initState() {
//     super.initState();
//     fetchParentStudents();
//   }

//   Future<void> fetchParentStudents() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) {
//       setState(() {
//         errorMessage = 'Token missing. Please login again.';
//         isLoading = false;
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/dashboard/students'),
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List students = data['data'] ?? [];

//         setState(() {
//           studentData = students
//               .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
//               .toList();
//           isLoading = false;
//         });
//         print("✅ Student data fetched: $studentData");
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load student data.';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching students: $e';
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> openPdf(String pdfPath) async {
//     final fileName = Uri.encodeComponent(pdfPath.split('/').last);
//     final pdfUrl = '$baseUrl/Uploads/$fileName';
//     final uri = Uri.parse(pdfUrl);

//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       setState(() {
//         errorMessage = 'Could not open PDF: $pdfUrl';
//       });
//     }
//   }

//   Future<void> _logout() async {
//     bool? shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Confirm Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text("No"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text("Yes"),
//           ),
//         ],
//       ),
//     );

//     if (shouldLogout == true) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('token');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }

//   Widget buildStudentCard(Map<String, dynamic> student) {
//     final String photoFileName = student['student_photo'] ?? '';
//     final String photoUrl =
//         photoFileName.isNotEmpty ? '$baseUrl/uploads/$photoFileName' : '';
//     final String teacherName = student['teacher_name'] ?? 'Not Available';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundImage: photoUrl.isNotEmpty
//                   ? NetworkImage(photoUrl)
//                   : const AssetImage('assets/images/student_default.png')
//                       as ImageProvider,
//               radius: 25,
//               backgroundColor: Colors.grey[200],
//             ),
//             title: Text(student['student_name'] ?? 'Unnamed'),
//             subtitle: Text(
//               '${student['assigned_class'] ?? 'N/A'} - ${student['assigned_section'] ?? 'N/A'}',
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 16, bottom: 8),
//             child: Text(
//               'Your class teacher is $teacherName',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: ''),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.deepPurple),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 35,
//                     backgroundImage: studentData.isNotEmpty &&
//                             studentData[0]['student_photo'] != null
//                         ? NetworkImage(
//                             '$baseUrl/uploads/${studentData[0]['student_photo']}')
//                         : const AssetImage('assets/images/student_default.png')
//                             as ImageProvider,
//                     backgroundColor: Colors.grey[200],
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     studentData.isNotEmpty
//                         ? 'Hello, ${studentData[0]['student_name']}'
//                         : 'Welcome Parent',
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text("Dashboard"),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.fact_check),
//               title: const Text("View attendance Report"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => ViewAttendance()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.send),
//               title: const Text("Sent Message"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => SendTextPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.message),
//               title: const Text("Receive Message"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => ViewMessagesPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text("Event Gallery"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => EventGalleryPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.book),
//               title: const Text("View Homework"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const ViewHomeworkPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text("Logout"),
//               onTap: _logout,
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(
//                   child: Text(
//                     errorMessage!,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 )
//               : ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     const Text(
//                       "Your Children",
//                       style:
//                           TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     ...studentData.map(buildStudentCard),
//                   ],
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/sidebar.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> studentData = [];

  final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchParentStudents();
  }

  Future<void> fetchParentStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        errorMessage = 'Token missing. Please login again.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/students'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List students = data['data'] ?? [];

        setState(() {
          studentData = students
              .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
              .toList();
          isLoading = false;
        });
        // debugPrint("✅ Student data fetched: $studentData");
      } else {
        setState(() {
          errorMessage = 'Failed to load student data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching students: $e';
        isLoading = false;
      });
    }
  }

  Future<void> openPdf(String pdfPath) async {
    final fileName = Uri.encodeComponent(pdfPath.split('/').last);
    final pdfUrl = '$baseUrl/Uploads/$fileName';
    final uri = Uri.parse(pdfUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        errorMessage = 'Could not open PDF: $pdfUrl';
      });
    }
  }

  Widget buildStudentCard(Map<String, dynamic> student) {
    final String photoFileName = student['student_photo'] ?? '';
    final String photoUrl =
        photoFileName.isNotEmpty ? '$baseUrl/uploads/$photoFileName' : '';
    final String teacherName = student['teacher_name'] ?? 'Not Available';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/student_default.png')
                      as ImageProvider,
              radius: 25,
              backgroundColor: Colors.grey[200],
            ),
            title: Text(student['student_name'] ?? 'Unnamed'),
            subtitle: Text(
              '${student['assigned_class'] ?? 'N/A'} - ${student['assigned_section'] ?? 'N/A'}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Your class teacher is $teacherName',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ''),
      drawer: Sidebar(
        userType: 'parent',
        userName:
            studentData.isNotEmpty ? studentData[0]['student_name'] : null,
        profileImageUrl: studentData.isNotEmpty
            ? '$baseUrl/uploads/${studentData[0]['student_photo']}'
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      "Your Children",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...studentData.map(buildStudentCard),
                  ],
                ),
    );
  }
}
