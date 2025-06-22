// import 'package:flutter/material.dart';
// import '../student_registration_controller.dart';

// class DocumentsSection extends StatefulWidget {
//   final StudentRegistrationController controller;

//   const DocumentsSection({super.key, required this.controller});

//   @override
//   _DocumentsSectionState createState() => _DocumentsSectionState();
// }

// class _DocumentsSectionState extends State<DocumentsSection> {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: Colors.blue.shade100, width: 1),
//       ),
//       child: ExpansionTile(
//         initiallyExpanded: true,
//         collapsedBackgroundColor: Colors.blue.shade50,
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         title: const Text(
//           "DOCUMENTS",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color.fromRGBO(21, 101, 192, 1),
//             fontSize: 16,
//           ),
//         ),
//         childrenPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         children: [
//           const SizedBox(height: 8),
//           _buildDocumentUploadRow(
//             label: 'Birth Certificate*',
//             isUploaded: widget.controller.birthCertificate != null,
//             fileName: widget.controller.birthCertificate?.name,
//             onPressed: () => widget.controller.pickFile(context, false),
//           ),
//           const SizedBox(height: 16),
//           _buildDocumentUploadRow(
//             label: 'Student Photo*',
//             isUploaded: widget.controller.studentPhoto != null,
//             fileName: widget.controller.studentPhoto?.name,
//             onPressed: () => widget.controller.pickFile(context, true),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentUploadRow({
//     required String label,
//     required bool isUploaded,
//     required String? fileName,
//     required VoidCallback onPressed,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.blue.shade800,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: onPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue.shade700,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 isUploaded ? 'Change' : 'Upload',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         if (isUploaded) ...[
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.insert_drive_file,
//                   color: Colors.blue.shade700,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     fileName ?? 'No file selected',
//                     style: TextStyle(
//                       color: Colors.blue.shade800,
//                       fontSize: 14,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     Icons.close,
//                     color: Colors.blue.shade700,
//                     size: 20,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       if (label.contains('Birth')) {
//                         widget.controller.birthCertificate = null;
//                       } else {
//                         widget.controller.studentPhoto = null;
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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
            xfile: widget.controller.birthCertificate,
            isImage: false,
            onPressed: () async {
              await widget.controller.pickFile(context, false);
              setState(() {});
            },
            onRemove: () {
              setState(() {
                widget.controller.birthCertificate = null;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadRow(
            label: 'Student Photo*',
            isUploaded: widget.controller.studentPhoto != null,
            xfile: widget.controller.studentPhoto,
            isImage: true,
            onPressed: () async {
              await widget.controller.pickFile(context, true);
              setState(() {});
            },
            onRemove: () {
              setState(() {
                widget.controller.studentPhoto = null;
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadRow({
    required String label,
    required bool isUploaded,
    required XFile? xfile,
    required bool isImage,
    required VoidCallback onPressed,
    required VoidCallback onRemove,
  }) {
    final fileName = xfile?.name ?? 'No file selected';

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
                backgroundColor:
                    isUploaded ? Colors.grey.shade300 : Colors.blue.shade700,
                foregroundColor:
                    isUploaded ? Colors.grey.shade700 : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isUploaded ? 'Change' : 'Upload'),
            ),
          ],
        ),
        if (isUploaded && xfile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                if (isImage)
                  FutureBuilder<Uint8List>(
                    future: xfile.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey);
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(
                            snapshot.data!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                    },
                  )
                else
                  Icon(
                    Icons.insert_drive_file,
                    color: Colors.blue.shade700,
                    size: 40,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: _getFileSize(xfile),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<String> _getFileSize(XFile? xfile) async {
    if (xfile == null) return '0 KB';
    final length = await xfile.length();
    if (length < 1024) return '$length B';
    if (length < 1048576) return '${(length / 1024).toStringAsFixed(1)} KB';
    return '${(length / 1048576).toStringAsFixed(1)} MB';
  }
}
