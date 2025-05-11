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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          const SizedBox(height: 8),
          _buildDocumentUploadRow(
            label: 'Birth Certificate*',
            isUploaded: widget.controller.birthCertificate != null,
            fileName: widget.controller.birthCertificate?.name,
            onPressed: () => widget.controller.pickFile(context, false),
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadRow(
            label: 'Student Photo*',
            isUploaded: widget.controller.studentPhoto != null,
            fileName: widget.controller.studentPhoto?.name,
            onPressed: () => widget.controller.pickFile(context, true),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadRow({
    required String label,
    required bool isUploaded,
    required String? fileName,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isUploaded ? 'Change' : 'Upload',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        if (isUploaded) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName ?? 'No file selected',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (label.contains('Birth')) {
                        widget.controller.birthCertificate = null;
                      } else {
                        widget.controller.studentPhoto = null;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
