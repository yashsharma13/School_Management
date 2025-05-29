import 'package:flutter/material.dart';
import 'package:sms/pages/teacher/teacher_registration/teacher_registration_form.dart';
import 'teacher_registration_controller.dart';

class TeacherRegistrationPage extends StatefulWidget {
  final void Function() onTeacherRegistered;

  const TeacherRegistrationPage({super.key, required this.onTeacherRegistered});

  @override
  _TeacherRegistrationPageState createState() =>
      _TeacherRegistrationPageState();
}

class _TeacherRegistrationPageState extends State<TeacherRegistrationPage> {
  final _controller = TeacherRegistrationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("New Teacher Registration"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: TeacherRegistrationForm(
          controller: _controller,
          onRegistered: widget.onTeacherRegistered,
        ),
      ),
    );
  }
}
