import 'package:flutter/material.dart';
import 'package:sms/pages/services/subject_service.dart';
import 'package:sms/pages/subjects/class_with_subjects.dart';
import 'package:sms/widgets/button.dart';

class EditSubjectsPage extends StatefulWidget {
  final ClassWithSubjects classData;
  final String token;

  EditSubjectsPage({
    required this.classData,
    required this.token,
  });

  @override
  _EditSubjectsPageState createState() => _EditSubjectsPageState();
}

class _EditSubjectsPageState extends State<EditSubjectsPage> {
  late List<TextEditingController> subjectControllers;
  late List<TextEditingController> marksControllers;
  late List<String> subjectIds;
  bool isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    subjectControllers = [];
    marksControllers = [];
    subjectIds = [];

    for (var subject in widget.classData.subjects) {
      subjectControllers.add(TextEditingController(text: subject.subjectName));
      marksControllers.add(TextEditingController(text: subject.marks));
      subjectIds.add(subject.id);
    }

    if (subjectControllers.isEmpty) {
      subjectControllers.add(TextEditingController());
      marksControllers.add(TextEditingController());
      subjectIds.add(''); // Empty ID for new subjects
    }
  }

  Future<void> _addSubject() async {
    setState(() {
      subjectControllers.add(TextEditingController());
      marksControllers.add(TextEditingController());
      subjectIds.add(''); // Empty ID for new subjects
    });
  }

  void _removeSubject(int index) {
    setState(() {
      subjectControllers.removeAt(index);
      marksControllers.removeAt(index);
      subjectIds.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.classData.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Class ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      List<Map<String, dynamic>> subjectsData = [];
      for (int i = 0; i < subjectControllers.length; i++) {
        subjectsData.add({
          'id': subjectIds[i].isEmpty
              ? null
              : subjectIds[i], // Send null for new subjects
          'subject_name': subjectControllers[i].text.trim(),
          'marks': marksControllers[i].text.trim(),
        });
      }

      bool success = await SubjectService.updateSubjects(
        classId: widget.classData.id,
        subjectsData: subjectsData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subjects updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subjects'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Subjects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: isSaving
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
              ),
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class: ${widget.classData.className}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Section: ${widget.classData.section}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: subjectControllers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: subjectControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Subject Name',
                                        labelStyle:
                                            TextStyle(color: Colors.blue[800]),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue[800]!),
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
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: marksControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Marks',
                                        labelStyle:
                                            TextStyle(color: Colors.blue[800]),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.blue[800]!),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 14),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Invalid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red[400]),
                                    onPressed: () => _removeSubject(index),
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
                          child: CustomButton(
                            text: 'Add Subject',
                            icon: Icons.add,
                            onPressed: _addSubject,
                            color: Colors.blue[50]!,
                            textColor: Colors.blue[800]!,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    CustomButton(
                      text: 'Save Changes',
                      icon: Icons.save,
                      onPressed: _saveChanges,
                      isLoading: isSaving,
                      color: Colors.blue[800]!,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    for (var controller in subjectControllers) {
      controller.dispose();
    }
    for (var controller in marksControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
