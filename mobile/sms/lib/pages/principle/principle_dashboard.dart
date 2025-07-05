// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/assign_teacher_class_subjects/assign_teacher.dart';
// import 'package:sms/pages/assign_teacher_class_subjects/view_teacher_assign.dart';
// import 'package:sms/pages/session/session.dart';
// import 'package:sms/pages/session/manage_session.dart';
// import 'package:sms/pages/student/admission/admission_letter.dart';
// import 'package:sms/pages/classes/all_class.dart';
// import 'package:sms/pages/classes/new_class.dart';
// import 'package:sms/pages/fees/fee_master.dart';
// import 'package:sms/pages/fees/fee_structure.dart';
// import 'package:sms/pages/fees/view_fee_structure.dart';
// import 'package:sms/pages/fees/fees_student_search.dart';
// import 'package:sms/pages/notices/notice_model.dart';
// import 'package:sms/pages/profile_setting/profile_setup.dart';
// import 'package:sms/pages/student/student_attendance/student_attendance.dart';
// import 'package:sms/pages/student/student_details/Student_details.dart';
// import 'package:sms/pages/student/student_registration/student_registration_page.dart';
// import 'package:sms/pages/student/student_report/Student_reports.dart';
// import 'package:sms/pages/subjects/assign_subjects.dart';
// import 'package:sms/pages/subjects/class_with_subjects.dart';
// import 'package:sms/pages/teacher/Job_letter/job_letter.dart';
// import 'package:sms/pages/teacher/teacher_attendance/teacher_attendance.dart';
// import 'package:sms/pages/teacher/teacher_details/teacher_details.dart';
// import 'package:sms/pages/teacher/teacher_registration/teacher_registration.dart';
// import 'package:sms/pages/teacher/teacher_report/teacher_report.dart';
// import 'package:sms/pages/auth/login.dart';
// import 'package:sms/pages/notices/notice.dart';
// import 'package:sms/pages/services/profile_service.dart';
// import 'package:sms/widgets/custom_appbar.dart';

// class PrincipleDashboard extends StatefulWidget {
//   const PrincipleDashboard({super.key});

//   @override
//   _PrincipleDashboardState createState() => _PrincipleDashboardState();
// }

// class _PrincipleDashboardState extends State<PrincipleDashboard> {
//   int totalStudents = 0;
//   int totalTeachers = 0;
//   bool isLoading = false;
//   String? userEmail;
//   List<Notice> notices = [];
//   static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   // Profile data variables
//   String? instituteName;
//   String? instituteAddress;
//   String? logoUrlFull;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData().then((_) {
//       _fetchCounts();
//       _fetchProfileData();
//     });
//     fetchNotices();
//   }

//   Future<void> _loadUserData() async {
//     setState(() => isLoading = true);
//     try {
//       // final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         // userEmail = prefs.getString('user_email');
//       });
//     } catch (e) {
//       debugPrint('Error loading user data: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _fetchProfileData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) {
//         debugPrint('No token found, cannot fetch profile');
//         return;
//       }

//       final profile = await ProfileService.getProfile();
//       // debugPrint('Fetched Profile: $profile');

//       // Remove extra ['data'] nesting
//       final innerData = profile['data'];
//       if (innerData != null) {
//         setState(() {
//           instituteName = innerData['institute_name'] ?? '';
//           instituteAddress = innerData['address'] ?? '';

//           final logoUrl = innerData['logo_url'] ?? '';
//           // debugPrint('Logo URL from API: $logoUrl');

//           if (logoUrl.isNotEmpty) {
//             // Construct full URL properly
//             final cleanBaseUrl = baseeUrl.endsWith('/')
//                 ? baseeUrl.substring(0, baseeUrl.length - 1)
//                 : baseeUrl;
//             final cleanLogoUrl =
//                 logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';

//             logoUrlFull = logoUrl.startsWith('http')
//                 ? logoUrl
//                 : cleanBaseUrl + cleanLogoUrl;

