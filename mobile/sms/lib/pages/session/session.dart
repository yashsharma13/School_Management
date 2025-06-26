import 'package:flutter/material.dart';
import 'package:sms/pages/services/session_service.dart';
import 'package:sms/widgets/date_picker.dart'; // Import the custom date picker

class CreateSessionPage extends StatefulWidget {
  @override
  _CreateSessionPageState createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final TextEditingController sessionNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  Future<void> createSession() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await SessionService.createSession(
      sessionName: sessionNameController.text.trim(),
      startDate: startDate!.toIso8601String().split('T').first,
      endDate: endDate!.toIso8601String().split('T').first,
    );

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Unknown error'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );

    if (result['success'] == true) {
      sessionNameController.clear();
      setState(() {
        startDate = null;
        endDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Session"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: sessionNameController,
              decoration: InputDecoration(
                labelText: 'Session Name*',
                prefixIcon:
                    Icon(Icons.edit_calendar, color: Colors.blue.shade600),
                labelStyle: TextStyle(color: Colors.blue.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomDatePicker(
              selectedDate: startDate ?? DateTime.now(),
              onDateSelected: (DateTime newDate) {
                setState(() {
                  startDate = newDate;
                });
              },
              labelText: 'Start Date',
              isExpanded: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: 16),
            CustomDatePicker(
              selectedDate: endDate ?? DateTime.now(),
              onDateSelected: (DateTime newDate) {
                setState(() {
                  endDate = newDate;
                });
              },
              labelText: 'End Date',
              isExpanded: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              firstDate: startDate ??
                  DateTime(2000), // End date can't be before start date
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: 24),
            isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text("Create Session"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      onPressed: createSession,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
