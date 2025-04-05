import 'package:flutter/material.dart';
import 'package:sms/pages/teacher/teacher_registration/teacher_registration_form.dart';
import 'teacher_registration_controller.dart';

class TeacherRegistrationPage extends StatefulWidget {
  final void Function() onTeacherRegistered;

  const TeacherRegistrationPage({super.key, required this.onTeacherRegistered});

  @override
  // ignore: library_private_types_in_public_api
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("New Teacher Registration"),
        centerTitle: true,
      ),
      body: TeacherRegistrationForm(
        controller: _controller,
        onRegistered: widget.onTeacherRegistered,
      ),
    );
  }
}
