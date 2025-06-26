import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms/pages/services/teacher_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class TeacherRegistrationController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final dojController = TextEditingController();
  final teacherNameController = TextEditingController();
  final registrationController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final teachersalaryController = TextEditingController();
  final teacherexperienceController = TextEditingController();
  final teacherqualificationController = TextEditingController();
  final guardianController = TextEditingController();
  final passwordController = TextEditingController();

  DateTime? dob;
  DateTime? doj;
  String? gender;
  XFile? teacherPhoto;
  XFile? qualificationCertificate;
  bool isLoading = false;

  // Method to update date of birth
  void updateDob(DateTime newDate) {
    dob = newDate;
    dobController.text = DateFormat('dd-MM-yyyy').format(newDate);
  }

  // Method to update date of joining
  void updateDoj(DateTime newDate) {
    doj = newDate;
    dojController.text = DateFormat('dd-MM-yyyy').format(newDate);
  }

  // File picking method for teacher photo or qualification certificate
  Future<void> pickFile(BuildContext context, bool isPhoto) async {
    try {
      if (isPhoto) {
        if (!kIsWeb) {
          final pickedFile =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            // Validate image type
            if (!pickedFile.path.endsWith('.jpg') &&
                !pickedFile.path.endsWith('.jpeg') &&
                !pickedFile.path.endsWith('.png')) {
              throw Exception('Invalid image format');
            }

            // Validate image size (minimum 100KB)
            final fileSize = await pickedFile.length();
            if (fileSize < 100 * 1024) {
              throw Exception('Image too small (min 100KB)');
            }

            teacherPhoto = pickedFile;
          }
        } else {
          FilePickerResult? result =
              await FilePicker.platform.pickFiles(type: FileType.image);
          if (result != null && result.files.single.bytes != null) {
            // Validate web image size
            if (result.files.single.bytes!.length < 100 * 1024) {
              throw Exception('Image too small (min 100KB)');
            }
            teacherPhoto = XFile.fromData(result.files.single.bytes!);
          }
        }
      } else {
        // For qualification certificate (PDF)
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.path != null) {
          qualificationCertificate = XFile(result.files.single.path!);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // Register teacher method
  Future<bool> registerteacher(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // Validate dates
    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date of birth')),
      );
      return false;
    }

    if (doj == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date of joining')),
      );
      return false;
    }

    // Validate documents
    if (teacherPhoto == null || qualificationCertificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all required documents')),
      );
      return false;
    }

    try {
      isLoading = true;

      bool success = await TeacherService.registerTeacher(
        teacherName: teacherNameController.text,
        email: emailController.text,
        password: passwordController.text,
        dob: DateFormat('yyyy-MM-dd').format(dob!),
        doj: DateFormat('yyyy-MM-dd').format(doj!),
        gender: gender ?? 'Male',
        guardianName: guardianController.text,
        qualification: teacherqualificationController.text,
        experience: teacherexperienceController.text,
        salary: teachersalaryController.text,
        address: addressController.text,
        phone: phoneController.text,
        teacherPhoto: kIsWeb
            ? await teacherPhoto?.readAsBytes()
            : File(teacherPhoto?.path ?? ''),
        qualificationCertificate: kIsWeb
            ? await qualificationCertificate?.readAsBytes()
            : File(qualificationCertificate?.path ?? ''),
      );

      isLoading = false;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher registered successfully')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register teacher')),
        );
        return false;
      }
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during registration: ${e.toString()}')),
      );
      return false;
    }
  }

  // Show confirmation dialog
  Future<void> showConfirmationDialog(
      BuildContext context, Function() onConfirm) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Registration'),
          content: Text('Are you sure you want to register this teacher?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  // Clean up resources
  void dispose() {
    dobController.dispose();
    dojController.dispose();
    teacherNameController.dispose();
    registrationController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    teachersalaryController.dispose();
    teacherexperienceController.dispose();
    teacherqualificationController.dispose();
    guardianController.dispose();
    passwordController.dispose();
  }
}
