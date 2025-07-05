// // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';

// // class FeeReceiptPage extends StatelessWidget {
// //   final String studentId;
// //   final String studentName;
// //   final String studentClass;
// //   final String studentSection;
// //   final List<String> feeMonths;
// //   final double totalPaid;
// //   final double totalDue;
// //   final double depositAmount;
// //   final String paymentDate;
// //   final String remark;
// //   final bool isYearlyPayment;
// //   final List<Map<String, dynamic>> feeItems;

// //   const FeeReceiptPage({
// //     Key? key,
// //     required this.studentId,
// //     required this.studentName,
// //     required this.studentClass,
// //     required this.studentSection,
// //     required this.feeMonths,
// //     required this.totalPaid,
// //     required this.totalDue,
// //     required this.depositAmount,
// //     required this.paymentDate,
// //     required this.remark,
// //     required this.isYearlyPayment,
// //     required this.feeItems,
// //   }) : super(key: key);

// //   Widget _buildDetailRow({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //   }) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Icon(icon, color: color, size: 20),
// //         SizedBox(width: 8),
// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 label,
// //                 style: TextStyle(
// //                   color: color.withOpacity(0.8),
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //               Text(
// //                 value,
// //                 style: TextStyle(
// //                   color: color,
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final blueTheme = Colors.blue.shade900;
// //     final whiteTheme = Colors.white;

// //     return Scaffold(
// //       backgroundColor: Colors.grey.shade100,
// //       appBar: AppBar(
// //         title: Text(
// //           'Fee Receipt',
// //           style: TextStyle(color: whiteTheme, fontWeight: FontWeight.bold),
// //         ),
// //         backgroundColor: blueTheme,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back, color: whiteTheme),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Card(
// //           elevation: 6,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [blueTheme, Colors.blue.shade700],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Header
// //                   Center(
// //                     child: Text(
// //                       'Fee Receipt',
// //                       style: TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.bold,
// //                         color: whiteTheme,
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 16),
// //                   Divider(color: whiteTheme.withOpacity(0.5)),
// //                   SizedBox(height: 16),

// //                   // Student Details
// //                   _buildDetailRow(
// //                     icon: Icons.person,
// //                     label: 'Student Name',
// //                     value: studentName,
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.school,
// //                     label: 'Class',
// //                     value: studentClass,
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.class_,
// //                     label: 'Section',
// //                     value: studentSection,
// //                     color: whiteTheme,
// //                   ),
// //                   // SizedBox(height: 12),
// //                   // _buildDetailRow(
// //                   //   icon: Icons.perm_identity,
// //                   //   label: 'Student ID',
// //                   //   value: studentId,
// //                   //   color: whiteTheme,
// //                   // ),
// //                   SizedBox(height: 16),
// //                   Divider(color: whiteTheme.withOpacity(0.5)),
// //                   SizedBox(height: 16),

// //                   // Payment Details
// //                   Text(
// //                     'Payment Details',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: whiteTheme,
// //                     ),
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.calendar_today,
// //                     label: 'Payment Date',
// //                     value: paymentDate,
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.payment,
// //                     label: 'Payment Type',
// //                     value: isYearlyPayment ? 'Yearly' : 'Monthly',
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.event,
// //                     label: 'Fee Months',
// //                     value: feeMonths.isEmpty ? 'N/A' : feeMonths.join(', '),
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 16),

// //                   // Fee Items
// //                   Text(
// //                     'Fee Breakdown',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: whiteTheme,
// //                     ),
// //                   ),
// //                   SizedBox(height: 12),
// //                   ...feeItems.map((item) {
// //                     return Container(
// //                       margin: EdgeInsets.only(bottom: 8),
// //                       padding: EdgeInsets.all(8),
// //                       decoration: BoxDecoration(
// //                         color: whiteTheme.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Expanded(
// //                             child: Text(
// //                               item['fee_name'] ?? 'Unknown',
// //                               style: TextStyle(
// //                                 color: whiteTheme,
// //                                 fontSize: 14,
// //                               ),
// //                             ),
// //                           ),
// //                           Text(
// //                             '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
// //                             style: TextStyle(
// //                               color: whiteTheme,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   }).toList(),
// //                   SizedBox(height: 16),
// //                   Divider(color: whiteTheme.withOpacity(0.5)),
// //                   SizedBox(height: 16),

