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
  String? _selectedSection;
  String _tuitionFees = '';
  String? _selectedTeacherName;
  String? token;

  bool isLoading = false;
  bool isFetchingTeachers = false;
  List<Teacher> teachers = [];

  final List<String> classOptions = [
    'Nursery',
    'LKG',
    'UKG',
    'class 1',
    'class 2',
    'class 3',
    'class 4',
    'class 5',
    'class 6',
    'class 7',
    'class 8',
    'class 9',
    'class 10',
    'class 11',
    'class 12',
  ];

  final List<String> sectionOptions = [
    'Section A',
    'Section B',
    'Section C',
    'Section D'
  ];

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

      setState(() {
        isLoading = true;
      });

      try {
        final success = await ApiService.registerClass(
          className: _className,
          section: _selectedSection!,
          tuitionFees: _tuitionFees,
          teacherName: _selectedTeacherName!,
        );

        if (success) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Class Added Successfully',
                    style: TextStyle(color: Colors.blue[900])),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Class: $_className - $_selectedSection',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Fees: $_tuitionFees', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Teacher: $_selectedTeacherName',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    child:
                        Text('OK', style: TextStyle(color: Colors.blue[900])),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add class'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Add New Class', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 16),
                _buildClassDropdown(),
                SizedBox(height: 16),
                _buildSectionDropdown(),
                SizedBox(height: 16),
                _buildInputField(
                  'Monthly Tuition Fees',
                  (value) => _tuitionFees = value,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24),
                if (token == null)
                  _buildWarningCard(
                      'You are not logged in. Please login to continue.')
                else if (isFetchingTeachers)
                  _buildLoadingIndicator('Loading teachers...')
                else if (teachers.isEmpty)
                  _buildWarningCard(
                      'No teachers found. Please add teachers first.')
                else
                  _buildTeacherDropdown(),
                SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Class',
            style: TextStyle(color: Colors.blue[900], fontSize: 16)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[900]!.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              value: _className.isNotEmpty ? _className : null,
              onChanged: (String? newValue) {
                setState(() {
                  _className = newValue!;
                });
              },
              items: classOptions.map((className) {
                return DropdownMenuItem<String>(
                  value: className,
                  child: Text(className),
                );
              }).toList(),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select a class'
                  : null,
              style: TextStyle(color: Colors.blue[900]),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[900]),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Section',
            style: TextStyle(color: Colors.blue[900], fontSize: 16)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[900]!.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              value: _selectedSection,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSection = newValue;
                });
              },
              items: sectionOptions.map((section) {
                return DropdownMenuItem<String>(
                  value: section,
                  child: Text(section),
                );
              }).toList(),
              validator: (value) =>
                  value == null ? 'Please select a section' : null,
              style: TextStyle(color: Colors.blue[900]),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[900]),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, Function(String) onSaved,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue[900]),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[900]!.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[900]!),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Monthly Tuition Fees' && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      onSaved: (value) => onSaved(value!),
    );
  }

  Widget _buildTeacherDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Class Teacher',
            style: TextStyle(color: Colors.blue[900], fontSize: 16)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[900]!.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              value: _selectedTeacherName,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTeacherName = newValue;
                });
              },
              items: teachers.map((teacher) {
                return DropdownMenuItem<String>(
                  value: teacher.name,
                  child: Text(teacher.name),
                );
              }).toList(),
              validator: (value) =>
                  value == null ? 'Please select a teacher' : null,
              style: TextStyle(color: Colors.blue[900]),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[900]),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard(String message) {
    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.orange[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[800]),
            SizedBox(width: 16),
            Expanded(
                child:
                    Text(message, style: TextStyle(color: Colors.orange[800]))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: Colors.blue[900]),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.blue[900])),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading || teachers.isEmpty ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Add Class',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
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
