// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/auth/login.dart';
// import 'package:sms/pages/services/teacher_profile_service.dart';
// import 'package:sms/pages/teacher_dashboard/ViewHomeworkPage.dart';
// import 'package:sms/pages/teacher_dashboard/event_image.dart';
// import 'package:sms/pages/teacher_dashboard/p_receive_mess.dart';
// import 'package:sms/pages/teacher_dashboard/p_send_message.dart';
// import 'package:sms/pages/teacher_dashboard/t_view_message.dart';
// import 'package:sms/pages/teacher_dashboard/take_attendance.dart';
// import 'package:sms/pages/teacher_dashboard/attendance_report.dart';
// import 'package:sms/pages/teacher_dashboard/add_homework.dart';
// import 'package:sms/pages/teacher_dashboard/view_event_img.dart';
// import 'package:sms/widgets/custom_appbar.dart';

// class TeacherDashboard extends StatefulWidget {
//   const TeacherDashboard({super.key});

//   @override
//   _TeacherDashboardState createState() => _TeacherDashboardState();
// }

// class _TeacherDashboardState extends State<TeacherDashboard> {
//   bool isLoading = false;
//   String teacherName = "Teacher";
//   String? profileImage;
//   List<Map<String, dynamic>> assignedClasses = [];
//   List<Map<String, dynamic>> students = [];
//   String? assignedClass;
//   String? assignedSection;
//   String? errorMessage;
//   static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     setState(() => isLoading = true);
//     await _fetchTeacherProfile();
//     await _loadAssignedClass();
//     setState(() => isLoading = false);
//   }

//   Future<void> _fetchTeacherProfile() async {
//     try {
//       final profile = await TeacherProfileService.getTeacherProfile();
//       debugPrint('Fetched Teacher Profile: $profile');

//       final innerData = profile['data'];
//       if (innerData != null) {
//         setState(() {
//           teacherName = innerData['teacher_name'] ?? 'Teacher';
//           profileImage = innerData['teacher_photo_url'] != null
//               ? _constructImageUrl(innerData['teacher_photo_url'])
//               : (innerData['teacher_photo'] != null
//                   ? _constructImageUrl(innerData['teacher_photo'])
//                   : null);
//           assignedClasses = List<Map<String, dynamic>>.from(
//               innerData['assigned_classes'] ?? []);
//           // students =
//           //     List<Map<String, dynamic>>.from(innerData['students'] ?? []);
//           students = (innerData['students'] as List)
//               .expand((e) => e as List)
//               .map((e) => Map<String, dynamic>.from(e))
//               .toList();
//         });

//         debugPrint('Assigned classes: $assignedClasses');
//         if (profileImage != null) {
//           // debugPrint('Profile image set: $profileImage');
//           _testImageUrl(profileImage!);
//         } else {
//           debugPrint('No profile image available');
//         }
//       } else {
//         debugPrint('Teacher profile data is null');
//         throw Exception('Invalid profile data');
//       }
//     } catch (e) {
//       _showError('Error fetching teacher profile: $e');
//     }
//   }

//   Future<void> _loadAssignedClass() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) {
//       _showError('No token found. Please login again.');
//       Navigator.pushReplacementNamed(context, '/login');
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/assigned-class'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           assignedClass = data['class_name']?.toString() ?? 'Not assigned';
//           assignedSection = data['section']?.toString() ?? 'Not assigned';
//         });
//       } else if (response.statusCode == 401) {
//         _handleUnauthorized();
//       } else if (response.statusCode == 404) {
//         _showError('No class assigned to this teacher');
//       } else {
//         _showError('Failed to fetch assigned class');
//       }
//     } catch (error) {
//       _showError('Error fetching class info: $error');
//     }
//   }

//   void _handleUnauthorized() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     _showError('Session expired. Please login again.');
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   void _showError(String message) {
//     setState(() {
//       errorMessage = message;
//     });
//     Future.delayed(Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() {
//           errorMessage = null;
//         });
//       }
//     });
//   }

//   String _constructImageUrl(String photoPath) {
//     final cleanBaseUrl = baseUrl.endsWith('/')
//         ? baseUrl.substring(0, baseUrl.length - 1)
//         : baseUrl;
//     final cleanPhotoPath =
//         photoPath.startsWith('/') ? photoPath : '/$photoPath';
//     final fullUrl = photoPath.startsWith('http')
//         ? photoPath
//         : '$cleanBaseUrl$cleanPhotoPath';
//     // debugPrint('Constructed teacher photo URL: $fullUrl');
//     return fullUrl;
//   }

//   Future<void> _testImageUrl(String url) async {
//     try {
//       final response = await http.head(Uri.parse(url));
//       // debugPrint('Teacher photo URL test - Status: ${response.statusCode}');
//       if (response.statusCode != 200) {
//         debugPrint('Teacher photo URL not accessible: $url');
//       }
//     } catch (e) {
//       debugPrint('Error testing teacher photo URL: $e');
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
//       setState(() => isLoading = true);
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('token');
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => const LoginPage()));
//     }
//   }