// //                   // Summary
// //                   Text(
// //                     'Summary',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: whiteTheme,
// //                     ),
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.account_balance_wallet,
// //                     label: 'Total Amount',
// //                     value: '₹${depositAmount.toStringAsFixed(2)}',
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.payments,
// //                     label: 'Total Paid (Cumulative)',
// //                     value: '₹${totalPaid.toStringAsFixed(2)}',
// //                     color: Colors.green.shade200,
// //                   ),
// //                   SizedBox(height: 12),
// //                   _buildDetailRow(
// //                     icon: Icons.account_balance,
// //                     label: 'Total Due',
// //                     value: '₹${totalDue.toStringAsFixed(2)}',
// //                     color: Colors.red.shade200,
// //                   ),
// //                   SizedBox(height: 16),
// //                   Divider(color: whiteTheme.withOpacity(0.5)),
// //                   SizedBox(height: 16),

// //                   // Remark
// //                   _buildDetailRow(
// //                     icon: Icons.note,
// //                     label: 'Remark',
// //                     value: remark.isEmpty ? 'N/A' : remark,
// //                     color: whiteTheme,
// //                   ),
// //                   SizedBox(height: 24),

// //                   // Footer
// //                   Center(
// //                     child: Text(
// //                       'Thank you for your payment!',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         fontStyle: FontStyle.italic,
// //                         color: whiteTheme.withOpacity(0.8),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:sms/widgets/button.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class FeeReceiptPage extends StatelessWidget {
//   final String studentId;
//   final String studentName;
//   final String studentClass;
//   final String studentSection;
//   final List<String> feeMonths;
//   final double totalPaid;
//   final double totalDue;
//   final double depositAmount;
//   final String paymentDate;
//   final String remark;
//   final bool isYearlyPayment;
//   final List<Map<String, dynamic>> feeItems;
//   static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   const FeeReceiptPage({
//     Key? key,
//     required this.studentId,
//     required this.studentName,
//     required this.studentClass,
//     required this.studentSection,
//     required this.feeMonths,
//     required this.totalPaid,
//     required this.totalDue,
//     required this.depositAmount,
//     required this.paymentDate,
//     required this.remark,
//     required this.isYearlyPayment,
//     required this.feeItems,
//   }) : super(key: key);

//   Future<void> _generatePdf(BuildContext context) async {
//     final pdf = pw.Document();

//     // Load school logo
//     // final ByteData? logoData =
//     //     await rootBundle.load('assets/images/almanet1.jpg');
//     // final Uint8List? logoBytes = logoData?.buffer.asUint8List();
//     // final pw.MemoryImage? logoImage =
//     //     logoBytes != null ? pw.MemoryImage(logoBytes) : null;

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         build: (pw.Context context) => [
//           // Header with logo
//           // pw.Container(
//           //   padding: pw.EdgeInsets.symmetric(vertical: 16),
//           //   width: double.infinity,
//           //   decoration: pw.BoxDecoration(
//           //     color: PdfColors.lightBlue50,
//           //     borderRadius: pw.BorderRadius.circular(12),
//           //   ),
//           //   child: pw.Column(
//           //     children: [
//           //       if (logoImage != null)
//           //         pw.Image(logoImage, width: 60, height: 60)
//           //       else
//           //         pw.Container(
//           //           width: 60,
//           //           height: 60,
//           //           decoration: pw.BoxDecoration(
//           //             shape: pw.BoxShape.circle,
//           //             color: PdfColors.lightBlue200,
//           //           ),
//           //           child: pw.Center(
//           //             child: pw.Text(
//           //               'AS',
//           //               style: pw.TextStyle(
//           //                 fontSize: 20,
//           //                 fontWeight: pw.FontWeight.bold,
//           //                 color: PdfColors.blue900,
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       pw.SizedBox(height: 8),
//           //       pw.Text(
//           //         'ALMANET SCHOOL',
//           //         style: pw.TextStyle(
//           //           fontSize: 24,
//           //           fontWeight: pw.FontWeight.bold,
//           //           color: PdfColors.blue900,
//           //         ),
//           //       ),
//           //       pw.SizedBox(height: 4),
//           //       pw.Text(
//           //         'Excellence in Education',
//           //         style: pw.TextStyle(
//           //           fontSize: 14,
//           //           color: PdfColors.blue900,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),

//           pw.SizedBox(height: 24),

//           pw.Text(
//             'FEE RECEIPT',
//             style: pw.TextStyle(
//               fontSize: 22,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue900,
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // Student information table
//           pw.Container(
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: PdfColors.blue100),
//               borderRadius: pw.BorderRadius.circular(12),
//             ),
//             child: pw.Table(
//               border: pw.TableBorder.symmetric(
//                 inside: pw.BorderSide(color: PdfColors.blue100),
//               ),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(1.2),
//                 1: pw.FlexColumnWidth(2),
//               },
//               children: [
//                 _buildPdfTableRow('Student Name', studentName, isHeader: true),
//                 _buildPdfTableRow('Class', studentClass),
//                 _buildPdfTableRow('Section', studentSection),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // Payment details table
//           pw.Container(
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: PdfColors.blue100),
//               borderRadius: pw.BorderRadius.circular(12),
//             ),
//             child: pw.Table(
//               border: pw.TableBorder.symmetric(
//                 inside: pw.BorderSide(color: PdfColors.blue100),
//               ),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(1.2),
//                 1: pw.FlexColumnWidth(2),
//               },
//               children: [
//                 _buildPdfTableRow('Payment Date', paymentDate, isHeader: true),
//                 _buildPdfTableRow(
//                     'Payment Type', isYearlyPayment ? 'Yearly' : 'Monthly'),
//                 _buildPdfTableRow('Fee Months',
//                     feeMonths.isEmpty ? 'N/A' : feeMonths.join(', ')),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // Fee breakdown
//           pw.Text(
//             'Fee Breakdown',
//             style: pw.TextStyle(
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue900,
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Container(
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: PdfColors.blue100),
//               borderRadius: pw.BorderRadius.circular(12),
//             ),
//             child: pw.Table(
//               border: pw.TableBorder.symmetric(
//                 inside: pw.BorderSide(color: PdfColors.blue100),
//               ),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(2),
//                 1: pw.FlexColumnWidth(1),
//               },
//               children: [
//                 _buildPdfTableRow('Fee Name', 'Amount', isHeader: true),
//                 ...feeItems.map((item) {
//                   return _buildPdfTableRow(
//                     item['fee_name'] ?? 'Unknown',
//                     '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // Summary table
//           pw.Text(
//             'Summary',
//             style: pw.TextStyle(
//               fontSize: 18,
//               fontWeight: pw.FontWeight.bold,
//               color: PdfColors.blue900,
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Container(
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: PdfColors.blue100),
//               borderRadius: pw.BorderRadius.circular(12),
//             ),
//             child: pw.Table(
//               border: pw.TableBorder.symmetric(
//                 inside: pw.BorderSide(color: PdfColors.blue100),
//               ),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(1.2),
//                 1: pw.FlexColumnWidth(2),
//               },
//               children: [
//                 _buildPdfTableRow(
//                     'Total Amount', '₹${depositAmount.toStringAsFixed(2)}',
//                     isHeader: true),
//                 _buildPdfTableRow('Total Paid (Cumulative)',
//                     '₹${totalPaid.toStringAsFixed(2)}',
//                     valueColor: PdfColors.green600),
//                 _buildPdfTableRow(
//                     'Total Due', '₹${totalDue.toStringAsFixed(2)}',
//                     valueColor: PdfColors.red600),
//               ],
//             ),
//           ),