//             // debugPrint('Constructed logo URL: $logoUrlFull');

//             _testLogoUrl(logoUrlFull!);
//           } else {
//             debugPrint('No logo URL found in profile data');
//             logoUrlFull = null;
//           }
//         });
//       } else {
//         debugPrint('Profile data is null');
//       }
//     } catch (e) {
//       debugPrint('Error fetching profile: $e');
//     }
//   }

//   Future<void> _testLogoUrl(String url) async {
//     try {
//       final response = await http.head(Uri.parse(url));
//       // debugPrint('Logo URL test - Status: ${response.statusCode}');
//       if (response.statusCode != 200) {
//         debugPrint('Logo URL not accessible: $url');
//       }
//     } catch (e) {
//       debugPrint('Error testing logo URL: $e');
//     }
//   }

//   Future<void> _fetchCounts() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) {
//         throw Exception('No token found.');
//       }

//       final studentResponse = await http.get(
//         Uri.parse('$baseeUrl/api/api/students/count'),
//         headers: {'Authorization': token},
//       );

//       final teacherResponse = await http.get(
//         Uri.parse('$baseeUrl/api/api/teachers/count'),
//         headers: {'Authorization': token},
//       );

//       if (studentResponse.statusCode == 200 &&
//           teacherResponse.statusCode == 200) {
//         final studentData = json.decode(studentResponse.body);
//         final teacherData = json.decode(teacherResponse.body);

//         setState(() {
//           totalStudents = studentData['totalStudents'];
//           totalTeachers = teacherData['totalTeachers'];
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching counts: $e');
//     }
//   }

//   Future<void> fetchNotices() async {
//     setState(() => isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) return;

//       final response = await http.get(
//         Uri.parse('$baseeUrl/api/notices'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final List<dynamic> data = jsonData['data'];
//         setState(() {
//           notices = data.map((n) => Notice.fromJson(n)).toList();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching notices: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void incrementStudentCount() {
//     setState(() => totalStudents += 1);
//   }

//   void incrementTeacherCount() {
//     setState(() => totalTeachers += 1);
//   }

//   Future<void> _logout() async {
//     bool? shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Confirm Logout"),
//           content: const Text("Are you sure you want to logout?"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text("No"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text("Yes"),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldLogout == true) {
//       setState(() => isLoading = true);
//       await Future.delayed(const Duration(seconds: 1));
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('token');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }

