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
      // print('Fetched classes data: $fetchedClasses'); // Debug print

      setState(() {
        classes = fetchedClasses
            .map((data) => Class.fromJson(data))
            .where((classObj) {
          // More flexible validation
          final isValid =
              classObj.id.isNotEmpty && classObj.className.isNotEmpty;
          if (!isValid) {
            print(
                '[WARNING] Skipping class - ID: "${classObj.id}", Name: "${classObj.className}"');
          }
          return isValid;
        }).toList();

        if (classes.isEmpty) {
          _showErrorSnackBar(
              'No valid classes found. Please check the class data format.');
        } else {
          print('Successfully loaded ${classes.length} classes');
        }
      });
    } catch (error) {
      print('Error loading classes: $error'); // Debug print
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
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addSubjectField() {
    setState(() {
      subjectFields.add(SubjectField());
    });
  }

  void _removeSubjectField(int index) {
    setState(() {
      subjectFields.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (selectedClass == null) {
      _showErrorSnackBar('Please select a class first');
      return;
    }

    // Validate that all subject fields are filled
    bool isValid = subjectFields.every(
        (field) => field.subjectName.isNotEmpty && field.marks.isNotEmpty);

    if (!isValid) {
      _showErrorSnackBar('Please fill all subject details');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare subjects data
      final List<Map<String, dynamic>> subjectsData = subjectFields
          .map((field) => {
                'subject_name': field.subjectName,
                'marks': field.marks,
              })
          .toList();

      // Call API to save the data
      final success = await ApiService.registerSubject(
        className: selectedClass!.className, // Pass the class ID
        subjectsData:
            subjectsData, // Pass the list of subjects with names and marks
      );

      // Handle API response
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subjects assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          subjectFields.clear(); // Clear the form
        });
      } else {
        _showErrorSnackBar('Failed to assign subjects');
      }
    } catch (error) {
      _showErrorSnackBar('Error submitting form: ${error.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Subject'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Class>(
                    decoration: InputDecoration(
                      labelText: 'Select Class',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text('Select Class'),
                    value: selectedClass,
                    onChanged: (Class? newValue) {
                      setState(() {
                        selectedClass = newValue;
                        subjectFields.clear();
                      });
                    },
                    items: classes.map((classItem) {
                      return DropdownMenuItem<Class>(
                        value: classItem,
                        child: Text(classItem.className),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Please select a class' : null,
                  ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: subjectFields.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Subject Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    subjectFields[index].subjectName = value;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Marks',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    subjectFields[index].marks = value;
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeSubjectField(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: selectedClass != null ? _addSubjectField : null,
                  child: Text('Add Subject'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
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
