// import 'package:flutter/material.dart';
// import '../student_registration_controller.dart';
// import 'package:sms/pages/services/api_service.dart'; // Assuming ApiService exists

// class ClassSectionInfo extends StatefulWidget {
//   final StudentRegistrationController controller;

//   const ClassSectionInfo({super.key, required this.controller});

//   @override
//   _ClassSectionInfoState createState() => _ClassSectionInfoState();
// }

// class _ClassSectionInfoState extends State<ClassSectionInfo> {
//   List<Class> classes = []; // List to hold fetched classes
//   bool isLoading = true; // To show loading state
//   Class? selectedClass;

//   @override
//   void initState() {
//     super.initState();
//     _loadClasses(); // Load classes when widget is initialized
//   }

//   // Fetch the classes from the API (similarly to how it's done in AssignSubjectPage)
//   Future<void> _loadClasses() async {
//     try {
//       setState(() {
//         isLoading = true; // Show loading state
//       });

//       final fetchedClasses = await ApiService
//           .fetchClasses(); // Assuming ApiService.fetchClasses() fetches the classes
//       setState(() {
//         // Mapping the data to Class objects
//         classes = fetchedClasses
//             .map((data) => Class.fromJson(data))
//             .where((classObj) {
//           final isValid =
//               classObj.id.isNotEmpty && classObj.className.isNotEmpty;
//           if (!isValid) {
//             print(
//                 '[WARNING] Skipping class - ID: "${classObj.id}", Name: "${classObj.className}"');
//           }
//           return isValid;
//         }).toList();
//       });
//     } catch (error) {
//       print('Error loading classes: $error');
//       _showErrorSnackBar('Error fetching classes: ${error.toString()}');
//     } finally {
//       setState(() {
//         isLoading = false; // Hide loading state after fetching
//       });
//     }
//   }

//   // Show an error message if fetching classes fails
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text(
//         "Class & Section",
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       children: [
//         // Loading indicator while fetching data
//         isLoading
//             ? Center(child: CircularProgressIndicator())
//             : DropdownButtonFormField<Class>(
//                 value: selectedClass,
//                 decoration: InputDecoration(labelText: 'Assigned Class*'),
//                 items: classes.map((classItem) {
//                   return DropdownMenuItem<Class>(
//                     value: classItem,
//                     child: Text(classItem.className),
//                   );
//                 }).toList(),
//                 onChanged: (Class? newValue) {
//                   setState(() {
//                     selectedClass = newValue;
//                     widget.controller.selectedClass = newValue?.className;
//                   });
//                 },
//                 validator: (value) =>
//                     value == null ? 'Please select a class' : null,
//               ),
//         // Section Dropdown (assuming it's not dynamic)
//         DropdownButtonFormField<String>(
//           value: widget.controller.selectedSection,
//           decoration: InputDecoration(labelText: 'Assigned Section*'),
//           items: ['Section A', 'Section B', 'Section C']
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: (value) =>
//               setState(() => widget.controller.selectedSection = value),
//         ),
//       ],
//     );
//   }
// }

// // Assuming this is a Class model
// class Class {
//   final String id;
//   final String className;

//   Class({required this.id, required this.className});

//   factory Class.fromJson(Map<String, dynamic> json) {
//     return Class(
//       id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
//       className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
//           .toString()
//           .trim(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../student_registration_controller.dart';
import 'package:sms/pages/services/api_service.dart';

class ClassSectionInfo extends StatefulWidget {
  final StudentRegistrationController controller;

  const ClassSectionInfo({super.key, required this.controller});

  @override
  _ClassSectionInfoState createState() => _ClassSectionInfoState();
}

class _ClassSectionInfoState extends State<ClassSectionInfo> {
  List<Class> classes = [];
  bool isLoading = true;
  Class? selectedClass;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      setState(() => isLoading = true);
      final fetchedClasses = await ApiService.fetchClasses();
      setState(() {
        classes = fetchedClasses
            .map((data) => Class.fromJson(data))
            .where((classObj) =>
                classObj.id.isNotEmpty && classObj.className.isNotEmpty)
            .toList();
      });
    } catch (error) {
      _showErrorSnackBar('Error fetching classes: ${error.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

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
          "CLASS & SECTION",
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
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade700,
                  ),
                )
              : _buildClassDropdown(),
          const SizedBox(height: 16),
          _buildSectionDropdown(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<Class>(
      value: selectedClass,
      decoration: InputDecoration(
        labelText: 'Assigned Class*',
        labelStyle: TextStyle(color: Colors.blue.shade700),
        prefixIcon: Icon(Icons.class_outlined, color: Colors.blue.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: classes.map((classItem) {
        return DropdownMenuItem<Class>(
          value: classItem,
          child: Text(
            classItem.className,
            style: TextStyle(color: Colors.blue.shade800),
          ),
        );
      }).toList(),
      onChanged: (Class? newValue) {
        setState(() {
          selectedClass = newValue;
          widget.controller.selectedClass = newValue?.className;
        });
      },
      validator: (value) => value == null ? 'Please select a class' : null,
      style: TextStyle(color: Colors.blue.shade800),
    );
  }

  Widget _buildSectionDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.controller.selectedSection,
      decoration: InputDecoration(
        labelText: 'Assigned Section*',
        labelStyle: TextStyle(color: Colors.blue.shade700),
        prefixIcon: Icon(Icons.groups_outlined, color: Colors.blue.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: ['Section A', 'Section B', 'Section C']
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ))
          .toList(),
      onChanged: (value) =>
          setState(() => widget.controller.selectedSection = value),
      validator: (value) => value == null ? 'Please select a section' : null,
      style: TextStyle(color: Colors.blue.shade800),
    );
  }
}

class Class {
  final String id;
  final String className;

  Class({required this.id, required this.className});

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
    );
  }
}
