import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/auth/login.dart';
import 'package:sms/widgets/dashboard_card.dart';
// import 'package:sms/widgets/drawer_item.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool isLoading = false;
  String studentName = "Student";
  String studentClass = "";
  String studentRoll = "";
  String studentProfileImage = "";
  Map<String, dynamic> studentData = {};

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  // Function to fetch student data from the backend
  Future<void> _fetchStudentDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        // If no token, redirect to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      // Get the student ID from SharedPreferences or token payload
      final studentId = _getStudentIdFromToken(token);

      final response = await http.get(
        Uri.parse('http://localhost:1000/api/students/$studentId'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          studentData = data;
          studentName = data['name'] ?? "Student";
          studentClass = data['class_name'] ?? "";
          // studentRoll = data['roll_number'] ?? "";
          studentProfileImage = data['profile_image'] ?? "";
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load student details');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch student details: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Parse the JWT token to get student ID
  String _getStudentIdFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return "";
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded);

    return payloadMap['id']?.toString() ?? "";
  }

  // Function to handle logout
  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await _showLogoutConfirmationDialog();

    if (shouldLogout != null && shouldLogout) {
      setState(() {
        isLoading = true; // Show loading spinner
      });

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
        title: Text(
          "Welcome, $studentName",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Profile image with dropdown menu
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                // Navigate to profile page
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('My Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: studentProfileImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(studentProfileImage),
                      )
                    : const Icon(Icons.person, color: Colors.blue),
              ),
            ),
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
                    backgroundImage: studentProfileImage.isNotEmpty
                        ? NetworkImage(studentProfileImage)
                        : const AssetImage('assets/images/almanet1.jpg')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    studentName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Student specific menu items
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.black87),
              title: const Text("Dashboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            // Academic menu
            ExpansionTile(
              leading: const Icon(Icons.school, color: Colors.black87),
              title: const Text("Academics",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.black54),
                  title: const Text("Class Schedule"),
                  onTap: () {
                    Navigator.pop(context);
                    // Add navigation to class schedule page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.black54),
                  title: const Text("Assignments"),
                  onTap: () {
                    Navigator.pop(context);
                    // Add navigation to assignments page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_turned_in,
                      color: Colors.black54),
                  title: const Text("Exam Results"),
                  onTap: () {
                    Navigator.pop(context);
                    // Add navigation to exam results page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.subject, color: Colors.black54),
                  title: const Text("Subjects"),
                  onTap: () {
                    Navigator.pop(context);
                    // Add navigation to subjects page
                  },
                ),
              ],
            ),

            // Attendance menu
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.black87),
              title: const Text("My Attendance",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to attendance page
              },
            ),

            // Fees menu
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.black87),
              title: const Text("Fees & Payments",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to fees page
              },
            ),

            // Notices and Announcements
            ListTile(
              leading: const Icon(Icons.announcement, color: Colors.black87),
              title: const Text("Notices",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to notices page
              },
            ),

            // Library menu
            ListTile(
              leading: const Icon(Icons.book, color: Colors.black87),
              title: const Text("Library",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to library page
              },
            ),

            // Profile menu
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: const Text("My Profile",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Add navigation to profile page
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Student Dashboard",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Class: $studentClass | Roll Number: $studentRoll",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Cards row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrap the cards with Expanded or Flexible widgets
                      Expanded(
                        child: buildDashboardCard(
                            "Attendance",
                            "85%", // Replace with actual attendance percentage
                            Icons.calendar_today,
                            Colors.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                            "Pending Fees",
                            "₹2000", // Replace with actual pending fees
                            Icons.payment,
                            Colors.orange),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                            "Assignments",
                            "2", // Replace with actual pending assignments
                            Icons.assignment,
                            Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Upcoming Events",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: const Text(
                        "Annual Sports Day",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("Date: April 15, 2025"),
                      leading: Icon(Icons.event, color: Colors.blue.shade700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Recent Notices",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: const Text(
                        "School will be closed on Monday for Spring Break",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("Posted on April 3, 2025"),
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
