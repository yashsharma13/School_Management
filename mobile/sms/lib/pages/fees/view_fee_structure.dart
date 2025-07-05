// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:sms/widgets/custom_appbar.dart';

// class ViewFeeStructurePage extends StatefulWidget {
//   const ViewFeeStructurePage({super.key});

//   @override
//   State<ViewFeeStructurePage> createState() => _ViewFeeStructurePageState();
// }

// class _ViewFeeStructurePageState extends State<ViewFeeStructurePage> {
//   String? token;
//   String? selectedClassId;
//   List<ClassModel> classes = [];
//   List<FeeStructureModel> feeStructure = [];
//   bool isLoading = false;

//   static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndData();
//   }

//   Future<void> _loadTokenAndData() async {
//     final prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token');
//     if (token != null) {
//       await _fetchClasses();
//     } else {
//       debugPrint('❌ Token not found!');
//     }
//   }

//   Future<void> _fetchClasses() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/classes'),
//         headers: {
//           'Authorization': 'Bearer $token', // ✅ FIXED - add Bearer
//         },
//       );

//       if (response.statusCode == 200) {
//         final List data = jsonDecode(response.body);
//         final uniqueClasses = <String, ClassModel>{};

//         for (var item in data) {
//           final id = item['id']?.toString() ?? item['_id']?.toString() ?? '';
//           final name = item['class_name']?.toString() ?? '';
//           if (!uniqueClasses.containsKey(name)) {
//             uniqueClasses[name] = ClassModel(id: id, name: name);
//           }
//         }

//         setState(() {
//           classes = uniqueClasses.values.toList();
//         });
//       } else {
//         debugPrint("❌ Error loading classes: ${response.body}");
//       }
//     } catch (e) {
//       debugPrint("❌ Error fetching classes: $e");
//     }
//   }

//   Future<void> _fetchFeeStructure(String classId) async {
//     setState(() {
//       isLoading = true;
//       feeStructure = [];
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/feestructure/$classId'),
//         headers: {
//           'Authorization': 'Bearer $token', // ✅ FIXED - add Bearer
//         },
//       );

//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         final List data = decoded['data'];

//         setState(() {
//           feeStructure =
//               data.map((item) => FeeStructureModel.fromJson(item)).toList();
//         });
//       } else {
//         debugPrint("❌ Failed to fetch fee structure: ${response.body}");
//       }
//     } catch (e) {
//       debugPrint("❌ Error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'View Fee Structure',
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: selectedClassId,
//               decoration: InputDecoration(
//                 labelText: "Select Class",
//                 border: OutlineInputBorder(),
//               ),
//               items: classes.map((c) {
//                 return DropdownMenuItem(
//                   value: c.id,
//                   child: Text(c.name),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedClassId = value!;
//                   _fetchFeeStructure(value);
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : feeStructure.isEmpty
//                     ? Text("No fee structure found.")
//                     : Expanded(
//                         child: ListView.builder(
//                           itemCount: feeStructure.length,
//                           itemBuilder: (context, index) {
//                             final item = feeStructure[index];
//                             return Card(
//                               margin: EdgeInsets.symmetric(vertical: 8),
//                               child: ListTile(
//                                 title: Text(item.feeFieldName),
//                                 subtitle: Text('Amount: ₹${item.amount}'),
//                                 trailing: Text(item.isCollectable
//                                     ? 'Collectable'
//                                     : 'Not Collectable'),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Model for Class
// class ClassModel {
//   final String id;
//   final String name;

//   ClassModel({required this.id, required this.name});
// }

// // Model for Fee Structure Entry
// class FeeStructureModel {
//   final String feeFieldName;
//   final String amount;
//   final bool isCollectable;

//   FeeStructureModel({
//     required this.feeFieldName,
//     required this.amount,
//     required this.isCollectable,
//   });

//   factory FeeStructureModel.fromJson(Map<String, dynamic> json) {
//     return FeeStructureModel(
//       feeFieldName: json['fee_field_name'] ?? 'Unknown Fee',
//       amount: json['amount']?.toString() ?? '0',
//       isCollectable: json['is_collectable'] ?? true,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/class_section_selector.dart';
import 'package:sms/widgets/custom_snackbar.dart';

class ViewFeeStructurePage extends StatefulWidget {
  const ViewFeeStructurePage({super.key});

  @override
  State<ViewFeeStructurePage> createState() => _ViewFeeStructurePageState();
}

class _ViewFeeStructurePageState extends State<ViewFeeStructurePage> {
  String? token;
  ClassModel? selectedClass;
  List<FeeStructureModel> feeStructure = [];
  bool isLoading = false;

  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    if (token == null) {
      showCustomSnackBar(context, 'Token not found, please login',
          backgroundColor: Colors.red);
    }
  }

  Future<void> _fetchFeeStructure(String classId) async {
    setState(() {
      isLoading = true;
      feeStructure = [];
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/feestructure/$classId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded is List ? decoded : decoded['data'] ?? [];

        setState(() {
          feeStructure =
              data.map((item) => FeeStructureModel.fromJson(item)).toList();
        });
      } else {
        showCustomSnackBar(
            context, 'Failed to fetch fee structure: ${response.reasonPhrase}',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      showCustomSnackBar(context, 'Error fetching fee structure: $e',
          backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'View Fee Structure',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClassSectionSelector(
              onSelectionChanged: (ClassModel? cls, String? sec) {
                setState(() {
                  selectedClass = cls;
                  if (cls != null) {
                    _fetchFeeStructure(cls.id.toString());
                  } else {
                    feeStructure = [];
                  }
                });
              },
              initialClass: selectedClass,
              showSectionDropdown: false,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : feeStructure.isEmpty
                    ? const Text("No fee structure found.")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: feeStructure.length,
                          itemBuilder: (context, index) {
                            final item = feeStructure[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(item.feeFieldName),
                                subtitle: Text('Amount: ₹${item.amount}'),
                                trailing: Text(item.isCollectable
                                    ? 'Collectable'
                                    : 'Not Collectable'),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

// Model for Fee Structure Entry
class FeeStructureModel {
  final String feeFieldName;
  final String amount;
  final bool isCollectable;

  FeeStructureModel({
    required this.feeFieldName,
    required this.amount,
    required this.isCollectable,
  });

  factory FeeStructureModel.fromJson(Map<String, dynamic> json) {
    return FeeStructureModel(
      feeFieldName: json['fee_field_name'] ?? 'Unknown Fee',
      amount: json['amount']?.toString() ?? '0',
      isCollectable: json['is_collectable'] ?? true,
    );
  }
}
