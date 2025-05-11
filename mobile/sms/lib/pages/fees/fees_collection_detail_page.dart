import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FeesCollectionPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentClass;
  final String monthlyFee;
  final bool isNewAdmission;

  const FeesCollectionPage({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.monthlyFee,
    this.isNewAdmission = true,
  }) : super(key: key);

  @override
  _FeesCollectionPageState createState() => _FeesCollectionPageState();
}

class _FeesCollectionPageState extends State<FeesCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  String? token;
  DateTime selectedDate = DateTime.now();
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  bool isLoading = false;
  bool isMonthlyFeePaidForSelectedMonth = false;

  // Previous balance and payment history
  double previousBalance = 0.0;
  String? lastPaymentMonth;

  // Fee suggestions
  static const double admissionFee = 500.0;
  static const double registrationFee = 500.0;
  static const double uniformFee = 1000.0;

  // Fee controllers
  final TextEditingController monthlyFeeController = TextEditingController();
  final TextEditingController admissionFeeController = TextEditingController();
  final TextEditingController registrationFeeController =
      TextEditingController();
  final TextEditingController artMaterialController = TextEditingController();
  final TextEditingController transportController = TextEditingController();
  final TextEditingController booksController = TextEditingController();
  final TextEditingController uniformController = TextEditingController();
  final TextEditingController fineController = TextEditingController();
  final TextEditingController othersController = TextEditingController();
  final TextEditingController previousBalanceController =
      TextEditingController();
  final TextEditingController totalDepositController = TextEditingController();
  final TextEditingController depositController = TextEditingController();
  final TextEditingController dueBalanceController = TextEditingController();

  // Fee enablers
  bool canCollectAdmissionFee = true;
  bool canCollectRegistrationFee = true;
  bool canCollectUniformFee = true;

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadToken();
    _initializeControllers();
    _loadFeeDetails();
  }

  void _initializeControllers() {
    monthlyFeeController.text = widget.monthlyFee;
    admissionFeeController.text = '0';
    registrationFeeController.text = '0';
    artMaterialController.text = '0';
    transportController.text = '0';
    booksController.text = '0';
    uniformController.text = '0';
    fineController.text = '0';
    othersController.text = '0';
    previousBalanceController.text = '0';
    depositController.text = '0';

    [
      monthlyFeeController,
      admissionFeeController,
      registrationFeeController,
      artMaterialController,
      transportController,
      booksController,
      uniformController,
      fineController,
      othersController,
      previousBalanceController,
      depositController,
    ].forEach((controller) {
      controller.addListener(_calculateTotals);
    });
  }

  @override
  void dispose() {
    monthlyFeeController.dispose();
    admissionFeeController.dispose();
    registrationFeeController.dispose();
    artMaterialController.dispose();
    transportController.dispose();
    booksController.dispose();
    uniformController.dispose();
    fineController.dispose();
    othersController.dispose();
    previousBalanceController.dispose();
    totalDepositController.dispose();
    depositController.dispose();
    dueBalanceController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> _loadFeeDetails() async {
    if (token == null) {
      _showErrorSnackBar('Authentication required');
      return;
    }

    setState(() => isLoading = true);

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse(
              'http://localhost:1000/api/eligibility/${widget.studentId}'),
          headers: {'Authorization': token!},
        ),
        http.get(
          Uri.parse('http://localhost:1000/api/summary/${widget.studentId}'),
          headers: {'Authorization': token!},
        ),
        http.get(
          Uri.parse(
              'http://localhost:1000/api/previous-payments/${widget.studentId}/$selectedMonth'),
          headers: {'Authorization': token!},
        ),
      ]);

      for (final response in responses) {
        if (response.statusCode != 200) {
          throw Exception('Failed to load fee details: ${response.statusCode}');
        }
      }

      final eligibilityData = jsonDecode(responses[0].body);
      final summaryData = jsonDecode(responses[1].body);
      final previousPaymentsData = jsonDecode(responses[2].body);

      if (eligibilityData['success'] != true ||
          summaryData['success'] != true ||
          previousPaymentsData['success'] != true) {
        throw Exception('Invalid API response format');
      }

      final previousPayments = previousPaymentsData['data'] as List;
      final hasMonthlyFeePaymentForThisMonth = previousPayments.any((payment) =>
          payment['fee_month'] == selectedMonth && payment['monthly_fee'] > 0);

      setState(() {
        canCollectAdmissionFee =
            eligibilityData['data']['canCollectAdmissionFee'] ?? false;
        canCollectRegistrationFee =
            eligibilityData['data']['canCollectRegistrationFee'] ?? false;
        canCollectUniformFee =
            eligibilityData['data']['canCollectUniformFee'] ?? false;

        if (canCollectAdmissionFee) {
          admissionFeeController.text = admissionFee.toStringAsFixed(2);
        } else {
          admissionFeeController.text = '0';
        }

        if (canCollectRegistrationFee) {
          registrationFeeController.text = registrationFee.toStringAsFixed(2);
        } else {
          registrationFeeController.text = '0';
        }

        if (canCollectUniformFee) {
          uniformController.text = uniformFee.toStringAsFixed(2);
        } else {
          uniformController.text = '0';
        }

        previousBalance =
            (summaryData['data']['last_due_balance'] ?? 0).toDouble();
        previousBalanceController.text = previousBalance.toStringAsFixed(2);

        isMonthlyFeePaidForSelectedMonth = hasMonthlyFeePaymentForThisMonth;

        if (isMonthlyFeePaidForSelectedMonth) {
          monthlyFeeController.text = '0';
          _showInfoSnackBar(
              'Monthly Fee Of This Student is Already Added for This Month! So System will Not Add it Again.');
        } else {
          monthlyFeeController.text = widget.monthlyFee;
        }

        lastPaymentMonth = summaryData['data']['last_payment_month'];
      });

      _calculateTotals();
    } on http.ClientException catch (error) {
      _showErrorSnackBar('Network error: ${error.message}');
    } on FormatException catch (_) {
      _showErrorSnackBar('Invalid data format from server');
    } catch (error) {
      _showErrorSnackBar('Error loading fee details: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _calculateTotals() {
    double total = 0;

    total += double.tryParse(monthlyFeeController.text) ?? 0;
    total += double.tryParse(admissionFeeController.text) ?? 0;
    total += double.tryParse(registrationFeeController.text) ?? 0;
    total += double.tryParse(artMaterialController.text) ?? 0;
    total += double.tryParse(transportController.text) ?? 0;
    total += double.tryParse(booksController.text) ?? 0;
    total += double.tryParse(uniformController.text) ?? 0;
    total += double.tryParse(fineController.text) ?? 0;
    total += double.tryParse(othersController.text) ?? 0;
    total += double.tryParse(previousBalanceController.text) ?? 0;

    double deposit = double.tryParse(depositController.text) ?? 0;
    double dueBalance = total - deposit;

    setState(() {
      totalDepositController.text = total.toStringAsFixed(2);
      dueBalanceController.text = dueBalance.toStringAsFixed(2);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitFees() async {
    if (!_formKey.currentState!.validate()) return;
    if (token == null) {
      _showErrorSnackBar('Authentication required');
      return;
    }

    if (isMonthlyFeePaidForSelectedMonth &&
        (double.tryParse(monthlyFeeController.text) ?? 0) > 0) {
      _showErrorSnackBar(
          'Monthly Fee Of This Student is Already Added for This Month! System will Not Add it Again.');
      monthlyFeeController.text = '0';
      _calculateTotals();
      return;
    }

    setState(() => isLoading = true);

    try {
      final feeData = {
        'student_id': int.parse(widget.studentId),
        'student_name': widget.studentName,
        'class_name': widget.studentClass,
        'fee_month': selectedMonth,
        'payment_date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'monthly_fee': double.tryParse(monthlyFeeController.text) ?? 0,
        'admission_fee': double.tryParse(admissionFeeController.text) ?? 0,
        'registration_fee':
            double.tryParse(registrationFeeController.text) ?? 0,
        'art_material': double.tryParse(artMaterialController.text) ?? 0,
        'transport': double.tryParse(transportController.text) ?? 0,
        'books': double.tryParse(booksController.text) ?? 0,
        'uniform': double.tryParse(uniformController.text) ?? 0,
        'fine': double.tryParse(fineController.text) ?? 0,
        'others': double.tryParse(othersController.text) ?? 0,
        'previous_balance':
            double.tryParse(previousBalanceController.text) ?? 0,
        'deposit': double.tryParse(depositController.text) ?? 0,
        'is_new_admission': widget.isNewAdmission,
      };

      final response = await http.post(
        Uri.parse('http://localhost:1000/api/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
        body: jsonEncode(feeData),
      );

      if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        _showErrorSnackBar(errorData['message']);
        return;
      } else if (response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to record fee payment');
      }

      _showSuccessSnackBar('Fee payment recorded successfully');
      Navigator.pop(context, true);
    } on http.ClientException catch (error) {
      _showErrorSnackBar('Network error: ${error.message}');
    } on FormatException catch (_) {
      _showErrorSnackBar('Invalid server response format');
    } catch (error) {
      _showErrorSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blueTheme = Colors.blue.shade900;
    final whiteTheme = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fees Collection - ${widget.studentName}',
          style: TextStyle(color: whiteTheme),
        ),
        backgroundColor: blueTheme,
        iconTheme: IconThemeData(color: whiteTheme),
        elevation: 4,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: blueTheme))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Info Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [blueTheme, Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, color: whiteTheme),
                                  SizedBox(width: 8),
                                  Text(
                                    'Student: ${widget.studentName}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: whiteTheme,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.school, color: whiteTheme),
                                  SizedBox(width: 8),
                                  Text(
                                    'Class: ${widget.studentClass}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: whiteTheme,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(color: whiteTheme.withOpacity(0.5)),
                              SizedBox(height: 16),

                              // Month and Date Selectors
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: whiteTheme.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Fee Month*',
                                            labelStyle:
                                                TextStyle(color: whiteTheme),
                                            border: InputBorder.none,
                                          ),
                                          dropdownColor: blueTheme,
                                          style: TextStyle(color: whiteTheme),
                                          icon: Icon(Icons.arrow_drop_down,
                                              color: whiteTheme),
                                          value: selectedMonth,
                                          items: months.map((String month) {
                                            return DropdownMenuItem<String>(
                                              value: month,
                                              child: Text(month),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedMonth = value!;
                                              _loadFeeDetails();
                                            });
                                          },
                                          validator: (value) => value == null
                                              ? 'Please select month'
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: whiteTheme.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 16),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 20, color: whiteTheme),
                                            SizedBox(width: 12),
                                            Text(
                                              DateFormat('dd/MM/yyyy')
                                                  .format(selectedDate),
                                              style:
                                                  TextStyle(color: whiteTheme),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Fee Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: blueTheme,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Fee Details Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Monthly Fee
                            _buildFeeTextField(
                              controller: monthlyFeeController,
                              label: 'Monthly Fee',
                              icon: Icons.money,
                              enabled: !isMonthlyFeePaidForSelectedMonth,
                              isRequired: true,
                            ),
                            SizedBox(height: 16),

                            // One-time fees row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: admissionFeeController,
                                    label: 'Admission Fee',
                                    icon: Icons.school,
                                    enabled: canCollectAdmissionFee,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: registrationFeeController,
                                    label: 'Registration Fee',
                                    icon: Icons.app_registration,
                                    enabled: canCollectRegistrationFee,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Additional fees row 1
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: artMaterialController,
                                    label: 'Art Material',
                                    icon: Icons.color_lens,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: transportController,
                                    label: 'Transport',
                                    icon: Icons.directions_bus,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Additional fees row 2
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: booksController,
                                    label: 'Books',
                                    icon: Icons.book,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: uniformController,
                                    label: 'Uniform',
                                    icon: Icons.person_outline,
                                    enabled: canCollectUniformFee,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Additional fees row 3
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: fineController,
                                    label: 'Fine',
                                    icon: Icons.error_outline,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildFeeTextField(
                                    controller: othersController,
                                    label: 'Others',
                                    icon: Icons.more_horiz,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Payment Summary',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: blueTheme,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Payment Summary Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryField(
                              controller: previousBalanceController,
                              label: 'Previous Balance',
                              icon: Icons.history,
                              isEditable: false,
                            ),
                            SizedBox(height: 16),
                            _buildSummaryField(
                              controller: totalDepositController,
                              label: 'Total Amount',
                              icon: Icons.account_balance_wallet,
                              isEditable: false,
                            ),
                            SizedBox(height: 16),
                            _buildSummaryField(
                              controller: depositController,
                              label: 'Deposit Amount*',
                              icon: Icons.payments,
                              isEditable: true,
                              isRequired: true,
                            ),
                            SizedBox(height: 16),
                            _buildSummaryField(
                              controller: dueBalanceController,
                              label: 'Due Balance',
                              icon: Icons.account_balance,
                              isEditable: false,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 32),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitFees,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueTheme,
                          foregroundColor: whiteTheme,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Submit Fee Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeeTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        labelStyle: TextStyle(color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
      keyboardType: TextInputType.number,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildSummaryField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isEditable,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: isEditable,
      decoration: InputDecoration(
        labelText: label + (isRequired ? '*' : ''),
        labelStyle: TextStyle(
          color: isEditable ? Colors.blue.shade800 : Colors.grey.shade700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
        prefixIcon: Icon(
          icon,
          color: isEditable ? Colors.blue.shade600 : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isEditable ? Colors.white : Colors.grey.shade100,
      ),
      style: TextStyle(
        color: isEditable ? Colors.black : Colors.grey.shade700,
        fontWeight: isEditable ? FontWeight.normal : FontWeight.bold,
      ),
      keyboardType: TextInputType.number,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              double? deposit = double.tryParse(value);
              double total = double.tryParse(totalDepositController.text) ?? 0;
              if (deposit != null && deposit > total) {
                return 'Deposit cannot be greater than total amount';
              }
              return null;
            }
          : null,
    );
  }
}