//   Widget _buildLogoImage({double? radius, double? width, double? height}) {
//     if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
//       if (radius != null) {
//         return CircleAvatar(
//           radius: radius,
//           backgroundColor: Colors.grey[300],
//           child: ClipOval(
//             child: Image.network(
//               logoUrlFull!,
//               width: radius * 2,
//               height: radius * 2,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Center(
//                   child: CircularProgressIndicator(
//                     value: loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                             loadingProgress.expectedTotalBytes!
//                         : null,
//                   ),
//                 );
//               },
//               errorBuilder: (context, error, stackTrace) {
//                 debugPrint('Error loading logo: $error');
//                 return Icon(Icons.school, size: radius, color: Colors.white);
//               },
//             ),
//           ),
//         );
//       } else {
//         return Image.network(
//           logoUrlFull!,
//           width: width ?? 80,
//           height: height ?? 80,
//           fit: BoxFit.contain,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return SizedBox(
//               width: width ?? 80,
//               height: height ?? 80,
//               child: Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded /
//                           loadingProgress.expectedTotalBytes!
//                       : null,
//                 ),
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             debugPrint('Error loading logo: $error');
//             return Icon(Icons.school, size: width ?? 80, color: Colors.white);
//           },
//         );
//       }
//     } else {
//       if (radius != null) {
//         return CircleAvatar(
//           radius: radius,
//           backgroundImage: const AssetImage('assets/images/almanet1.jpg'),
//         );
//       } else {
//         return CircleAvatar(
//           radius: (width ?? 80) / 2,
//           backgroundImage: const AssetImage('assets/images/almanet1.jpg'),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         // backgroundColor: Colors.blue.shade900,
//         // iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           PopupMenuButton<String>(
//             icon: Row(
//               children: [
//                 _buildLogoImage(radius: 20),
//                 const SizedBox(width: 4),
//                 const Icon(Icons.keyboard_arrow_down, color: Colors.white),
//               ],
//             ),
//             onSelected: (value) async {
//               if (value == 'profile') {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ProfileSetupPage()),
//                 );
//                 _fetchProfileData();
//               } else if (value == 'settings') {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Settings Page Coming Soon")),
//                 );
//               } else if (value == 'logout') {
//                 _logout();
//               }
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'profile',
//                 child: ListTile(
//                   leading: Icon(Icons.person),
//                   title: Text('Set Profile'),
//                 ),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'settings',
//                 child: ListTile(
//                   leading: Icon(Icons.settings),
//                   title: Text('Settings'),
//                 ),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'logout',
//                 child: ListTile(
//                   leading: Icon(Icons.logout),
//                   title: Text('Logout'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//         title: '',
//       ),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               color: Colors.deepPurple,
//               child: DrawerHeader(
//                 margin: EdgeInsets.zero,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildLogoImage(radius: 40),
//                     const SizedBox(height: 10),
//                     Text(
//                       instituteName ?? "Almanet Dashboard",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     if (instituteAddress != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(
//                           instituteAddress!,
//                           style: const TextStyle(color: Colors.white70),
//                           textAlign: TextAlign.center,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.dashboard, color: Colors.black87),
//                     title: const Text(
//                       "Dashboard",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const PrincipleDashboard()),
//                       );
//                     },
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.calendar_today,
//                         color: Colors.black87), // Session Icon
//                     title: const Text("Session",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.note_add_outlined,
//                             color: Colors.black54), // Create Session Icon
//                         title: const Text("Create Session"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => CreateSessionPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.manage_accounts,
//                             color: Colors.black54), // Manage Session Icon
//                         title: const Text("Manage Session"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => ManageSessionsPage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.person, color: Colors.black87),
//                     title: const Text("Teacher",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Add New Teacher"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => TeacherRegistrationPage(
//                                   onTeacherRegistered: incrementTeacherCount),
//                             ),
//                           );
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.view_agenda_rounded,
//                             color: Colors.black54),
//                         title: const Text("View Teacher details"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       TeacherProfileManagementPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.calendar_month,
//                             color: Colors.black54),
//                         title: const Text("Teacher attendance"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       TeacherAttendancePage()));
//                         },
//                       ),
//                       ListTile(
//                         leading:
//                             const Icon(Icons.report, color: Colors.black54),
//                         title: const Text("Teacher Reports"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => TeacherReportPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading:
//                             const Icon(Icons.report, color: Colors.black54),
//                         title: const Text("Job letter"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       TeacherAdmissionLetterPage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.class_, color: Colors.black87),
//                     title: const Text("Classes",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("New Class"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => AddClassPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.view_agenda_rounded,
//                             color: Colors.black54),
//                         title: const Text("All Classes"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => AllClassesPage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.subject, color: Colors.black87),
//                     title: const Text("Subjects",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.view_agenda_rounded,
//                             color: Colors.black54),
//                         title: const Text("Assign Subjects"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => AssignSubjectPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Classes with Subjects"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       ClassWithSubjectsPage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.class_, color: Colors.black87),
//                     title: const Text("	Teacher Assignment",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Assign Teacher"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => AssignTeacherPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.view_agenda_rounded,
//                             color: Colors.black54),
//                         title: const Text("View Assigned Teachers"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       ViewTeacherAssignmentsPage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.school, color: Colors.black87),
//                     title: const Text("Students",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Add New Student"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => StudentRegistrationPage(
//                                   onStudentRegistered: incrementStudentCount),
//                             ),
//                           );
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.view_agenda_rounded,
//                             color: Colors.black54),
//                         title: const Text("View Student details"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       StudentProfileManagementPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.calendar_month,
//                             color: Colors.black54),
//                         title: const Text("Student attendance"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       StudentAttendancePage()));
//                         },
//                       ),
//                       ListTile(
//                         leading:
//                             const Icon(Icons.report, color: Colors.black54),
//                         title: const Text("Student Reports"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => StudentReportPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.insert_drive_file,
//                             color: Colors.black54),
//                         title: const Text("Admission Letter"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => AdmissionLetterPage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ExpansionTile(
//                     leading: const Icon(Icons.payment, color: Colors.black87),
//                     title: const Text("Fees",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Collect Fees"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       // FeesStudentSearchPage()
//                                       FeeCollectPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Fee Master"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => FeeMasterPage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("Fee Structure"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => FeeStructurePage()));
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.add, color: Colors.black54),
//                         title: const Text("View Fee Structure"),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       ViewFeeStructurePage()));
//                         },
//                       ),
//                     ],
//                   ),
//                   ListTile(
//                     leading:
//                         const Icon(Icons.announcement, color: Colors.black87),
//                     title: const Text(
//                       "Notices",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => NoticesPage()));
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Welcome to ${instituteName ?? 'Dashboard'}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: buildDashboardCard("Total Student",
//                             totalStudents.toString(), Icons.group, Colors.blue),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: buildDashboardCard(
//                             "Total Teacher",
//                             totalTeachers.toString(),
//                             Icons.person,
//                             Colors.green),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: buildDashboardCard(
//                             "Total Classes", "0", Icons.class_, Colors.orange),
//                       ),
//                     ],
//                   ),
//             const SizedBox(height: 30),
//             const Text(
//               "Notices",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: notices.isEmpty
//                   ? const Center(child: Text("No notices available."))
//                   : ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: notices.length,
//                       itemBuilder: (context, index) {
//                         final notice = notices[index];
//                         return Card(
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           margin: const EdgeInsets.only(bottom: 10),
//                           child: ListTile(
//                             title: Text(
//                               notice.title,
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text("Posted on ${notice.noticeDate}"),
//                             leading: Icon(Icons.notification_important,
//                                 color: Colors.red.shade700),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildDashboardCard(
//       String title, String value, IconData icon, Color color) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Icon(icon, size: 40, color: color),
//             const SizedBox(height: 10),
//             Text(title, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 5),
//             Text(value,
//                 style:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/notices/notice_model.dart';
import 'package:sms/pages/profile_setting/profile_setup.dart';
import 'package:sms/pages/auth/login.dart';
import 'package:sms/pages/services/profile_service.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/sidebar.dart';

class PrincipleDashboard extends StatefulWidget {
  const PrincipleDashboard({super.key});

  @override
  _PrincipleDashboardState createState() => _PrincipleDashboardState();
}

class _PrincipleDashboardState extends State<PrincipleDashboard> {
  int totalStudents = 0;
  int totalTeachers = 0;
  bool isLoading = false;
  String? userEmail;
  List<Notice> notices = [];
  static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  // Profile data variables
  String? instituteName;
  String? instituteAddress;
  String? logoUrlFull;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchCounts();
      _fetchProfileData();
    });
    fetchNotices();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      // final prefs = await SharedPreferences.getInstance();
      setState(() {
        // userEmail = prefs.getString('user_email');
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No token found, cannot fetch profile');
        return;
      }

      final profile = await ProfileService.getProfile();
      // debugPrint('Fetched Profile: $profile');

      // Remove extra ['data'] nesting
      final innerData = profile['data'];
      if (innerData != null) {
        setState(() {
          instituteName = innerData['institute_name'] ?? '';
          instituteAddress = innerData['address'] ?? '';

          final logoUrl = innerData['logo_url'] ?? '';
          // debugPrint('Logo URL from API: $logoUrl');

          if (logoUrl.isNotEmpty) {
            // Construct full URL properly
            final cleanBaseUrl = baseeUrl.endsWith('/')
                ? baseeUrl.substring(0, baseeUrl.length - 1)
                : baseeUrl;
            final cleanLogoUrl =
                logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';

            logoUrlFull = logoUrl.startsWith('http')
                ? logoUrl
                : cleanBaseUrl + cleanLogoUrl;

            // debugPrint('Constructed logo URL: $logoUrlFull');

            _testLogoUrl(logoUrlFull!);
          } else {
            debugPrint('No logo URL found in profile data');
            logoUrlFull = null;
          }
        });
      } else {
        debugPrint('Profile data is null');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _testLogoUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      // debugPrint('Logo URL test - Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Logo URL not accessible: $url');
      }
    } catch (e) {
      debugPrint('Error testing logo URL: $e');
    }
  }

  Future<void> _fetchCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found.');
      }

      final studentResponse = await http.get(
        Uri.parse('$baseeUrl/api/api/students/count'),
        headers: {'Authorization': token},
      );

      final teacherResponse = await http.get(
        Uri.parse('$baseeUrl/api/api/teachers/count'),
        headers: {'Authorization': token},
      );

      if (studentResponse.statusCode == 200 &&
          teacherResponse.statusCode == 200) {
        final studentData = json.decode(studentResponse.body);
        final teacherData = json.decode(teacherResponse.body);

        setState(() {
          totalStudents = studentData['totalStudents'];
          totalTeachers = teacherData['totalTeachers'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching counts: $e');
    }
  }

  Future<void> fetchNotices() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseeUrl/api/notices'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        setState(() {
          notices = data.map((n) => Notice.fromJson(n)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching notices: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void incrementStudentCount() {
    setState(() => totalStudents += 1);
  }

  void incrementTeacherCount() {
    setState(() => totalTeachers += 1);
  }

  Future<void> _logout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildLogoImage({double? radius, double? width, double? height}) {
    if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
      if (radius != null) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: Image.network(
              logoUrlFull!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading logo: $error');
                return Icon(Icons.school, size: radius, color: Colors.white);
              },
            ),
          ),
        );
      } else {
        return Image.network(
          logoUrlFull!,
          width: width ?? 80,
          height: height ?? 80,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: width ?? 80,
              height: height ?? 80,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading logo: $error');
            return Icon(Icons.school, size: width ?? 80, color: Colors.white);
          },
        );
      }
    } else {
      if (radius != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: const AssetImage('assets/images/almanet1.jpg'),
        );
      } else {
        return CircleAvatar(
          radius: (width ?? 80) / 2,
          backgroundImage: const AssetImage('assets/images/almanet1.jpg'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // backgroundColor: Colors.blue.shade900,
        // iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              children: [
                _buildLogoImage(radius: 20),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSetupPage()),
                );
                _fetchProfileData();
              } else if (value == 'settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings Page Coming Soon")),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Set Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
        title: '',
      ),
      drawer: Sidebar(
        userType: 'principal',
        // userName: "Principal Name",
        profileImageUrl: logoUrlFull,
        instituteName: instituteName,
        instituteAddress: instituteAddress,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to ${instituteName ?? 'Dashboard'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildDashboardCard("Total Student",
                            totalStudents.toString(), Icons.group, Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                            "Total Teacher",
                            totalTeachers.toString(),
                            Icons.person,
                            Colors.green),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                            "Total Classes", "0", Icons.class_, Colors.orange),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            const Text(
              "Notices",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: notices.isEmpty
                  ? const Center(child: Text("No notices available."))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: notices.length,
                      itemBuilder: (context, index) {
                        final notice = notices[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              notice.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Posted on ${notice.noticeDate}"),
                            leading: Icon(Icons.notification_important,
                                color: Colors.red.shade700),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
