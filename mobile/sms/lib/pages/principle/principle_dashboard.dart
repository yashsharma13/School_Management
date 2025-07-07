import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/profile_setting/profile_setup.dart';
import 'package:sms/pages/auth/login.dart';
import 'package:sms/pages/services/profile_service.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/sidebar.dart';
import 'package:sms/widgets/notice_widget.dart';

class PrincipleDashboard extends StatefulWidget {
  const PrincipleDashboard({super.key});

  @override
  State<PrincipleDashboard> createState() => _PrincipleDashboardState();
}

class _PrincipleDashboardState extends State<PrincipleDashboard> {
  int totalStudents = 0;
  int totalTeachers = 0;
  int totalClasses = 0;
  bool isLoading = false;
  static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

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
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      // Can be used for future user data
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
      final innerData = profile['data'];
      if (innerData != null) {
        setState(() {
          instituteName = innerData['institute_name'] ?? '';
          instituteAddress = innerData['address'] ?? '';

          final logoUrl = innerData['logo_url'] ?? '';
          if (logoUrl.isNotEmpty) {
            final cleanBaseUrl = baseeUrl.endsWith('/')
                ? baseeUrl.substring(0, baseeUrl.length - 1)
                : baseeUrl;
            final cleanLogoUrl =
                logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';

            logoUrlFull = logoUrl.startsWith('http')
                ? logoUrl
                : cleanBaseUrl + cleanLogoUrl;

            _testLogoUrl(logoUrlFull!);
          } else {
            logoUrlFull = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _testLogoUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
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

      if (token == null) throw Exception('No token found.');

      // Fetch student count
      final studentResponse = await http.get(
        Uri.parse('$baseeUrl/api/api/students/count'), // Removed duplicate /api
        headers: {'Authorization': 'Bearer $token'}, // Added Bearer prefix
      );

      // Fetch teacher count
      final teacherResponse = await http.get(
        Uri.parse('$baseeUrl/api/api/teachers/count'), // Removed duplicate /api
        headers: {'Authorization': 'Bearer $token'}, // Added Bearer prefix
      );

      // Fetch class count
      final classResponse = await http.get(
        Uri.parse('$baseeUrl/api/count'),
        headers: {'Authorization': 'Bearer $token'}, // Added Bearer prefix
      );

      if (studentResponse.statusCode == 200 &&
          teacherResponse.statusCode == 200 &&
          classResponse.statusCode == 200) {
        final studentData = json.decode(studentResponse.body);
        final teacherData = json.decode(teacherResponse.body);
        final classData = json.decode(classResponse.body);

        setState(() {
          // Parse all counts as integers
          totalStudents =
              int.tryParse(studentData['totalStudents'].toString()) ?? 0;
          totalTeachers =
              int.tryParse(teacherData['totalTeachers'].toString()) ?? 0;
          totalClasses =
              int.tryParse(classData['totalClasses'].toString()) ?? 0;
        });
      } else {
        debugPrint('Failed to fetch counts: '
            'Students: ${studentResponse.statusCode}, '
            'Teachers: ${teacherResponse.statusCode}, '
            'Classes: ${classResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching counts: $e');
      if (!mounted) return;
      // Optionally show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading counts: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      if (!mounted) return;
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
                        child: buildDashboardCard(
                          "Total Student",
                          totalStudents.toString(),
                          Icons.group,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                          "Total Teacher",
                          totalTeachers.toString(),
                          Icons.person,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildDashboardCard(
                          "Total Classes",
                          totalClasses.toString(),
                          Icons.class_,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            const NoticeWidget(), // ✅ Reusable widget inserted here
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
