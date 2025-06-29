import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/class_service.dart';
import 'package:sms/pages/services/subject_service.dart';
import 'package:sms/widgets/button.dart';

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
  String? selectedSection;
  List<String> availableSections = [];
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

      final fetchedClasses = await ClassService.fetchClasses();

      final Map<String, Class> classMap = {}; // ✅ Key: class_name

      for (final data in fetchedClasses) {
        final className = (data['class_name'] ?? '').toString().trim();
        final section = (data['section'] ?? '').toString().trim();
        final classId = data['id']; // you can still keep the first one

        if (className.isEmpty) continue;

        // If class doesn't exist in the map yet, add it
        if (!classMap.containsKey(className)) {
          classMap[className] = Class(
            id: classId, // just pick first ID you get for this class name
            className: className,
            sections: [],
          );
        }

        // Add section if it's not already added
        if (section.isNotEmpty &&
            !classMap[className]!.sections.contains(section)) {
          classMap[className]!.sections.add(section);
        }
      }

      setState(() {
        classes = classMap.values.toList();
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
    if (selectedSection == null) {
      _showErrorSnackBar('Please select a section');
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

      final success = await SubjectService.registerSubject(
        classId: selectedClass!.id,
        subjectsData: subjectsData,
      );

      if (success) {
        _showSuccessSnackBar('Subjects assigned successfully!');
        setState(() {
          subjectFields.clear();
          selectedClass = null;
          selectedSection = null;
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
        backgroundColor: Colors.blue.shade900,
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
                      selectedSection = null;
                      availableSections = newValue?.sections ?? [];
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
                SizedBox(height: 16),

                // Section Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Section',
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
                    'Select Section',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                  value: selectedSection,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSection = newValue;
                    });
                  },
                  items: availableSections.map((section) {
                    return DropdownMenuItem<String>(
                      value: section,
                      child: Text(
                        section,
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    );
                  }).toList(),
                  validator: (value) =>
                      value == null ? 'Please select a section' : null,
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
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[800]!),
                                  ),
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
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.blue[800]!),
                                  ),
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
                CustomButton(
                  text: 'Add Subject',
                  icon: Icons.add,
                  onPressed: () async {
                    _addSubjectField();
                  },
                  color: Colors.red,
                ),

                SizedBox(height: 12),
                CustomButton(
                  text: 'Assign Subjects',
                  onPressed: _submitForm,
                  isLoading: isLoading,
                  // color: Colors.blue.shade900,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Class model
class Class {
  final int id;
  final String className;
  final List<String> sections;

  Class({
    required this.id,
    required this.className,
    required this.sections,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['_id'],
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
      sections: [],
    );
  }
}

// SubjectField model
class SubjectField {
  String subjectName = '';
  String marks = '';
}
