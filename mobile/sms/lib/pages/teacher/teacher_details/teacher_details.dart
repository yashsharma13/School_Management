// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/services/teacher_service.dart';
// import 'dart:io';
// import 'teacher_model.dart';
// import 'package:sms/widgets/user_photo_widget.dart';
// import 'package:sms/widgets/pdf_viewer_widget.dart';

// // const String baseUrl = 'http://localhost:1000/uploads';
// final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
// final String uploadBaseUrl = '$baseeUrl/uploads';

// class TeacherProfileManagementPage extends StatefulWidget {
//   const TeacherProfileManagementPage({super.key});

//   @override
//   _TeacherProfileManagementPageState createState() =>
//       _TeacherProfileManagementPageState();
// }

// class _TeacherProfileManagementPageState
//     extends State<TeacherProfileManagementPage> {
//   List<Teacher> teachers = [];
//   List<Teacher> filteredTeachers = [];
//   // final TeacherService _teacherService = TeacherService();
//   TextEditingController searchController = TextEditingController();
//   bool _isLoading = true;
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//     if (token != null) {
//       await _fetchTeachers();
//     }
//   }

//   Future<void> _fetchTeachers() async {
//     try {
//       setState(() => _isLoading = true);
//       final fetchedTeachers = await TeacherService.fetchTeachers();
//       setState(() {
//         teachers = fetchedTeachers;
//         filteredTeachers = fetchedTeachers;
//       });
//     } catch (e) {
//       _showErrorSnackBar('Error loading teachers: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red[800],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green[800],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }

//   void _filterTeachers() {
//     setState(() {
//       filteredTeachers = teachers.where((teacher) {
//         final nameMatch = teacher.name
//             .toLowerCase()
//             .contains(searchController.text.toLowerCase());
//         return nameMatch;
//       }).toList();
//     });
//   }

//   String formatDate(String dateString) {
//     try {
//       DateTime date = DateTime.parse(dateString);
//       return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//     } catch (e) {
//       return dateString;
//     }
//   }

//   Future<void> _editTeacher(Teacher teacher) async {
//     final formKey = GlobalKey<FormState>();
//     final nameController = TextEditingController(text: teacher.name);
//     final dobController =
//         TextEditingController(text: formatDate(teacher.dateOfBirth));
//     final dojController =
//         TextEditingController(text: formatDate(teacher.dateOfJoining));
//     final genderController = TextEditingController(text: teacher.gender);
//     final guardianController =
//         TextEditingController(text: teacher.guardian_name);
//     final qualificationController =
//         TextEditingController(text: teacher.qualification);
//     final experienceController =
//         TextEditingController(text: teacher.experience);
//     final salaryController = TextEditingController(text: teacher.salary);
//     final addressController = TextEditingController(text: teacher.address);
//     final phoneController = TextEditingController(text: teacher.phone);

//     String? profilePhoto = teacher.teacherPhoto;
//     Uint8List? photoBytes;
//     File? selectedImage;

//     String parseDate(String formattedDate) {
//       try {
//         if (formattedDate.isEmpty) return '';
//         List<String> parts = formattedDate.split('-');
//         if (parts.length != 3) return formattedDate;
//         DateTime date = DateTime(
//           int.parse(parts[2]),
//           int.parse(parts[1]),
//           int.parse(parts[0]),
//         );
//         return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//       } catch (e) {
//         return formattedDate;
//       }
//     }

//     Future<void> selectDate(TextEditingController controller) async {
//       DateTime initialDate = DateTime.now();
//       try {
//         if (controller.text.isNotEmpty) {
//           List<String> parts = controller.text.split('-');
//           if (parts.length == 3) {
//             initialDate = DateTime(
//               int.parse(parts[2]),
//               int.parse(parts[1]),
//               int.parse(parts[0]),
//             );
//           }
//         }
//       } catch (e) {
//         print('Error parsing date: $e');
//       }

//       final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: initialDate,
//         firstDate: DateTime(1900),
//         lastDate: DateTime.now(),
//       );

