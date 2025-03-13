// // import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:sms/pages/services/api_service.dart';
// import 'package:file_picker/file_picker.dart';
// // import 'dart:typed_data';

// class StudentRegistrationPage extends StatefulWidget {
//   final void Function() onStudentRegistered;

//   const StudentRegistrationPage({super.key, required this.onStudentRegistered});

//   @override
//   _StudentRegistrationPageState createState() =>
//       _StudentRegistrationPageState();
// }

// class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _dobController = TextEditingController();
//   final _studentNameController = TextEditingController();
//   final _registrationController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _fathersNameController = TextEditingController();
//   final _mothersNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();

//   String? gender;
//   String? selectedClass;
//   String? selectedSection;
//   XFile? studentPhoto;
//   XFile? birthCertificate;

//   bool isLoading = false; // Track loading state

//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
//       });
//     }
//   }

//   // Function to pick image or file based on isPhoto flag
//   Future<void> pickFile(bool isPhoto) async {
//     if (isPhoto) {
//       if (!kIsWeb) {
//         // Mobile-specific logic for picking an image
//         final pickedFile =
//             await ImagePicker().pickImage(source: ImageSource.gallery);
//         if (pickedFile != null) {
//           setState(() {
//             studentPhoto = pickedFile;
//           });

//           // Check if it's a valid image
//           if (studentPhoto != null &&
//               (studentPhoto!.path.endsWith('.jpg') ||
//                   studentPhoto!.path.endsWith('.jpeg') ||
//                   studentPhoto!.path.endsWith('.png'))) {
//             print("Valid image selected: ${studentPhoto!.path}");
//           } else {
//             print("Invalid image selected.");
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Selected image is invalid.')));

//             return;
//           }

//           // Check image size
//           final fileSize = await studentPhoto!.length();
//           print("Selected photo file size: $fileSize bytes");

//           // Validate file size
//           if (fileSize < 100) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Selected image is too small')));
//             return;
//           }
//         }
//       } else {
//         // Web-specific logic for picking an image
//         FilePickerResult? result =
//             await FilePicker.platform.pickFiles(type: FileType.image);
//         if (result != null) {
//           setState(() {
//             studentPhoto = XFile.fromData(result.files.single.bytes!);
//           });

//           print("Web image selected: ${studentPhoto?.name}");
//           final fileSize = result.files.single.bytes!.length;
//           print("Selected photo file size (web): $fileSize bytes");

//           // Validate file size
//           if (fileSize < 100) {
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Selected image is too small')));
//             return;
//           }
//         }
//       }
//     } else {
//       // Handling for Birth Certificate upload
//       if (kIsWeb) {
//         FilePickerResult? result = await FilePicker.platform
//             .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
//         if (result != null) {
//           setState(() {
//             birthCertificate = XFile.fromData(result.files.single.bytes!);
//           });
//           print("Birth certificate selected: ${birthCertificate?.name}");
//         }
//       } else {
//         FilePickerResult? result = await FilePicker.platform
//             .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
//         if (result != null) {
//           setState(() {
//             birthCertificate = XFile(result.files.single.path!);
//           });
//           print("Birth certificate selected: ${birthCertificate?.path}");
//         }
//       }
//     }
//   }

//   Future<void> registerStudent() async {
//     if (_formKey.currentState!.validate()) {
//       // First, check if date is selected
//       if (_dobController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Please select date of birth')));
//         return;
//       }

//       String studentName = _studentNameController.text;
//       String registrationNumber = _registrationController.text;

//       // Fix the date conversion
//       try {
//         String dob = _dobController.text;
//         // Parse from dd-MM-yyyy to MySQL format yyyy-MM-dd
//         DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dob);
//         String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

//         // Debug print to verify date conversion
//         print('Original DOB: $dob');
//         print('Formatted DOB: $formattedDate');

//         String address = _addressController.text;
//         String fatherName = _fathersNameController.text;
//         String motherName = _mothersNameController.text;
//         String email = _emailController.text;
//         String phone = _phoneController.text;
//         String assignedClass = selectedClass ?? '';
//         String assignedSection = selectedSection ?? '';

//         // Age validation
//         DateTime today = DateTime.now();
//         int age = today.year - parsedDate.year;
//         if (today.month < parsedDate.month ||
//             (today.month == parsedDate.month && today.day < parsedDate.day)) {
//           age--;
//         }

//         if (age < 5) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Student must be at least 5 years old')));
//           return;
//         }

//         // Check if required documents are uploaded
//         if (studentPhoto == null || birthCertificate == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Please upload all required documents')));
//           return;
//         }

//         // Set loading state
//         setState(() {
//           isLoading = true;
//         });

//         // Call the API service with the correctly formatted date
//         bool success = await ApiService.registerStudent(
//           studentName: studentName,
//           registrationNumber: registrationNumber,
//           dob: formattedDate, // Send the MySQL formatted date
//           gender: gender ?? 'Male',
//           address: address,
//           fatherName: fatherName,
//           motherName: motherName,
//           email: email,
//           phone: phone,
//           assignedClass: assignedClass,
//           assignedSection: assignedSection,
//           studentPhoto: kIsWeb
//               ? await studentPhoto?.readAsBytes()
//               : File(studentPhoto?.path ?? ''),
//           birthCertificate: kIsWeb
//               ? await birthCertificate?.readAsBytes()
//               : File(birthCertificate?.path ?? ''),
//         );

