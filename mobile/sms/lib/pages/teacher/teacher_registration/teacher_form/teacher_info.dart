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
          "TEACHER INFORMATION",
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
          _buildFormField(
            controller: widget.controller.teacherNameController,
            label: 'Teacher Name',
            icon: Icons.person_outline,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller: widget.controller.emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            isRequired: true,
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
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.controller.dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth*',
              labelStyle: TextStyle(color: Colors.blue.shade700),
              prefixIcon:
                  Icon(Icons.calendar_today, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            readOnly: true,
            onTap: () => widget.controller.selectDate(context),
            validator: (value) => value!.isEmpty ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.controller.dojController,
            decoration: InputDecoration(
              labelText: 'Date of Joining*',
              labelStyle: TextStyle(color: Colors.blue.shade700),
              prefixIcon:
                  Icon(Icons.calendar_today, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            readOnly: true,
            onTap: () => widget.controller.selectJoiningDate(context),
            validator: (value) => value!.isEmpty ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.controller.gender,
            decoration: InputDecoration(
              labelText: 'Gender*',
              labelStyle: TextStyle(color: Colors.blue.shade700),
              prefixIcon: Icon(Icons.transgender, color: Colors.blue.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: ['Male', 'Female', 'Other']
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => widget.controller.gender = value),
            validator: (value) => value == null ? 'Please select gender' : null,
            style: TextStyle(color: Colors.blue.shade800),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: isRequired ? '$label*' : label,
        labelStyle: TextStyle(color: Colors.blue.shade700),
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator ??
          (isRequired
              ? (value) => value!.isEmpty ? 'Please enter $label' : null
              : null),
    );
  }
}
