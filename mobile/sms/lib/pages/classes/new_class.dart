import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/api_service.dart';

class AddClassPage extends StatefulWidget {
  @override
  _AddClassPageState createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  String _className = '';
  String _tuitionFees = '';
  String? _selectedTeacherName; // Now we're storing the teacher name
  String? token;

  bool isLoading = false;
  bool isFetchingTeachers = false;
  List<Teacher> teachers = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });

    if (token != null) {
      fetchTeachers();
    }
  }

  Future<void> fetchTeachers() async {
    if (token == null) return;

    setState(() {
      isFetchingTeachers = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1000/api/teachers'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> teacherData = json.decode(response.body);
        setState(() {
          teachers = teacherData
              .map((data) => Teacher(
                    id: data['id'].toString(),
                    name: data['teacher_name'],
                  ))
              .toList();
        });
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        setState(() {
          token = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load teachers: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error connecting to server. Please check your connection.')),
      );
    } finally {
      setState(() {
        isFetchingTeachers = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Print values to debug
      print('Class Name: $_className');
      print('Tuition Fees: $_tuitionFees');
      print('Teacher Name: $_selectedTeacherName');

      // Show loading indicator while submitting data
      setState(() {
        isLoading = true;
      });

      // Call the API to register the class
      try {
        final success = await ApiService.registerClass(
          className: _className,
          tuitionFees: _tuitionFees,
          teacherName:
              _selectedTeacherName!, // Send the teacher's name instead of ID
        );

        if (success) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Class Added'),
                content: Text(
                    'Class: $_className\nFees: $_tuitionFees\nTeacher: $_selectedTeacherName'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pop(context); // Go back to previous page
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add class')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Class'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Class Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the class name';
                    }
                    return null;
                  },
                  onSaved: (value) => _className = value!,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Monthly Tuition Fees'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the tuition fees';
                    }
                    return null;
                  },
                  onSaved: (value) => _tuitionFees = value!,
                ),
                const SizedBox(height: 20),
                if (token == null)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.warning, size: 48, color: Colors.orange),
                        Text(
                            'You are not logged in. Please login to continue.'),
                      ],
                    ),
                  )
                else if (isFetchingTeachers)
                  const Center(child: Text('Loading teachers...'))
                else if (teachers.isEmpty)
                  const Center(
                    child: Text(
                      'No teachers found. Please add teachers first.',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Select Class Teacher'),
                    value: _selectedTeacherName,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTeacherName = newValue;
                        print(
                            'Selected Teacher: $_selectedTeacherName'); // Debugging line
                      });
                    },
                    items: teachers
                        .map((teacher) => DropdownMenuItem<String>(
                              value: teacher.name, // Use the teacher name here
                              child: Text(teacher.name),
                            ))
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Please select a teacher' : null,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading || teachers.isEmpty ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit', style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Teacher {
  final String id;
  final String name;

  Teacher({required this.id, required this.name});
}
