import 'package:flutter/material.dart';
import '../student_registration_controller.dart';

class ParentInfoSection extends StatefulWidget {
  final StudentRegistrationController controller;

  const ParentInfoSection({super.key, required this.controller});

  @override
  _ParentInfoSectionState createState() => _ParentInfoSectionState();
}

class _ParentInfoSectionState extends State<ParentInfoSection> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Parent Information",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        TextFormField(
            controller: widget.controller.fathersNameController,
            decoration: InputDecoration(labelText: "Father's Name*"),
            validator: (value) =>
                value!.isEmpty ? "Please enter father's name" : null),
        TextFormField(
            controller: widget.controller.mothersNameController,
            decoration: InputDecoration(labelText: "Mother's Name*"),
            validator: (value) =>
                value!.isEmpty ? "Please enter mother's name" : null),
        TextFormField(
            controller: widget.controller.emailController,
            decoration: InputDecoration(labelText: 'Email*'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter email';
              }
              String pattern =
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            }),
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
