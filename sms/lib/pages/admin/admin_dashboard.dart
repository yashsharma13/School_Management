// import 'package:flutter/material.dart';
// import 'package:sms/pages/admin/student/Student_Registraion.dart';
// import 'package:sms/pages/admin/student/Student_attendance.dart';
// import 'package:sms/pages/admin/student/Student_details.dart';
// import 'package:sms/pages/admin/student/Student_reports.dart';

// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   _AdminDashboardState createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   int totalStudents = 0; // Student count initialized at 0

//   // Function to update the student count
//   void incrementStudentCount() {
//     setState(() {
//       totalStudents += 1; // Increment student count
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade900,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.home, color: Colors.white),
//               onPressed: () {}),
//           IconButton(
//               icon: const Icon(Icons.notifications, color: Colors.white),
//               onPressed: () {}),
//           IconButton(
//               icon: const Icon(Icons.design_services, color: Colors.white),
//               onPressed: () {}),
//           IconButton(
//               icon: const Icon(Icons.info, color: Colors.white),
//               onPressed: () {}),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue.shade900),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 40, // Adjust size
//                     backgroundImage: AssetImage('assets/images/almanet1.jpg'),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Almanet Dashboard",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             // ExpansionTile for Students
//             ExpansionTile(
//               leading: const Icon(Icons.school, color: Colors.black87),
//               title: const Text("Students",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.add, color: Colors.black54),
//                   title: const Text("Add New Student"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => StudentRegistrationPage(
//                           onStudentRegistered:
//                               incrementStudentCount, // Pass callback
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.view_agenda_rounded,
//                       color: Colors.black54),
//                   title: const Text("View Student details"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => StudentProfileManagementPage()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading:
//                       const Icon(Icons.calendar_month, color: Colors.black54),
//                   title: const Text("Student attendance"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => AttendancePage()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.report, color: Colors.black54),
//                   title: const Text("Student Reports"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => StudentReportPage()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             buildDrawerItem(Icons.person, "Teachers", context),
//             buildDrawerItem(Icons.family_restroom, "Parents", context),
//             buildDrawerItem(Icons.announcement, "Notices", context),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Admin Dashboard",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 buildDashboardCard("Total Students", totalStudents.toString(),
//                     Icons.group, Colors.blue),
//                 buildDashboardCard(
//                     "Total Teachers", "0", Icons.person, Colors.green),
//                 buildDashboardCard(
//                     "Total Classes", "0", Icons.class_, Colors.orange),
//               ],
//             ),
//             const SizedBox(height: 30),
//             const Text(
//               "Notices",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               child: ListTile(
//                 title: const Text(
//                   "Notice 1: School will be closed on Monday.",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: const Text("Posted on 2023-10-01"),
//                 leading: Icon(Icons.notification_important,
//                     color: Colors.red.shade700),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildDashboardCard(
//       String title, String value, IconData icon, Color color) {
//     return Expanded(
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Icon(icon, size: 40, color: color),
//               const SizedBox(height: 10),
//               Text(title,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 5),
//               Text(value,
//                   style: TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.bold, color: color)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildDrawerItem(IconData icon, String title, BuildContext context) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.black87),
//       title: Text(title, style: const TextStyle(fontSize: 16)),
//       onTap: () {
//         Navigator.pop(context);
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:sms/pages/admin/student/student_attendance/Student_attendance.dart';
// import 'package:sms/pages/admin/student/student_details/Student_details.dart';
// import 'package:sms/pages/admin/student/student_registration/student_registration_page.dart';
// import 'package:sms/pages/admin/student/student_report/Student_reports.dart';
// import 'package:sms/widgets/dashboard_card.dart';
// import 'package:sms/widgets/drawer_item.dart';

// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});

//   @override
//   _AdminDashboardState createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   int totalStudents = 0; // Student count initialized at 0

