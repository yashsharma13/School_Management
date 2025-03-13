import 'package:flutter/material.dart';
import '../student_registration_controller.dart';

class DocumentsSection extends StatefulWidget {
  final StudentRegistrationController controller;

  const DocumentsSection({super.key, required this.controller});

  @override
  _DocumentsSectionState createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends State<DocumentsSection> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Documents", style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Row(
          children: [
            Expanded(child: Text('Birth Certificate*')),
            ElevatedButton(
              onPressed: () => widget.controller.pickFile(context, false),
              child: Text('Upload'),
            ),
          ],
        ),
        if (widget.controller.birthCertificate != null)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child:
                Text('Selected: ${widget.controller.birthCertificate!.name}'),
          ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: Text('Student Photo*')),
            ElevatedButton(
              onPressed: () => widget.controller.pickFile(context, true),
              child: Text('Upload'),
            ),
          ],
        ),
        if (widget.controller.studentPhoto != null)
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text('Selected: ${widget.controller.studentPhoto!.name}'),
          ),
      ],
    );
  }
}
