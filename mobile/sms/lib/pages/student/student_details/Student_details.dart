import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/student_service.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';
import 'package:sms/widgets/user_photo_widget.dart';
import 'package:sms/widgets/pdf_viewer_widget.dart';
import 'student_model.dart';
import 'edit_student.dart';
import 'delete_student.dart';
import 'package:sms/pages/services/class_service.dart';
import 'package:sms/models/class_model.dart';

final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
final String uploadBaseUrl = '$baseeUrl/uploads';

class StudentProfileManagementPage extends StatefulWidget {
  const StudentProfileManagementPage({super.key});

  @override
  _StudentProfileManagementPageState createState() =>
      _StudentProfileManagementPageState();
}

class _StudentProfileManagementPageState
    extends State<StudentProfileManagementPage> {
  List<Student> students = [];
  List<Student> filteredStudents = [];
  TextEditingController searchController = TextEditingController();
  String? selectedClass;
  String? selectedSection;
  List<Class> classes = [];
  List<String> availableSections = [];
  bool _isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      token = prefs.getString('token');
    });
    if (token != null) {
      await _loadClasses();
      await _fetchInitialData();
    }
  }

  Future<void> _loadClasses() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      final fetchedClasses = await ClassService.fetchClasses();

      final Map<String, Set<String>> classSectionMap = {};
      final List<Class> tempClasses = [];

      for (final data in fetchedClasses) {
        final className =
            (data['class_name'] ?? data['className'] ?? '').toString().trim();
        final section = (data['section'] ?? '').toString().trim();

        if (className.isEmpty) continue;

        if (!classSectionMap.containsKey(className)) {
          classSectionMap[className] = {};
        }

        classSectionMap[className]!.add(section);
      }

      classSectionMap.forEach((className, sections) {
        tempClasses.add(Class(
          id: className,
          className: className,
          sections: sections.toList(),
        ));
      });
      if (!mounted) return;
      setState(() {
        classes = tempClasses;
      });
    } catch (error) {
      // _showErrorSnackBar('Error fetching classes: ${error.toString()}');

      showCustomSnackBar(context, 'Error fetching classes: ${error.toString()}',
          backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateAvailableSections(String? className) {
    setState(() {
      if (className != null) {
        final selectedClassObj =
            classes.firstWhere((c) => c.className == className);
        availableSections = selectedClassObj.sections;
      } else {
        availableSections = [];
      }
      selectedSection = null;
    });
    _filterStudents();
  }

  Future<void> _fetchInitialData() async {
    await _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final studentService = StudentService(); // ✅ FIX
      final fetchedStudents = await studentService.fetchStudents(); // ✅ FIX
      if (!mounted) return;
      setState(() {
        students = fetchedStudents;
        filteredStudents = fetchedStudents;
      });
    } catch (e) {
      showCustomSnackBar(context, 'Error loading students: $e',
          backgroundColor: Colors.red);
    }
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        final nameMatch = student.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        final classMatch =
            selectedClass == null || student.assignedClass == selectedClass;
        final sectionMatch = selectedSection == null ||
            student.assignedSection == selectedSection;
        return nameMatch && classMatch && sectionMatch;
      }).toList();
    });
  }

  Future<void> _editStudent(Student student) async {
    await showDialog(
      context: context,
      builder: (context) => EditStudentDialog(
        student: student,
        classes: classes,
        onStudentUpdated: _fetchInitialData,
      ),
    );
  }

  Future<void> _deleteStudent(int index) async {
    final student = filteredStudents[index];
    final confirmed = await showDeleteStudentDialog(context, student.name);

    if (confirmed) {
      try {
        final studentService = StudentService(); // ✅ FIX
        await studentService.deleteStudent(student.id); // ✅ FIX
        if (!mounted) return;
        setState(() {
          students.removeWhere((s) => s.id == student.id);
          filteredStudents.removeWhere((s) => s.id == student.id);
        });

        showCustomSnackBar(context, 'Student deleted successfully',
            backgroundColor: Colors.red);
      } catch (e) {
        if (!mounted) return;
        showCustomSnackBar(context, 'Failed to delete student :${e.toString()}',
            backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: ' Student Profile Management',
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.deepPurple[800]!),
              ),
            )
          : Column(
              children: [
                _buildFilterSection(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : _buildStudentList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search Students',
                  labelStyle: TextStyle(color: Colors.deepPurple[800]),
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple[800]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.deepPurple[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.deepPurple[800]!, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.deepPurple[800]),
                    onPressed: () {
                      searchController.clear();
                      _filterStudents();
                    },
                  ),
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                ),
                onChanged: (value) => _filterStudents(),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Filter by Class',
                        labelStyle: TextStyle(color: Colors.deepPurple[800]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.deepPurple[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.deepPurple[800]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Classes',
                              style: TextStyle(color: Colors.deepPurple[900])),
                        ),
                        ...classes.map((classItem) {
                          return DropdownMenuItem<String>(
                            value: classItem.className,
                            child: Text(classItem.className,
                                style:
                                    TextStyle(color: Colors.deepPurple[900])),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedClass = newValue;
                          _updateAvailableSections(newValue);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSection,
                      decoration: InputDecoration(
                        labelText: 'Filter by Section',
                        labelStyle: TextStyle(color: Colors.deepPurple[800]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.deepPurple[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.deepPurple[800]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Sections',
                              style: TextStyle(color: Colors.deepPurple[900])),
                        ),
                        ...availableSections.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style:
                                    TextStyle(color: Colors.deepPurple[900])),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSection = newValue;
                          _filterStudents();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            selectedClass == null &&
                    selectedSection == null &&
                    searchController.text.isEmpty
                ? 'No students found'
                : 'No students match your filters',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (selectedClass != null ||
              selectedSection != null ||
              searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedClass = null;
                  selectedSection = null;
                  searchController.clear();
                  filteredStudents = students;
                });
              },
              child: Text('Clear Filters',
                  style: TextStyle(color: Colors.deepPurple[800])),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurple[100]!,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: buildUserPhoto(student.studentPhoto, uploadBaseUrl),
              ),
            ),
            title: Text(
              student.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registration: ${student.registrationNumber}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${student.assignedClass} - ${student.assignedSection}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.deepPurple[800]),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepPurple[800]),
                      SizedBox(width: 8),
                      Text('Edit',
                          style: TextStyle(color: Colors.deepPurple[900])),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[400]),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red[600])),
                    ],
                  ),
                ),
                if (student.birthCertificate.isNotEmpty)
                  PopupMenuItem(
                    value: 'view_certificate',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.green[600]),
                        SizedBox(width: 8),
                        Text('View Certificate',
                            style: TextStyle(color: Colors.green[800])),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editStudent(student);
                } else if (value == 'delete') {
                  await _deleteStudent(index);
                } else if (value == 'view_certificate') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        pdfData: student.birthCertificate,
                        baseUrl: uploadBaseUrl,
                        title: 'Birth Certificate',
                        label: 'Birth Certificate PDF',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

