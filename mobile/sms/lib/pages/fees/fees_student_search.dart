import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';
import 'package:sms/widgets/class_section_selector.dart';
import 'fees_collection_detail_page.dart';

class FeeCollectPage extends StatefulWidget {
  const FeeCollectPage({super.key});

  @override
  State<FeeCollectPage> createState() => _FeeCollectPageState();
}

class _FeeCollectPageState extends State<FeeCollectPage> {
  List<StudentModel> students = [];
  List<StudentModel> filteredStudents = [];
  bool isLoadingStudents = false;
  String? token;
  TextEditingController searchController = TextEditingController();
  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
  static final Map<String, String> classIdCache = {};
  static final Map<String, List<FeeStructureModel>> feeStructureCache = {};

  ClassModel? selectedClass;
  String? selectedSection;

  @override
  void initState() {
    super.initState();
    _loadToken();
    searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> _fetchStudents() async {
    if (token == null || selectedClass == null) {
      showCustomSnackBar(context, 'Please login or select a class',
          backgroundColor: Colors.red);
      return;
    }

    setState(() {
      isLoadingStudents = true;
      filteredStudents = [];
    });

    try {
      String encodedClassName = Uri.encodeComponent(selectedClass!.className);

      final response = await http.get(
        Uri.parse('$baseUrl/api/students/$encodedClassName'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> studentData = json.decode(response.body);
        setState(() {
          students = studentData
              .map((data) => StudentModel(
                    id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
                    name: data['student_name']?.toString() ?? 'Unknown Student',
                    classId: selectedClass!.id.toString(),
                    className: selectedClass!.className,
                    section: data['assigned_section']?.toString() ?? '',
                  ))
              .where((student) => student.id.isNotEmpty)
              .toList();

          _filterStudents();
        });
      } else {
        if (!mounted) return;
        showCustomSnackBar(
            context, 'Failed to load students: ${response.reasonPhrase}',
            backgroundColor: Colors.red);
      }
    } catch (error) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Error loading students: $error',
          backgroundColor: Colors.red);
    } finally {
      setState(() {
        isLoadingStudents = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchStudentFeeData(
      StudentModel student) async {
    final classId =
        classIdCache[student.className] ?? await _getClassId(student.className);
    final feeStructure =
        feeStructureCache[student.className] ?? await _getFeeStructure(classId);
    final paidFeeMasterIds = await _getPaidFees(student.id);
    final previousBalance = await _getPreviousBalance(student.id);

    // Calculate total yearly fee for the student
    double totalYearlyFee = 0.0;
    for (var fee in feeStructure) {
      if (!paidFeeMasterIds.contains(fee.feeMasterId.toString()) ||
          !fee.isOneTime) {
        double amount = double.tryParse(fee.amount) ?? 0.0;
        totalYearlyFee += fee.isMonthly ? amount : amount;
      }
    }

    return {
      'classId': classId,
      'feeStructure': feeStructure,
      'paidFeeMasterIds': paidFeeMasterIds,
      'previousBalance': previousBalance,
      'totalYearlyFee': totalYearlyFee,
    };
  }

  Future<String> _getClassId(String className) async {
    if (classIdCache.containsKey(className)) return classIdCache[className]!;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> classData = json.decode(response.body);
        for (final data in classData) {
          final name =
              (data['class_name'] ?? data['className'] ?? '').toString().trim();
          if (name.toLowerCase() == className.toLowerCase()) {
            final id = data['id']?.toString() ?? data['class_id']?.toString();
            if (id != null) {
              classIdCache[className] = id;
              return id;
            }
          }
        }
      }
    } catch (error) {
      // Fallback to class name if API fails
    }
    classIdCache[className] = className;
    return className;
  }

  Future<List<FeeStructureModel>> _getFeeStructure(String classId) async {
    if (feeStructureCache.containsKey(classId)) {
      return feeStructureCache[classId]!;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feestructure/$classId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final feeStructureData = jsonDecode(response.body);
        List<dynamic> feeStructureList = feeStructureData is List
            ? feeStructureData
            : feeStructureData['data'] ?? [];
        final feeStructure = feeStructureList
            .map((item) => FeeStructureModel.fromJson(item))
            .toList();
        feeStructureCache[classId] = feeStructure;
        return feeStructure;
      }
    } catch (error) {
      // Return empty list on error
    }
    return [];
  }

  Future<List<String>> _getPaidFees(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/fees/paid?studentId=$studentId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      }
    } catch (error) {
      // Return empty list on error
    }
    return [];
  }

  Future<double> _getPreviousBalance(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/summary/$studentId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
      );

      if (response.statusCode == 200) {
        final balanceData = jsonDecode(response.body);
        return (balanceData['data']['last_due_balance'] ?? 0).toDouble();
      }
    } catch (error) {
      // Return 0 on error
    }
    return 0.0;
  }

  void _filterStudents() {
    String searchText = searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        final nameMatch = student.name.toLowerCase().contains(searchText);
        final sectionMatch =
            selectedSection == null || student.section == selectedSection;
        return nameMatch && sectionMatch;
      }).toList();
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   final deepPurpleTheme = Colors.deepPurple.shade900;
  //   return Scaffold(
  //     backgroundColor: Colors.grey.shade100,
  //     appBar: const CustomAppBar(
  //       title: 'Collect Fee',
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Filter Students',
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       color: deepPurpleTheme,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 12),
  //                   ClassSectionSelector(
  //                     onSelectionChanged: (ClassModel? cls, String? sec) {
  //                       setState(() {
  //                         selectedClass = cls;
  //                         selectedSection = sec;
  //                         students = [];
  //                         filteredStudents = [];
  //                         if (cls != null) {
  //                           _fetchStudents();
  //                         }
  //                       });
  //                     },
  //                     initialClass: selectedClass,
  //                     initialSection: selectedSection,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           if (selectedClass != null)
  //             Card(
  //               elevation: 4,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: TextField(
  //                 controller: searchController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Search Student',
  //                   labelStyle: TextStyle(color: deepPurpleTheme),
  //                   prefixIcon: Icon(Icons.search, color: deepPurpleTheme),
  //                   border: InputBorder.none,
  //                   contentPadding: const EdgeInsets.symmetric(
  //                       horizontal: 16, vertical: 14),
  //                   filled: true,
  //                   fillColor: Colors.deepPurple.shade50,
  //                 ),
  //                 style: TextStyle(color: deepPurpleTheme, fontSize: 14),
  //               ),
  //             ),
  //           const SizedBox(height: 16),
  //           if (selectedClass != null)
  //             Text(
  //               'Students',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: deepPurpleTheme,
  //               ),
  //             ),
  //           const SizedBox(height: 8),
  //           Expanded(
  //             child: isLoadingStudents
  //                 ? Center(
  //                     child: CircularProgressIndicator(
  //                       color: deepPurpleTheme,
  //                     ),
  //                   )
  //                 : selectedClass == null
  //                     ? Center(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Icon(
  //                               Icons.school,
  //                               color: deepPurpleTheme,
  //                               size: 48,
  //                             ),
  //                             const SizedBox(height: 16),
  //                             Text(
  //                               'Please select a class to view students',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: Colors.grey.shade600,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       )
  //                     : filteredStudents.isEmpty
  //                         ? Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(
  //                                   selectedSection == null
  //                                       ? Icons.people_outline
  //                                       : Icons.filter_alt_outlined,
  //                                   color: deepPurpleTheme,
  //                                   size: 48,
  //                                 ),
  //                                 const SizedBox(height: 16),
  //                                 Text(
  //                                   selectedSection == null
  //                                       ? 'No students found in this class'
  //                                       : 'No students found in this section',
  //                                   style: TextStyle(
  //                                     fontSize: 16,
  //                                     color: Colors.grey.shade600,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           )
  //                         : ListView.separated(
  //                             itemCount: filteredStudents.length,
  //                             separatorBuilder: (context, index) =>
  //                                 const SizedBox(height: 8),
  //                             itemBuilder: (context, index) {
  //                               final student = filteredStudents[index];
  //                               return Card(
  //                                 elevation: 3,
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(12),
  //                                 ),
  //                                 child: ListTile(
  //                                   leading: CircleAvatar(
  //                                     backgroundColor:
  //                                         Colors.deepPurple.shade50,
  //                                     child: Icon(
  //                                       Icons.person,
  //                                       color: deepPurpleTheme,
  //                                       size: 20,
  //                                     ),
  //                                   ),
  //                                   title: Text(
  //                                     student.name,
  //                                     style: TextStyle(
  //                                       fontWeight: FontWeight.w600,
  //                                       color: deepPurpleTheme,
  //                                       fontSize: 16,
  //                                     ),
  //                                   ),
  //                                   subtitle: Text(
  //                                     'Class: ${student.className} • Section: ${student.section}',
  //                                     style: TextStyle(
  //                                       color: Colors.grey.shade600,
  //                                       fontSize: 13,
  //                                     ),
  //                                   ),
  //                                   trailing: Container(
  //                                     padding: const EdgeInsets.all(6),
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.deepPurple.shade50,
  //                                       shape: BoxShape.circle,
  //                                     ),
  //                                     child: Icon(
  //                                       Icons.arrow_forward,
  //                                       color: deepPurpleTheme,
  //                                       size: 20,
  //                                     ),
  //                                   ),
  //                                   onTap: () async {
  //                                     // Show loading dialog
  //                                     showDialog(
  //                                       context: context,
  //                                       barrierDismissible: false,
  //                                       builder: (context) => Center(
  //                                         child: CircularProgressIndicator(
  //                                             color: deepPurpleTheme),
  //                                       ),
  //                                     );

  //                                     final feeData =
  //                                         await _fetchStudentFeeData(student);
  //                                     if (context.mounted) {
  //                                       // Dismiss loading dialog
  //                                       Navigator.pop(context);
  //                                     }
  //                                     if (context.mounted) {
  //                                       Navigator.push(
  //                                         context,
  //                                         PageRouteBuilder(
  //                                           pageBuilder: (context, animation,
  //                                                   secondaryAnimation) =>
  //                                               FeesCollectionPage(
  //                                             studentId: student.id,
  //                                             studentName: student.name,
  //                                             studentClass: student.className,
  //                                             studentSection: student.section,
  //                                             isNewAdmission: false,
  //                                             preloadedData: feeData,
  //                                           ),
  //                                           transitionsBuilder: (context,
  //                                               animation,
  //                                               secondaryAnimation,
  //                                               child) {
  //                                             const begin = Offset(1.0, 0.0);
  //                                             const end = Offset.zero;
  //                                             const curve = Curves.easeInOut;
  //                                             var tween = Tween(
  //                                                     begin: begin, end: end)
  //                                                 .chain(
  //                                                     CurveTween(curve: curve));
  //                                             return SlideTransition(
  //                                               position:
  //                                                   animation.drive(tween),
  //                                               child: child,
  //                                             );
  //                                           },
  //                                           transitionDuration: const Duration(
  //                                               milliseconds: 300),
  //                                         ),
  //                                       );
  //                                     }
  //                                   },
  //                                   contentPadding: const EdgeInsets.symmetric(
  //                                       horizontal: 16, vertical: 12),
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final deepPurpleTheme = Colors.deepPurple.shade900;
    // Get screen height for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(
        title: 'Collect Fee',
      ),
      body: SingleChildScrollView(
        // Wrap content in SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(
              isLandscape ? 8.0 : 16.0), // Adjust padding for landscape
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Students',
                        style: TextStyle(
                          fontSize: isLandscape
                              ? 16
                              : 18, // Smaller font in landscape
                          fontWeight: FontWeight.bold,
                          color: deepPurpleTheme,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClassSectionSelector(
                        onSelectionChanged: (ClassModel? cls, String? sec) {
                          setState(() {
                            selectedClass = cls;
                            selectedSection = sec;
                            students = [];
                            filteredStudents = [];
                            if (cls != null) {
                              _fetchStudents();
                            }
                          });
                        },
                        initialClass: selectedClass,
                        initialSection: selectedSection,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedClass != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Student',
                      labelStyle: TextStyle(color: deepPurpleTheme),
                      prefixIcon: Icon(Icons.search, color: deepPurpleTheme),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.deepPurple.shade50,
                    ),
                    style: TextStyle(
                        color: deepPurpleTheme,
                        fontSize: isLandscape ? 12 : 14),
                  ),
                ),
              const SizedBox(height: 16),
              if (selectedClass != null)
                Text(
                  'Students',
                  style: TextStyle(
                    fontSize: isLandscape ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: deepPurpleTheme,
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                // Constrain ListView height dynamically
                height: isLandscape
                    ? screenHeight * 0.5 // Smaller height in landscape
                    : screenHeight * 0.6, // Larger height in portrait
                child: isLoadingStudents
                    ? Center(
                        child: CircularProgressIndicator(
                          color: deepPurpleTheme,
                        ),
                      )
                    : selectedClass == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school,
                                  color: deepPurpleTheme,
                                  size: isLandscape ? 36 : 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Please select a class to view students',
                                  style: TextStyle(
                                    fontSize: isLandscape ? 14 : 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : filteredStudents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      selectedSection == null
                                          ? Icons.people_outline
                                          : Icons.filter_alt_outlined,
                                      color: deepPurpleTheme,
                                      size: isLandscape ? 36 : 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      selectedSection == null
                                          ? 'No students found in this class'
                                          : 'No students found in this section',
                                      style: TextStyle(
                                        fontSize: isLandscape ? 14 : 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: filteredStudents.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final student = filteredStudents[index];
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.deepPurple.shade50,
                                        child: Icon(
                                          Icons.person,
                                          color: deepPurpleTheme,
                                          size: isLandscape ? 16 : 20,
                                        ),
                                      ),
                                      title: Text(
                                        student.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: deepPurpleTheme,
                                          fontSize: isLandscape ? 14 : 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Class: ${student.className} • Section: ${student.section}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: isLandscape ? 11 : 13,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: deepPurpleTheme,
                                          size: isLandscape ? 16 : 20,
                                        ),
                                      ),
                                      onTap: () async {
                                        // Show loading dialog
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => Center(
                                            child: CircularProgressIndicator(
                                                color: deepPurpleTheme),
                                          ),
                                        );

                                        final feeData =
                                            await _fetchStudentFeeData(student);
                                        if (context.mounted) {
                                          // Dismiss loading dialog
                                          Navigator.pop(context);
                                        }
                                        if (context.mounted) {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  FeesCollectionPage(
                                                studentId: student.id,
                                                studentName: student.name,
                                                studentClass: student.className,
                                                studentSection: student.section,
                                                isNewAdmission: false,
                                                preloadedData: feeData,
                                              ),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;
                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));
                                                return SlideTransition(
                                                  position:
                                                      animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 300),
                                            ),
                                          );
                                        }
                                      },
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isLandscape ? 8 : 16,
                                        vertical: isLandscape ? 8 : 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentModel {
  final String id;
  final String name;
  final String classId;
  final String className;
  final String section;

  StudentModel({
    required this.id,
    required this.name,
    required this.classId,
    required this.className,
    required this.section,
  });
}
