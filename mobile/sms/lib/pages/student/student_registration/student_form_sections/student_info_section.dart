import 'package:flutter/material.dart';
import 'package:sms/pages/services/student_service.dart';
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
      final lastReg = await StudentService.getLastRegistrationNumber();
      setState(() => _lastRegistrationNumber = lastReg);
    } catch (e) {
      debugPrint('Error fetching last registration: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
          "STUDENT INFORMATION",
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
            controller: widget.controller.studentNameController,
            label: 'Student Name',
            icon: Icons.person_outline,
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Registration Number Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                controller: widget.controller.registrationController,
                label: 'Registration Number',
                icon: Icons.numbers,
                isRequired: true,
                suffix: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),
              if (_lastRegistrationNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Text(
                    'Last registered number: $_lastRegistrationNumber',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Date of Birth Field
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

          // Gender Dropdown
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
          const SizedBox(height: 16),

          // Address Field
          _buildFormField(
            controller: widget.controller.addressController,
            label: 'Address',
            icon: Icons.home_outlined,
            isRequired: true,
            maxLines: 1,
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
    Widget? suffix,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: isRequired ? '$label*' : label,
        labelStyle: TextStyle(color: Colors.blue.shade700),
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        suffixIcon: suffix,
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
      validator: isRequired
          ? (value) => value!.isEmpty ? 'Please enter $label' : null
          : null,
    );
  }
}