//   // Function to update the student count
//   void incrementStudentCount() {
//     setState(() {
//       totalStudents += 1; // Increment student count
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade900,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.home, color: Colors.white),
//               onPressed: () {}),
//           IconButton(
//               icon: const Icon(Icons.notifications, color: Colors.white),
//               onPressed: () {}),
//           IconButton(
//               icon: const Icon(Icons.design_services, color: Colors.white),
//               onPressed: () {}),
//           IconButton(
//               icon: const Icon(Icons.info, color: Colors.white),
//               onPressed: () {}),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue.shade900),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 40, // Adjust size
//                     backgroundImage: AssetImage('assets/images/almanet1.jpg'),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Almanet Dashboard",
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             // ExpansionTile for Students
//             ExpansionTile(
//               leading: const Icon(Icons.school, color: Colors.black87),
//               title: const Text("Students",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.add, color: Colors.black54),
//                   title: const Text("Add New Student"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => StudentRegistrationPage(
//                           onStudentRegistered:
//                               incrementStudentCount, // Pass callback
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.view_agenda_rounded,
//                       color: Colors.black54),
//                   title: const Text("View Student details"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => StudentProfileManagementPage()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading:
//                       const Icon(Icons.calendar_month, color: Colors.black54),
//                   title: const Text("Student attendance"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => AttendancePage()),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.report, color: Colors.black54),
//                   title: const Text("Student Reports"),
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => StudentReportPage()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             buildDrawerItem(Icons.person, "Teachers", context),
//             buildDrawerItem(Icons.family_restroom, "Parents", context),
//             buildDrawerItem(Icons.announcement, "Notices", context),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Admin Dashboard",
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 buildDashboardCard("Total Students", totalStudents.toString(),
//                     Icons.group, Colors.blue),
//                 buildDashboardCard(
//                     "Total Teachers", "0", Icons.person, Colors.green),
//                 buildDashboardCard(
//                     "Total Classes", "0", Icons.class_, Colors.orange),
//               ],
//             ),
//             const SizedBox(height: 30),
//             const Text(
//               "Notices",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               child: ListTile(
//                 title: const Text(
//                   "Notice 1: School will be closed on Monday.",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: const Text("Posted on 2023-10-01"),
//                 leading: Icon(Icons.notification_important,
//                     color: Colors.red.shade700),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:sms/pages/admin/student/student_attendance/Student_attendance.dart';
import 'package:sms/pages/admin/student/student_details/Student_details.dart';
import 'package:sms/pages/admin/student/student_registration/student_registration_page.dart';
import 'package:sms/pages/admin/student/student_report/Student_reports.dart';
import 'package:sms/widgets/dashboard_card.dart';
import 'package:sms/widgets/drawer_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/auth/login.dart'; // Import your login page

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalStudents = 0; // Student count initialized at 0
  bool isLoading = false; // To show loading state

  @override
  void initState() {
    super.initState();
    _fetchTotalStudents(); // Fetch total students when the dashboard is loaded
  }

  // Function to fetch total students from the backend
  Future<void> _fetchTotalStudents() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:1000/api/students/count'), // Replace with your API endpoint
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalStudents =
              data['totalStudents']; // Update the total student count
        });
      } else {
        throw Exception('Failed to load student count');
      }
    } catch (e) {
      print('Error fetching student count: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch student count: $e')),
      );
    }
  }

  // Function to update the student count
  void incrementStudentCount() {
    setState(() {
      totalStudents += 1; // Increment student count
    });
  }

  // Function to handle logout
  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await _showLogoutConfirmationDialog();

    if (shouldLogout != null && shouldLogout) {
      setState(() {
        isLoading = true; // Show loading spinner
      });

      // Simulate a delay (you can replace it with real API logout if needed)
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Clear the token from local storage

      // Navigate to the login page after delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  // Show confirmation dialog for logout
  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose "No"
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User chose "Yes"
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // Call logout function
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40, // Adjust size
                    backgroundImage: AssetImage('assets/images/almanet1.jpg'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Almanet Dashboard",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // ExpansionTile for Students
            ExpansionTile(
              leading: const Icon(Icons.school, color: Colors.black87),
              title: const Text("Students",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.black54),
                  title: const Text("Add New Student"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentRegistrationPage(
                          onStudentRegistered:
                              incrementStudentCount, // Pass callback
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda_rounded,
                      color: Colors.black54),
                  title: const Text("View Student details"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentProfileManagementPage()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.calendar_month, color: Colors.black54),
                  title: const Text("Student attendance"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AttendancePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.black54),
                  title: const Text("Student Reports"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentReportPage()),
                    );
                  },
                ),
              ],
            ),
            buildDrawerItem(Icons.person, "Teachers", context),
            buildDrawerItem(Icons.family_restroom, "Parents", context),
            buildDrawerItem(Icons.announcement, "Notices", context),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator()) // Show loading spinner
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrap the cards with Expanded or Flexible widgets
                      Expanded(
                        child: buildDashboardCard("Total Students",
                            totalStudents.toString(), Icons.group, Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                            "Total Teachers", "0", Icons.person, Colors.green),
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
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: const Text(
                  "Notice 1: School will be closed on Monday.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Posted on 2023-10-01"),
                leading: Icon(Icons.notification_important,
                    color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
