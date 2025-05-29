import 'package:flutter/material.dart';
import 'student_registration_controller.dart';
import 'student_registration_form.dart';

class StudentRegistrationPage extends StatefulWidget {
  final void Function() onStudentRegistered;

  const StudentRegistrationPage({super.key, required this.onStudentRegistered});

  @override
  _StudentRegistrationPageState createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final _controller = StudentRegistrationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("New Student Registration"),
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
      body: StudentRegistrationForm(
        controller: _controller,
        onRegistered: widget.onStudentRegistered,
      ),
    );
  }
}
