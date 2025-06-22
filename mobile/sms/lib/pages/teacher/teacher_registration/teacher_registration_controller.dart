import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms/pages/services/api_service.dart';
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

  String? gender;
  XFile? teacherPhoto;
  XFile? qualificationCertificate;
  bool isLoading = false;

  // Select date method for Date of Birth
  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  // Select joining date method for Date of Joining
  Future<void> selectJoiningDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dojController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  // File picking method for teacher photo or qualification certificate
  Future<void> pickFile(BuildContext context, bool isPhoto) async {
    if (isPhoto) {
      if (!kIsWeb) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          teacherPhoto = pickedFile;
          // Check if it's a valid image
          if (teacherPhoto != null &&
              (teacherPhoto!.path.endsWith('.jpg') ||
                  teacherPhoto!.path.endsWith('.jpeg') ||
                  teacherPhoto!.path.endsWith('.png'))) {
            // print("Valid image selected: ${teacherPhoto!.path}");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected image is invalid.')));
            return;
          }

          // Check image size (100 KB size check)
          final fileSize = await teacherPhoto!.length();
          if (fileSize < 100 * 1024) {
            // 100 KB size check
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected image is too small')));
            return;
          }
        }
      } else {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null) {
          teacherPhoto = XFile.fromData(result.files.single.bytes!);
          // print("Web image selected: ${teacherPhoto?.name}");
          final fileSize = result.files.single.bytes!.length;
          if (fileSize < 100) {
            // 100 KB size check
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected image is too small')));
            return;
          }
        }
      }
    } else {
      // Birth Certificate handling
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        qualificationCertificate = XFile(result.files.single.path!);
        // print("Certificate selected: ${qualificationCertificate?.path}");
      }
    }
  }

  // Register teacher method
  Future<bool> registerteacher(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (dobController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select date of birth')));
      return false;
    }

    if (dojController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select date of Joining')));
      return false;
    }

    String teacherName = teacherNameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      String dob = dobController.text;
      String doj = dojController.text;
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dob);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      DateTime parsedjoinDate = DateFormat('dd-MM-yyyy').parse(doj);
      String formattedjoinDate =
          DateFormat('yyyy-MM-dd').format(parsedjoinDate);

      String guardian_name = guardianController.text;
      String qualification = teacherqualificationController.text;
      String experience = teacherexperienceController.text;
      String salary = teachersalaryController.text;
      String address = addressController.text;
      String phone = phoneController.text;
      // Check if required documents are uploaded
      if (teacherPhoto == null || qualificationCertificate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please upload all required documents')));
        return false;
      }

      isLoading = true;

      bool success = await ApiService.registerTeacher(
        teacherName: teacherName,
        email: email,
        password: password,
        dob: formattedDate,
        doj: formattedjoinDate, // Corrected here
        gender: gender ?? 'Male',
        guardian_name: guardian_name,
        qualification: qualification,
        experience: experience,
        salary: salary,
        address: address,
        phone: phone,
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
            SnackBar(content: Text('Teacher registered successfully')));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register Teacher')));
        return false;
      }
    } catch (e) {
      // print('Error processing date: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error processing date of birth or joining date')));
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
}
