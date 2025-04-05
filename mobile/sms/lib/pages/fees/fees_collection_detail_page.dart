// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/services/api_service.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class FeesCollectionPage extends StatefulWidget {
//   final String studentId;
//   final String studentName;
//   final String className;
//   final String monthlyFee;
//   final bool isNewAdmission;

//   const FeesCollectionPage({
//     Key? key,
//     required this.studentId,
//     required this.studentName,
//     required this.className,
//     required this.monthlyFee,
//     this.isNewAdmission = false,
//   }) : super(key: key);

//   @override
//   _FeesCollectionPageState createState() => _FeesCollectionPageState();
// }

// class _FeesCollectionPageState extends State<FeesCollectionPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? token;
//   DateTime selectedDate = DateTime.now();
//   String selectedMonth = DateFormat('MMMM').format(DateTime.now());
//   bool isLoading = false;

//   // Previous balance
//   double previousBalance = 0.0;

//   // Fee controllers
//   final TextEditingController monthlyFeeController = TextEditingController();
//   final TextEditingController admissionFeeController = TextEditingController();
//   final TextEditingController registrationFeeController =
//       TextEditingController();
//   final TextEditingController artMaterialController = TextEditingController();
//   final TextEditingController transportController = TextEditingController();
//   final TextEditingController booksController = TextEditingController();
//   final TextEditingController uniformController = TextEditingController();
//   final TextEditingController fineController = TextEditingController();
//   final TextEditingController othersController = TextEditingController();
//   final TextEditingController previousBalanceController =
//       TextEditingController();
//   final TextEditingController totalDepositController = TextEditingController();
//   final TextEditingController dueBalanceController = TextEditingController();

//   // Fee enablers - to control which fees can be collected
//   bool canCollectAdmissionFee = true;
//   bool canCollectRegistrationFee = true;
//   bool canCollectUniformFee = true;

//   List<String> months = [
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//     _loadFeeDetails();

//     // Set monthly fee from class data
//     monthlyFeeController.text = widget.monthlyFee;

//     // Set default values
//     admissionFeeController.text = '0';
//     registrationFeeController.text = '0';
//     artMaterialController.text = '0';
//     transportController.text = '0';
//     booksController.text = '0';
//     uniformController.text = '0';
//     fineController.text = '0';
//     othersController.text = '0';

//     // Calculate totals whenever text changes
//     [
//       monthlyFeeController,
//       admissionFeeController,
//       registrationFeeController,
//       artMaterialController,
//       transportController,
//       booksController,
//       uniformController,
//       fineController,
//       othersController,
//       previousBalanceController
//     ].forEach((controller) {
//       controller.addListener(_calculateTotals);
//     });
//   }

//   @override
//   void dispose() {
//     // Dispose all controllers
//     monthlyFeeController.dispose();
//     admissionFeeController.dispose();
//     registrationFeeController.dispose();
//     artMaterialController.dispose();
//     transportController.dispose();
//     booksController.dispose();
//     uniformController.dispose();
//     fineController.dispose();
//     othersController.dispose();
//     previousBalanceController.dispose();
//     totalDepositController.dispose();
//     dueBalanceController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }

//   Future<void> _loadFeeDetails() async {
//     setState(() => isLoading = true);

//     // try {
//     //   // Check if student has paid admission, registration or uniform fee before
//     //   final response =
//     //       await ApiService.checkStudentFeeHistory(widget.studentId);

//     //   if (response != null) {
//     //     // Check if student has already paid one-time fees
//     //     setState(() {
//     //       canCollectAdmissionFee = !response['has_paid_admission_fee'] ?? true;
//     //       canCollectRegistrationFee =
//     //           !response['has_paid_registration_fee'] ?? true;
//     //       canCollectUniformFee = !response['has_paid_uniform_fee'] ?? true;
//     //       previousBalance = response['previous_balance']?.toDouble() ?? 0.0;
//     //       previousBalanceController.text = previousBalance.toString();
//     //     });
//     //   }

//     //   // If new admission, enable all fees
//     //   if (widget.isNewAdmission) {
//     //     setState(() {
//     //       canCollectAdmissionFee = true;
//     //       canCollectRegistrationFee = true;
//     //       canCollectUniformFee = true;
//     //     });
//     //   }

