import 'package:flutter/material.dart';
import 'package:sms/pages/teacher/teacher_registration/teacher_form/teacher_advance.dart';
import 'package:sms/pages/teacher/teacher_registration/teacher_form/teacher_document.dart';
import 'teacher_registration_controller.dart';
import 'teacher_form/teacher_info.dart';

class TeacherRegistrationForm extends StatefulWidget {
  final TeacherRegistrationController controller;
  final void Function() onRegistered;

  const TeacherRegistrationForm(
      {super.key, required this.controller, required this.onRegistered});

  @override
  _TeacherRegistrationFormState createState() =>
      _TeacherRegistrationFormState();
}

class _TeacherRegistrationFormState extends State<TeacherRegistrationForm> {
  late TeacherRegistrationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _controller.formKey,
        child: ListView(
          children: [
            Text("Fields marked with an asterisk (*) are mandatory",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 14)),
            SizedBox(height: 20),

            // STUDENT INFORMATION SECTION
            TeacherInfo(controller: _controller),
            TeacherAdvance(controller: _controller),
            TeacherDocument(controller: _controller),

            SizedBox(height: 20),

            // REGISTER STUDENT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _controller.showConfirmationDialog(context, () async {
                    if (await _controller.registerteacher(context)) {
                      widget.onRegistered();
                      Navigator.pop(context);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: _controller.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Register Teacher'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
