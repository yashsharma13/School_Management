import 'package:flutter/material.dart';
import '../student_registration_controller.dart';

class StudentInfoSection extends StatefulWidget {
  final StudentRegistrationController controller;

  const StudentInfoSection({super.key, required this.controller});

  @override
  _StudentInfoSectionState createState() => _StudentInfoSectionState();
}

class _StudentInfoSectionState extends State<StudentInfoSection> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text("Student Information",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        TextFormField(
            controller: widget.controller.studentNameController,
            decoration: InputDecoration(labelText: 'Student Name*'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter student name' : null),
        TextFormField(
            controller: widget.controller.registrationController,
            decoration: InputDecoration(
                labelText: 'Registration Number*',
                hintText: 'e.g., REG2024001'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter registration number' : null),
        TextFormField(
          controller: widget.controller.dobController,
          decoration: InputDecoration(
              labelText: 'Date of Birth*',
              suffixIcon: Icon(Icons.calendar_today)),
          readOnly: true,
          onTap: () => widget.controller.selectDate(context),
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
        TextFormField(
            controller: widget.controller.addressController,
            decoration: InputDecoration(labelText: 'Address*'),
            validator: (value) =>
                value!.isEmpty ? 'Please enter address' : null),
      ],
    );
  }
}
