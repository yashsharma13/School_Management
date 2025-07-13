import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/report_service.dart';
import 'package:sms/widgets/custom_snackbar.dart';

class ClassSectionSelector extends StatefulWidget {
  final Function(ClassModel?, String?) onSelectionChanged;
  final ClassModel? initialClass;
  final String? initialSection;
  final bool showSectionDropdown;

  const ClassSectionSelector({
    super.key,
    required this.onSelectionChanged,
    this.initialClass,
    this.initialSection,
    this.showSectionDropdown = true, // default is true
  });

  @override
  State<ClassSectionSelector> createState() => _ClassSectionSelectorState();
}

class _ClassSectionSelectorState extends State<ClassSectionSelector> {
  List<ClassModel> classes = [];
  ClassModel? selectedClass;
  String? selectedSection;
  List<String> availableSections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.initialClass;
    selectedSection = widget.initialSection;
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showError('No token, please login.');
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ReportService.baseUrl}/api/classes'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final List<dynamic> classData =
            data is List ? data : data['data'] ?? [];
        final Map<String, ClassModel> map = {};

        for (var item in classData) {
          final name = (item['class_name'] ?? '').toString().trim();
          final section = (item['section'] ?? '').toString().trim();
          final id = int.tryParse(
                  (item['class_id'] ?? item['id'] ?? '0').toString()) ??
              0;

          if (name.isEmpty || id == 0) continue;

          if (!map.containsKey(name)) {
            map[name] = ClassModel(id: id, className: name, sections: []);
          }

          if (section.isNotEmpty && !map[name]!.sections.contains(section)) {
            map[name]!.sections.add(section);
          }
        }

        setState(() {
          classes = map.values.toList();
          if (selectedClass != null) {
            selectedClass = classes.firstWhere(
              (c) =>
                  c.id == selectedClass!.id &&
                  c.className == selectedClass!.className,
              orElse: () => selectedClass!,
            );
            availableSections = selectedClass?.sections ?? [];
            if (selectedSection != null &&
                !availableSections.contains(selectedSection)) {
              selectedSection = null;
            }
          }
          isLoading = false;
        });

        widget.onSelectionChanged(selectedClass, selectedSection);
      } else {
        _showError('Failed to fetch classes: ${response.reasonPhrase}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showError('Error fetching classes: $e');
      setState(() => isLoading = false);
    }
  }
  // Future<void> _loadClasses() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   if (token == null) {
  //     _showError('No token, please login.');
  //     setState(() => isLoading = false);
  //     return;
  //   }

  //   try {
  //     final response = await http.get(
  //       Uri.parse('${ReportService.baseUrl}/api/classes'),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final dynamic data = json.decode(response.body);
  //       final List<dynamic> classData =
  //           data is List ? data : data['data'] ?? [];
  //       final Map<String, ClassModel> map = {};

  //       for (var item in classData) {
  //         final rawName = (item['class_name'] ?? '').toString().trim();
  //         final section = (item['section'] ?? '').toString().trim();
  //         final id = int.tryParse(
  //                 (item['class_id'] ?? item['id'] ?? '0').toString()) ??
  //             0;

  //         if (rawName.isEmpty || id == 0) continue;

  //         final name = normalizeClassName(rawName);

  //         if (!map.containsKey(name)) {
  //           map[name] = ClassModel(id: id, className: name, sections: []);
  //         }

  //         if (section.isNotEmpty && !map[name]!.sections.contains(section)) {
  //           map[name]!.sections.add(section);
  //         }
  //       }

  //       // Sort classes in custom order
  //       final List<String> classOrder = [
  //         'Nursery',
  //         'LKG',
  //         'UKG',
  //         'Class 1',
  //         'Class 2',
  //         'Class 3',
  //         'Class 4',
  //         'Class 5',
  //         'Class 6',
  //         'Class 7',
  //         'Class 8',
  //         'Class 9',
  //         'Class 10',
  //         'Class 11',
  //         'Class 12',
  //       ];

  //       List<ClassModel> sortedClasses = map.values.toList();
  //       sortedClasses.sort((a, b) {
  //         final indexA = classOrder.indexOf(a.className);
  //         final indexB = classOrder.indexOf(b.className);

  //         if (indexA == -1 && indexB == -1)
  //           return a.className.compareTo(b.className);
  //         if (indexA == -1) return 1;
  //         if (indexB == -1) return -1;

  //         return indexA.compareTo(indexB);
  //       });

  //       setState(() {
  //         classes = sortedClasses;
  //         if (selectedClass != null) {
  //           selectedClass = classes.firstWhere(
  //             (c) =>
  //                 c.id == selectedClass!.id &&
  //                 c.className == selectedClass!.className,
  //             orElse: () => selectedClass!,
  //           );
  //           availableSections = selectedClass?.sections ?? [];
  //           if (selectedSection != null &&
  //               !availableSections.contains(selectedSection)) {
  //             selectedSection = null;
  //           }
  //         }
  //         isLoading = false;
  //       });

  //       widget.onSelectionChanged(selectedClass, selectedSection);
  //     } else {
  //       _showError('Failed to fetch classes: ${response.reasonPhrase}');
  //       setState(() => isLoading = false);
  //     }
  //   } catch (e) {
  //     _showError('Error fetching classes: $e');
  //     setState(() => isLoading = false);
  //   }
  // }

  // String normalizeClassName(String name) {
  //   final lower = name.toLowerCase();

  //   if (lower == 'nursery' || lower == 'n') return 'Nursery';
  //   if (lower == 'lkg') return 'LKG';
  //   if (lower == 'ukg') return 'UKG';

  //   final numVal = int.tryParse(name);
  //   if (numVal != null) {
  //     return 'Class $numVal';
  //   }

  //   return name[0].toUpperCase() + name.substring(1);
  // }

  void _showError(String msg) {
    if (mounted) {
      showCustomSnackBar(context, msg, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        DropdownButtonFormField<ClassModel>(
          decoration: _dropdownDecoration('Select Class'),
          value: selectedClass,
          onChanged: classes.isEmpty
              ? null
              : (ClassModel? value) {
                  setState(() {
                    selectedClass = value;
                    selectedSection = null;
                    availableSections = value?.sections ?? [];
                    widget.onSelectionChanged(selectedClass, selectedSection);
                  });
                },
          items: classes.map((cls) {
            return DropdownMenuItem(
              value: cls,
              child: Text(cls.className),
            );
          }).toList(),
          validator: (value) => value == null ? 'Please select a class' : null,
        ),
        const SizedBox(height: 12),
        if (widget.showSectionDropdown &&
            selectedClass != null &&
            availableSections.isNotEmpty)
          DropdownButtonFormField<String>(
            decoration: _dropdownDecoration('Select Section'),
            value: selectedSection,
            onChanged: (String? value) {
              setState(() {
                selectedSection = value;
                widget.onSelectionChanged(selectedClass, selectedSection);
              });
            },
            items: availableSections.map((sec) {
              return DropdownMenuItem(
                value: sec,
                child: Text(sec),
              );
            }).toList(),
            validator: (value) =>
                value == null ? 'Please select a section' : null,
          ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.deepPurple[50],
    );
  }
}

class ClassModel {
  final int id;
  final String className;
  final List<String> sections;

  ClassModel({
    required this.id,
    required this.className,
    required this.sections,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          className == other.className;

  @override
  int get hashCode => id.hashCode ^ className.hashCode;
}
