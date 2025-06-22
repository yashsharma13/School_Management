import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ViewFeeStructurePage extends StatefulWidget {
  const ViewFeeStructurePage({super.key});

  @override
  State<ViewFeeStructurePage> createState() => _ViewFeeStructurePageState();
}

class _ViewFeeStructurePageState extends State<ViewFeeStructurePage> {
  String? token;
  String? selectedClassId;
  List<ClassModel> classes = [];
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
    token = prefs.getString('token');
    if (token != null) {
      await _fetchClasses();
    } else {
      print('❌ Token not found!');
    }
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes'),
        headers: {
          'Authorization': 'Bearer $token', // ✅ FIXED - add Bearer
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final uniqueClasses = <String, ClassModel>{};

        for (var item in data) {
          final id = item['id']?.toString() ?? item['_id']?.toString() ?? '';
          final name = item['class_name']?.toString() ?? '';
          if (!uniqueClasses.containsKey(name)) {
            uniqueClasses[name] = ClassModel(id: id, name: name);
          }
        }

        setState(() {
          classes = uniqueClasses.values.toList();
        });
      } else {
        print("❌ Error loading classes: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching classes: $e");
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
          'Authorization': 'Bearer $token', // ✅ FIXED - add Bearer
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'];

        setState(() {
          feeStructure =
              data.map((item) => FeeStructureModel.fromJson(item)).toList();
        });
      } else {
        print("❌ Failed to fetch fee structure: ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Fee Structure'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedClassId,
              decoration: InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(),
              ),
              items: classes.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value!;
                  _fetchFeeStructure(value);
                });
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : feeStructure.isEmpty
                    ? Text("No fee structure found.")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: feeStructure.length,
                          itemBuilder: (context, index) {
                            final item = feeStructure[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
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

// Model for Class
class ClassModel {
  final String id;
  final String name;

  ClassModel({required this.id, required this.name});
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
