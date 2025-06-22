import 'package:flutter/material.dart';
import 'package:sms/pages/services/feemaster_service.dart';

class FeeMasterPage extends StatefulWidget {
  @override
  _FeeMasterPageState createState() => _FeeMasterPageState();
}

class _FeeMasterPageState extends State<FeeMasterPage> {
  final _formKey = GlobalKey<FormState>();
  List<FeeField> feeFields = [];

  @override
  void initState() {
    super.initState();
    _addFeeField(); // Start with one field
  }

  void _addFeeField() {
    setState(() {
      feeFields.add(FeeField());
    });
  }

  void _removeFeeField(int index) {
    if (feeFields.length > 1) {
      setState(() {
        feeFields.removeAt(index);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final List<Map<String, dynamic>> feeData = feeFields.map((field) {
        return {
          'fee_name': field.feeName.trim(),
          'is_one_time': field.isOneTime,
          'is_common_for_all_classes': field.isCommonForAllClasses,
          'amount': field.isCommonForAllClasses ? field.amount : null,
        };
      }).toList();

      final success = await FeeMasterService.submitFeeFields(feeData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? "Fees submitted successfully!" : "Submission failed!"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fee Master"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Define Fee Fields',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: feeFields.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Fee ${index + 1}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800]),
                                ),
                                Spacer(),
                                if (feeFields.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red[400]),
                                    onPressed: () => _removeFeeField(index),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Fee Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a fee name';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                feeFields[index].feeName = value;
                              },
                            ),
                            SizedBox(height: 10),
                            CheckboxListTile(
                              title: Text("Is One Time?"),
                              value: feeFields[index].isOneTime,
                              onChanged: (val) {
                                setState(() {
                                  feeFields[index].isOneTime = val ?? false;
                                });
                              },
                            ),
                            CheckboxListTile(
                              title: Text("Same for All Classes?"),
                              value: feeFields[index].isCommonForAllClasses,
                              onChanged: (val) {
                                setState(() {
                                  feeFields[index].isCommonForAllClasses =
                                      val ?? false;
                                });
                              },
                            ),
                            if (feeFields[index].isCommonForAllClasses)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Amount (Same for All Classes)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (value) {
                                  if (feeFields[index].isCommonForAllClasses &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Please enter the amount';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  feeFields[index].amount =
                                      double.tryParse(value) ?? 0.0;
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Fee Field'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  foregroundColor: Colors.blue[800],
                ),
                onPressed: _addFeeField,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Submit Fees'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeeField {
  String feeName = '';
  bool isOneTime = false;
  bool isCommonForAllClasses = false;
  double? amount; // Only used when isCommonForAllClasses is true
}
