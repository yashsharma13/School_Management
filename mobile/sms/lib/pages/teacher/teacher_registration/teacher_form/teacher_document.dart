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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: Colors.blue.shade50,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text(
          "DOCUMENTS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(21, 101, 192, 1),
            fontSize: 16,
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildDocumentRow(
            label: 'Qualification Document',
            onPressed: () => widget.controller.pickFile(context, false),
            fileName: widget.controller.qualificationCertificate?.name,
          ),
          const SizedBox(height: 16),
          _buildDocumentRow(
            label: 'Teacher Photo*',
            onPressed: () => widget.controller.pickFile(context, true),
            fileName: widget.controller.teacherPhoto?.name,
            isRequired: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDocumentRow({
    required String label,
    required VoidCallback onPressed,
    String? fileName,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isRequired ? '$label*' : label,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade300),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
            child: Text(
              'Selected: $fileName',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