//     //   _calculateTotals();
//     // } catch (error) {
//     //   _showErrorSnackBar('Failed to load fee details: $error');
//     // } finally {
//     //   setState(() => isLoading = false);
//     // }
//   }

//   void _calculateTotals() {
//     double total = 0;

//     // Add all fees
//     total += double.tryParse(monthlyFeeController.text) ?? 0;
//     total += double.tryParse(admissionFeeController.text) ?? 0;
//     total += double.tryParse(registrationFeeController.text) ?? 0;
//     total += double.tryParse(artMaterialController.text) ?? 0;
//     total += double.tryParse(transportController.text) ?? 0;
//     total += double.tryParse(booksController.text) ?? 0;
//     total += double.tryParse(uniformController.text) ?? 0;
//     total += double.tryParse(fineController.text) ?? 0;
//     total += double.tryParse(othersController.text) ?? 0;

//     // Previous balance
//     double prevBalance = double.tryParse(previousBalanceController.text) ?? 0;

//     // Calculate due balance (previous balance - total paid)
//     double dueBalance = prevBalance - total;

//     setState(() {
//       totalDepositController.text = total.toString();
//       dueBalanceController.text = dueBalance.toString();
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _submitFees() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final feeData = {
//         'student_id': widget.studentId,
//         'student_name': widget.studentName,
//         'class_name': widget.className,
//         'fee_month': selectedMonth,
//         'payment_date': DateFormat('yyyy-MM-dd').format(selectedDate),
//         'fees': {
//           'monthly_fee': double.tryParse(monthlyFeeController.text) ?? 0,
//           'admission_fee': double.tryParse(admissionFeeController.text) ?? 0,
//           'registration_fee':
//               double.tryParse(registrationFeeController.text) ?? 0,
//           'art_material': double.tryParse(artMaterialController.text) ?? 0,
//           'transport': double.tryParse(transportController.text) ?? 0,
//           'books': double.tryParse(booksController.text) ?? 0,
//           'uniform': double.tryParse(uniformController.text) ?? 0,
//           'fine': double.tryParse(fineController.text) ?? 0,
//           'others': double.tryParse(othersController.text) ?? 0,
//         },
//         'previous_balance':
//             double.tryParse(previousBalanceController.text) ?? 0,
//         'total_amount': double.tryParse(totalDepositController.text) ?? 0,
//         'due_balance': double.tryParse(dueBalanceController.text) ?? 0,
//       };

//       // final success = await ApiService.submitFeePayment(feeData);

//       // if (success) {
//       //   _showSuccessSnackBar('Fee payment recorded successfully');
//       //   Navigator.pop(context, true);
//       // } else {
//       //   _showErrorSnackBar('Failed to record fee payment');
//       // }
//     } catch (error) {
//       _showErrorSnackBar('Error submitting fees: $error');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fees Collection - ${widget.studentName}'),
//         backgroundColor: Colors.blue.shade900,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header area
//                     Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Student: ${widget.studentName}',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 8),
//                             Text('Class: ${widget.className}'),
//                             Divider(),

//                             // Month and Date Selectors
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: DropdownButtonFormField<String>(
//                                     decoration: InputDecoration(
//                                       labelText: 'Fee Month*',
//                                       border: OutlineInputBorder(),
//                                     ),
//                                     value: selectedMonth,
//                                     items: months.map((String month) {
//                                       return DropdownMenuItem<String>(
//                                         value: month,
//                                         child: Text(month),
//                                       );
//                                     }).toList(),
//                                     onChanged: (value) {
//                                       setState(() {
//                                         selectedMonth = value!;
//                                       });
//                                     },
//                                     validator: (value) => value == null
//                                         ? 'Please select month'
//                                         : null,
//                                   ),
//                                 ),
//                                 SizedBox(width: 16),
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () => _selectDate(context),
//                                     child: InputDecorator(
//                                       decoration: InputDecoration(
//                                         labelText: 'Date*',
//                                         border: OutlineInputBorder(),
//                                       ),
//                                       child: Text(
//                                         DateFormat('dd/MM/yyyy')
//                                             .format(selectedDate),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 20),
//                     Text(
//                       'Fee Details',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Divider(),

//                     // Fee Items Table
//                     Table(
//                       border: TableBorder.all(),
//                       columnWidths: {
//                         0: FlexColumnWidth(1),
//                         1: FlexColumnWidth(3),
//                         2: FlexColumnWidth(2),
//                       },
//                       children: [
//                         TableRow(
//                           decoration:
//                               BoxDecoration(color: Colors.grey.shade200),
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('Sr.',
//                                   style:
//                                       TextStyle(fontWeight: FontWeight.bold)),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('Particulars',
//                                   style:
//                                       TextStyle(fontWeight: FontWeight.bold)),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('Amount',
//                                   style:
//                                       TextStyle(fontWeight: FontWeight.bold)),
//                             ),
//                           ],
//                         ),

//                         // Monthly Fee
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('1'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('MONTHLY FEE'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: monthlyFeeController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Admission Fee
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('2'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('ADMISSION FEE'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: admissionFeeController,
//                                 keyboardType: TextInputType.number,
//                                 enabled: canCollectAdmissionFee,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                   hintText: canCollectAdmissionFee
//                                       ? null
//                                       : 'Already Paid',
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Registration Fee
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('3'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('REGISTRATION FEE'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: registrationFeeController,
//                                 keyboardType: TextInputType.number,
//                                 enabled: canCollectRegistrationFee,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                   hintText: canCollectRegistrationFee
//                                       ? null
//                                       : 'Already Paid',
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Art Material
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('4'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('ART MATERIAL'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: artMaterialController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Transport
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('5'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('TRANSPORT'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: transportController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Books
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('6'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('BOOKS'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: booksController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Uniform
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('7'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('UNIFORM'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: uniformController,
//                                 keyboardType: TextInputType.number,
//                                 enabled: canCollectUniformFee,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                   hintText: canCollectUniformFee
//                                       ? null
//                                       : 'Already Paid',
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Fine
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('8'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('FINE'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: fineController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // Others
//                         TableRow(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('9'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text('OTHERS'),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 controller: othersController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   contentPadding:
//                                       EdgeInsets.symmetric(vertical: 8.0),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 24),

//                     // Summary Section
//                     Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Payment Summary',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 16),

//                             // Previous Balance
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text('Previous Balance:'),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: TextFormField(
//                                     controller: previousBalanceController,
//                                     keyboardType: TextInputType.number,
//                                     decoration: InputDecoration(
//                                       isDense: true,
//                                       border: OutlineInputBorder(),
//                                       contentPadding: EdgeInsets.symmetric(
//                                           horizontal: 8, vertical: 8),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 8),

//                             // Total Deposit
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text('Total Deposit:'),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: TextFormField(
//                                     controller: totalDepositController,
//                                     readOnly: true,
//                                     decoration: InputDecoration(
//                                       isDense: true,
//                                       border: OutlineInputBorder(),
//                                       contentPadding: EdgeInsets.symmetric(
//                                           horizontal: 8, vertical: 8),
//                                       fillColor: Colors.grey.shade200,
//                                       filled: true,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 8),

//                             // Due Balance
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text(
//                                     'Due Balance:',
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: TextFormField(
//                                     controller: dueBalanceController,
//                                     readOnly: true,
//                                     decoration: InputDecoration(
//                                       isDense: true,
//                                       border: OutlineInputBorder(),
//                                       contentPadding: EdgeInsets.symmetric(
//                                           horizontal: 8, vertical: 8),
//                                       fillColor: Colors.grey.shade200,
//                                       filled: true,
//                                     ),
//                                     style: TextStyle(
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 24),

//                     // Submit Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 48,
//                       child: ElevatedButton(
//                         onPressed: _submitFees,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue.shade800,
//                         ),
//                         child: Text(
//                           'SUBMIT FEE PAYMENT',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';

// class FeesCollectionPage extends StatefulWidget {
//   final String studentId;
//   final String studentName;
//   final String studentClass;
//   final String monthlyFee;
//   final bool isNewAdmission;

//   const FeesCollectionPage({
//     Key? key,
//     required this.studentId,
//     required this.studentName,
//     required this.studentClass,
//     required this.monthlyFee,
//     this.isNewAdmission = true,
//   }) : super(key: key);

//   @override
//   _FeesCollectionPageState createState() => _FeesCollectionPageState();
// }

// class _FeesCollectionPageState extends State<FeesCollectionPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? token;
//   DateTime selectedDate = DateTime.now();
//   String selectedMonth = DateFormat('MMMM').format(DateTime.now());
//   bool isLoading = false;

//   // Previous balance
//   double previousBalance = 0.0;

//   // Fee controllers
//   final TextEditingController monthlyFeeController = TextEditingController();
//   final TextEditingController admissionFeeController = TextEditingController();
//   final TextEditingController registrationFeeController =
//       TextEditingController();
//   final TextEditingController artMaterialController = TextEditingController();
//   final TextEditingController transportController = TextEditingController();
//   final TextEditingController booksController = TextEditingController();
//   final TextEditingController uniformController = TextEditingController();
//   final TextEditingController fineController = TextEditingController();
//   final TextEditingController othersController = TextEditingController();
//   final TextEditingController previousBalanceController =
//       TextEditingController();
//   final TextEditingController totalDepositController = TextEditingController();
//   final TextEditingController depositController = TextEditingController();
//   final TextEditingController dueBalanceController = TextEditingController();

//   // Fee enablers
//   bool canCollectAdmissionFee = true;
//   bool canCollectRegistrationFee = true;
//   bool canCollectUniformFee = true;

//   List<String> months = [
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();

//     // Initialize all controllers with default values
//     monthlyFeeController.text = widget.monthlyFee;
//     admissionFeeController.text = '0';
//     registrationFeeController.text = '0';
//     artMaterialController.text = '0';
//     transportController.text = '0';
//     booksController.text = '0';
//     uniformController.text = '0';
//     fineController.text = '0';
//     othersController.text = '0';
//     previousBalanceController.text = '0';
//     depositController.text = '0';

//     // Set up listeners for automatic calculation
//     [
//       monthlyFeeController,
//       admissionFeeController,
//       registrationFeeController,
//       artMaterialController,
//       transportController,
//       booksController,
//       uniformController,
//       fineController,
//       othersController,
//       previousBalanceController,
//       depositController,
//     ].forEach((controller) {
//       controller.addListener(_calculateTotals);
//     });

//     // Calculate initial totals
//     _calculateTotals();

//     // Load fee details (without API call for now)
//     _loadFeeDetails();
//   }

//   @override
//   void dispose() {
//     // Dispose all controllers
//     monthlyFeeController.dispose();
//     admissionFeeController.dispose();
//     registrationFeeController.dispose();
//     artMaterialController.dispose();
//     transportController.dispose();
//     booksController.dispose();
//     uniformController.dispose();
//     fineController.dispose();
//     othersController.dispose();
//     previousBalanceController.dispose();
//     totalDepositController.dispose();
//     // depositController.dispose();
//     dueBalanceController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }

//   Future<void> _loadFeeDetails() async {
//     // For now, just set default values without API call
//     setState(() {
//       canCollectAdmissionFee = widget.isNewAdmission;
//       canCollectRegistrationFee = widget.isNewAdmission;
//       canCollectUniformFee = widget.isNewAdmission;
//       previousBalance = 0.0;
//       previousBalanceController.text = previousBalance.toString();
//     });
//     _calculateTotals();
//   }

//   void _calculateTotals() {
//     double total = 0;

//     // Add all fees
//     total += double.tryParse(monthlyFeeController.text) ?? 0;
//     total += double.tryParse(admissionFeeController.text) ?? 0;
//     total += double.tryParse(registrationFeeController.text) ?? 0;
//     total += double.tryParse(artMaterialController.text) ?? 0;
//     total += double.tryParse(transportController.text) ?? 0;
//     total += double.tryParse(booksController.text) ?? 0;
//     total += double.tryParse(uniformController.text) ?? 0;
//     total += double.tryParse(fineController.text) ?? 0;
//     total += double.tryParse(othersController.text) ?? 0;

//     // Previous balance
//     // double prevBalance = double.tryParse(previousBalanceController.text) ?? 0;
//     double deposit = double.tryParse(depositController.text) ?? 0;

//     // Calculate due balance (previous balance - total paid)
//     double dueBalance = total - deposit;

//     setState(() {
//       totalDepositController.text = total.toStringAsFixed(2);
//       // depositController.text = total.toStringAsFixed(2);
//       dueBalanceController.text = dueBalance.toStringAsFixed(2);
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _submitFees() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final feeData = {
//         'student_id': int.parse(widget.studentId), // Convert to int
//         'student_name': widget.studentName,
//         'class_name': widget.studentClass,
//         'fee_month': selectedMonth,
//         'payment_date': DateFormat('yyyy-MM-dd').format(selectedDate),
//         'monthly_fee': double.tryParse(monthlyFeeController.text) ?? 0,
//         'admission_fee': double.tryParse(admissionFeeController.text) ?? 0,
//         'registration_fee':
//             double.tryParse(registrationFeeController.text) ?? 0,
//         'art_material': double.tryParse(artMaterialController.text) ?? 0,
//         'transport': double.tryParse(transportController.text) ?? 0,
//         'books': double.tryParse(booksController.text) ?? 0,
//         'uniform': double.tryParse(uniformController.text) ?? 0,
//         'fine': double.tryParse(fineController.text) ?? 0,
//         'others': double.tryParse(othersController.text) ?? 0,
//         'deposit': double.tryParse(depositController.text) ?? 0,
//       };

//       final response = await http.post(
//         Uri.parse('http://localhost:1000/api/submit'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': token!,
//         },
//         body: jsonEncode(feeData),
//       );

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 201) {
//         _showSuccessSnackBar('Fee payment recorded successfully');
//         Navigator.pop(context, true);
//       } else {
//         _showErrorSnackBar(
//             responseData['message'] ?? 'Failed to record fee payment');
//       }
//     } catch (error) {
//       _showErrorSnackBar('Error submitting fees: $error');
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fees Collection - ${widget.studentName}'),
//         backgroundColor: Colors.blue.shade900,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header area
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Student: ${widget.studentName}',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text('Class: ${widget.studentClass}'),
//                       Divider(),

//                       // Month and Date Selectors
//                       Row(
//                         children: [
//                           Expanded(
//                             child: DropdownButtonFormField<String>(
//                               decoration: InputDecoration(
//                                 labelText: 'Fee Month*',
//                                 border: OutlineInputBorder(),
//                               ),
//                               value: selectedMonth,
//                               items: months.map((String month) {
//                                 return DropdownMenuItem<String>(
//                                   value: month,
//                                   child: Text(month),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedMonth = value!;
//                                 });
//                               },
//                               validator: (value) =>
//                                   value == null ? 'Please select month' : null,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: InkWell(
//                               onTap: () => _selectDate(context),
//                               child: InputDecorator(
//                                 decoration: InputDecoration(
//                                   labelText: 'Date*',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 child: Text(
//                                   DateFormat('dd/MM/yyyy').format(selectedDate),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),
//               Text(
//                 'Fee Details',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Divider(),

//               // Fee Items Table
//               Table(
//                 border: TableBorder.all(),
//                 columnWidths: {
//                   0: FlexColumnWidth(1),
//                   1: FlexColumnWidth(3),
//                   2: FlexColumnWidth(2),
//                 },
//                 children: [
//                   TableRow(
//                     decoration: BoxDecoration(color: Colors.grey.shade200),
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Text('Sr.',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Text('Particulars',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Text('Amount',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),

//                   // Monthly Fee
//                   _buildFeeRow('1', 'MONTHLY FEE', monthlyFeeController),

//                   // Admission Fee
//                   _buildFeeRow('2', 'ADMISSION FEE', admissionFeeController,
//                       enabled: canCollectAdmissionFee),

//                   // Registration Fee
//                   _buildFeeRow(
//                       '3', 'REGISTRATION FEE', registrationFeeController,
//                       enabled: canCollectRegistrationFee),

//                   // Art Material
//                   _buildFeeRow('4', 'ART MATERIAL', artMaterialController),

//                   // Transport
//                   _buildFeeRow('5', 'TRANSPORT', transportController),

//                   // Books
//                   _buildFeeRow('6', 'BOOKS', booksController),

//                   // Uniform
//                   _buildFeeRow('7', 'UNIFORM', uniformController,
//                       enabled: canCollectUniformFee),

//                   // Fine
//                   _buildFeeRow('8', 'FINE', fineController),

//                   // Others
//                   _buildFeeRow('9', 'OTHERS', othersController),
//                 ],
//               ),

//               SizedBox(height: 24),

//               // Summary Section
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Payment Summary',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       // Previous Balance
//                       _buildSummaryRow(
//                           'Previous Balance:', previousBalanceController),
//                       SizedBox(height: 8),

//                       // Total Deposit
//                       _buildSummaryRow('Total :', totalDepositController),
//                       SizedBox(height: 8),

//                       //Deposit
//                       _buildSummaryRow('Deposit :', depositController),
//                       SizedBox(height: 8),

//                       // Due Balance
//                       _buildSummaryRow('Due Balance:', dueBalanceController,
//                           isReadOnly: true, isDue: true),
//                     ],
//                   ),
//                 ),
//               ),

//               SizedBox(height: 24),

//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _submitFees,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade800,
//                   ),
//                   child: isLoading
//                       ? CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'SUBMIT FEE PAYMENT',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   TableRow _buildFeeRow(
//       String srNo, String label, TextEditingController controller,
//       {bool enabled = true}) {
//     return TableRow(
//       children: [
//         Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(srNo),
//         ),
//         Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(label),
//         ),
//         Padding(
//           padding: EdgeInsets.all(8.0),
//           child: TextFormField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             enabled: enabled,
//             decoration: InputDecoration(
//               isDense: true,
//               contentPadding: EdgeInsets.symmetric(vertical: 8.0),
//               hintText: enabled ? null : 'Already Paid',
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryRow(String label, TextEditingController controller,
//       {bool isReadOnly = false, bool isDue = false}) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Text(
//             label,
//             style: isDue ? TextStyle(fontWeight: FontWeight.bold) : null,
//           ),
//         ),
//         Expanded(
//           flex: 2,
//           child: TextFormField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//             readOnly: isReadOnly,
//             decoration: InputDecoration(
//               isDense: true,
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               fillColor: isReadOnly ? Colors.grey.shade200 : null,
//               filled: isReadOnly,
//             ),
//             style: isDue
//                 ? TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   )
//                 : null,
//           ),
//         ),
//       ],
//     );
//   }
// }
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
    // Initialize all controllers with default values
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

    // Set up listeners for automatic calculation
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
    // Dispose all controllers
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
      // Make parallel API calls for better performance
      final responses = await Future.wait([
        // Check fee eligibility
        http.get(
          Uri.parse(
              'http://localhost:1000/api/eligibility/${widget.studentId}'),
          headers: {'Authorization': token!},
        ),
        // Get fee summary
        http.get(
          Uri.parse('http://localhost:1000/api/summary/${widget.studentId}'),
          headers: {'Authorization': token!},
        ),
        // Check previous payments for this month
        http.get(
          Uri.parse(
              'http://localhost:1000/api/previous-payments/${widget.studentId}/$selectedMonth'),
          headers: {'Authorization': token!},
        ),
      ]);

      // Check for API errors
      for (final response in responses) {
        if (response.statusCode != 200) {
          throw Exception('Failed to load fee details: ${response.statusCode}');
        }
      }

      final eligibilityData = jsonDecode(responses[0].body);
      final summaryData = jsonDecode(responses[1].body);
      final previousPaymentsData = jsonDecode(responses[2].body);

      // Validate API responses
      if (eligibilityData['success'] != true ||
          summaryData['success'] != true ||
          previousPaymentsData['success'] != true) {
        throw Exception('Invalid API response format');
      }

      // Check if monthly fee has been paid for this month
      final previousPayments = previousPaymentsData['data'] as List;
      final hasMonthlyFeePaymentForThisMonth = previousPayments.any((payment) =>
          payment['fee_month'] == selectedMonth && payment['monthly_fee'] > 0);

      setState(() {
        // Set one-time fees eligibility
        canCollectAdmissionFee =
            eligibilityData['data']['canCollectAdmissionFee'] ?? false;
        canCollectRegistrationFee =
            eligibilityData['data']['canCollectRegistrationFee'] ?? false;
        canCollectUniformFee =
            eligibilityData['data']['canCollectUniformFee'] ?? false;

        // Set suggested values for one-time fees if eligible
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

        // Set previous balance from the latest due amount
        previousBalance =
            (summaryData['data']['last_due_balance'] ?? 0).toDouble();
        previousBalanceController.text = previousBalance.toStringAsFixed(2);

        // Track monthly fee payment status
        isMonthlyFeePaidForSelectedMonth = hasMonthlyFeePaymentForThisMonth;

        // If monthly fee already paid for this month, disable it
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

    // Add all fees
    total += double.tryParse(monthlyFeeController.text) ?? 0;
    total += double.tryParse(admissionFeeController.text) ?? 0;
    total += double.tryParse(registrationFeeController.text) ?? 0;
    total += double.tryParse(artMaterialController.text) ?? 0;
    total += double.tryParse(transportController.text) ?? 0;
    total += double.tryParse(booksController.text) ?? 0;
    total += double.tryParse(uniformController.text) ?? 0;
    total += double.tryParse(fineController.text) ?? 0;
    total += double.tryParse(othersController.text) ?? 0;

    // Always add previous balance
    total += double.tryParse(previousBalanceController.text) ?? 0;

    double deposit = double.tryParse(depositController.text) ?? 0;

    // Calculate due balance (total - deposit)
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

    // Additional validation: Check if trying to submit monthly fee when already paid
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
        // Handle specific validation errors
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Fees Collection - ${widget.studentName}'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header area
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student: ${widget.studentName}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Class: ${widget.studentClass}'),
                            Divider(),

                            // Month and Date Selectors
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Fee Month*',
                                      border: OutlineInputBorder(),
                                    ),
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
                                        _loadFeeDetails(); // Reload details when month changes
                                      });
                                    },
                                    validator: (value) => value == null
                                        ? 'Please select month'
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date*',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(selectedDate),
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

                    SizedBox(height: 20),
                    Text(
                      'Fee Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Fee Details Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Monthly Fee
                            TextFormField(
                              controller: monthlyFeeController,
                              decoration: InputDecoration(
                                labelText: 'Monthly Fee',
                                hintText: 'Enter monthly fee',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.money),
                                enabled: !isMonthlyFeePaidForSelectedMonth,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter amount';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // One-time fees row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: admissionFeeController,
                                    enabled: canCollectAdmissionFee,
                                    decoration: InputDecoration(
                                      labelText: 'Admission Fee',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.school),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: registrationFeeController,
                                    enabled: canCollectRegistrationFee,
                                    decoration: InputDecoration(
                                      labelText: 'Registration Fee',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.app_registration),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Additional fees row 1
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: artMaterialController,
                                    decoration: InputDecoration(
                                      labelText: 'Art Material',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.color_lens),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: transportController,
                                    decoration: InputDecoration(
                                      labelText: 'Transport',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.directions_bus),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Additional fees row 2
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: booksController,
                                    decoration: InputDecoration(
                                      labelText: 'Books',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.book),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: uniformController,
                                    enabled: canCollectUniformFee,
                                    decoration: InputDecoration(
                                      labelText: 'Uniform',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Additional fees row 3
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: fineController,
                                    decoration: InputDecoration(
                                      labelText: 'Fine',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.error_outline),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: othersController,
                                    decoration: InputDecoration(
                                      labelText: 'Others',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.more_horiz),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Payment Summary Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Previous Balance
                            TextFormField(
                              controller: previousBalanceController,
                              decoration: InputDecoration(
                                labelText: 'Previous Balance',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.history),
                                enabled: false,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),

                            // Total Amount
                            TextFormField(
                              controller: totalDepositController,
                              decoration: InputDecoration(
                                labelText: 'Total Amount',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance_wallet),
                                enabled: false,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16),

                            // Deposit Amount
                            TextFormField(
                              controller: depositController,
                              decoration: InputDecoration(
                                labelText: 'Deposit Amount*',
                                hintText: 'Enter amount paid',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.payments),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter deposit amount';
                                }
                                double? deposit = double.tryParse(value);
                                double total = double.tryParse(
                                        totalDepositController.text) ??
                                    0;
                                if (deposit != null && deposit > total) {
                                  return 'Deposit cannot be greater than total amount';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Due Balance
                            TextFormField(
                              controller: dueBalanceController,
                              decoration: InputDecoration(
                                labelText: 'Due Balance',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance),
                                enabled: false,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitFees,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Submit Fee Payment',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
