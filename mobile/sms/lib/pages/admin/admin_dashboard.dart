import 'package:flutter/material.dart';
import 'package:sms/pages/admission/admission_letter.dart';
import 'package:sms/pages/classes/all_class.dart';
import 'package:sms/pages/classes/new_class.dart';
import 'package:sms/pages/fees/fees_student_search.dart';
import 'package:sms/pages/notices/notice_model.dart';
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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/auth/login.dart'; // Import your login page
import 'package:sms/pages/notices/notice.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalStudents = 0; // Student count initialized at 0
  int totalTeachers = 0;
  bool isLoading = false; // To show loading state
  String? userEmail;
  List<Notice> notices = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchNotices(); // fetch notices on dashboard load
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userEmail = prefs.getString('user_email'); // This should set the value
      });
      if (userEmail != null) {
        await _fetchCounts();
      }
    } catch (e) {
      // handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Function to fetch total students and teachers from the backend
  Future<void> _fetchCounts() async {
    print("User email: $userEmail");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found. Please log in.');
      }
      final studentResponse = await http.get(
        Uri.parse(
            'http://localhost:1000/api/api/students/count?user_email=$userEmail'),
        headers: {
          'Authorization': token,
        },
        // Replace with your API
      );
      final teacherResponse = await http.get(
        Uri.parse(
            'http://localhost:1000/api/api/teachers/count?user_email=$userEmail'), // Replace with your API
        headers: {
          'Authorization': token,
        },
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

  Future<void> fetchNotices() async {
    setState(() {
      isLoading = true;
      // error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => 'Please login again.');
        // Navigate to login page if needed
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:1000/api/notices'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Notices from API: ${jsonData['data']}');

        final List<dynamic> data = jsonData['data'];
        setState(() {
          notices = data.map((n) => Notice.fromJson(n)).toList();
        });
      } else if (response.statusCode == 401) {
        setState(() => 'Session expired. Please login again.');
      } else {
        setState(() => 'Failed to fetch notices.');
      }
    } catch (e) {
      setState(() => e.toString());
    } finally {
      setState(() => isLoading = false);
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
        child: Column(
          children: [
            // Full-width header
            Container(
              width: double.infinity,
              color: Colors.blue.shade900,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/almanet1.jpg'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Almanet Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: Colors.black87),
                    title: const Text(
                      "Dashboard",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminDashboard()),
                      );
                    },
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.class_, color: Colors.black87),
                    title: const Text("Classes",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add, color: Colors.black54),
                        title: const Text("New Class"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddClassPage()));
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
                                  builder: (context) => AllClassesPage()));
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.subject, color: Colors.black87),
                    title: const Text("Subjects",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add, color: Colors.black54),
                        title: const Text("Classes with Subjects"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ClassWithSubjectsPage()));
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
                                  builder: (context) => AssignSubjectPage()));
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.school, color: Colors.black87),
                    title: const Text("Students",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  onStudentRegistered: incrementStudentCount),
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
                                  builder: (context) =>
                                      StudentProfileManagementPage()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month,
                            color: Colors.black54),
                        title: const Text("Student attendance"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AttendancePage()));
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.report, color: Colors.black54),
                        title: const Text("Student Reports"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StudentReportPage()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.insert_drive_file,
                            color: Colors.black54),
                        title: const Text("Admission Letter"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdmissionLetterPage()));
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.payment, color: Colors.black87),
                    title: const Text("Fees",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add, color: Colors.black54),
                        title: const Text("Collect Fees"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FeesStudentSearchPage()));
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.person, color: Colors.black87),
                    title: const Text("Teacher",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  onTeacherRegistered: incrementTeacherCount),
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
                                  builder: (context) =>
                                      TeacherProfileManagementPage()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month,
                            color: Colors.black54),
                        title: const Text("Teacher attendance"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherAttendancePage()));
                        },
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.report, color: Colors.black54),
                        title: const Text("Teacher Reports"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherReportPage()));
                        },
                      ),
                    ],
                  ),
                  // buildDrawerItem(Icons.family_restroom, "Parents", context),
                  ListTile(
                    leading:
                        const Icon(Icons.announcement, color: Colors.black87),
                    // title: const Text("Notices"),
                    title: const Text(
                      "Notices",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NoticesPage()));
                    },
                  ),
                ],
              ),
            ),
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
            notices.isEmpty
                ? Text("No notices available.")
                : Column(
                    children: notices.map((notice) {
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            notice.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Posted on ${notice.noticeDate}"),
                          leading: Icon(Icons.notification_important,
                              color: Colors.red.shade700),
                        ),
                      );
                    }).toList(),
                  )
          ],
        ),
      ),
    );
  }
}
