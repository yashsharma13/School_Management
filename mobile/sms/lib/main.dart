// import 'package:flutter/material.dart';
// import 'package:sms/firebase_options.dart';
// import 'package:sms/pages/welcome/welcome.dart';
// import 'package:firebase_core/firebase_core.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     runApp(const MyApp());
//   } catch (e) {
//     // print("Firebase initialization failed: $e");
//     // Handle the error (maybe show an error message to the user)
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: WelcomePage(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:sms/firebase_options.dart';
// import 'package:sms/pages/welcome/welcome.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ Import this package

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Load .env file
//   await dotenv.load(fileName: 'assets/.env');

//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     runApp(const MyApp());
//   } catch (e) {
//     // print("Firebase initialization failed: $e");
//     // Handle the error (maybe show an error message to the user)
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: WelcomePage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sms/firebase_options.dart';
import 'package:sms/pages/auth/login.dart';
import 'package:sms/pages/teacher_dashboard/t_dashboard.dart';
import 'package:sms/pages/welcome/welcome.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';
import 'package:sms/pages/principle/principle_dashboard.dart';
import 'package:sms/pages/stud_dashboard/student_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load user login state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? role = prefs.getString('role');

  Widget initialPage;

  if (token != null && role != null) {
    switch (role.toLowerCase()) {
      case 'student':
        initialPage = const StudentDashboard();
        break;
      case 'teacher':
        initialPage = const TeacherDashboard();
      case 'operator':
        initialPage = const PrincipleDashboard();
        break;
      case 'admin':
        initialPage = const AdminDashboard();
      default:
        initialPage = const LoginPage();
        break;
    }
  } else {
    initialPage = const WelcomePage(); // Show login/register options
  }

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialPage,
    );
  }
}
