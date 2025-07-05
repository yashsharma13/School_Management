// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:sms/pages/principle/principle_dashboard.dart';
// import 'package:sms/pages/services/fee_structure_service.dart';
// import 'package:sms/pages/services/feemaster_service.dart';
// import 'package:sms/widgets/button.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/widgets/custom_snackbar.dart';

// class FeeStructurePage extends StatefulWidget {
//   const FeeStructurePage({super.key});

//   @override
//   State<FeeStructurePage> createState() => _FeeStructurePageState();
// }

// class _FeeStructurePageState extends State<FeeStructurePage> {
//   String? token;
//   String? selectedClass;
//   String? selectedClassId;

//   List<Class> classes = [];
//   List<String> uniqueClassNames = [];
//   List<FeeField> feeFields = [];

//   bool isLoading = false;
//   static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token');
//     if (token != null) {
//       await _loadClasses();
//       await _loadFeeFields();
//     }
//   }

//   Future<void> _loadClasses() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/classes'),
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': token!,
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> classData = json.decode(response.body);

//         final allClasses = classData
//             .map((data) => Class(
//                   id: data['id']?.toString() ?? data['_id']?.toString() ?? '',
//                   className:
//                       data['class_name']?.toString().trim() ?? 'Unnamed Class',
//                 ))
//             .where((c) => c.id.isNotEmpty)
//             .toList();

//         // Filter unique class names
//         final seenNames = <String>{};
//         final uniqueList =
//             allClasses.where((c) => seenNames.add(c.className)).toList();

//         setState(() {
//           classes = allClasses;
//           uniqueClassNames = uniqueList.map((c) => c.className).toList();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading classes: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _loadFeeFields() async {
//     try {
//       final fetchedFields = await FeeMasterService.getFeeFields();

//       setState(() {
//         feeFields = fetchedFields.map((field) {
//           final amount = field['amount'] != null
//               ? double.tryParse(field['amount'].toString())
//               : null;
//           final isCommon = field['is_common_for_all_classes'] ?? false;

//           return FeeField(
//             label: field['fee_field_name'] ?? 'Unnamed Fee',
//             id: field['id']?.toString() ?? '0',
//             defaultAmount: amount,
//             isCommonForAll: isCommon,
//           );
//         }).toList();
//       });
//     } catch (e) {
//       debugPrint('Error loading fee fields: $e');
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       //   content: Text("Error loading fee fields: ${e.toString()}"),
//       //   backgroundColor: Colors.red,
//       // ));
//       showCustomSnackBar(context, "Error loading fee fields: ${e.toString()}",
//           backgroundColor: Colors.red);
//     }
//   }

//   void _saveFeeStructure() async {
//     if (selectedClassId == null) {
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       //   content: Text("Please select a class"),
//       //   backgroundColor: Colors.red,
//       // ));
//       showCustomSnackBar(context, "Please select a class",
//           backgroundColor: Colors.red);
//       return;
//     }

//     List<Map<String, dynamic>> feeStructure = [];

//     for (var field in feeFields) {
//       if (field.amountController.text.isEmpty) {
//         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         //   content: Text("Please enter amount for ${field.label}"),
//         //   backgroundColor: Colors.red,
//         // ));
//         showCustomSnackBar(context, "Please enter amount for ${field.label}",
//             backgroundColor: Colors.red);
//         return;
//       }

//       feeStructure.add({
//         'fee_master_id': int.parse(field.id),
//         'amount': double.parse(field.amountController.text),
//         'is_collectable': field.isCollectable,
//       });
//     }

//     setState(() => isLoading = true);
//     try {
//       final success = await FeeStructureService.submitFeeStructure(
//         classId: selectedClassId!,
//         structure: feeStructure,
//       );

//       if (success) {
//         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         //   content: Text("Fee Structure saved successfully"),
//         //   backgroundColor: Colors.green,
//         // ));
//         showCustomSnackBar(context, 'Fee Structure saved successfully',
//             backgroundColor: Colors.green);

//         Future.delayed(Duration(milliseconds: 500), () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PrincipleDashboard(),
//             ),
//           );
//         });
//       } else {
//         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         //   content: Text("Failed to save Fee Structure"),
//         //   backgroundColor: Colors.red,
//         // ));
//         showCustomSnackBar(context, "Failed to save Fee Structure",
//             backgroundColor: Colors.red);
//       }
//     } catch (e) {
//       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       //   content: Text("Error saving Fee Structure: ${e.toString()}"),
//       //   backgroundColor: Colors.red,
//       // ));
//       showCustomSnackBar(context, "Error saving Fee Structure: ${e.toString()}",
//           backgroundColor: Colors.red);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Fee Structure',
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: selectedClass,
//                     decoration: InputDecoration(
//                       labelText: 'Select Class',
//                       border: OutlineInputBorder(),
//                     ),
//                     items: uniqueClassNames.map((name) {
//                       return DropdownMenuItem(
//                         value: name,
//                         child: Text(name),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedClass = value;
//                         selectedClassId =
//                             classes.firstWhere((c) => c.className == value).id;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 20),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: feeFields.length,
//                       itemBuilder: (context, index) {
//                         final field = feeFields[index];
//                         return Card(
//                           elevation: 2,
//                           margin: EdgeInsets.symmetric(vertical: 8),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(field.label,
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold)),
//                                 SizedBox(height: 10),
//                                 TextField(
//                                   controller: field.amountController,
//                                   keyboardType: TextInputType.number,
//                                   readOnly: field.isCommonForAll &&
//                                       field.defaultAmount != null,
//                                   decoration: InputDecoration(
//                                     labelText: field.isCommonForAll
//                                         ? 'Fixed Amount (from Fee Master)'
//                                         : 'Amount',
//                                     border: OutlineInputBorder(),
//                                     suffixIcon: field.isCommonForAll
//                                         ? Icon(Icons.lock, color: Colors.grey)
//                                         : null,
//                                   ),
//                                 ),
//                                 if (!field.isCommonForAll)
//                                   CheckboxListTile(
//                                     title: Text('Not Collectable'),
//                                     value: !field.isCollectable,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         field.isCollectable = !value!;
//                                       });
//                                     },
//                                   ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: CustomButton(
//                       text: 'Save',
//                       icon: Icons.save_alt,
//                       onPressed: _saveFeeStructure,
//                       width: 130,
//                       height: 45,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// // Data Models
// class Class {
//   final String id;
//   final String className;