//   Widget buildDashboardCard(
//       String title, String value, IconData icon, Color color) {
//     return Card(
//       color: color.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, size: 32, color: color),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold, color: color),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.bold, color: color),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileImage({double? radius}) {
//     // debugPrint('Building profile image: $profileImage');
//     if (profileImage != null && profileImage!.isNotEmpty) {
//       return CircleAvatar(
//         radius: radius ?? 20,
//         backgroundColor: Colors.grey[300],
//         child: ClipOval(
//           child: Image.network(
//             profileImage!,
//             width: (radius ?? 20) * 2,
//             height: (radius ?? 20) * 2,
//             fit: BoxFit.cover,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded /
//                           loadingProgress.expectedTotalBytes!
//                       : null,
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) {
//               debugPrint('Error loading teacher photo: $error');
//               return Icon(Icons.person, size: radius ?? 20, color: Colors.blue);
//             },
//           ),
//         ),
//       );
//     } else {
//       // debugPrint('Using default profile image');
//       return CircleAvatar(
//         radius: radius ?? 20,
//         backgroundImage: const AssetImage('assets/images/almanet1.jpg'),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         actions: [
//           PopupMenuButton<String>(
//             icon: _buildProfileImage(radius: 20),
//             offset: const Offset(0, 45),
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _logout();
//               }
//             },
//             itemBuilder: (context) => const [
//               PopupMenuItem(value: 'logout', child: Text('Logout')),
//             ],
//           ),
//         ],
//         title: '',
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.deepPurple),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildProfileImage(radius: 40),
//                   const SizedBox(height: 10),
//                   Text(
//                     teacherName,
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
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt_outlined),
//               title: const Text("Event Images"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => EventImageUploadPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt_outlined),
//               title: const Text("View Event Images"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => TeacherEventImagesPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.check_circle_outline),
//               title: const Text("Take attendance"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const TakeAttendancePage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.assignment_turned_in),
//               title: const Text("Attendance Report"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const AttendanceReportPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.home_work),
//               title: const Text("Add Homework"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => AddHomeworkPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.menu_book),
//               title: const Text("View Homework"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => ViewTeacherHomeworkPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.outbox),
//               title: const Text("Sent Message"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => SendMessagePage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.mark_email_read),
//               title: const Text("View Message"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => ViewSentMessagesPage()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.mark_email_unread),
//               title: const Text("Receive Message"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => ViewReceivedMessagesPage()));
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
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: ListView(
//                 children: [
//                   Text(
//                     "Welcome, $teacherName",
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black),
//                   ),
//                   const SizedBox(height: 10),
//                   Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         assignedClass != null && assignedSection != null
//                             ? 'You are the class teacher of $assignedClass - $assignedSection'
//                             : 'No class assigned',
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.blue.shade900),
//                       ),
//                     ),
//                   ),
//                   if (errorMessage != null) ...[
//                     const SizedBox(height: 10),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                           color: Colors.red.shade600,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: Text(errorMessage!,
//                           style: const TextStyle(color: Colors.white)),
//                     ),
//                   ],
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Assigned Classes",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   ...assignedClasses.map(
//                     (cls) => Card(
//                       child: ListTile(
//                         title: Text(
//                             "${cls['class_name'] ?? 'N/A'} - ${cls['section'] ?? 'N/A'}"),
//                         subtitle: Text(
//                             "Subjects: ${(cls['subjects'] as List<dynamic>?)?.join(', ') ?? 'N/A'}"),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   buildDashboardCard(
//                       "Total Classes",
//                       assignedClasses.length.toString(),
//                       Icons.class_,
//                       Colors.blue),
//                 ],
//               ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/auth/login.dart';
import 'package:sms/pages/services/teacher_profile_service.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/sidebar.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool isLoading = false;
  String teacherName = "Teacher";
  String? profileImage;
  List<Map<String, dynamic>> assignedClasses = [];
  List<Map<String, dynamic>> students = [];
  String? assignedClass;
  String? assignedSection;
  String? errorMessage;
  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => isLoading = true);
    await _fetchTeacherProfile();
    await _loadAssignedClass();
    setState(() => isLoading = false);
  }

  Future<void> _fetchTeacherProfile() async {
    try {
      final profile = await TeacherProfileService.getTeacherProfile();
      debugPrint('Fetched Teacher Profile: $profile');

      final innerData = profile['data'];
      if (innerData != null) {
        setState(() {
          teacherName = innerData['teacher_name'] ?? 'Teacher';
          profileImage = innerData['teacher_photo_url'] != null
              ? _constructImageUrl(innerData['teacher_photo_url'])
              : (innerData['teacher_photo'] != null
                  ? _constructImageUrl(innerData['teacher_photo'])
                  : null);
          assignedClasses = List<Map<String, dynamic>>.from(
              innerData['assigned_classes'] ?? []);
          // students =
          //     List<Map<String, dynamic>>.from(innerData['students'] ?? []);
          students = (innerData['students'] as List)
              .expand((e) => e as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });

        debugPrint('Assigned classes: $assignedClasses');
        if (profileImage != null) {
          // debugPrint('Profile image set: $profileImage');
          _testImageUrl(profileImage!);
        } else {
          debugPrint('No profile image available');
        }
      } else {
        debugPrint('Teacher profile data is null');
        throw Exception('Invalid profile data');
      }
    } catch (e) {
      _showError('Error fetching teacher profile: $e');
    }
  }

  Future<void> _loadAssignedClass() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showError('No token found. Please login again.');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/assigned-class'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          assignedClass = data['class_name']?.toString() ?? 'Not assigned';
          assignedSection = data['section']?.toString() ?? 'Not assigned';
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else if (response.statusCode == 404) {
        _showError('No class assigned to this teacher');
      } else {
        _showError('Failed to fetch assigned class');
      }
    } catch (error) {
      _showError('Error fetching class info: $error');
    }
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _showError('Session expired. Please login again.');
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  String _constructImageUrl(String photoPath) {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPhotoPath =
        photoPath.startsWith('/') ? photoPath : '/$photoPath';
    final fullUrl = photoPath.startsWith('http')
        ? photoPath
        : '$cleanBaseUrl$cleanPhotoPath';
    // debugPrint('Constructed teacher photo URL: $fullUrl');
    return fullUrl;
  }

  Future<void> _testImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      // debugPrint('Teacher photo URL test - Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Teacher photo URL not accessible: $url');
      }
    } catch (e) {
      debugPrint('Error testing teacher photo URL: $e');
    }
  }

  Future<void> _logout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  Widget buildDashboardCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage({double? radius}) {
    // debugPrint('Building profile image: $profileImage');
    if (profileImage != null && profileImage!.isNotEmpty) {
      return CircleAvatar(
        radius: radius ?? 20,
        backgroundColor: Colors.grey[300],
        child: ClipOval(
          child: Image.network(
            profileImage!,
            width: (radius ?? 20) * 2,
            height: (radius ?? 20) * 2,
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
              debugPrint('Error loading teacher photo: $error');
              return Icon(Icons.person, size: radius ?? 20, color: Colors.blue);
            },
          ),
        ),
      );
    } else {
      // debugPrint('Using default profile image');
      return CircleAvatar(
        radius: radius ?? 20,
        backgroundImage: const AssetImage('assets/images/almanet1.jpg'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          PopupMenuButton<String>(
            icon: _buildProfileImage(radius: 20),
            offset: const Offset(0, 45),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
        title: '',
      ),
      drawer: Sidebar(
        userType: 'teacher',
        userName: teacherName,
        profileImageUrl: profileImage,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    "Welcome, $teacherName",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        assignedClass != null && assignedSection != null
                            ? 'You are the class teacher of $assignedClass - $assignedSection'
                            : 'No class assigned',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade900),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(errorMessage!,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    "Assigned Classes",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...assignedClasses.map(
                    (cls) => Card(
                      child: ListTile(
                        title: Text(
                            "${cls['class_name'] ?? 'N/A'} - ${cls['section'] ?? 'N/A'}"),
                        subtitle: Text(
                            "Subjects: ${(cls['subjects'] as List<dynamic>?)?.join(', ') ?? 'N/A'}"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildDashboardCard(
                      "Total Classes",
                      assignedClasses.length.toString(),
                      Icons.class_,
                      Colors.blue),
                ],
              ),
            ),
    );
  }
}
