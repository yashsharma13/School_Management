import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/api_service.dart';

class AssignSubjectPage extends StatefulWidget {
  @override
  _AssignSubjectPageState createState() => _AssignSubjectPageState();
}

class _AssignSubjectPageState extends State<AssignSubjectPage> {
  List<Class> classes = [];
  List<SubjectField> subjectFields = [];
  bool isLoading = true;
  String? token;
  Class? selectedClass;
  final _formKey = GlobalKey<FormState>();

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
      await _loadClasses();
    }
  }

  Future<void> _loadClasses() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedClasses = await ApiService.fetchClasses();

      setState(() {
        classes = fetchedClasses
            .map((data) => Class.fromJson(data))
            .where((classObj) =>
                classObj.id.isNotEmpty && classObj.className.isNotEmpty)
            .toList();

        if (classes.isEmpty) {
          _showErrorSnackBar(
              'No valid classes found. Please add classes first.');
        }
      });
    } catch (error) {
      _showErrorSnackBar('Error fetching classes: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _addSubjectField() {
    setState(() {
      subjectFields.add(SubjectField());
    });
  }

  void _removeSubjectField(int index) {
    if (subjectFields.length > 1) {
      setState(() {
        subjectFields.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedClass == null) {
      _showErrorSnackBar('Please select a class');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> subjectsData = subjectFields
          .map((field) => {
                'subject_name': field.subjectName.trim(),
                'marks': field.marks.trim(),
              })
          .toList();

      final success = await ApiService.registerSubject(
        className: selectedClass!.className,
        subjectsData: subjectsData,
      );

      if (success) {
        _showSuccessSnackBar('Subjects assigned successfully!');
        setState(() {
          subjectFields.clear();
          _formKey.currentState!.reset();
        });
      } else {
        _showErrorSnackBar('Failed to assign subjects');
      }
    } catch (error) {
      _showErrorSnackBar('Error: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Assign Subjects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                  ),
                )
              else if (classes.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_,
                        color: Colors.blue[800],
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No classes available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadClasses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                DropdownButtonFormField<Class>(
                  decoration: InputDecoration(
                    labelText: 'Select Class',
                    labelStyle: TextStyle(color: Colors.blue[800]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[800]!),
                    ),
                    filled: true,
                    fillColor: Colors.blue[50],
                  ),
                  hint: Text(
                    'Select Class',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  value: selectedClass,
                  onChanged: (Class? newValue) {
                    setState(() {
                      selectedClass = newValue;
                      subjectFields.clear();
                      _addSubjectField(); // Add first subject field automatically
                    });
                  },
                  items: classes.map((classItem) {
                    return DropdownMenuItem<Class>(
                      value: classItem,
                      child: Text(
                        classItem.className,
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    );
                  }).toList(),
                  validator: (value) =>
                      value == null ? 'Please select a class' : null,
                ),
                SizedBox(height: 24),
                Text(
                  'Subjects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: subjectFields.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Subject ${index + 1}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  if (subjectFields.length > 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[400],
                                      ),
                                      onPressed: () =>
                                          _removeSubjectField(index),
                                    ),
                                ],
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Subject Name',
                                  labelStyle:
                                      TextStyle(color: Colors.blue[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[800]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  subjectFields[index].subjectName = value;
                                },
                              ),
                              SizedBox(height: 12),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Marks',
                                  labelStyle:
                                      TextStyle(color: Colors.blue[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[800]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Enter valid number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  subjectFields[index].marks = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 20),
                        label: Text('Add Subject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[800],
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _addSubjectField,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text('Assign Subjects'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Class {
  final String id;
  final String className;

  Class({required this.id, required this.className});

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
    );
  }
}

class SubjectField {
  String subjectName = '';
  String marks = '';
}
