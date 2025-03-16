import 'package:flutter/material.dart';
import '../teacher_registration_controller.dart';

class TeacherDocument extends StatefulWidget {
  final TeacherRegistrationController controller;

  const TeacherDocument({super.key, required this.controller});

  @override
  _TeacherDocumentState createState() => _TeacherDocumentState();
}

class _TeacherDocumentState extends State<TeacherDocument> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Documents", style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Row(
          children: [
            Expanded(child: Text('Qualification Document')),
            ElevatedButton(
              onPressed: () => widget.controller.pickFile(context, false),
              child: Text('Upload'),
            ),
          ],
        ),
        if (widget.controller.qualificationCertificate != null)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                'Selected: ${widget.controller.qualificationCertificate!.name}'),
          ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: Text('Teacher Photo*')),
            ElevatedButton(
              onPressed: () => widget.controller.pickFile(context, true),
              child: Text('Upload'),
            ),
          ],
        ),
        if (widget.controller.teacherPhoto != null)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('Selected: ${widget.controller.teacherPhoto!.name}'),
          ),
      ],
    );
  }
}
