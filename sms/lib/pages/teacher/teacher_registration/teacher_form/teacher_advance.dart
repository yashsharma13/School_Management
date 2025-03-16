import 'package:flutter/material.dart';
import '../teacher_registration_controller.dart';

class TeacherAdvance extends StatefulWidget {
  final TeacherRegistrationController controller;

  const TeacherAdvance({super.key, required this.controller});

  @override
  _TeacherAdvanceState createState() => _TeacherAdvanceState();
}

class _TeacherAdvanceState extends State<TeacherAdvance> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Detail Information",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        TextFormField(
            controller: widget.controller.guardianController,
            decoration: InputDecoration(labelText: 'Father/Husband Name'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter details' : null),
        TextFormField(
            controller: widget.controller.teacherqualificationController,
            decoration: InputDecoration(labelText: 'Qualification'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter Qualification details' : null),
        TextFormField(
            controller: widget.controller.teacherexperienceController,
            decoration: InputDecoration(labelText: 'Experience'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter experience details' : null),
        TextFormField(
            controller: widget.controller.teachersalaryController,
            decoration: InputDecoration(labelText: 'Salary'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter Salary details' : null),
        TextFormField(
            controller: widget.controller.addressController,
            decoration: InputDecoration(labelText: 'Address*'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter address' : null),
        TextFormField(
            controller: widget.controller.phoneController,
            decoration: InputDecoration(labelText: 'Phone*'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length != 10) {
                return 'Phone number must be 10 digits';
              }
              return null;
            }),
      ],
    );
  }
}
