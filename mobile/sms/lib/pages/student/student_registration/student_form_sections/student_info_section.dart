// import 'package:flutter/material.dart';
// import '../student_registration_controller.dart';

// class StudentInfoSection extends StatefulWidget {
//   final StudentRegistrationController controller;

//   const StudentInfoSection({super.key, required this.controller});

//   @override
//   _StudentInfoSectionState createState() => _StudentInfoSectionState();
// }

// class _StudentInfoSectionState extends State<StudentInfoSection> {
//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text("Student Information",
//           style: TextStyle(fontWeight: FontWeight.bold)),
//       children: [
//         TextFormField(
//             controller: widget.controller.studentNameController,
//             decoration: InputDecoration(labelText: 'Student Name*'),
//             validator: (value) =>
//                 value!.isEmpty ? 'Please enter student name' : null),
//         TextFormField(
//             controller: widget.controller.registrationController,
//             decoration: InputDecoration(
//                 labelText: 'Registration Number*',
//                 hintText: 'e.g., REG2024001'),
//             validator: (value) =>
//                 value!.isEmpty ? 'Please enter registration number' : null),
//         TextFormField(
//           controller: widget.controller.dobController,
//           decoration: InputDecoration(
//               labelText: 'Date of Birth*',
//               suffixIcon: Icon(Icons.calendar_today)),
//           readOnly: true,
//           onTap: () => widget.controller.selectDate(context),
//         ),
//         DropdownButtonFormField<String>(
//           value: widget.controller.gender,
//           decoration: InputDecoration(labelText: 'Gender*'),
//           items: ['Male', 'Female', 'Other']
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: (value) =>
//               setState(() => widget.controller.gender = value),
//         ),
//         TextFormField(
//             controller: widget.controller.addressController,
//             decoration: InputDecoration(labelText: 'Address*'),
//             validator: (value) =>
//                 value!.isEmpty ? 'Please enter address' : null),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:sms/pages/services/api_service.dart';
// import '../student_registration_controller.dart';

// class StudentInfoSection extends StatefulWidget {
//   final StudentRegistrationController controller;

//   const StudentInfoSection({super.key, required this.controller});

//   @override
//   _StudentInfoSectionState createState() => _StudentInfoSectionState();
// }

// class _StudentInfoSectionState extends State<StudentInfoSection> {
//   String? _lastRegistrationNumber;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchLastRegistrationNumber();
//   }

//   Future<void> _fetchLastRegistrationNumber() async {
//     setState(() => _isLoading = true);
//     try {
//       final lastReg = await ApiService.getLastRegistrationNumber();
//       setState(() => _lastRegistrationNumber = lastReg);
//     } catch (e) {
//       debugPrint('Error fetching last registration: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: const Text("Student Information",
//           style: TextStyle(fontWeight: FontWeight.bold)),
//       children: [
//         TextFormField(
//           controller: widget.controller.studentNameController,
//           decoration: const InputDecoration(labelText: 'Student Name*'),
//           validator: (value) =>
//               value!.isEmpty ? 'Please enter student name' : null,
//         ),
//         TextFormField(
//           controller: widget.controller.registrationController,
//           decoration: InputDecoration(
//             labelText: 'Registration Number*',
//             hintText: _lastRegistrationNumber != null
//                 ? 'Last: $_lastRegistrationNumber'
//                 : 'e.g., REG2024001',
//             suffixIcon: _isLoading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : null,
//           ),
//           validator: (value) =>
//               value!.isEmpty ? 'Please enter registration number' : null,
//         ),
//         TextFormField(
//           controller: widget.controller.dobController,
//           decoration: const InputDecoration(
//               labelText: 'Date of Birth*',
//               suffixIcon: Icon(Icons.calendar_today)),
//           readOnly: true,
//           onTap: () => widget.controller.selectDate(context),
//         ),
//         DropdownButtonFormField<String>(
//           value: widget.controller.gender,
//           decoration: const InputDecoration(labelText: 'Gender*'),
//           items: ['Male', 'Female', 'Other']
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: (value) =>
//               setState(() => widget.controller.gender = value),
//         ),
//         TextFormField(
//           controller: widget.controller.addressController,
//           decoration: const InputDecoration(labelText: 'Address*'),
//           validator: (value) => value!.isEmpty ? 'Please enter address' : null,
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:sms/pages/services/api_service.dart';
import '../student_registration_controller.dart';

class StudentInfoSection extends StatefulWidget {
  final StudentRegistrationController controller;

  const StudentInfoSection({super.key, required this.controller});

  @override
  _StudentInfoSectionState createState() => _StudentInfoSectionState();
}

class _StudentInfoSectionState extends State<StudentInfoSection> {
  String? _lastRegistrationNumber;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLastRegistrationNumber();
  }

  Future<void> _fetchLastRegistrationNumber() async {
    setState(() => _isLoading = true);
    try {
      final lastReg = await ApiService.getLastRegistrationNumber();
      setState(() => _lastRegistrationNumber = lastReg);
    } catch (e) {
      debugPrint('Error fetching last registration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text("Student Information",
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        TextFormField(
          controller: widget.controller.studentNameController,
          decoration: const InputDecoration(labelText: 'Student Name*'),
          validator: (value) =>
              value!.isEmpty ? 'Please enter student name' : null,
        ),

        // Registration Number Field with last number reference below
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: widget.controller.registrationController,
              decoration: InputDecoration(
                labelText: 'Registration Number*',
                hintText: 'e.g., REG2024001',
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter registration number' : null,
            ),
            if (_lastRegistrationNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  'Last registration: $_lastRegistrationNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),

        TextFormField(
          controller: widget.controller.dobController,
          decoration: const InputDecoration(
              labelText: 'Date of Birth*',
              suffixIcon: Icon(Icons.calendar_today)),
          readOnly: true,
          onTap: () => widget.controller.selectDate(context),
        ),
        DropdownButtonFormField<String>(
          value: widget.controller.gender,
          decoration: const InputDecoration(labelText: 'Gender*'),
          items: ['Male', 'Female', 'Other']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) =>
              setState(() => widget.controller.gender = value),
        ),
        TextFormField(
          controller: widget.controller.addressController,
          decoration: const InputDecoration(labelText: 'Address*'),
          validator: (value) => value!.isEmpty ? 'Please enter address' : null,
        ),
      ],
    );
  }
}