//         setState(() {
//           isLoading = false;
//         });

//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Student registered successfully')));
//           widget.onStudentRegistered();
//           Navigator.pop(context);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Failed to register student')));
//         }
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//         });
//         print('Error processing date: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error processing date of birth')));
//       }
//     }
//   }

//   Future<void> _showConfirmationDialog() async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Registration'),
//           content: Text('Are you sure you want to register this student?'),
//           actions: [
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Confirm'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 registerStudent();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text("New Student Registration"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               Text("Fields marked with an asterisk (*) are mandatory",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.red, fontSize: 14)),
//               SizedBox(height: 20),
//               // STUDENT INFORMATION SECTION
//               ExpansionTile(
//                 title: Text("Student Information",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 children: [
//                   TextFormField(
//                       controller: _studentNameController,
//                       decoration: InputDecoration(labelText: 'Student Name*'),
//                       validator: (value) =>
//                           value!.isEmpty ? 'Please enter student name' : null),
//                   TextFormField(
//                       controller: _registrationController,
//                       decoration: InputDecoration(
//                           labelText: 'Registration Number*',
//                           hintText: 'e.g., REG2024001'),
//                       validator: (value) => value!.isEmpty
//                           ? 'Please enter registration number'
//                           : null),
//                   TextFormField(
//                     controller: _dobController,
//                     decoration: InputDecoration(
//                         labelText: 'Date of Birth*',
//                         suffixIcon: Icon(Icons.calendar_today)),
//                     readOnly: true,
//                     onTap: () => _selectDate(context),
//                   ),
//                   DropdownButtonFormField<String>(
//                     value: gender,
//                     decoration: InputDecoration(labelText: 'Gender*'),
//                     items: ['Male', 'Female', 'Other']
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: (value) => setState(() => gender = value),
//                   ),
//                   TextFormField(
//                       controller: _addressController,
//                       decoration: InputDecoration(labelText: 'Address*'),
//                       validator: (value) =>
//                           value!.isEmpty ? 'Please enter address' : null),
//                 ],
//               ),
//               // PARENT INFORMATION SECTION
//               ExpansionTile(
//                 title: Text("Parent Information",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 children: [
//                   TextFormField(
//                       controller: _fathersNameController,
//                       decoration: InputDecoration(labelText: "Father's Name*"),
//                       validator: (value) =>
//                           value!.isEmpty ? "Please enter father's name" : null),
//                   TextFormField(
//                       controller: _mothersNameController,
//                       decoration: InputDecoration(labelText: "Mother's Name*"),
//                       validator: (value) =>
//                           value!.isEmpty ? "Please enter mother's name" : null),
//                   TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(labelText: 'Email*'),
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please enter email';
//                         }
//                         String pattern =
//                             r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
//                         RegExp regex = RegExp(pattern);
//                         if (!regex.hasMatch(value)) {
//                           return 'Enter a valid email address';
//                         }
//                         return null;
//                       }),
//                   TextFormField(
//                       controller: _phoneController,
//                       decoration: InputDecoration(labelText: 'Phone*'),
//                       validator: (value) {
//                         if (value!.isEmpty) {
//                           return 'Please enter phone number';
//                         }
//                         if (value.length != 10) {
//                           return 'Phone number must be 10 digits';
//                         }
//                         return null;
//                       }),
//                 ],
//               ),
//               // Class and Section
//               ExpansionTile(
//                 title: Text("Class & Section",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: selectedClass,
//                     decoration: InputDecoration(labelText: 'Assigned Class*'),
//                     items: ['Class 1', 'Class 2', 'Class 3', 'Class 4']
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: (value) => setState(() => selectedClass = value),
//                   ),
//                   DropdownButtonFormField<String>(
//                     value: selectedSection,
//                     decoration: InputDecoration(labelText: 'Assigned Section*'),
//                     items: ['Section A', 'Section B', 'Section C']
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: (value) =>
//                         setState(() => selectedSection = value),
//                   ),
//                 ],
//               ),
//               // DOCUMENTS SECTION
//               ExpansionTile(
//                 title: Text("Documents",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(child: Text('Birth Certificate*')),
//                       ElevatedButton(
//                         onPressed: () => pickFile(false),
//                         child: Text('Upload'),
//                       ),
//                     ],
//                   ),
//                   if (birthCertificate != null)
//                     Padding(
//                       padding: EdgeInsets.only(top: 5),
//                       child: Text('Selected: ${birthCertificate!.name}'),
//                     ),
//                   SizedBox(height: 15),
//                   Row(
//                     children: [
//                       Expanded(child: Text('Student Photo*')),
//                       ElevatedButton(
//                         onPressed: () => pickFile(true),
//                         child: Text('Upload'),
//                       ),
//                     ],
//                   ),
//                   if (studentPhoto != null)
//                     Padding(
//                       padding: EdgeInsets.only(top: 5),
//                       child: Text('Selected: ${studentPhoto!.name}'),
//                     ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               // REGISTER STUDENT BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _showConfirmationDialog(); // Show confirmation dialog
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     textStyle: TextStyle(fontSize: 18),
//                   ),
//                   child: isLoading
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text('Register Student'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