//           pw.SizedBox(height: 20),

//           // // Remark
//           // pw.Text(
//           //   'Remark',
//           //   style: pw.TextStyle(
//           //     fontSize: 18,
//           //     fontWeight: pw.FontWeight.bold,
//           //     color: PdfColors.blue900,
//           //   ),
//           // ),
//           // pw.SizedBox(height: 12),
//           // pw.Container(
//           //   decoration: pw.BoxDecoration(
//           //     border: pw.Border.all(color: PdfColors.blue100),
//           //     borderRadius: pw.BorderRadius.circular(12),
//           //   ),
//           //   child: pw.Table(
//           //     border: pw.TableBorder.symmetric(
//           //       inside: pw.BorderSide(color: PdfColors.blue100),
//           //     ),
//           //     columnWidths: {
//           //       0: pw.FlexColumnWidth(1.2),
//           //       1: pw.FlexColumnWidth(2),
//           //     },
//           //     children: [
//           //       _buildPdfTableRow('Remark', remark.isEmpty ? 'N/A' : remark,
//           //           isHeader: true),
//           //     ],
//           //   ),
//           // ),

//           pw.SizedBox(height: 40),

//           // Signature
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.center,
//                 children: [
//                   pw.Container(
//                     width: 150,
//                     height: 1,
//                     color: PdfColors.black,
//                   ),
//                   pw.SizedBox(height: 5),
//                   pw.Text('Principal Signature',
//                       style: pw.TextStyle(fontSize: 10)),
//                 ],
//               ),
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.center,
//                 children: [
//                   pw.Container(
//                     width: 150,
//                     height: 1,
//                     color: PdfColors.black,
//                   ),
//                   pw.SizedBox(height: 5),
//                   pw.Text('School Stamp', style: pw.TextStyle(fontSize: 10)),
//                 ],
//               ),
//             ],
//           ),

//           pw.SizedBox(height: 40),