//   Class({
//     required this.id,
//     required this.className,
//   });
// }

// class FeeField {
//   final String label;
//   final String id;
//   final double? defaultAmount;
//   final bool isCommonForAll;
//   final TextEditingController amountController = TextEditingController();
//   bool isCollectable = true;

//   FeeField({
//     required this.label,
//     required this.id,
//     this.defaultAmount,
//     this.isCommonForAll = false,
//   }) {
//     if (defaultAmount != null) {
//       amountController.text = defaultAmount.toString();
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms/pages/principle/principle_dashboard.dart';
import 'package:sms/pages/services/fee_structure_service.dart';
import 'package:sms/pages/services/feemaster_service.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';
import 'package:sms/widgets/class_section_selector.dart';

class FeeStructurePage extends StatefulWidget {
  const FeeStructurePage({super.key});

  @override
  State<FeeStructurePage> createState() => _FeeStructurePageState();
}

class _FeeStructurePageState extends State<FeeStructurePage> {
  String? token;
  ClassModel? selectedClass;
  List<FeeField> feeFields = [];
  bool isLoading = false;
  // static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

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
      await _loadFeeFields();
    }
  }

  Future<void> _loadFeeFields() async {
    try {
      final fetchedFields = await FeeMasterService.getFeeFields();

      setState(() {
        feeFields = fetchedFields.map((field) {
          final amount = field['amount'] != null
              ? double.tryParse(field['amount'].toString())
              : null;
          final isCommon = field['is_common_for_all_classes'] ?? false;

          return FeeField(
            label: field['fee_field_name'] ?? 'Unnamed Fee',
            id: field['id']?.toString() ?? '0',
            defaultAmount: amount,
            isCommonForAll: isCommon,
          );
        }).toList();
      });
    } catch (e) {
      showCustomSnackBar(context, "Error loading fee fields: ${e.toString()}",
          backgroundColor: Colors.red);
    }
  }

  void _saveFeeStructure() async {
    if (selectedClass == null) {
      showCustomSnackBar(context, "Please select a class",
          backgroundColor: Colors.red);
      return;
    }

    List<Map<String, dynamic>> feeStructure = [];

    for (var field in feeFields) {
      if (field.amountController.text.isEmpty) {
        showCustomSnackBar(context, "Please enter amount for ${field.label}",
            backgroundColor: Colors.red);
        return;
      }

      feeStructure.add({
        'fee_master_id': int.parse(field.id),
        'amount': double.parse(field.amountController.text),
        'is_collectable': field.isCollectable,
      });
    }

    setState(() => isLoading = true);
    try {
      final success = await FeeStructureService.submitFeeStructure(
        classId: selectedClass!.id.toString(),
        structure: feeStructure,
      );

      if (success) {
        showCustomSnackBar(context, 'Fee Structure saved successfully',
            backgroundColor: Colors.green);

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PrincipleDashboard(),
            ),
          );
        });
      } else {
        showCustomSnackBar(context, "Failed to save Fee Structure",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      showCustomSnackBar(context, "Error saving Fee Structure: ${e.toString()}",
          backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fee Structure',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ClassSectionSelector(
                    onSelectionChanged: (ClassModel? cls, String? sec) {
                      setState(() {
                        selectedClass = cls;
                      });
                    },
                    initialClass: selectedClass,
                    // apiEndpoint: '$baseUrl/api/classes',
                    showSectionDropdown: false, // Hide section dropdown
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: feeFields.length,
                      itemBuilder: (context, index) {
                        final field = feeFields[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(field.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: field.amountController,
                                  keyboardType: TextInputType.number,
                                  readOnly: field.isCommonForAll &&
                                      field.defaultAmount != null,
                                  decoration: InputDecoration(
                                    labelText: field.isCommonForAll
                                        ? 'Fixed Amount (from Fee Master)'
                                        : 'Amount',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: field.isCommonForAll
                                        ? const Icon(Icons.lock,
                                            color: Colors.grey)
                                        : null,
                                  ),
                                ),
                                if (!field.isCommonForAll)
                                  CheckboxListTile(
                                    title: const Text('Not Collectable'),
                                    value: !field.isCollectable,
                                    onChanged: (value) {
                                      setState(() {
                                        field.isCollectable = !value!;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      text: 'Save',
                      icon: Icons.save_alt,
                      onPressed: _saveFeeStructure,
                      width: 130,
                      height: 45,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class FeeField {
  final String label;
  final String id;
  final double? defaultAmount;
  final bool isCommonForAll;
  final TextEditingController amountController = TextEditingController();
  bool isCollectable = true;

  FeeField({
    required this.label,
    required this.id,
    this.defaultAmount,
    this.isCommonForAll = false,
  }) {
    if (defaultAmount != null) {
      amountController.text = defaultAmount.toString();
    }
  }
}
