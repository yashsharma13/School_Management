import 'package:flutter/material.dart';
import 'package:sms/pages/classes/all_class.dart';
import 'package:sms/pages/classes/new_class.dart';
import 'package:sms/pages/fees/fees_student_search.dart';
import 'package:sms/pages/student/student_attendance/student_attendance.dart';
import 'package:sms/pages/student/student_details/Student_details.dart';
import 'package:sms/pages/student/student_registration/student_registration_page.dart';
import 'package:sms/pages/student/student_report/Student_reports.dart';
import 'package:sms/pages/subjects/assign_subjects.dart';
import 'package:sms/pages/subjects/class_with_subjects.dart';
import 'package:sms/pages/teacher/teacher_attendance/teacher_attendance.dart';
import 'package:sms/pages/teacher/teacher_details/teacher_details.dart';
import 'package:sms/pages/teacher/teacher_registration/teacher_registration.dart';
import 'package:sms/pages/teacher/teacher_report/teacher_report.dart';
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
  int totalTeachers = 0;
  bool isLoading = false; // To show loading state

  @override
  void initState() {
    super.initState();
    _fetchCounts(); // Fetch total students when the dashboard is loaded
  }

  // Function to fetch total students and teachers from the backend
  Future<void> _fetchCounts() async {
    try {
      final studentResponse = await http.get(
        Uri.parse(
            'http://localhost:1000/api/api/students/count'), // Replace with your API
      );
      final teacherResponse = await http.get(
        Uri.parse(
            'http://localhost:1000/api/api/teachers/count'), // Replace with your API
      );

      if (studentResponse.statusCode == 200 &&
          teacherResponse.statusCode == 200) {
        final studentData = json.decode(studentResponse.body);
        final teacherData = json.decode(teacherResponse.body);

        setState(() {
          totalStudents = studentData['totalStudents']; // Update student count
          totalTeachers = teacherData['totalTeachers']; // Update teacher count
        });
      } else {
        throw Exception('Failed to load counts');
      }
    } catch (e) {
      // print('Error fetching counts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch counts: $e')),
      );
    }
  }

  // Function to update the student count
  void incrementStudentCount() {
    setState(() {
      totalStudents += 1; // Increment student count
    });
  }

  // Function to update teacher count
  void incrementTeacherCount() {
    setState(() {
      totalTeachers += 1; // Increment teacher count
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

            // ExpansionTile for classes
            ExpansionTile(
              leading: const Icon(Icons.class_, color: Colors.black87),
              title: const Text("Classes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.black54),
                  title: const Text("New Class"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => (AddClassPage()),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda_rounded,
                      color: Colors.black54),
                  title: const Text("All Classes"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllClassesPage(), // Create a page to view classes
                      ),
                    );
                  },
                ),
              ],
            ),
            // ExpansionTile for Subjects
            ExpansionTile(
              leading: const Icon(Icons.subject, color: Colors.black87),
              title: const Text("Subjects",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.black54),
                  title: const Text("Classes with Subjects"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => (ClassWithSubjectsPage()),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda_rounded,
                      color: Colors.black54),
                  title: const Text("Assign Subjects"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignSubjectPage(), // Create a page to view classes
                      ),
                    );
                  },
                ),
              ],
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
            ExpansionTile(
              leading: const Icon(
                Icons.payment,
                color: Colors.black87,
              ),
              title: const Text(
                "Fees",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.black54),
                  title: const Text("Collect Fees"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeesStudentSearchPage()),
                    );
                  },
                )
              ],
            ),
            // ExpansionTile for teacher
            ExpansionTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: const Text("Teacher",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.black54),
                  title: const Text("Add New Teacher"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherRegistrationPage(
                          onTeacherRegistered:
                              incrementTeacherCount, // Pass callback
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda_rounded,
                      color: Colors.black54),
                  title: const Text("View Teacher details"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeacherProfileManagementPage()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.calendar_month, color: Colors.black54),
                  title: const Text("Teacher attendance"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeacherAttendancePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.black54),
                  title: const Text("Teacher Reports"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TeacherReportPage()),
                    );
                  },
                ),
              ],
            ),

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
                            "Total Teachers",
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
