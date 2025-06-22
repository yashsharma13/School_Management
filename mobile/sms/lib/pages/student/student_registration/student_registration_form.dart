import 'package:flutter/material.dart';
import 'package:sms/pages/student/admission/admission_letter.dart';
import 'package:sms/widgets/button.dart';
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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _controller.formKey,
            child: Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                children: [
                  // Header with mandatory fields note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Fields marked with an asterisk (*) are mandatory",
                            style: TextStyle(
                              color: Color.fromRGBO(21, 101, 192, 1),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section headers with blue accent
                  _buildSectionHeader("Student Information"),
                  const SizedBox(height: 16),
                  StudentInfoSection(controller: _controller),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Parent Information"),
                  const SizedBox(height: 16),
                  ParentInfoSection(controller: _controller),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Class & Section"),
                  const SizedBox(height: 16),
                  ClassSectionInfo(controller: _controller),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Documents"),
                  const SizedBox(height: 16),
                  DocumentsSection(controller: _controller),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Register Student',
                    icon: Icons.app_registration,
                    onPressed: () async {
                      _controller.showConfirmationDialog(context, () async {
                        if (await _controller.registerStudent(context)) {
                          widget.onRegistered();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdmissionLetterPage(),
                            ),
                          );
                        }
                      });
                    },
                    isLoading: _controller.isLoading,
                    // color: Colors.blue.shade700,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 4,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }
}
