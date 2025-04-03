// import 'package:flutter/material.dart';
// import '../student_registration_controller.dart';

// class ClassSectionInfo extends StatefulWidget {
//   final StudentRegistrationController controller;

//   const ClassSectionInfo({super.key, required this.controller});

//   @override
//   _ClassSectionInfoState createState() => _ClassSectionInfoState();
// }

// class _ClassSectionInfoState extends State<ClassSectionInfo> {
//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text("Class & Section",
//           style: TextStyle(fontWeight: FontWeight.bold)),
//       children: [
//         DropdownButtonFormField<String>(
//           value: widget.controller.selectedClass,
//           decoration: InputDecoration(labelText: 'Assigned Class*'),
//           items: [
//             'Class 1',
//             'Class 2',
//             'Class 3',
//             'Class 4',
//             'Class 5',
//             'Class 6',
//             'Class 7',
//             'Class 8',
//             'Class 9',
//             'Class 10',
//             'Class 11',
//             'Class 12'
//           ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//           onChanged: (value) =>
//               setState(() => widget.controller.selectedClass = value),
//         ),
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

import 'package:flutter/material.dart';
import '../student_registration_controller.dart';
import 'package:sms/pages/services/api_service.dart'; // Assuming ApiService exists

class ClassSectionInfo extends StatefulWidget {
  final StudentRegistrationController controller;

  const ClassSectionInfo({super.key, required this.controller});

  @override
  _ClassSectionInfoState createState() => _ClassSectionInfoState();
}

class _ClassSectionInfoState extends State<ClassSectionInfo> {
  List<Class> classes = []; // List to hold fetched classes
  bool isLoading = true; // To show loading state
  Class? selectedClass;

  @override
  void initState() {
    super.initState();
    _loadClasses(); // Load classes when widget is initialized
  }

  // Fetch the classes from the API (similarly to how it's done in AssignSubjectPage)
  Future<void> _loadClasses() async {
    try {
      setState(() {
        isLoading = true; // Show loading state
      });

      final fetchedClasses = await ApiService
          .fetchClasses(); // Assuming ApiService.fetchClasses() fetches the classes
      setState(() {
        // Mapping the data to Class objects
        classes = fetchedClasses
            .map((data) => Class.fromJson(data))
            .where((classObj) {
          final isValid =
              classObj.id.isNotEmpty && classObj.className.isNotEmpty;
          if (!isValid) {
            print(
                '[WARNING] Skipping class - ID: "${classObj.id}", Name: "${classObj.className}"');
          }
          return isValid;
        }).toList();
      });
    } catch (error) {
      print('Error loading classes: $error');
      _showErrorSnackBar('Error fetching classes: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false; // Hide loading state after fetching
      });
    }
  }

  // Show an error message if fetching classes fails
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
    return ExpansionTile(
      title: Text(
        "Class & Section",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        // Loading indicator while fetching data
        isLoading
            ? Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<Class>(
                value: selectedClass,
                decoration: InputDecoration(labelText: 'Assigned Class*'),
                items: classes.map((classItem) {
                  return DropdownMenuItem<Class>(
                    value: classItem,
                    child: Text(classItem.className),
                  );
                }).toList(),
                onChanged: (Class? newValue) {
                  setState(() {
                    selectedClass = newValue;
                    widget.controller.selectedClass = newValue?.className;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a class' : null,
              ),
        // Section Dropdown (assuming it's not dynamic)
        DropdownButtonFormField<String>(
          value: widget.controller.selectedSection,
          decoration: InputDecoration(labelText: 'Assigned Section*'),
          items: ['Section A', 'Section B', 'Section C']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) =>
              setState(() => widget.controller.selectedSection = value),
        ),
      ],
    );
  }
}

// Assuming this is a Class model
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
