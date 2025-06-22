import 'package:flutter/material.dart';
import 'package:sms/pages/services/session_service.dart';
import 'package:sms/pages/session/manage_session.dart'; // for Session model
import 'package:intl/intl.dart'; // For date formatting

class EditSessionDialog extends StatefulWidget {
  final Session session;

  EditSessionDialog({required this.session});

  @override
  _EditSessionDialogState createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<EditSessionDialog> {
  late TextEditingController _sessionNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _sessionNameController =
        TextEditingController(text: widget.session.sessionName);
    _startDateController =
        TextEditingController(text: widget.session.startDate);
    _endDateController = TextEditingController(text: widget.session.endDate);
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = _dateFormat.format(pickedDate);
    }
  }

  Future<void> _updateSession() async {
    final result = await SessionService.updateSession(
      id: widget.session.id,
      sessionName: _sessionNameController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
    );

    if (result['success'] == true) {
      Navigator.pop(context, true); // return true on success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Failed to update session')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Session', style: TextStyle(color: Colors.blue[900])),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _sessionNameController,
              decoration: InputDecoration(
                labelText: 'Session Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _startDateController,
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
              decoration: InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _endDateController,
              readOnly: true,
              onTap: () => _selectDate(context, _endDateController),
              decoration: InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.blue[900])),
        ),
        ElevatedButton(
          onPressed: _updateSession,
          child: Text('Save'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