//           // Footer
//           // pw.Container(
//           //   width: double.infinity,
//           //   padding: pw.EdgeInsets.all(10),
//           //   decoration: pw.BoxDecoration(
//           //     color: PdfColors.lightBlue50,
//           //     borderRadius: pw.BorderRadius.circular(8),
//           //   ),
//           //   child: pw.Text(
//           //     'Thank you for your payment!',
//           //     textAlign: pw.TextAlign.center,
//           //     style: pw.TextStyle(
//           //       fontSize: 14,
//           //       fontStyle: pw.FontStyle.italic,
//           //       color: PdfColors.blue900,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }

//   pw.TableRow _buildPdfTableRow(String header, String value,
//       {bool isHeader = false, PdfColor? valueColor}) {
//     return pw.TableRow(
//       decoration: isHeader
//           ? pw.BoxDecoration(
//               color: PdfColors.blue50,
//               borderRadius: pw.BorderRadius.only(
//                 topLeft: pw.Radius.circular(12),
//                 topRight: pw.Radius.circular(12),
//               ),
//             )
//           : null,
//       children: [
//         pw.Container(
//           padding: pw.EdgeInsets.all(12),
//           child: pw.Text(
//             header,
//             style: pw.TextStyle(
//               fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: isHeader ? PdfColors.blue900 : PdfColors.blue800,
//             ),
//           ),
//         ),
//         pw.Container(
//           padding: pw.EdgeInsets.all(12),
//           child: pw.Text(
//             value,
//             style: pw.TextStyle(
//               fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//               color: valueColor ?? PdfColors.blue800,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: CustomAppBar(
//         title: 'Fee Receipt',
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // School header
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(Icons.school, size: 48, color: Colors.blue[900]),
//                     SizedBox(height: 8),
//                     Text(
//                       'ALMANET SCHOOL',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue[900],
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       'Excellence in Education',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.blue[900],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 24),

//             Text(
//               'FEE RECEIPT',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[900],
//               ),
//             ),

//             SizedBox(height: 20),

//             // Student information
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue[100]!),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Table(
//                   border: TableBorder.all(
//                     color: Colors.blue[100]!,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   columnWidths: {
//                     0: FlexColumnWidth(1.2),
//                     1: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       children: [
//                         _buildTableCell('Student Name', true),
//                         _buildTableCell(studentName, false),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Class', true),
//                         _buildTableCell(studentClass, false),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Section', true),
//                         _buildTableCell(studentSection, false),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Payment details
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue[100]!),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Table(
//                   border: TableBorder.all(
//                     color: Colors.blue[100]!,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   columnWidths: {
//                     0: FlexColumnWidth(1.2),
//                     1: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       children: [
//                         _buildTableCell('Payment Date', true),
//                         _buildTableCell(paymentDate, false),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Payment Type', true),
//                         _buildTableCell(
//                             isYearlyPayment ? 'Yearly' : 'Monthly', false),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Fee Months', true),
//                         _buildTableCell(
//                             feeMonths.isEmpty ? 'N/A' : feeMonths.join(', '),
//                             false),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Fee breakdown
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue[100]!),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Table(
//                   border: TableBorder.all(
//                     color: Colors.blue[100]!,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   columnWidths: {
//                     0: FlexColumnWidth(2),
//                     1: FlexColumnWidth(1),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       children: [
//                         _buildTableCell('Fee Name', true),
//                         _buildTableCell('Amount', true),
//                       ],
//                     ),
//                     ...feeItems.map((item) {
//                       return TableRow(
//                         children: [
//                           _buildTableCell(item['fee_name'] ?? 'Unknown', false),
//                           _buildTableCell(
//                               '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
//                               false),
//                         ],
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Summary
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue[100]!),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Table(
//                   border: TableBorder.all(
//                     color: Colors.blue[100]!,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   columnWidths: {
//                     0: FlexColumnWidth(1.2),
//                     1: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       children: [
//                         _buildTableCell('Total Amount', true),
//                         _buildTableCell(
//                             '₹${depositAmount.toStringAsFixed(2)}', false),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Total Paid (Cumulative)', true),
//                         _buildTableCell(
//                             '₹${totalPaid.toStringAsFixed(2)}', false,
//                             statusColor: Colors.green[200]),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Total Due', true),
//                         _buildTableCell(
//                             '₹${totalDue.toStringAsFixed(2)}', false,
//                             statusColor: Colors.red[200]),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Remark
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue[100]!),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Table(
//                   border: TableBorder.all(
//                     color: Colors.blue[100]!,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   columnWidths: {
//                     0: FlexColumnWidth(1.2),
//                     1: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       children: [
//                         _buildTableCell('Remark', true),
//                         _buildTableCell(remark.isEmpty ? 'N/A' : remark, false),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 30),

//             // Print button
//             CustomButton(
//               text: 'Print',
//               icon: Icons.print,
//               onPressed: () async {
//                 await _generatePdf(context);
//               },
//               width: 150,
//             ),

//             SizedBox(height: 20),

//             // Footer
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   'Thank you for your payment!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.blue[900],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTableCell(String text, bool isHeader, {Color? statusColor}) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isHeader ? Colors.blue[50] : Colors.white,
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//           color:
//               statusColor ?? (isHeader ? Colors.blue[900] : Colors.blue[800]),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/pages/services/profile_service.dart';

class FeeReceiptPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentClass;
  final String studentSection;
  final List<String> feeMonths;
  final double totalPaid;
  final double totalDue;
  final double depositAmount;
  final String paymentDate;
  final String remark;
  final bool isYearlyPayment;
  final List<Map<String, dynamic>> feeItems;
  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  const FeeReceiptPage({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.studentSection,
    required this.feeMonths,
    required this.totalPaid,
    required this.totalDue,
    required this.depositAmount,
    required this.paymentDate,
    required this.remark,
    required this.isYearlyPayment,
    required this.feeItems,
  }) : super(key: key);

  @override
  _FeeReceiptPageState createState() => _FeeReceiptPageState();
}