//  code hai toh kaam ka but ek problem thi isme edit student kr reh hai toh problem hai toh abhi comment kr diya hai

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/services/student_service.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/widgets/custom_snackbar.dart';
// import 'package:sms/widgets/user_photo_widget.dart';
// import 'package:sms/widgets/pdf_viewer_widget.dart';
// import 'package:sms/widgets/class_section_selector.dart';
// import 'student_model.dart';
// import 'edit_student.dart';
// import 'delete_student.dart';

// final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL']?.trim() ?? '';
// final String uploadBaseUrl = '$baseUrl/uploads';

// class StudentProfileManagementPage extends StatefulWidget {
//   const StudentProfileManagementPage({super.key});

//   @override
//   _StudentProfileManagementPageState createState() =>
//       _StudentProfileManagementPageState();
// }

// class _StudentProfileManagementPageState
//     extends State<StudentProfileManagementPage> {
//   List<Student> students = [];
//   List<Student> filteredStudents = [];
//   TextEditingController searchController = TextEditingController();
//   ClassModel? selectedClass;
//   String? selectedSection;
//   bool _isLoading = true;
//   String? token;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!mounted) return;
//     setState(() {
//       token = prefs.getString('token');
//     });
//     if (token != null) {
//       await _fetchInitialData();
//     } else {
//       showCustomSnackBar(context, 'No token, please login.',
//           backgroundColor: Colors.red);
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _fetchInitialData() async {
//     await _fetchStudents();
//   }

//   Future<void> _fetchStudents() async {
//     try {
//       final studentService = StudentService();
//       final fetchedStudents = await studentService.fetchStudents();
//       if (!mounted) return;
//       setState(() {
//         students = fetchedStudents;
//         filteredStudents = fetchedStudents;
//       });
//     } catch (e) {
//       showCustomSnackBar(context, 'Error loading students: $e',
//           backgroundColor: Colors.red);
//     }
//   }

//   void _filterStudents() {
//     setState(() {
//       filteredStudents = students.where((student) {
//         final nameMatch = student.name
//             .toLowerCase()
//             .contains(searchController.text.toLowerCase());
//         final classMatch = selectedClass == null ||
//             student.assignedClass == selectedClass!.className;
//         final sectionMatch = selectedSection == null ||
//             student.assignedSection == selectedSection;
//         return nameMatch && classMatch && sectionMatch;
//       }).toList();
//     });
//   }

//   Future<void> _editStudent(Student student) async {
//     await showDialog(
//       context: context,
//       builder: (context) => EditStudentDialog(
//         student: student,
//         classes: [], // Update this if EditStudentDialog needs ClassModel list
//         onStudentUpdated: _fetchInitialData,
//       ),
//     );
//   }

//   Future<void> _deleteStudent(int index) async {
//     final student = filteredStudents[index];
//     final confirmed = await showDeleteStudentDialog(context, student.name);

//     if (confirmed) {
//       try {
//         final studentService = StudentService();
//         await studentService.deleteStudent(student.id);
//         if (!mounted) return;
//         setState(() {
//           students.removeWhere((s) => s.id == student.id);
//           filteredStudents.removeWhere((s) => s.id == student.id);
//         });

//         showCustomSnackBar(context, 'Student deleted successfully',
//             backgroundColor: Colors.green);
//       } catch (e) {
//         if (!mounted) return;
//         showCustomSnackBar(context, 'Failed to delete student: $e',
//             backgroundColor: Colors.red);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: const CustomAppBar(
//         title: 'Student Profile Management',
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple[800]!),
//               ),
//             )
//           : Column(
//               children: [
//                 _buildFilterSection(),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: filteredStudents.isEmpty
//                         ? _buildEmptyState()
//                         : _buildStudentList(),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildFilterSection() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   labelText: 'Search Students',
//                   labelStyle: TextStyle(color: Colors.deepPurple[800]),
//                   prefixIcon: Icon(Icons.search, color: Colors.deepPurple[800]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.deepPurple[300]!),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.deepPurple[800]!, width: 2),
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.clear, color: Colors.deepPurple[800]),
//                     onPressed: () {
//                       searchController.clear();
//                       _filterStudents();
//                     },
//                   ),
//                   filled: true,
//                   fillColor: Colors.deepPurple[50],
//                 ),
//                 onChanged: (value) => _filterStudents(),
//               ),
//               const SizedBox(height: 16),
//               ClassSectionSelector(
//                 onSelectionChanged: (ClassModel? cls, String? sec) {
//                   setState(() {
//                     selectedClass = cls;
//                     selectedSection = sec;
//                     _filterStudents();
//                   });
//                 },
//                 initialClass: selectedClass,
//                 initialSection: selectedSection,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.people_outline,
//             size: 60,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             selectedClass == null &&
//                     selectedSection == null &&
//                     searchController.text.isEmpty
//                 ? 'No students found'
//                 : 'No students match your filters',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//             ),
//           ),
//           if (selectedClass != null ||
//               selectedSection != null ||
//               searchController.text.isNotEmpty)
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   selectedClass = null;
//                   selectedSection = null;
//                   searchController.clear();
//                   filteredStudents = students;
//                 });
//               },
//               child: Text('Clear Filters',
//                   style: TextStyle(color: Colors.deepPurple[800])),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStudentList() {
//     return ListView.builder(
//       itemCount: filteredStudents.length,
//       itemBuilder: (context, index) {
//         final student = filteredStudents[index];
//         return Card(
//           elevation: 2,
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(12),
//             leading: Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.deepPurple[100]!,
//                   width: 2,
//                 ),
//               ),
//               child: ClipOval(
//                 child: buildUserPhoto(student.studentPhoto, uploadBaseUrl),
//               ),
//             ),
//             title: Text(
//               student.name,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple[800],
//               ),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Registration: ${student.registrationNumber}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 Text(
//                   '${student.assignedClass} - ${student.assignedSection}',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//             trailing: PopupMenuButton(
//               icon: Icon(Icons.more_vert, color: Colors.deepPurple[800]),
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit, color: Colors.deepPurple[800]),
//                       const SizedBox(width: 8),
//                       Text('Edit', style: TextStyle(color: Colors.deepPurple[900])),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete, color: Colors.red[400]),
//                       const SizedBox(width: 8),
//                       Text('Delete', style: TextStyle(color: Colors.red[600])),
//                     ],
//                   ),
//                 ),
//                 if (student.birthCertificate.isNotEmpty)
//                   PopupMenuItem(
//                     value: 'view_certificate',
//                     child: Row(
//                       children: [
//                         Icon(Icons.picture_as_pdf, color: Colors.green[600]),
//                         const SizedBox(width: 8),
//                         Text('View Certificate',
//                             style: TextStyle(color: Colors.green[800])),
//                       ],
//                     ),
//                   ),
//               ],
//               onSelected: (value) async {
//                 if (value == 'edit') {
//                   await _editStudent(student);
//                 } else if (value == 'delete') {
//                   await _deleteStudent(index);
//                 } else if (value == 'view_certificate') {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PDFViewerScreen(
//                         pdfData: student.birthCertificate,
//                         baseUrl: uploadBaseUrl,
//                         title: 'Birth Certificate',
//                         label: 'Birth Certificate PDF',
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
