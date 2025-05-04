// import 'package:flutter/material.dart';
// import '../student_registration_controller.dart';

// class ParentInfoSection extends StatefulWidget {
//   final StudentRegistrationController controller;

//   const ParentInfoSection({super.key, required this.controller});

//   @override
//   _ParentInfoSectionState createState() => _ParentInfoSectionState();
// }

// class _ParentInfoSectionState extends State<ParentInfoSection> {
//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text("Parent Information",
//           style: TextStyle(fontWeight: FontWeight.bold)),
//       children: [
//         TextFormField(
//             controller: widget.controller.fathersNameController,
//             decoration: InputDecoration(labelText: "Father's Name*"),
//             validator: (value) =>
//                 value!.isEmpty ? "Please enter father's name" : null),
//         TextFormField(
//             controller: widget.controller.mothersNameController,
//             decoration: InputDecoration(labelText: "Mother's Name*"),
//             validator: (value) =>
//                 value!.isEmpty ? "Please enter mother's name" : null),
//         TextFormField(
//             controller: widget.controller.emailController,
//             decoration: InputDecoration(labelText: 'Email*'),
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter email';
//               }
//               String pattern =
//                   r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
//               RegExp regex = RegExp(pattern);
//               if (!regex.hasMatch(value)) {
//                 return 'Enter a valid email address';
//               }
//               return null;
//             }),
//         TextFormField(
//             controller: widget.controller.phoneController,
//             decoration: InputDecoration(labelText: 'Phone*'),
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter phone number';
//               }
//               if (value.length != 10) {
//                 return 'Phone number must be 10 digits';
//               }
//               return null;
//             }),
//       ],
//     );
//   }
// }

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
          "PARENT INFORMATION",
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
          _buildParentFormField(
            controller: widget.controller.fathersNameController,
            label: "Father's Name",
            icon: Icons.man_outlined,
          ),
          const SizedBox(height: 16),
          _buildParentFormField(
            controller: widget.controller.mothersNameController,
            label: "Mother's Name",
            icon: Icons.woman_outlined,
          ),
          const SizedBox(height: 16),
          _buildParentFormField(
            controller: widget.controller.emailController,
            label: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) return 'Please enter email';
              String pattern =
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(value)) return 'Enter valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildParentFormField(
            controller: widget.controller.phoneController,
            label: "Phone",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty) return 'Please enter phone';
              if (value.length != 10) return 'Must be 10 digits';
              return null;
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildParentFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: '$label*',
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      validator:
          validator ?? (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
