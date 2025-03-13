import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sms/pages/services/api_service.dart';
import 'package:file_picker/file_picker.dart';

class StudentRegistrationController {
  final formKey = GlobalKey<FormState>();
  final dobController = TextEditingController();
  final studentNameController = TextEditingController();
  final registrationController = TextEditingController();
  final addressController = TextEditingController();
  final fathersNameController = TextEditingController();
  final mothersNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? gender;
  String? selectedClass;
  String? selectedSection;
  XFile? studentPhoto;
  XFile? birthCertificate;
  bool isLoading = false;

  // Select date method
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

  // File picking methods
  Future<void> pickFile(BuildContext context, bool isPhoto) async {
    // Existing file picking logic...
    if (isPhoto) {
      if (!kIsWeb) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          studentPhoto = pickedFile;

          // Check if it's a valid image
          if (studentPhoto != null &&
              (studentPhoto!.path.endsWith('.jpg') ||
                  studentPhoto!.path.endsWith('.jpeg') ||
                  studentPhoto!.path.endsWith('.png'))) {
            print("Valid image selected: ${studentPhoto!.path}");
          } else {
            print("Invalid image selected.");
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected image is invalid.')));
            return;
          }

          // Check image size
          final fileSize = await studentPhoto!.length();
          print("Selected photo file size: $fileSize bytes");

          // Validate file size
          if (fileSize < 100) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected image is too small')));
            return;
          }
        }
      } else {
        // Web-specific logic for picking an image
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null) {
          studentPhoto = XFile.fromData(result.files.single.bytes!);

          print("Web image selected: ${studentPhoto?.name}");
          final fileSize = result.files.single.bytes!.length;
          print("Selected photo file size (web): $fileSize bytes");

          // Validate file size
          if (fileSize < 100) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected image is too small')));
            return;
          }
        }
      }
    } else {
      // Handling for Birth Certificate upload
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
        if (result != null) {
          birthCertificate = XFile.fromData(result.files.single.bytes!);
          print("Birth certificate selected: ${birthCertificate?.name}");
        }
      } else {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
        if (result != null) {
          birthCertificate = XFile(result.files.single.path!);
          print("Birth certificate selected: ${birthCertificate?.path}");
        }
      }
    }
  }

  // Register student method
  Future<bool> registerStudent(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // First, check if date is selected
    if (dobController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select date of birth')));
      return false;
    }

    String studentName = studentNameController.text;
    String registrationNumber = registrationController.text;

    // Fix the date conversion
    try {
      String dob = dobController.text;
      // Parse from dd-MM-yyyy to MySQL format yyyy-MM-dd
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dob);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      // Debug print to verify date conversion
      print('Original DOB: $dob');
      print('Formatted DOB: $formattedDate');

      String address = addressController.text;
      String fatherName = fathersNameController.text;
      String motherName = mothersNameController.text;
      String email = emailController.text;
      String phone = phoneController.text;
      String assignedClass = selectedClass ?? '';
      String assignedSection = selectedSection ?? '';

      // Age validation
      DateTime today = DateTime.now();
      int age = today.year - parsedDate.year;
      if (today.month < parsedDate.month ||
          (today.month == parsedDate.month && today.day < parsedDate.day)) {
        age--;
      }

      if (age < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student must be at least 5 years old')));
        return false;
      }

      // Check if required documents are uploaded
      if (studentPhoto == null || birthCertificate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please upload all required documents')));
        return false;
      }

      isLoading = true;

      // Call the API service with the correctly formatted date
      bool success = await ApiService.registerStudent(
        studentName: studentName,
        registrationNumber: registrationNumber,
        dob: formattedDate, // Send the MySQL formatted date
        gender: gender ?? 'Male',
        address: address,
        fatherName: fatherName,
        motherName: motherName,
        email: email,
        phone: phone,
        assignedClass: assignedClass,
        assignedSection: assignedSection,
        studentPhoto: kIsWeb
            ? await studentPhoto?.readAsBytes()
            : File(studentPhoto?.path ?? ''),
        birthCertificate: kIsWeb
            ? await birthCertificate?.readAsBytes()
            : File(birthCertificate?.path ?? ''),
      );

      isLoading = false;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student registered successfully')));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register student')));
        return false;
      }
    } catch (e) {
      isLoading = false;
      print('Error processing date: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing date of birth')));
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
          content: Text('Are you sure you want to register this student?'),
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