//       if (picked != null) {
//         controller.text =
//             "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
//       }
//     }

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Theme(
//               data: Theme.of(context).copyWith(
//                 dialogBackgroundColor: Colors.white,
//                 inputDecorationTheme: InputDecorationTheme(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
//                   ),
//                 ),
//               ),
//               child: Dialog(
//                 insetPadding: EdgeInsets.all(20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Edit Teacher',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[800],
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Form(
//                           key: formKey,
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Text(
//                                         'Current Photo',
//                                         style: TextStyle(
//                                           color: Colors.blue[800],
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Container(
//                                         width: 80,
//                                         height: 80,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: Colors.blue[100]!,
//                                             width: 2,
//                                           ),
//                                         ),
//                                         child: ClipOval(
//                                           child: buildUserPhoto(
//                                               teacher.teacherPhoto,
//                                               uploadBaseUrl),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   if (selectedImage != null ||
//                                       photoBytes != null)
//                                     Column(
//                                       children: [
//                                         Text(
//                                           'New Photo',
//                                           style: TextStyle(
//                                             color: Colors.blue[800],
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         SizedBox(height: 8),
//                                         Container(
//                                           width: 80,
//                                           height: 80,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             border: Border.all(
//                                               color: Colors.green[100]!,
//                                               width: 2,
//                                             ),
//                                           ),
//                                           child: ClipOval(
//                                             child: kIsWeb
//                                                 ? Image.memory(photoBytes!,
//                                                     fit: BoxFit.cover)
//                                                 : Image.file(selectedImage!,
//                                                     fit: BoxFit.cover),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                               SizedBox(height: 20),
//                               ElevatedButton.icon(
//                                 icon: Icon(Icons.camera_alt, size: 20),
//                                 label: Text('Update Photo'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue[800],
//                                   foregroundColor: Colors.white,
//                                   padding: EdgeInsets.symmetric(
//                                       vertical: 12, horizontal: 20),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 onPressed: () async {
//                                   final pickedFile = await ImagePicker()
//                                       .pickImage(source: ImageSource.gallery);
//                                   if (pickedFile != null) {
//                                     if (kIsWeb) {
//                                       final bytes =
//                                           await pickedFile.readAsBytes();
//                                       setState(() {
//                                         photoBytes = bytes;
//                                         profilePhoto = base64Encode(bytes);
//                                       });
//                                     } else {
//                                       setState(() {
//                                         selectedImage = File(pickedFile.path);
//                                         profilePhoto = pickedFile.path;
//                                       });
//                                     }
//                                   }
//                                 },
//                               ),
//                               SizedBox(height: 20),
//                               _buildEditField(nameController, 'Name', true),
//                               TextFormField(
//                                 controller: dobController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Date of Birth (DD-MM-YYYY)',
//                                   labelStyle:
//                                       TextStyle(color: Colors.blue[800]),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Colors.blue[300]!),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: BorderSide(
//                                         color: Colors.blue[800]!, width: 2),
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.blue[50],
//                                   suffixIcon: IconButton(
//                                     icon: Icon(Icons.calendar_today,
//                                         color: Colors.blue[800]),
//                                     onPressed: () => selectDate(dobController),
//                                   ),
//                                 ),
//                                 readOnly: true,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Date of Birth is required'
//                                     : null,
//                               ),
//                               SizedBox(height: 16),
//                               TextFormField(
//                                 controller: dojController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Date of Joining (DD-MM-YYYY)',
//                                   labelStyle:
//                                       TextStyle(color: Colors.blue[800]),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide:
//                                         BorderSide(color: Colors.blue[300]!),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: BorderSide(
//                                         color: Colors.blue[800]!, width: 2),
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.blue[50],
//                                   suffixIcon: IconButton(
//                                     icon: Icon(Icons.calendar_today,
//                                         color: Colors.blue[800]),
//                                     onPressed: () => selectDate(dojController),
//                                   ),
//                                 ),
//                                 readOnly: true,
//                                 validator: (value) => value!.isEmpty
//                                     ? 'Date of Joining is required'
//                                     : null,
//                               ),
//                               SizedBox(height: 16),
//                               _buildEditField(genderController, 'Gender', true),
//                               _buildEditField(
//                                   guardianController, 'Guardian Name', true),
//                               _buildEditField(qualificationController,
//                                   'Qualification', true),
//                               _buildEditField(
//                                   experienceController, 'Experience', true),
//                               _buildEditField(salaryController, 'Salary', true),
//                               _buildEditField(
//                                   addressController, 'Address', true),
//                               _buildEditField(phoneController, 'Phone', true),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               child: Text(
//                                 'Cancel',
//                                 style: TextStyle(color: Colors.grey[700]),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue[800],
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 24, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               onPressed: () async {
//                                 if (formKey.currentState!.validate()) {
//                                   try {
//                                     final updatedTeacher = {
//                                       'teacher_name': nameController.text,
//                                       'date_of_birth':
//                                           parseDate(dobController.text),
//                                       'date_of_joining':
//                                           parseDate(dojController.text),
//                                       'gender': genderController.text,
//                                       'guardian_name': guardianController.text,
//                                       'qualification':
//                                           qualificationController.text,
//                                       'experience': experienceController.text,
//                                       'salary': salaryController.text,
//                                       'address': addressController.text,
//                                       'phone': phoneController.text,
//                                       'qualification_certificate':
//                                           teacher.qualificationCertificate,
//                                     };

//                                     if (profilePhoto != null &&
//                                         profilePhoto != teacher.teacherPhoto) {
//                                       updatedTeacher['teacher_photo'] =
//                                           profilePhoto!;
//                                     } else {
//                                       updatedTeacher['teacher_photo'] =
//                                           teacher.teacherPhoto;
//                                     }

//                                     await TeacherService.updateTeacher(
//                                         teacher, updatedTeacher);
//                                     _showSuccessSnackBar(
//                                         'Teacher updated successfully');
//                                     Navigator.of(context).pop();
//                                     _fetchTeachers();
//                                   } catch (e) {
//                                     _showErrorSnackBar(
//                                         'Failed to update teacher: ${e.toString()}');
//                                   }
//                                 }
//                               },
//                               child: Text('Save'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildEditField(
//       TextEditingController controller, String label, bool required) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.blue[800]),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.blue[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
//           ),
//           filled: true,
//           fillColor: Colors.blue[50],
//         ),
//         validator: required
//             ? (value) => value!.isEmpty ? '$label is required' : null
//             : null,
//       ),
//     );
//   }

//   Future<void> _deleteTeacher(int index) async {
//     final teacher = filteredTeachers[index];
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Delete',
//             style: TextStyle(
//                 color: Colors.blue[800], fontWeight: FontWeight.bold)),
//         content: Text('Delete ${teacher.name} permanently?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red[400],
//               foregroundColor: Colors.white,
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await TeacherService.deleteTeacher(teacher.id);
//         setState(() {
//           teachers.removeWhere((t) => t.id == teacher.id);
//           filteredTeachers.removeAt(index);
//         });
//         _showSuccessSnackBar('Teacher deleted successfully');
//       } catch (e) {
//         _showErrorSnackBar('Failed to delete teacher: ${e.toString()}');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'Teacher Profile Management',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue.shade900,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
//               ),
//             )
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           TextField(
//                             controller: searchController,
//                             decoration: InputDecoration(
//                               labelText: 'Search Teachers',
//                               labelStyle: TextStyle(color: Colors.blue[800]),
//                               prefixIcon:
//                                   Icon(Icons.search, color: Colors.blue[800]),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide:
//                                     BorderSide(color: Colors.blue[300]!),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                     color: Colors.blue[800]!, width: 2),
//                               ),
//                               suffixIcon: IconButton(
//                                 icon:
//                                     Icon(Icons.clear, color: Colors.blue[800]),
//                                 onPressed: () {
//                                   searchController.clear();
//                                   _filterTeachers();
//                                 },
//                               ),
//                               filled: true,
//                               fillColor: Colors.blue[50],
//                             ),
//                             onChanged: (value) => _filterTeachers(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: filteredTeachers.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.people_outline,
//                                   size: 60,
//                                   color: Colors.grey[400],
//                                 ),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   searchController.text.isEmpty
//                                       ? 'No teachers found'
//                                       : 'No teachers match your search',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 if (searchController.text.isNotEmpty)
//                                   TextButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         searchController.clear();
//                                         filteredTeachers = teachers;
//                                       });
//                                     },
//                                     child: Text('Clear Search',
//                                         style:
//                                             TextStyle(color: Colors.blue[800])),
//                                   ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: filteredTeachers.length,
//                             itemBuilder: (context, index) {
//                               final teacher = filteredTeachers[index];
//                               return Card(
//                                 elevation: 2,
//                                 margin: EdgeInsets.only(bottom: 12),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: ListTile(
//                                   contentPadding: EdgeInsets.all(12),
//                                   leading: Container(
//                                     width: 50,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                         color: Colors.blue[100]!,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     child: ClipOval(
//                                       child: buildUserPhoto(
//                                           teacher.teacherPhoto, uploadBaseUrl),
//                                     ),
//                                   ),
//                                   title: Text(
//                                     teacher.name,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blue[800],
//                                     ),
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${teacher.email}',
//                                         style: TextStyle(
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                       Text(
//                                         '${teacher.qualification}',
//                                         style: TextStyle(
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: PopupMenuButton(
//                                     icon: Icon(Icons.more_vert,
//                                         color: Colors.blue[800]),
//                                     itemBuilder: (context) => [
//                                       PopupMenuItem(
//                                         value: 'edit',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.edit,
//                                                 color: Colors.blue[800]),
//                                             SizedBox(width: 8),
//                                             Text('Edit',
//                                                 style: TextStyle(
//                                                     color: Colors.blue[900])),
//                                           ],
//                                         ),
//                                       ),
//                                       PopupMenuItem(
//                                         value: 'delete',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.delete,
//                                                 color: Colors.red[400]),
//                                             SizedBox(width: 8),
//                                             Text('Delete',
//                                                 style: TextStyle(
//                                                     color: Colors.red[600])),
//                                           ],
//                                         ),
//                                       ),
//                                       if (teacher
//                                           .qualificationCertificate.isNotEmpty)
//                                         PopupMenuItem(
//                                           value: 'view_certificate',
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.picture_as_pdf,
//                                                   color: Colors.green[600]),
//                                               SizedBox(width: 8),
//                                               Text('View Certificate',
//                                                   style: TextStyle(
//                                                       color:
//                                                           Colors.green[800])),
//                                             ],
//                                           ),
//                                         ),
//                                     ],
//                                     onSelected: (value) {
//                                       if (value == 'edit') {
//                                         _editTeacher(teacher);
//                                       } else if (value == 'delete') {
//                                         _deleteTeacher(index);
//                                       } else if (value == 'view_certificate') {
//                                         // Navigator.push(
//                                         //   context,
//                                         //   MaterialPageRoute(
//                                         //     builder: (context) =>
//                                         //         PDFViewerScreen(
//                                         //       pdfData: teacher
//                                         //           .qualificationCertificate,
//                                         //       baseUrl: uploadBaseUrl,
//                                         //     ),
//                                         //   ),
//                                         // );
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 PDFViewerScreen(
//                                               pdfData: teacher
//                                                   .qualificationCertificate,
//                                               baseUrl: uploadBaseUrl,
//                                               title:
//                                                   'Qualification Certificate',
//                                               label:
//                                                   'Qualification Certificate PDF',
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/teacher_service.dart';
import 'package:sms/widgets/user_photo_widget.dart';
import 'package:sms/widgets/pdf_viewer_widget.dart';
import 'teacher_model.dart';
import 'edit_teacher.dart';
import 'delete_teacher.dart';

final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
final String uploadBaseUrl = '$baseeUrl/uploads';

class TeacherProfileManagementPage extends StatefulWidget {
  const TeacherProfileManagementPage({super.key});

  @override
  _TeacherProfileManagementPageState createState() =>
      _TeacherProfileManagementPageState();
}

class _TeacherProfileManagementPageState
    extends State<TeacherProfileManagementPage> {
  List<Teacher> teachers = [];
  List<Teacher> filteredTeachers = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    if (token != null) {
      await _fetchTeachers();
    }
  }

  Future<void> _fetchTeachers() async {
    try {
      setState(() => _isLoading = true);
      final fetchedTeachers = await TeacherService.fetchTeachers();
      setState(() {
        teachers = fetchedTeachers;
        filteredTeachers = fetchedTeachers;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading teachers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _filterTeachers() {
    setState(() {
      filteredTeachers = teachers.where((teacher) {
        final nameMatch = teacher.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        return nameMatch;
      }).toList();
    });
  }

  Future<void> _editTeacher(Teacher teacher) async {
    await showDialog(
      context: context,
      builder: (context) => EditTeacherDialog(
        teacher: teacher,
        onTeacherUpdated: _fetchTeachers,
      ),
    );
  }

  // Future<void> _deleteTeacher(int index) async {
  //   final teacher = filteredTeachers[index];
  //   final confirmed = await showDeleteTeacherDialog(context, teacher.name);

  //   if (confirmed) {
  //     try {
  //       await TeacherService.deleteTeacher(teacher.id);
  //       setState(() {
  //         teachers.removeWhere((t) => t.id == teacher.id);
  //         filteredTeachers.removeAt(index);
  //       });
  //       _showSuccessSnackBar('Teacher deleted successfully');
  //     } catch (e) {
  //       _showErrorSnackBar('Failed to delete teacher: ${e.toString()}');
  //     }
  //   }
  // }
  Future<void> _deleteTeacher(int index) async {
    final teacher = filteredTeachers[index];
    final confirmed = await showDeleteTeacherDialog(context, teacher.name);

    if (!confirmed) return;

    final error = await TeacherService.deleteTeacher(teacher.id.toString());

    if (error == null) {
      setState(() {
        teachers.removeWhere((t) => t.id == teacher.id);
        filteredTeachers.removeWhere((t) => t.id == teacher.id); // ✅ Safe
      });

      _showSuccessSnackBar('Teacher deleted successfully');
    } else {
      _showErrorSnackBar(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Teacher Profile Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Teachers',
                              labelStyle: TextStyle(color: Colors.blue[800]),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.blue[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.blue[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.blue[800]!, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.blue[800]),
                                onPressed: () {
                                  searchController.clear();
                                  _filterTeachers();
                                },
                              ),
                              filled: true,
                              fillColor: Colors.blue[50],
                            ),
                            onChanged: (value) => _filterTeachers(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filteredTeachers.isEmpty
                        ? _buildEmptyState()
                        : _buildTeacherList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            searchController.text.isEmpty
                ? 'No teachers found'
                : 'No teachers match your search',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  filteredTeachers = teachers;
                });
              },
              child: Text('Clear Search',
                  style: TextStyle(color: Colors.blue[800])),
            ),
        ],
      ),
    );
  }

  Widget _buildTeacherList() {
    return ListView.builder(
      itemCount: filteredTeachers.length,
      itemBuilder: (context, index) {
        final teacher = filteredTeachers[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue[100]!,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: buildUserPhoto(teacher.teacherPhoto, uploadBaseUrl),
              ),
            ),
            title: Text(
              teacher.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher.email}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${teacher.qualification}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.blue[800]),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue[800]),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: Colors.blue[900])),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[400]),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red[600])),
                    ],
                  ),
                ),
                if (teacher.qualificationCertificate.isNotEmpty)
                  PopupMenuItem(
                    value: 'view_certificate',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.green[600]),
                        SizedBox(width: 8),
                        Text('View Certificate',
                            style: TextStyle(color: Colors.green[800])),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editTeacher(teacher);
                } else if (value == 'delete') {
                  await _deleteTeacher(index);
                } else if (value == 'view_certificate') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        pdfData: teacher.qualificationCertificate,
                        baseUrl: uploadBaseUrl,
                        title: 'Qualification Certificate',
                        label: 'Qualification Certificate PDF',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
