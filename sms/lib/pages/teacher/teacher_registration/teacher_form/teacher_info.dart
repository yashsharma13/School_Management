import 'package:flutter/material.dart';
import '../teacher_registration_controller.dart';

class TeacherInfo extends StatefulWidget {
  final TeacherRegistrationController controller;

  const TeacherInfo({super.key, required this.controller});

  @override
  _TeacherInfoState createState() => _TeacherInfoState();
}

class _TeacherInfoState extends State<TeacherInfo> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Basic Information",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        TextFormField(
            controller: widget.controller.teacherNameController,
            decoration: InputDecoration(labelText: 'Teacher Name*'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter Teacher name' : null),
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
          controller: widget.controller.dobController,
          decoration: InputDecoration(
              labelText: 'Date of Birth*',
              suffixIcon: Icon(Icons.calendar_today)),
          readOnly: true,
          onTap: () => widget.controller.selectDate(context),
        ),
        TextFormField(
          controller: widget.controller.dojController,
          decoration: InputDecoration(
              labelText: 'Date of Joining*',
              suffixIcon: Icon(Icons.calendar_today)),
          readOnly: true,
          onTap: () => widget.controller.selectJoiningDate(context),
        ),
        DropdownButtonFormField<String>(
          value: widget.controller.gender,
          decoration: InputDecoration(labelText: 'Gender*'),
          items: ['Male', 'Female', 'Other']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) =>
              setState(() => widget.controller.gender = value),
        ),
      ],
    );
  }
}
