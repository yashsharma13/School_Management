import 'package:flutter/material.dart';
import 'student_registration_controller.dart';
import 'student_form_sections/student_info_section.dart';
import 'student_form_sections/parent_info_section.dart';
import 'student_form_sections/class_section_info.dart';
import 'student_form_sections/documents_section.dart';

class StudentRegistrationForm extends StatefulWidget {
  final StudentRegistrationController controller;
  final void Function() onRegistered;

  const StudentRegistrationForm(
      {super.key, required this.controller, required this.onRegistered});

  @override
  _StudentRegistrationFormState createState() =>
      _StudentRegistrationFormState();
}

class _StudentRegistrationFormState extends State<StudentRegistrationForm> {
  late StudentRegistrationController _controller;

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
            StudentInfoSection(controller: _controller),

            // PARENT INFORMATION SECTION
            ParentInfoSection(controller: _controller),

            // Class and Section
            ClassSectionInfo(controller: _controller),

            // DOCUMENTS SECTION
            DocumentsSection(controller: _controller),

            SizedBox(height: 20),

            // REGISTER STUDENT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _controller.showConfirmationDialog(context, () async {
                    if (await _controller.registerStudent(context)) {
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
                    : Text('Register Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
