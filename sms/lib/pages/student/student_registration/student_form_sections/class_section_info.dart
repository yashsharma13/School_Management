import 'package:flutter/material.dart';
import '../student_registration_controller.dart';

class ClassSectionInfo extends StatefulWidget {
  final StudentRegistrationController controller;

  const ClassSectionInfo({super.key, required this.controller});

  @override
  _ClassSectionInfoState createState() => _ClassSectionInfoState();
}

class _ClassSectionInfoState extends State<ClassSectionInfo> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Class & Section",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        DropdownButtonFormField<String>(
          value: widget.controller.selectedClass,
          decoration: InputDecoration(labelText: 'Assigned Class*'),
          items: [
            'Class 1',
            'Class 2',
            'Class 3',
            'Class 4',
            'Class 5',
            'Class 6',
            'Class 7',
            'Class 8',
            'Class 9',
            'Class 10',
            'Class 11',
            'Class 12'
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) =>
              setState(() => widget.controller.selectedClass = value),
        ),
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