class _FeeReceiptPageState extends State<FeeReceiptPage> {
  String? instituteName;
  String? logoUrlFull;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('No token found, cannot fetch profile');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final profile = await ProfileService.getProfile();
      final innerData = profile['data'];
      if (innerData != null) {
        setState(() {
          instituteName = innerData['institute_name'] ?? 'ALMANET SCHOOL';
          final logoUrl = innerData['logo_url'] ?? '';
          if (logoUrl.isNotEmpty) {
            final cleanBaseUrl = FeeReceiptPage.baseUrl.endsWith('/')
                ? FeeReceiptPage.baseUrl
                    .substring(0, FeeReceiptPage.baseUrl.length - 1)
                : FeeReceiptPage.baseUrl;
            final cleanLogoUrl =
                logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';
            logoUrlFull = logoUrl.startsWith('http')
                ? logoUrl
                : cleanBaseUrl + cleanLogoUrl;
          } else {
            logoUrlFull = null;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      setState(() {
        instituteName = 'ALMANET SCHOOL'; // Fallback
        logoUrlFull = null;
        isLoading = false;
      });
    }
  }

  Widget _buildLogoImage({double size = 72}) {
    if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logoUrlFull!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading logo: $error');
            return Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
              ),
              child: Icon(Icons.school, size: size / 2, color: Colors.white),
            );
          },
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent,
        ),
        child: Icon(Icons.school, size: size / 2, color: Colors.white),
      );
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Load school logo
    pw.MemoryImage? logoImage;
    if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(logoUrlFull!));
        if (response.statusCode == 200) {
          logoImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        debugPrint('Failed to load logo image: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 16,
          marginBottom: 16,
          marginLeft: 16,
          marginRight: 16,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo - made more compact
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Image(logoImage, width: 40, height: 40)
                  else
                    pw.Container(
                      width: 40,
                      height: 40,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: PdfColors.lightBlue200,
                      ),
                      child: pw.Center(
                        child: pw.Text('AS',
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                      ),
                    ),
                  pw.SizedBox(width: 8),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        instituteName ?? 'ALMANET SCHOOL',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'Excellence in Education',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'FEE RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              // Student information table - made more compact
              _buildCompactPdfTable([
                ['Student Name', widget.studentName],
                ['Class', widget.studentClass],
                ['Section', widget.studentSection],
              ]),

              pw.SizedBox(height: 12),

              // Payment details table - made more compact
              _buildCompactPdfTable([
                ['Payment Date', widget.paymentDate],
                ['Payment Type', widget.isYearlyPayment ? 'Yearly' : 'Monthly'],
                [
                  'Fee Months',
                  widget.feeMonths.isEmpty ? 'N/A' : widget.feeMonths.join(', ')
                ],
              ]),

              pw.SizedBox(height: 12),

              // Fee breakdown - made more compact
              pw.Text(
                'Fee Breakdown',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              _buildCompactPdfTable([
                ['Fee Name', 'Amount'],
                ...widget.feeItems.map((item) => [
                      item['fee_name'] ?? 'Unknown',
                      '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}'
                    ]),
              ], isFirstRowHeader: true),

              pw.SizedBox(height: 12),

              // Summary table - made more compact
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),
              _buildCompactPdfTable([
                ['Total Amount', '₹${widget.depositAmount.toStringAsFixed(2)}'],
                [
                  'Total Paid (Cumulative)',
                  '₹${widget.totalPaid.toStringAsFixed(2)}'
                ],
                ['Total Due', '₹${widget.totalDue.toStringAsFixed(2)}'],
              ], valueColors: [
                null,
                PdfColors.green600,
                PdfColors.red600,
              ]),

              pw.SizedBox(height: 16),

              // Signature - made more compact
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSignatureField('Principal Signature'),
                  _buildSignatureField('School Stamp'),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildSignatureField(String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 100,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  pw.Widget _buildCompactPdfTable(
    List<List<String>> rows, {
    bool isFirstRowHeader = false,
    List<PdfColor?>? valueColors,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue100),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: PdfColors.blue100),
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(2),
        },
        children: [
          for (int i = 0; i < rows.length; i++)
            pw.TableRow(
              decoration: (isFirstRowHeader && i == 0)
                  ? pw.BoxDecoration(
                      color: PdfColors.blue50,
                      borderRadius: i == 0
                          ? const pw.BorderRadius.only(
                              topLeft: pw.Radius.circular(8),
                              topRight: pw.Radius.circular(8),
                            )
                          : null,
                    )
                  : null,
              children: [
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: pw.Text(
                    rows[i][0],
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: (isFirstRowHeader && i == 0)
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: pw.Text(
                    rows[i][1],
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: (isFirstRowHeader && i == 0)
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                      color: valueColors != null &&
                              i < valueColors.length &&
                              valueColors[i] != null
                          ? valueColors[i]
                          : PdfColors.blue800,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHeader, {Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue[50] : Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color:
              statusColor ?? (isHeader ? Colors.blue[900] : Colors.blue[800]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Fee Receipt',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // School header
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildLogoImage(size: 72),
                          const SizedBox(height: 8),
                          Text(
                            instituteName ?? 'ALMANET SCHOOL',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Excellence in Education',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'FEE RECEIPT',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Student information
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[100]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.blue[100]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            children: [
                              _buildTableCell('Student Name', true),
                              _buildTableCell(widget.studentName, false),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell('Class', true),
                              _buildTableCell(widget.studentClass, false),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell('Section', true),
                              _buildTableCell(widget.studentSection, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment details
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[100]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.blue[100]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            children: [
                              _buildTableCell('Payment Date', true),
                              _buildTableCell(widget.paymentDate, false),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell('Payment Type', true),
                              _buildTableCell(
                                  widget.isYearlyPayment ? 'Yearly' : 'Monthly',
                                  false),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell('Fee Months', true),
                              _buildTableCell(
                                  widget.feeMonths.isEmpty
                                      ? 'N/A'
                                      : widget.feeMonths.join(', '),
                                  false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fee breakdown
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[100]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.blue[100]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            children: [
                              _buildTableCell('Fee Name', true),
                              _buildTableCell('Amount', true),
                            ],
                          ),
                          ...widget.feeItems.map((item) {
                            return TableRow(
                              children: [
                                _buildTableCell(
                                    item['fee_name'] ?? 'Unknown', false),
                                _buildTableCell(
                                    '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    false),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Summary
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[100]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.blue[100]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            children: [
                              _buildTableCell('Total Amount', true),
                              _buildTableCell(
                                  '₹${widget.depositAmount.toStringAsFixed(2)}',
                                  false),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell('Total Paid (Cumulative)', true),
                              _buildTableCell(
                                  '₹${widget.totalPaid.toStringAsFixed(2)}',
                                  false,
                                  statusColor: Colors.green[200]),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildTableCell('Total Due', true),
                              _buildTableCell(
                                  '₹${widget.totalDue.toStringAsFixed(2)}',
                                  false,
                                  statusColor: Colors.red[200]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Remark
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[100]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.blue[100]!,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            children: [
                              _buildTableCell('Remark', true),
                              _buildTableCell(
                                  widget.remark.isEmpty ? 'N/A' : widget.remark,
                                  false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Print button
                  CustomButton(
                    text: 'Print',
                    icon: Icons.print,
                    onPressed: () async {
                      await _generatePdf(context);
                    },
                    width: 150,
                  ),

                  const SizedBox(height: 20),

                  // Footer
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Thank you for your payment!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ye code shi hai bas chitransh bhai ko shi krne ke liye comment kra hai component nhi hai unike pass isliye
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/widgets/button.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/pages/services/profile_service.dart';
// import 'package:sms/widgets/pdf_widgets/school_header.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_info_table.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_header.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_tables.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_signature.dart' as custom_signature;
// import 'package:sms/widgets/pdf_widgets/pdf_utils.dart';

// class FeeReceiptPage extends StatefulWidget {
//   final String studentId;
//   final String studentName;
//   final String studentClass;
//   final String studentSection;
//   final List<String> feeMonths;
//   final double totalPaid;
//   final double totalDue;
//   final double depositAmount;
//   final String paymentDate;
//   final String remark;
//   final bool isYearlyPayment;
//   final List<Map<String, dynamic>> feeItems;
//   static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   const FeeReceiptPage({
//     Key? key,
//     required this.studentId,
//     required this.studentName,
//     required this.studentClass,
//     required this.studentSection,
//     required this.feeMonths,
//     required this.totalPaid,
//     required this.totalDue,
//     required this.depositAmount,
//     required this.paymentDate,
//     required this.remark,
//     required this.isYearlyPayment,
//     required this.feeItems,
//   }) : super(key: key);

//   @override
//   _FeeReceiptPageState createState() => _FeeReceiptPageState();
// }

// class _FeeReceiptPageState extends State<FeeReceiptPage> {
//   String? instituteName;
//   String? logoUrlFull;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//   }

//   Future<void> _fetchProfileData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) {
//         debugPrint('No token found, cannot fetch profile');
//         setState(() {
//           isLoading = false;
//         });
//         return;
//       }

//       final profile = await ProfileService.getProfile();
//       final innerData = profile['data'];
//       if (innerData != null) {
//         setState(() {
//           instituteName = innerData['institute_name'] ?? 'ALMANET SCHOOL';
//           final logoUrl = innerData['logo_url'] ?? '';
//           if (logoUrl.isNotEmpty) {
//             final cleanBaseUrl = FeeReceiptPage.baseUrl.endsWith('/')
//                 ? FeeReceiptPage.baseUrl
//                     .substring(0, FeeReceiptPage.baseUrl.length - 1)
//                 : FeeReceiptPage.baseUrl;
//             final cleanLogoUrl =
//                 logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';
//             logoUrlFull = logoUrl.startsWith('http')
//                 ? logoUrl
//                 : cleanBaseUrl + cleanLogoUrl;
//           } else {
//             logoUrlFull = null;
//           }
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching profile: $e');
//       setState(() {
//         instituteName = 'ALMANET SCHOOL'; // Fallback
//         logoUrlFull = null;
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: const CustomAppBar(
//         title: 'Fee Receipt',
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // School header
//                   SchoolHeader(
//                     instituteName: instituteName,
//                     logoUrl: logoUrlFull,
//                     logoSize: 72,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'FEE RECEIPT',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[900],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   // Student information
//                   InfoTable(
//                     context: context,
//                     rows: [
//                       {
//                         'text': 'Student Name',
//                         'value': widget.studentName,
//                         'isHeader': true,
//                       },
//                       {
//                         'text': 'Class',
//                         'value': widget.studentClass,
//                         'isHeader': false,
//                       },
//                       {
//                         'text': 'Section',
//                         'value': widget.studentSection,
//                         'isHeader': false,
//                       },
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Payment details
//                   InfoTable(
//                     context: context,
//                     rows: [
//                       {
//                         'text': 'Payment Date',
//                         'value': widget.paymentDate,
//                         'isHeader': true,
//                       },
//                       {
//                         'text': 'Payment Type',
//                         'value': widget.isYearlyPayment ? 'Yearly' : 'Monthly',
//                         'isHeader': false,
//                       },
//                       {
//                         'text': 'Fee Months',
//                         'value': widget.feeMonths.isEmpty
//                             ? 'N/A'
//                             : widget.feeMonths.join(', '),
//                         'isHeader': false,
//                       },
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Fee breakdown
//                   InfoTable(
//                     context: context,
//                     rows: [
//                       {
//                         'text': 'Fee Name',
//                         'value': 'Amount',
//                         'isHeader': true,
//                       },
//                       ...widget.feeItems.map((item) => {
//                             'text': item['fee_name'] ?? 'Unknown',
//                             'value':
//                                 '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
//                             'isHeader': false,
//                           }),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Summary
//                   InfoTable(
//                     context: context,
//                     rows: [
//                       {
//                         'text': 'Total Amount',
//                         'value': '₹${widget.depositAmount.toStringAsFixed(2)}',
//                         'isHeader': true,
//                       },
//                       {
//                         'text': 'Total Paid (Cumulative)',
//                         'value': '₹${widget.totalPaid.toStringAsFixed(2)}',
//                         'isHeader': false,
//                         'statusColor': Colors.green[200],
//                       },
//                       {
//                         'text': 'Total Due',
//                         'value': '₹${widget.totalDue.toStringAsFixed(2)}',
//                         'isHeader': false,
//                         'statusColor': Colors.red[200],
//                       },
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Remark
//                   InfoTable(
//                     context: context,
//                     rows: [
//                       {
//                         'text': 'Remark',
//                         'value': widget.remark.isEmpty ? 'N/A' : widget.remark,
//                         'isHeader': true,
//                       },
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   // Print button
//                   CustomButton(
//                     text: 'Print',
//                     icon: Icons.print,
//                     onPressed: () async {
//                       await _generatePdf(context);
//                     },
//                     width: 150,
//                   ),
//                   const SizedBox(height: 20),
//                   // Footer
//                   Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         'Thank you for your payment!',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontStyle: FontStyle.italic,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Future<void> _generatePdf(BuildContext context) async {
//     final pdf = pw.Document();
//     final instituteName = await PdfUtils.fetchInstituteName();
//     final logoUrl = await PdfUtils.fetchLogoUrl();
//     final logoImage =
//         logoUrl != null ? await PdfUtils.fetchImage(logoUrl) : null;

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4.copyWith(
//           marginTop: 12,
//           marginBottom: 12,
//           marginLeft: 12,
//           marginRight: 12,
//         ),
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // Header
//               PdfHeader.build(
//                 instituteName: instituteName!,
//                 logoImage: logoImage,
//                 // fontSize: 14, // Reduced font size
//                 logoSize: 36, // Reduced logo size
//               ),
//               pw.SizedBox(height: 6),
//               pw.Center(
//                 child: pw.Text(
//                   'FEE RECEIPT',
//                   style: pw.TextStyle(
//                     fontSize: 16, // Reduced from 18
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue900,
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               // Student information
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(6),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: const pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: const {
//                     0: pw.FlexColumnWidth(1.3), // Slightly more compact
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     PdfTables.buildHeaderRow(['Field', 'Value'], fontSize: 9),
//                     PdfTables.buildRow(['Student Name', widget.studentName],
//                         fontSize: 9),
//                     PdfTables.buildRow(['Class', widget.studentClass],
//                         fontSize: 9),
//                     PdfTables.buildRow(['Section', widget.studentSection],
//                         fontSize: 9),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               // Payment details
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(6),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: const pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: const {
//                     0: pw.FlexColumnWidth(1.3),
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     PdfTables.buildHeaderRow(['Field', 'Value'], fontSize: 9),
//                     PdfTables.buildRow(['Payment Date', widget.paymentDate],
//                         fontSize: 9),
//                     PdfTables.buildRow([
//                       'Payment Type',
//                       widget.isYearlyPayment ? 'Yearly' : 'Monthly'
//                     ], fontSize: 9),
//                     PdfTables.buildRow([
//                       'Fee Months',
//                       widget.feeMonths.isEmpty
//                           ? 'N/A'
//                           : widget.feeMonths.join(', ')
//                     ], fontSize: 9),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               // Fee breakdown
//               pw.Text(
//                 'Fee Breakdown',
//                 style: pw.TextStyle(
//                   fontSize: 12, // Reduced from 14
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.blue900,
//                 ),
//               ),
//               pw.SizedBox(height: 4),
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(6),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: const pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: const {
//                     0: pw.FlexColumnWidth(1.3),
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     PdfTables.buildHeaderRow(['Fee Name', 'Amount'],
//                         fontSize: 9),
//                     ...widget.feeItems.map((item) => PdfTables.buildRow([
//                           item['fee_name'] ?? 'Unknown',
//                           '₹${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}'
//                         ], fontSize: 9)),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               // Summary
//               pw.Text(
//                 'Summary',
//                 style: pw.TextStyle(
//                   fontSize: 12, // Reduced from 14
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.blue900,
//                 ),
//               ),
//               pw.SizedBox(height: 4),
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(6),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: const pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: const {
//                     0: pw.FlexColumnWidth(1.3),
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     PdfTables.buildHeaderRow(['Field', 'Value'], fontSize: 9),
//                     PdfTables.buildRow([
//                       'Total Amount',
//                       '₹${widget.depositAmount.toStringAsFixed(2)}'
//                     ], fontSize: 9),
//                     PdfTables.buildRow(
//                       [
//                         'Total Paid (Cumulative)',
//                         '₹${widget.totalPaid.toStringAsFixed(2)}'
//                       ],
//                       fontSize: 9,
//                       valueColor: PdfColors.green600,
//                     ),
//                     PdfTables.buildRow(
//                       ['Total Due', '₹${widget.totalDue.toStringAsFixed(2)}'],
//                       fontSize: 9,
//                       valueColor: PdfColors.red600,
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               // Signature
//               custom_signature.PdfSignature.build(compact: true),
//               pw.SizedBox(height: 8),
//               // Footer
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(6), // Reduced padding
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.lightBlue50,
//                   borderRadius: pw.BorderRadius.circular(6),
//                 ),
//                 child: pw.Text(
//                   'Thank you for your payment!',
//                   textAlign: pw.TextAlign.center,
//                   style: pw.TextStyle(
//                     fontSize: 9, // Reduced from 10
//                     fontStyle: pw.FontStyle.italic,
//                     color: PdfColors.blue,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
// }
