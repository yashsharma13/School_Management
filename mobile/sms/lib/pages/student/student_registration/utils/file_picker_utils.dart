// // import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';

// class FilePickerUtils {
//   static Future<XFile?> pickImageFile(BuildContext context) async {
//     if (!kIsWeb) {
//       // Mobile-specific logic
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//       );

//       if (pickedFile != null) {
//         // Validate file format
//         if (!(pickedFile.path.endsWith('.jpg') ||
//             pickedFile.path.endsWith('.jpeg') ||
//             pickedFile.path.endsWith('.png'))) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content:
//                   Text('Invalid image format. Please select JPG or PNG.')));
//           return null;
//         }

//         // Validate file size
//         final fileSize = await pickedFile.length();
//         if (fileSize < 100) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Selected image is too small')));
//           return null;
//         }

//         return pickedFile;
//       }
//     } else {
//       // Web-specific logic
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//       );

//       if (result != null) {
//         final fileSize = result.files.single.bytes!.length;
//         if (fileSize < 100) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Selected image is too small')));
//           return null;
//         }

//         return XFile.fromData(result.files.single.bytes!);
//       }
//     }

//     return null;
//   }

//   static Future<XFile?> pickPdfFile(BuildContext context) async {
//     if (kIsWeb) {
//       FilePickerResult? result = await FilePicker.platform
//           .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

//       if (result != null) {
//         return XFile.fromData(result.files.single.bytes!);
//       }
//     } else {
//       FilePickerResult? result = await FilePicker.platform
//           .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

//       if (result != null) {
//         return XFile(result.files.single.path!);
//       }
//     }

//     return null;
//   }
// }
