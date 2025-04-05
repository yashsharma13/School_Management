// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/services/api_service.dart';

// class ClassWithSubjectsPage extends StatefulWidget {
//   @override
//   _ClassWithSubjectsPageState createState() => _ClassWithSubjectsPageState();
// }

// class _ClassWithSubjectsPageState extends State<ClassWithSubjectsPage> {
//   List<ClassWithSubjects> classesWithSubjects = [];
//   bool isLoading = true;
//   String? token;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         token = prefs.getString('token');
//       });

//       if (token != null) {
//         await _loadClassesWithSubjects();
//       } else {
//         setState(() {
//           errorMessage = 'No authentication token found';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error loading token: ${e.toString()}';
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _loadClassesWithSubjects() async {
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = null;
//       });

//       final fetchedData = await ApiService.fetchClassesWithSubjects();

//       setState(() {
//         classesWithSubjects = fetchedData
//             .map((data) => ClassWithSubjects.fromJson(data))
//             .toList();

//         if (classesWithSubjects.isEmpty) {
//           errorMessage = 'No classes with subjects found';
//         }
//       });
//     } catch (error) {
//       print('Error loading classes with subjects: $error');
//       setState(() {
//         errorMessage = 'Error fetching data: ${error.toString()}';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshData() async {
//     await _loadClassesWithSubjects();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Classes with Subjects'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _refreshData,
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               errorMessage!,
//               style: TextStyle(fontSize: 18, color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadClassesWithSubjects,
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (classesWithSubjects.isEmpty) {
//       return Center(
//         child: Text(
//           'No classes with subjects found',
//           style: TextStyle(fontSize: 18),
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshData,
//       child: ListView.builder(
//         itemCount: classesWithSubjects.length,
//         itemBuilder: (context, index) {
//           final classData = classesWithSubjects[index];
//           return _buildClassCard(classData);
//         },
//       ),
//     );
//   }

//   Widget _buildClassCard(ClassWithSubjects classData) {
//     // Calculate the total number of subjects for the class
//     int totalSubjects = classData.subjects.fold(0, (sum, subject) {
//       return sum +
//           subject.subjectNames.length; // Sum up all subject names for a class
//     });

//     // Calculate the total marks for the class
//     int totalMarks = classData.subjects.fold(0, (sum, subject) {
//       return sum +
//           subject.marks.fold(0, (markSum, mark) {
//             return markSum +
//                 (int.tryParse(mark) ?? 0); // Add up the marks for each subject
//           });
//     });

//     return Card(
//       margin: EdgeInsets.all(8.0),
//       elevation: 4.0,
//       child: ExpansionTile(
//         title: Text(
//           classData.className,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         subtitle: Text(
//           'Total Subjects: $totalSubjects | Total Marks: $totalMarks', // Updated subtitle to show total marks and subjects
//           style: TextStyle(fontSize: 14),
//         ),
//         children: [
//           if (classData.subjects.isEmpty)
//             Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Text('No subjects assigned yet'),
//             )
//           else
//             ...classData.subjects.map((subject) => _buildSubjectTile(subject)),
//           _buildEditButton(classData), // Edit button added here
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectTile(Subject subject) {
//     return Column(
//       children: List.generate(subject.subjectNames.length, (index) {
//         return ListTile(
//           title: Text(subject.subjectNames[index]),
//           trailing: Text(
//             'Marks: ${index < subject.marks.length ? subject.marks[index] : 'N/A'}',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           dense: true,
//         );
//       }),
//     );
//   }

//   Widget _buildEditButton(ClassWithSubjects classData) {
//     return ListTile(
//       title: Text('Edit Subjects'),
//       trailing: Icon(Icons.edit),
//       onTap: () {
//         // You can implement navigation to a new screen or open a dialog to edit subjects
//         _navigateToEditPage(classData);
//       },
//     );
//   }

//   void _navigateToEditPage(ClassWithSubjects classData) {
//     // Navigate to the Edit screen with the current classData
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditSubjectsPage(
//           classData: classData,
//           token: token!,
//         ),
//       ),
//     );
//   }
// }

// class EditSubjectsPage extends StatefulWidget {
//   final ClassWithSubjects classData;
//   final String token;

//   EditSubjectsPage({
//     required this.classData,
//     required this.token,
//   });

//   @override
//   _EditSubjectsPageState createState() => _EditSubjectsPageState();
// }

// class _EditSubjectsPageState extends State<EditSubjectsPage> {
//   late List<TextEditingController> subjectControllers;
//   late List<TextEditingController> marksControllers;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with current subjects and marks
//     subjectControllers = widget.classData.subjects
//         .expand((subject) => subject.subjectNames)
//         .map((subject) => TextEditingController(text: subject))
//         .toList();

//     marksControllers = widget.classData.subjects
//         .expand((subject) => subject.marks)
//         .map((mark) => TextEditingController(text: mark))
//         .toList();
//   }

//   void _addSubject() {
//     setState(() {
//       subjectControllers.add(TextEditingController());
//       marksControllers.add(TextEditingController());
//     });
//   }

//   Future<void> _saveChanges() async {
//     try {
//       // Validate input
//       for (int i = 0; i < subjectControllers.length; i++) {
//         String subjectName = subjectControllers[i].text.trim();
//         String marks = marksControllers[i].text.trim();

//         if (subjectName.isEmpty || marks.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Please fill all subject and marks fields')),
//           );
//           return;
//         }
//       }

//       // Prepare data for API - this is the key change
//       List<Map<String, dynamic>> subjectsData = [];

//       // Create individual subject entries instead of comma-separated strings
//       for (int i = 0; i < subjectControllers.length; i++) {
//         subjectsData.add({
//           'class_name': widget.classData.className,
//           'subject_name': subjectControllers[i].text.trim(),
//           'marks': marksControllers[i].text.trim(),
//         });
//       }

//       // Call API service with the properly formatted data
//       bool success = await ApiService.updateSubject(
//         subjectId: widget.classData.id,
//         subjectsData: subjectsData,
//       );

//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Subjects updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update subjects'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error during save changes: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('An error occurred: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Edit Subjects')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: subjectControllers.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: TextField(
//                     controller: subjectControllers[index],
//                     decoration: InputDecoration(labelText: 'Subject Name'),
//                   ),
//                   subtitle: TextField(
//                     controller: marksControllers[index],
//                     decoration: InputDecoration(labelText: 'Marks'),
//                     keyboardType: TextInputType.number,
//                   ),
//                 );
//               },
//             ),
//             ElevatedButton(
//               onPressed: _addSubject,
//               child: Text('Add Subject'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveChanges,
//               child: Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   updateSubject(
//       {required String subjectId,
//       required List<Map<String, dynamic>> subjectsData}) {}
// }

// class ClassWithSubjects {
//   final String id;
//   final String className;
//   final List<Subject> subjects;

//   ClassWithSubjects({
//     required this.id,
//     required this.className,
//     required this.subjects,
//   });

//   factory ClassWithSubjects.fromJson(Map<String, dynamic> json) {
//     final subjectsData = json['subjects'] as List? ?? [];

//     return ClassWithSubjects(
//       id: (json['_id'] ??
//               json['id'] ??
//               DateTime.now().millisecondsSinceEpoch.toString())
//           .toString()
//           .trim(),
//       className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
//           .toString()
//           .trim(),
//       subjects: subjectsData
//           .map((subjectJson) => Subject.fromJson(subjectJson))
//           .toList(),
//     );
//   }
// }

// class Subject {
//   final List<String> subjectNames;
//   final List<String> marks;

//   Subject({
//     required this.subjectNames,
//     required this.marks,
//   });

//   factory Subject.fromJson(Map<String, dynamic> json) {
//     final rawSubjectNames =
//         (json['subject_name'] ?? 'Unknown Subject').toString().trim();
//     final rawMarks = (json['marks'] ?? '0').toString().trim();

//     return Subject(
//       subjectNames: rawSubjectNames.split(',').map((s) => s.trim()).toList(),
//       marks: rawMarks.split(',').map((m) => m.trim()).toList(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/api_service.dart';

class ClassWithSubjectsPage extends StatefulWidget {
  @override
  _ClassWithSubjectsPageState createState() => _ClassWithSubjectsPageState();
}

class _ClassWithSubjectsPageState extends State<ClassWithSubjectsPage> {
  List<ClassWithSubjects> classesWithSubjects = [];
  bool isLoading = true;
  String? token;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        token = prefs.getString('token');
      });

      if (token != null) {
        await _loadClassesWithSubjects();
      } else {
        setState(() {
          errorMessage = 'No authentication token found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading token: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _loadClassesWithSubjects() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final fetchedData = await ApiService.fetchClassesWithSubjects();

      setState(() {
        classesWithSubjects = fetchedData
            .map((data) => ClassWithSubjects.fromJson(data))
            .toList();

        if (classesWithSubjects.isEmpty) {
          errorMessage = 'No classes with subjects found';
        }
      });
    } catch (error) {
      print('Error loading classes with subjects: $error');
      setState(() {
        errorMessage = 'Error fetching data: ${error.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadClassesWithSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes with Subjects'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadClassesWithSubjects,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (classesWithSubjects.isEmpty) {
      return Center(
        child: Text(
          'No classes with subjects found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: classesWithSubjects.length,
        itemBuilder: (context, index) {
          final classData = classesWithSubjects[index];
          return _buildClassCard(classData);
        },
      ),
    );
  }

  Widget _buildClassCard(ClassWithSubjects classData) {
    // Calculate the total number of subjects for the class
    int totalSubjects = classData.subjects.fold(0, (sum, subject) {
      return sum +
          subject.subjectNames.length; // Sum up all subject names for a class
    });

    // Calculate the total marks for the class
    int totalMarks = classData.subjects.fold(0, (sum, subject) {
      return sum +
          subject.marks.fold(0, (markSum, mark) {
            return markSum +
                (int.tryParse(mark) ?? 0); // Add up the marks for each subject
          });
    });

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      child: ExpansionTile(
        title: Text(
          classData.className,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Total Subjects: $totalSubjects | Total Marks: $totalMarks', // Updated subtitle to show total marks and subjects
          style: TextStyle(fontSize: 14),
        ),
        children: [
          if (classData.subjects.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No subjects assigned yet'),
            )
          else
            ...classData.subjects.map((subject) => _buildSubjectTile(subject)),
          _buildEditButton(classData), // Edit button added here
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Subject subject) {
    return Column(
      children: List.generate(subject.subjectNames.length, (index) {
        return ListTile(
          title: Text(subject.subjectNames[index]),
          trailing: Text(
            'Marks: ${index < subject.marks.length ? subject.marks[index] : 'N/A'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          dense: true,
        );
      }),
    );
  }

  Widget _buildEditButton(ClassWithSubjects classData) {
    return ListTile(
      title: Text('Edit Subjects'),
      trailing: Icon(Icons.edit),
      onTap: () {
        // You can implement navigation to a new screen or open a dialog to edit subjects
        _navigateToEditPage(classData);
      },
    );
  }

  void _navigateToEditPage(ClassWithSubjects classData) {
    // Navigate to the Edit screen with the current classData
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSubjectsPage(
          classData: classData,
          token: token!,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Reload data if subjects were updated
        _refreshData();
      }
    });
  }
}

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
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Create flattened lists of subject names and marks
    List<String> allSubjectNames = [];
    List<String> allMarks = [];

    for (var subject in widget.classData.subjects) {
      for (int i = 0; i < subject.subjectNames.length; i++) {
        allSubjectNames.add(subject.subjectNames[i]);
        // Make sure we have a mark for each subject, otherwise use default
        if (i < subject.marks.length) {
          allMarks.add(subject.marks[i]);
        } else {
          allMarks.add('0');
        }
      }
    }

    // Initialize controllers with the values
    subjectControllers = allSubjectNames
        .map((subject) => TextEditingController(text: subject))
        .toList();

    marksControllers =
        allMarks.map((mark) => TextEditingController(text: mark)).toList();

    // If no subjects yet, add one empty field
    if (subjectControllers.isEmpty) {
      subjectControllers.add(TextEditingController());
      marksControllers.add(TextEditingController());
    }
  }

  void _addSubject() {
    setState(() {
      subjectControllers.add(TextEditingController());
      marksControllers.add(TextEditingController());
    });
  }

  void _removeSubject(int index) {
    if (subjectControllers.length > 1) {
      setState(() {
        subjectControllers.removeAt(index);
        marksControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (widget.classData.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Class ID is missing')),
      );
      return;
    }

    // Validate input fields
    for (int i = 0; i < subjectControllers.length; i++) {
      if (subjectControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject name cannot be empty')),
        );
        return;
      }

      if (marksControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marks cannot be empty')),
        );
        return;
      }

      if (int.tryParse(marksControllers[i].text.trim()) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Marks must be a valid number')),
        );
        return;
      }
    }

    setState(() {
      isSaving = true;
    });

    try {
      print("[DEBUG] Starting updateSubject with ID: ${widget.classData.id}");

      // Prepare subjects data
      List<Map<String, dynamic>> subjectsData = [];
      for (int i = 0; i < subjectControllers.length; i++) {
        String subjectName = subjectControllers[i].text.trim();
        String marks = marksControllers[i].text.trim();

        subjectsData.add({
          'class_name': widget.classData.className,
          'subject_name': subjectName,
          'marks': marks,
        });
      }

      // Call API to update subjects
      bool success = await ApiService.updateSubject(
        subjectId: widget.classData.id,
        subjectsData: subjectsData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subjects updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subjects'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during save changes: $e');
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
      appBar: AppBar(
        title: Text('Edit Subjects for ${widget.classData.className}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isSaving ? null : _saveChanges,
          ),
        ],
      ),
      body: isSaving
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: subjectControllers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: subjectControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Subject Name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: marksControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Marks',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeSubject(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _addSubject,
                      icon: Icon(Icons.add),
                      label: Text('Add Subject'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (var controller in subjectControllers) {
      controller.dispose();
    }
    for (var controller in marksControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class ClassWithSubjects {
  final String id;
  final String className;
  final List<Subject> subjects;

  ClassWithSubjects({
    required this.id,
    required this.className,
    required this.subjects,
  });

  factory ClassWithSubjects.fromJson(Map<String, dynamic> json) {
    final subjectsData = json['subjects'] as List? ?? [];

    return ClassWithSubjects(
      id: (json['_id'] ??
              json['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString())
          .toString()
          .trim(),
      className: (json['class_name'] ?? json['className'] ?? 'Unknown Class')
          .toString()
          .trim(),
      subjects: subjectsData
          .map((subjectJson) => Subject.fromJson(subjectJson))
          .toList(),
    );
  }
}

class Subject {
  final List<String> subjectNames;
  final List<String> marks;

  Subject({
    required this.subjectNames,
    required this.marks,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    final rawSubjectNames =
        (json['subject_name'] ?? 'Unknown Subject').toString().trim();
    final rawMarks = (json['marks'] ?? '0').toString().trim();

    return Subject(
      subjectNames: rawSubjectNames.split(',').map((s) => s.trim()).toList(),
      marks: rawMarks.split(',').map((m) => m.trim()).toList(),
    );
  }
}
