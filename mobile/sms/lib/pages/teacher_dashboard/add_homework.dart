import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddHomeworkPage extends StatefulWidget {
  @override
  _AddHomeworkPageState createState() => _AddHomeworkPageState();
}

class _AddHomeworkPageState extends State<AddHomeworkPage> {
  final _formKey = GlobalKey<FormState>();
  final _homeworkController = TextEditingController();

  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool isSubmitting = false;

  String error = '';
  String success = '';
  String? selectedClassKey; // Nullable String to store selected class key
  List<Map<String, dynamic>> availableClasses = [];

  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  @override
  void dispose() {
    _homeworkController.dispose();
    super.dispose();
  }

  Future<void> fetchClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/teachers/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);
      debugPrint('Teacher profile response (for classes): $data');

      if (response.statusCode == 200 && data['success'] == true) {
        // Extract the assigned_classes array inside data object
        final assigned = data['data']['assigned_classes'] as List<dynamic>?;

        if (assigned != null && assigned.isNotEmpty) {
          // Map each assigned class to a Map<String, dynamic> with a unique key string
          setState(() {
            availableClasses = assigned.map<Map<String, dynamic>>((cls) {
              final key = '${cls['class_name']} - ${cls['section']}';
              return {
                'key': key,
                'class_name': cls['class_name'],
                'section': cls['section'],
              };
            }).toList();

            // Select the first class by default
            selectedClassKey = availableClasses.first['key'] as String;
          });
        } else {
          setState(() => error = 'No classes assigned.');
        }
      } else {
        setState(() => error = 'Failed to load classes.');
      }
    } catch (e) {
      setState(() => error = 'Error fetching classes: $e');
    }
  }

  Future<void> submitHomework() async {
    if (!_formKey.currentState!.validate()) return;

    if (endDate == null || endDate!.isBefore(startDate)) {
      setState(() => error = 'Please select a valid end date.');
      return;
    }

    setState(() {
      isSubmitting = true;
      error = '';
      success = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Find the class_id by matching selectedClassKey in availableClasses
      final selectedClass = availableClasses.firstWhere(
          (cls) => cls['key'] == selectedClassKey,
          orElse: () => {});

      if (selectedClass.isEmpty) {
        setState(() {
          error = 'Selected class not found.';
          isSubmitting = false;
        });
        return;
      }

      // IMPORTANT: Here you need to send the correct class_id
      // Your API expects 'class_id' but from API data you have only class_name and section
      // You might need to get class_id from the API response or adapt accordingly
      // For demo, assuming class_id is available in 'id' field; if not, you need to update your API/backend.
      // Here I assume 'id' is missing so you must modify API or this logic to get 'class_id'

      // For now, let's send class_name as class_id for demonstration purposes:
      final classIdToSend =
          selectedClass['class_name']; // Change this accordingly

      final body = {
        'class_id': classIdToSend,
        'homework': _homeworkController.text,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate!.toIso8601String().split('T')[0],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/homework'),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final resData = json.decode(response.body);
      debugPrint('Submit homework response: $resData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          success = 'Homework assigned successfully!';
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context, true);
        });
      } else {
        setState(
            () => error = resData['message'] ?? 'Failed to assign homework.');
      }
    } catch (e) {
      setState(() => error = 'Error submitting homework: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> pickDate({required bool isEndDate}) async {
    final DateTime initial = isEndDate ? (endDate ?? startDate) : startDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isEndDate) {
          endDate = picked;
        } else {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Homework'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: availableClasses.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (error.isNotEmpty) _buildStatusCard(error, true),
                    if (success.isNotEmpty) _buildStatusCard(success, false),
                    DropdownButtonFormField<String>(
                      value: selectedClassKey,
                      items:
                          availableClasses.map<DropdownMenuItem<String>>((cls) {
                        return DropdownMenuItem<String>(
                          value: cls['key'] as String,
                          child: Text(cls['key'] as String),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Class',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) =>
                          setState(() => selectedClassKey = val),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Class is required'
                          : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _homeworkController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Homework Details',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Details are required'
                          : null,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text(
                          'Start Date: ${DateFormat.yMMMd().format(startDate)}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => pickDate(isEndDate: false),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(endDate == null
                          ? 'Select End Date'
                          : 'End Date: ${DateFormat.yMMMd().format(endDate!)}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => pickDate(isEndDate: true),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : submitHomework,
                      child: isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Assign Homework'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard(String message, bool isError) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? Colors.red : Colors.green,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red.shade800 : Colors.green.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
