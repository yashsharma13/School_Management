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
//     ).then((result) {
//       if (result == true) {
//         // Reload data if subjects were updated
//         _refreshData();
//       }
//     });
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
//   bool isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }

//   void _initializeControllers() {
//     // Create flattened lists of subject names and marks
//     List<String> allSubjectNames = [];
//     List<String> allMarks = [];

//     for (var subject in widget.classData.subjects) {
//       for (int i = 0; i < subject.subjectNames.length; i++) {
//         allSubjectNames.add(subject.subjectNames[i]);
//         // Make sure we have a mark for each subject, otherwise use default
//         if (i < subject.marks.length) {
//           allMarks.add(subject.marks[i]);
//         } else {
//           allMarks.add('0');
//         }
//       }
//     }

//     // Initialize controllers with the values
//     subjectControllers = allSubjectNames
//         .map((subject) => TextEditingController(text: subject))
//         .toList();

//     marksControllers =
//         allMarks.map((mark) => TextEditingController(text: mark)).toList();

//     // If no subjects yet, add one empty field
//     if (subjectControllers.isEmpty) {
//       subjectControllers.add(TextEditingController());
//       marksControllers.add(TextEditingController());
//     }
//   }

//   void _addSubject() {
//     setState(() {
//       subjectControllers.add(TextEditingController());
//       marksControllers.add(TextEditingController());
//     });
//   }

//   void _removeSubject(int index) {
//     if (subjectControllers.length > 1) {
//       setState(() {
//         subjectControllers.removeAt(index);
//         marksControllers.removeAt(index);
//       });
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (widget.classData.id.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: Class ID is missing')),
//       );
//       return;
//     }

//     // Validate input fields
//     for (int i = 0; i < subjectControllers.length; i++) {
//       if (subjectControllers[i].text.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Subject name cannot be empty')),
//         );
//         return;
//       }

//       if (marksControllers[i].text.trim().isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Marks cannot be empty')),
//         );
//         return;
//       }

//       if (int.tryParse(marksControllers[i].text.trim()) == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Marks must be a valid number')),
//         );
//         return;
//       }
//     }

//     setState(() {
//       isSaving = true;
//     });

//     try {
//       print("[DEBUG] Starting updateSubject with ID: ${widget.classData.id}");

//       // Prepare subjects data
//       List<Map<String, dynamic>> subjectsData = [];
//       for (int i = 0; i < subjectControllers.length; i++) {
//         String subjectName = subjectControllers[i].text.trim();
//         String marks = marksControllers[i].text.trim();

//         subjectsData.add({
//           'class_name': widget.classData.className,
//           'subject_name': subjectName,
//           'marks': marks,
//         });
//       }

//       // Call API to update subjects
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
//         Navigator.pop(context, true); // Return true to indicate success
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
//     } finally {
//       setState(() {
//         isSaving = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Subjects for ${widget.classData.className}'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: isSaving ? null : _saveChanges,
//           ),
//         ],
//       ),
//       body: isSaving
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: subjectControllers.length,
//                       itemBuilder: (context, index) {
//                         return Card(
//                           margin: EdgeInsets.only(bottom: 16),
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 2,
//                                   child: TextField(
//                                     controller: subjectControllers[index],
//                                     decoration: InputDecoration(
//                                       labelText: 'Subject Name',
//                                       border: OutlineInputBorder(),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   flex: 1,
//                                   child: TextField(
//                                     controller: marksControllers[index],
//                                     decoration: InputDecoration(
//                                       labelText: 'Marks',
//                                       border: OutlineInputBorder(),
//                                     ),
//                                     keyboardType: TextInputType.number,
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () => _removeSubject(index),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                     child: ElevatedButton.icon(
//                       onPressed: _addSubject,
//                       icon: Icon(Icons.add),
//                       label: Text('Add Subject'),
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: Size(double.infinity, 48),
//                       ),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: _saveChanges,
//                     child: Text('Save Changes'),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(double.infinity, 48),
//                       backgroundColor: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   @override
//   void dispose() {
//     // Dispose all controllers to prevent memory leaks
//     for (var controller in subjectControllers) {
//       controller.dispose();
//     }
//     for (var controller in marksControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Classes with Subjects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadClassesWithSubjects,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      );
    }

    if (classesWithSubjects.isEmpty) {
      return Center(
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
              'No classes with subjects found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.blue[800],
      onRefresh: _refreshData,
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: classesWithSubjects.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final classData = classesWithSubjects[index];
          return _buildClassCard(classData);
        },
      ),
    );
  }

  Widget _buildClassCard(ClassWithSubjects classData) {
    int totalSubjects = classData.subjects.fold(0, (sum, subject) {
      return sum + subject.subjectNames.length;
    });

    int totalMarks = classData.subjects.fold(0, (sum, subject) {
      return sum +
          subject.marks.fold(0, (markSum, mark) {
            return markSum + (int.tryParse(mark) ?? 0);
          });
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          classData.className,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue[900],
          ),
        ),
        subtitle: Text(
          '$totalSubjects Subjects • Total Marks: $totalMarks',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(
            Icons.class_,
            color: Colors.blue[800],
          ),
        ),
        children: [
          if (classData.subjects.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No subjects assigned yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ...classData.subjects.map((subject) => _buildSubjectTile(subject)),
          _buildEditButton(classData),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Subject subject) {
    return Column(
      children: List.generate(subject.subjectNames.length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.blue[300]!,
                width: 3,
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              subject.subjectNames[index],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${index < subject.marks.length ? subject.marks[index] : 'N/A'} marks',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          ),
        );
      }),
    );
  }

  Widget _buildEditButton(ClassWithSubjects classData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(Icons.edit, size: 20),
        label: Text('Edit Subjects'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          _navigateToEditPage(classData);
        },
      ),
    );
  }

  void _navigateToEditPage(ClassWithSubjects classData) {
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    List<String> allSubjectNames = [];
    List<String> allMarks = [];

    for (var subject in widget.classData.subjects) {
      for (int i = 0; i < subject.subjectNames.length; i++) {
        allSubjectNames.add(subject.subjectNames[i]);
        if (i < subject.marks.length) {
          allMarks.add(subject.marks[i]);
        } else {
          allMarks.add('0');
        }
      }
    }

    subjectControllers = allSubjectNames
        .map((subject) => TextEditingController(text: subject))
        .toList();

    marksControllers =
        allMarks.map((mark) => TextEditingController(text: mark)).toList();

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
        String subjectName = subjectControllers[i].text.trim();
        String marks = marksControllers[i].text.trim();

        subjectsData.add({
          'class_name': widget.classData.className,
          'subject_name': subjectName,
          'marks': marks,
        });
      }

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
          'Edit Subjects - ${widget.classData.className}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: isSaving ? null : _saveChanges,
          ),
        ],
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
                            onPressed: _addSubject,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text('Save Changes'),
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
