// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:sms/pages/student/admission/admission_letter.dart';
// import 'package:sms/widgets/button.dart';
// import 'package:sms/widgets/custom_appbar.dart';

// class AdmissionConfirmationPage extends StatelessWidget {
//   final Student student;
//   static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   const AdmissionConfirmationPage({Key? key, required this.student})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Admission Confirmation',
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
// // School header
// Card(
//   elevation: 3,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(12),
//   ),
//   child: Container(
//     padding: EdgeInsets.symmetric(vertical: 16),
//     width: double.infinity,
//     decoration: BoxDecoration(
//       color: Colors.blue[50],
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       children: [
//         Icon(Icons.school, size: 48, color: Colors.blue[900]),
//         SizedBox(height: 8),
//         Text(
//           'ALMANET SCHOOL',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.blue[900],
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           'Excellence in Education',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.blue[900],
//           ),
//         ),
//       ],
//     ),
//   ),
// ),

//             SizedBox(height: 24),

//             Text(
//               'ADMISSION CONFIRMATION',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[900],
//               ),
//             ),

//             SizedBox(height: 20),

//             // Student photo
//             Card(
//               elevation: 2,
//               shape: CircleBorder(),
//               child: Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.blue[200]!, width: 2),
//                 ),
//                 child: ClipOval(
//                   child: student.studentPhoto.isNotEmpty
//                       ? student.studentPhoto.startsWith('http')
//                           ? Image.network(student.studentPhoto,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.person,
//                                       size: 48, color: Colors.blue[900]))
//                           : Image.network(
//                               '$baseeUrl/uploads/${student.studentPhoto}',
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.person,
//                                       size: 48, color: Colors.blue[900]),
//                             )
//                       : Icon(Icons.person, size: 48, color: Colors.blue[900]),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Student information table
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
//                         _buildTableCell('Student Name', true, context: context),
//                         _buildTableCell(student.name, false, context: context),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Registration/ID', true,
//                             context: context),
//                         _buildTableCell(student.registrationNumber, false,
//                             context: context),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Class', true, context: context),
//                         _buildTableCell(
//                             '${student.className} - ${student.assignedSection}',
//                             false,
//                             context: context),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Admission Date', true,
//                             context: context),
//                         _buildTableCell(
//                             DateFormat('dd MMMM, yyyy')
//                                 .format(student.admissionDate),
//                             false,
//                             context: context),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Account Status', true,
//                             context: context),
//                         _buildTableCell('Active', false,
//                             status: true, context: context),
//                       ],
//                     ),
//                     TableRow(
//                       children: [
//                         _buildTableCell('Username', true, context: context),
//                         _buildTableCell(student.username, false,
//                             copyEnabled: true, context: context),
//                       ],
//                     ),
//                     TableRow(
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       children: [
//                         _buildTableCell('Password', true, context: context),
//                         _buildTableCell(student.password, false,
//                             copyEnabled: true,
//                             isPassword: true,
//                             context: context),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 30),

//             // debugPrint Admission Letter button
//             // ElevatedButton.icon(
//             //   icon: Icon(Icons.debugPrint, color: Colors.white),
//             //   label: Text('debugPrint Admission Letter',
//             //       style: TextStyle(color: Colors.white)),
//             //   style: ElevatedButton.styleFrom(
//             //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             //     backgroundColor: Colors.blue[900],
//             //     shape: RoundedRectangleBorder(
//             //       borderRadius: BorderRadius.circular(8),
//             //     ),
//             //     elevation: 3,
//             //   ),
//             //   onPressed: () => _generatePdf(context),
//             // ),
//             CustomButton(
//               text: 'Print',
//               icon: Icons.print,
//               onPressed: () async {
//                 await _generatePdf(context);
//               },
//               // color: Colors.blue.shade900,
//               width: 150,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTableCell(String text, bool isHeader,
//       {required BuildContext context,
//       bool copyEnabled = false,
//       bool isPassword = false,
//       bool status = false}) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isHeader ? Colors.blue[50] : Colors.white,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               isPassword ? '••••••••' : text,
//               style: TextStyle(
//                 fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//                 color: isHeader ? Colors.blue[900] : Colors.blue[800],
//               ),
//             ),
//           ),
//           if (status)
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Active',
//                 style: TextStyle(
//                   color: Colors.green[800],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           if (copyEnabled)
//             IconButton(
//               icon: Icon(Icons.copy, size: 16, color: Colors.blue[800]),
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: text));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Copied to clipboard'),
//                     backgroundColor: Colors.blue[800],
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     duration: Duration(seconds: 1),
//                   ),
//                 );
//               },
//               tooltip: 'Copy to clipboard',
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _generatePdf(BuildContext context) async {
//     final pdf = pw.Document();

//     // Add school logo
//     final ByteData? logoData =
//         await rootBundle.load('assets/images/almanet1.jpg');
//     final Uint8List? logoBytes = logoData?.buffer.asUint8List();
//     final pw.MemoryImage? logoImage =
//         logoBytes != null ? pw.MemoryImage(logoBytes) : null;

//     // Add student photo
//     pw.MemoryImage? studentImage;
//     if (student.studentPhoto.isNotEmpty) {
//       try {
//         final response = await http.get(Uri.parse(
//           student.studentPhoto.startsWith('http')
//               ? student.studentPhoto
//               : '$baseeUrl/uploads/${student.studentPhoto}',
//         ));
//         if (response.statusCode == 200) {
//           studentImage = pw.MemoryImage(response.bodyBytes);
//         }
//       } catch (e) {
//         debugPrint('Failed to load student image: $e');
//       }
//     }

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.center,
//             children: [
//               // Header with logo
//               pw.Container(
//                 padding: pw.EdgeInsets.symmetric(vertical: 16),
//                 width: double.infinity,
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.lightBlue50,
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     if (logoImage != null)
//                       pw.Image(logoImage, width: 60, height: 60)
//                     else
//                       pw.Container(
//                         width: 60,
//                         height: 60,
//                         decoration: pw.BoxDecoration(
//                           shape: pw.BoxShape.circle,
//                           color: PdfColors.lightBlue200,
//                         ),
//                         child: pw.Center(
//                           child: pw.Text('AS',
//                               style: pw.TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: PdfColors.blue900)),
//                         ),
//                       ),
//                     pw.SizedBox(height: 8),
//                     pw.Text(
//                       'ALMANET SCHOOL',
//                       style: pw.TextStyle(
//                         fontSize: 24,
//                         fontWeight: pw.FontWeight.bold,
//                         color: PdfColors.blue900,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       'Excellence in Education',
//                       style: pw.TextStyle(
//                         fontSize: 14,
//                         color: PdfColors.blue900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 24),

//               pw.Text(
//                 'ADMISSION CONFIRMATION',
//                 style: pw.TextStyle(
//                   fontSize: 22,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.blue900,
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Student photo
//               pw.Container(
//                 width: 120,
//                 height: 120,
//                 decoration: pw.BoxDecoration(
//                   shape: pw.BoxShape.circle,
//                   border: pw.Border.all(color: PdfColors.blue200, width: 2),
//                 ),
//                 child: studentImage != null
//                     ? pw.ClipOval(
//                         child: pw.Image(studentImage, fit: pw.BoxFit.cover))
//                     : pw.Center(
//                         child: pw.Text('PHOTO',
//                             style: pw.TextStyle(color: PdfColors.blue900)),
//                       ),
//               ),

//               pw.SizedBox(height: 20),

//               // Student information table
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: {
//                     0: pw.FlexColumnWidth(1.2),
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     _buildPdfTableHeaderRow('Student Name', student.name),
//                     _buildPdfTableRow(
//                         'Registration/ID', student.registrationNumber),
//                     _buildPdfTableRow('Class',
//                         '${student.className} - ${student.assignedSection}'),
//                     _buildPdfTableRow(
//                         'Admission Date',
//                         DateFormat('dd MMMM, yyyy')
//                             .format(student.admissionDate)),
//                     _buildPdfTableStatusRow('Account Status', 'Active'),
//                     _buildPdfTableRow('Username', student.username),
//                     _buildPdfTableRow('Password', student.password,
//                         isPassword: true),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 40),

//               // Signature
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.center,
//                     children: [
//                       pw.Container(
//                         width: 150,
//                         height: 1,
//                         color: PdfColors.black,
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text('Principal Signature',
//                           style: pw.TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.center,
//                     children: [
//                       pw.Container(
//                         width: 150,
//                         height: 1,
//                         color: PdfColors.black,
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text('School Stamp',
//                           style: pw.TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ],
//               ),

//               pw.SizedBox(height: 40),

//               pw.Container(
//                 width: double.infinity,
//                 padding: pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.lightBlue50,
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Text(
//                       'Important Note:',
//                       style: pw.TextStyle(
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.blue900),
//                     ),
//                     pw.SizedBox(height: 5),
//                     pw.Text(
//                       'Please keep this admission letter for your records. Your username and password will be required to access the student portal.',
//                       textAlign: pw.TextAlign.center,
//                       style: pw.TextStyle(color: PdfColors.blue900),
//                     ),
//                   ],
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

//   pw.TableRow _buildPdfTableHeaderRow(String header, String value) {
//     return pw.TableRow(
//       decoration: pw.BoxDecoration(
//         color: PdfColors.blue50,
//         borderRadius: pw.BorderRadius.only(
//           topLeft: pw.Radius.circular(12),
//           topRight: pw.Radius.circular(12),
//         ),
//       ),
//       children: [
//         _buildPdfTableCell(header, true),
//         _buildPdfTableCell(value, false),
//       ],
//     );
//   }

//   pw.TableRow _buildPdfTableRow(String header, String value,
//       {bool isPassword = false}) {
//     return pw.TableRow(
//       children: [
//         _buildPdfTableCell(header, true),
//         _buildPdfTableCell(isPassword ? '••••••••' : value, false),
//       ],
//     );
//   }

//   pw.TableRow _buildPdfTableStatusRow(String header, String value) {
//     return pw.TableRow(
//       children: [
//         _buildPdfTableCell(header, true),
//         pw.Container(
//           padding: pw.EdgeInsets.all(12),
//           child: pw.Container(
//             padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.green100,
//               borderRadius: pw.BorderRadius.circular(12),
//             ),
//             child: pw.Text(
//               value,
//               style: pw.TextStyle(
//                 color: PdfColors.green800,
//                 fontWeight: pw.FontWeight.bold,
//                 fontSize: 10,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildPdfTableCell(String text, bool isHeader) {
//     return pw.Container(
//       padding: pw.EdgeInsets.all(12),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: isHeader ? PdfColors.blue900 : PdfColors.blue800,
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/student/admission/admission_letter.dart';
// import 'package:sms/widgets/button.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/pages/services/profile_service.dart';

// class AdmissionConfirmationPage extends StatefulWidget {
//   final Student student;
//   static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   const AdmissionConfirmationPage({Key? key, required this.student})
//       : super(key: key);

//   @override
//   _AdmissionConfirmationPageState createState() =>
//       _AdmissionConfirmationPageState();
// }

// class _AdmissionConfirmationPageState extends State<AdmissionConfirmationPage> {
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
//             final cleanBaseUrl = AdmissionConfirmationPage.baseeUrl
//                     .endsWith('/')
//                 ? AdmissionConfirmationPage.baseeUrl
//                     .substring(0, AdmissionConfirmationPage.baseeUrl.length - 1)
//                 : AdmissionConfirmationPage.baseeUrl;
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
//       appBar: const CustomAppBar(
//         title: 'Admission Confirmation',
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // School header (will be replaced with reusable widget)
//                   Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           _buildLogoImage(size: 72),
//                           const SizedBox(height: 8),
//                           Text(
//                             instituteName ?? 'ALMANET SCHOOL',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue[900],
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Excellence in Education',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue[900],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   Text(
//                     'ADMISSION CONFIRMATION',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[900],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Student photo
//                   Card(
//                     elevation: 2,
//                     shape: const CircleBorder(),
//                     child: Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.blue[200]!, width: 2),
//                       ),
//                       child: ClipOval(
//                         child: widget.student.studentPhoto.isNotEmpty
//                             ? Image.network(
//                                 widget.student.studentPhoto.startsWith('http')
//                                     ? widget.student.studentPhoto
//                                     : '${AdmissionConfirmationPage.baseeUrl}/uploads/${widget.student.studentPhoto}',
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Icon(Icons.person,
//                                         size: 48, color: Colors.blue[900]),
//                               )
//                             : Icon(Icons.person,
//                                 size: 48, color: Colors.blue[900]),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Student information table
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.blue[100]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Table(
//                         border: TableBorder.all(
//                           color: Colors.blue[100]!,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         columnWidths: const {
//                           0: FlexColumnWidth(1.2),
//                           1: FlexColumnWidth(2),
//                         },
//                         children: [
//                           TableRow(
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(12),
//                                 topRight: Radius.circular(12),
//                               ),
//                             ),
//                             children: [
//                               _buildTableCell('Student Name', true,
//                                   context: context),
//                               _buildTableCell(widget.student.name, false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Registration/ID', true,
//                                   context: context),
//                               _buildTableCell(
//                                   widget.student.registrationNumber, false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Class', true, context: context),
//                               _buildTableCell(
//                                   '${widget.student.className} - ${widget.student.assignedSection}',
//                                   false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Admission Date', true,
//                                   context: context),
//                               _buildTableCell(
//                                   DateFormat('dd MMMM, yyyy')
//                                       .format(widget.student.admissionDate),
//                                   false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Account Status', true,
//                                   context: context),
//                               _buildTableCell('Active', false,
//                                   status: true, context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Username', true,
//                                   context: context),
//                               _buildTableCell(widget.student.username, false,
//                                   copyEnabled: true, context: context),
//                             ],
//                           ),
//                           TableRow(
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: const BorderRadius.only(
//                                 bottomLeft: Radius.circular(12),
//                                 bottomRight: Radius.circular(12),
//                               ),
//                             ),
//                             children: [
//                               _buildTableCell('Password', true,
//                                   context: context),
//                               _buildTableCell(widget.student.password, false,
//                                   copyEnabled: true,
//                                   isPassword: true,
//                                   context: context),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   CustomButton(
//                     text: 'Print',
//                     icon: Icons.print,
//                     width: 150,
//                     onPressed: () => _generatePdf(context),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildLogoImage({double size = 72}) {
//     if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
//       return ClipOval(
//         child: Image.network(
//           logoUrlFull!,
//           width: size,
//           height: size,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             debugPrint('Error loading logo: $error');
//             return Container(
//               width: size,
//               height: size,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.blueAccent,
//               ),
//               child: Icon(Icons.school, size: size / 2, color: Colors.white),
//             );
//           },
//         ),
//       );
//     } else {
//       return Container(
//         width: size,
//         height: size,
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.blueAccent,
//         ),
//         child: Icon(Icons.school, size: size / 2, color: Colors.white),
//       );
//     }
//   }

//   Widget _buildTableCell(String text, bool isHeader,
//       {required BuildContext context,
//       bool copyEnabled = false,
//       bool isPassword = false,
//       bool status = false}) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isHeader ? Colors.blue[50] : Colors.white,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               isPassword ? '••••••••' : text,
//               style: TextStyle(
//                 fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//                 color: isHeader ? Colors.blue[900] : Colors.blue[800],
//               ),
//             ),
//           ),
//           if (status)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Active',
//                 style: TextStyle(
//                   color: Colors.green[800],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           if (copyEnabled)
//             IconButton(
//               icon: Icon(Icons.copy, size: 16, color: Colors.blue[800]),
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: text));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Copied to clipboard'),
//                     backgroundColor: Colors.blue[800],
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     duration: const Duration(seconds: 1),
//                   ),
//                 );
//               },
//               tooltip: 'Copy to clipboard',
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _generatePdf(BuildContext context) async {
//     final pdf = pw.Document();

//     // Load school logo
//     pw.MemoryImage? logoImage;
//     if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
//       try {
//         final response = await http.get(Uri.parse(logoUrlFull!));
//         if (response.statusCode == 200) {
//           logoImage = pw.MemoryImage(response.bodyBytes);
//         }
//       } catch (e) {
//         debugPrint('Failed to load logo image: $e');
//       }
//     }

//     // Load student photo
//     pw.MemoryImage? studentImage;
//     if (widget.student.studentPhoto.isNotEmpty) {
//       try {
//         final response = await http.get(Uri.parse(
//           widget.student.studentPhoto.startsWith('http')
//               ? widget.student.studentPhoto
//               : '${AdmissionConfirmationPage.baseeUrl}/uploads/${widget.student.studentPhoto}',
//         ));
//         if (response.statusCode == 200) {
//           studentImage = pw.MemoryImage(response.bodyBytes);
//         }
//       } catch (e) {
//         debugPrint('Failed to load student image: $e');
//       }
//     }

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.center,
//             children: [
//               // Header with logo
//               pw.Container(
//                 padding: const pw.EdgeInsets.symmetric(vertical: 16),
//                 width: double.infinity,
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.lightBlue50,
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     if (logoImage != null)
//                       pw.Image(logoImage, width: 60, height: 60)
//                     else
//                       pw.Container(
//                         width: 60,
//                         height: 60,
//                         decoration: const pw.BoxDecoration(
//                           shape: pw.BoxShape.circle,
//                           color: PdfColors.lightBlue200,
//                         ),
//                         child: pw.Center(
//                           child: pw.Text('AS',
//                               style: pw.TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: PdfColors.blue900)),
//                         ),
//                       ),
//                     pw.SizedBox(height: 8),
//                     pw.Text(
//                       instituteName ?? 'ALMANET SCHOOL',
//                       style: pw.TextStyle(
//                         fontSize: 24,
//                         fontWeight: pw.FontWeight.bold,
//                         color: PdfColors.blue900,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       'Excellence in Education',
//                       style: const pw.TextStyle(
//                         fontSize: 14,
//                         color: PdfColors.blue900,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 24),

//               pw.Text(
//                 'ADMISSION CONFIRMATION',
//                 style: pw.TextStyle(
//                   fontSize: 22,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.blue900,
//                 ),
//               ),

//               pw.SizedBox(height: 20),

//               // Student photo
//               pw.Container(
//                 width: 120,
//                 height: 120,
//                 decoration: pw.BoxDecoration(
//                   shape: pw.BoxShape.circle,
//                   border: pw.Border.all(color: PdfColors.blue200, width: 2),
//                 ),
//                 child: studentImage != null
//                     ? pw.ClipOval(
//                         child: pw.Image(studentImage, fit: pw.BoxFit.cover))
//                     : pw.Center(
//                         child: pw.Text('PHOTO',
//                             style:
//                                 const pw.TextStyle(color: PdfColors.blue900)),
//                       ),
//               ),

//               pw.SizedBox(height: 20),

//               // Student information table
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: const pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: const {
//                     0: pw.FlexColumnWidth(1.2),
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     _buildPdfTableHeaderRow(
//                         'Student Name', widget.student.name),
//                     _buildPdfTableRow(
//                         'Registration/ID', widget.student.registrationNumber),
//                     _buildPdfTableRow('Class',
//                         '${widget.student.className} - ${widget.student.assignedSection}'),
//                     _buildPdfTableRow(
//                         'Admission Date',
//                         DateFormat('dd MMMM, yyyy')
//                             .format(widget.student.admissionDate)),
//                     _buildPdfTableStatusRow('Account Status', 'Active'),
//                     _buildPdfTableRow('Username', widget.student.username),
//                     _buildPdfTableRow('Password', widget.student.password,
//                         isPassword: true),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 40),

//               // Signature
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.center,
//                     children: [
//                       pw.Container(
//                         width: 150,
//                         height: 1,
//                         color: PdfColors.black,
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text('Principal Signature',
//                           style: const pw.TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.center,
//                     children: [
//                       pw.Container(
//                         width: 150,
//                         height: 1,
//                         color: PdfColors.black,
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text('School Stamp',
//                           style: const pw.TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ],
//               ),

//               pw.SizedBox(height: 40),

//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.lightBlue50,
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Text(
//                       'Important Note:',
//                       style: pw.TextStyle(
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.blue900),
//                     ),
//                     pw.SizedBox(height: 5),
//                     pw.Text(
//                       'Please keep this admission letter for your records. Your username and password will be required to access the student portal.',
//                       textAlign: pw.TextAlign.center,
//                       style: const pw.TextStyle(color: PdfColors.blue900),
//                     ),
//                   ],
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

//   pw.TableRow _buildPdfTableHeaderRow(String header, String value) {
//     return pw.TableRow(
//       decoration: const pw.BoxDecoration(
//         color: PdfColors.blue50,
//         borderRadius: pw.BorderRadius.only(
//           topLeft: pw.Radius.circular(12),
//           topRight: pw.Radius.circular(12),
//         ),
//       ),
//       children: [
//         _buildPdfTableCell(header, true),
//         _buildPdfTableCell(value, false),
//       ],
//     );
//   }

//   pw.TableRow _buildPdfTableRow(String header, String value,
//       {bool isPassword = false}) {
//     return pw.TableRow(
//       children: [
//         _buildPdfTableCell(header, true),
//         _buildPdfTableCell(isPassword ? '••••••••' : value, false),
//       ],
//     );
//   }

//   pw.TableRow _buildPdfTableStatusRow(String header, String value) {
//     return pw.TableRow(
//       children: [
//         _buildPdfTableCell(header, true),
//         pw.Container(
//           padding: const pw.EdgeInsets.all(12),
//           child: pw.Container(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.green100,
//               borderRadius: pw.BorderRadius.circular(12),
//             ),
//             child: pw.Text(
//               value,
//               style: pw.TextStyle(
//                 color: PdfColors.green800,
//                 fontWeight: pw.FontWeight.bold,
//                 fontSize: 10,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _buildPdfTableCell(String text, bool isHeader) {
//     return pw.Container(
//       padding: const pw.EdgeInsets.all(12),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: isHeader ? PdfColors.blue900 : PdfColors.blue800,
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sms/pages/student/admission/admission_letter.dart';
// import 'package:sms/widgets/button.dart';
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:sms/pages/services/profile_service.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_header.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_tables.dart';
// import 'package:sms/widgets/pdf_widgets/pdf_signature.dart' as custom_signature;
// import 'package:sms/widgets/pdf_widgets/pdf_utils.dart';

// class AdmissionConfirmationPage extends StatefulWidget {
//   final Student student;
//   static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   const AdmissionConfirmationPage({super.key, required this.student});

//   @override
//   _AdmissionConfirmationPageState createState() =>
//       _AdmissionConfirmationPageState();
// }

// class _AdmissionConfirmationPageState extends State<AdmissionConfirmationPage> {
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
//             final cleanBaseUrl = AdmissionConfirmationPage.baseeUrl
//                     .endsWith('/')
//                 ? AdmissionConfirmationPage.baseeUrl
//                     .substring(0, AdmissionConfirmationPage.baseeUrl.length - 1)
//                 : AdmissionConfirmationPage.baseeUrl;
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
//       appBar: const CustomAppBar(
//         title: 'Admission Confirmation',
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // School header
//                   Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           _buildLogoImage(size: 72),
//                           const SizedBox(height: 8),
//                           Text(
//                             instituteName ?? 'ALMANET SCHOOL',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue[900],
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Excellence in Education',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue[900],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   Text(
//                     'ADMISSION CONFIRMATION',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[900],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Student photo
//                   Card(
//                     elevation: 2,
//                     shape: const CircleBorder(),
//                     child: Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.blue[200]!, width: 2),
//                       ),
//                       child: ClipOval(
//                         child: widget.student.studentPhoto.isNotEmpty
//                             ? Image.network(
//                                 widget.student.studentPhoto.startsWith('http')
//                                     ? widget.student.studentPhoto
//                                     : '${AdmissionConfirmationPage.baseeUrl}/uploads/${widget.student.studentPhoto}',
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Icon(Icons.person,
//                                         size: 48, color: Colors.blue[900]),
//                               )
//                             : Icon(Icons.person,
//                                 size: 48, color: Colors.blue[900]),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Student information table
//                   Card(
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.blue[100]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Table(
//                         border: TableBorder.all(
//                           color: Colors.blue[100]!,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         columnWidths: const {
//                           0: FlexColumnWidth(1.2),
//                           1: FlexColumnWidth(2),
//                         },
//                         children: [
//                           TableRow(
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(12),
//                                 topRight: Radius.circular(12),
//                               ),
//                             ),
//                             children: [
//                               _buildTableCell('Student Name', true,
//                                   context: context),
//                               _buildTableCell(widget.student.name, false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Registration/ID', true,
//                                   context: context),
//                               _buildTableCell(
//                                   widget.student.registrationNumber, false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Class', true, context: context),
//                               _buildTableCell(
//                                   '${widget.student.className} - ${widget.student.assignedSection}',
//                                   false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Admission Date', true,
//                                   context: context),
//                               _buildTableCell(
//                                   DateFormat('dd MMMM, yyyy')
//                                       .format(widget.student.admissionDate),
//                                   false,
//                                   context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Account Status', true,
//                                   context: context),
//                               _buildTableCell('Active', false,
//                                   status: true, context: context),
//                             ],
//                           ),
//                           TableRow(
//                             children: [
//                               _buildTableCell('Username', true,
//                                   context: context),
//                               _buildTableCell(widget.student.username, false,
//                                   copyEnabled: true, context: context),
//                             ],
//                           ),
//                           TableRow(
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: const BorderRadius.only(
//                                 bottomLeft: Radius.circular(12),
//                                 bottomRight: Radius.circular(12),
//                               ),
//                             ),
//                             children: [
//                               _buildTableCell('Password', true,
//                                   context: context),
//                               _buildTableCell(widget.student.password, false,
//                                   copyEnabled: true,
//                                   isPassword: true,
//                                   context: context),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   CustomButton(
//                     text: 'Print',
//                     icon: Icons.print,
//                     width: 150,
//                     onPressed: () => _generatePdf(context),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildLogoImage({double size = 72}) {
//     if (logoUrlFull != null && logoUrlFull!.isNotEmpty) {
//       return ClipOval(
//         child: Image.network(
//           logoUrlFull!,
//           width: size,
//           height: size,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             debugPrint('Error loading logo: $error');
//             return Container(
//               width: size,
//               height: size,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.blueAccent,
//               ),
//               child: Icon(Icons.school, size: size / 2, color: Colors.white),
//             );
//           },
//         ),
//       );
//     } else {
//       return Container(
//         width: size,
//         height: size,
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.blueAccent,
//         ),
//         child: Icon(Icons.school, size: size / 2, color: Colors.white),
//       );
//     }
//   }

//   Widget _buildTableCell(String text, bool isHeader,
//       {required BuildContext context,
//       bool copyEnabled = false,
//       bool isPassword = false,
//       bool status = false}) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isHeader ? Colors.blue[50] : Colors.white,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               isPassword ? '••••••••' : text,
//               style: TextStyle(
//                 fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//                 color: isHeader ? Colors.blue[900] : Colors.blue[800],
//               ),
//             ),
//           ),
//           if (status)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Active',
//                 style: TextStyle(
//                   color: Colors.green[800],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           if (copyEnabled)
//             IconButton(
//               icon: Icon(Icons.copy, size: 16, color: Colors.blue[800]),
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: text));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Copied to clipboard'),
//                     backgroundColor: Colors.blue[800],
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     duration: const Duration(seconds: 1),
//                   ),
//                 );
//               },
//               tooltip: 'Copy to clipboard',
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _generatePdf(BuildContext context) async {
//     final pdf = pw.Document();
//     final instituteName = await PdfUtils.fetchInstituteName();
//     final logoUrl = await PdfUtils.fetchLogoUrl();
//     final logoImage =
//         logoUrl != null ? await PdfUtils.fetchImage(logoUrl) : null;

//     // Load student photo
//     pw.MemoryImage? studentImage;
//     if (widget.student.studentPhoto.isNotEmpty) {
//       final photoUrl = widget.student.studentPhoto.startsWith('http')
//           ? widget.student.studentPhoto
//           : '${AdmissionConfirmationPage.baseeUrl}/uploads/${widget.student.studentPhoto}';
//       studentImage = await PdfUtils.fetchImage(photoUrl);
//     }

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.center,
//             children: [
//               PdfHeader.build(
//                 instituteName: instituteName!,
//                 logoImage: logoImage,
//               ),

//               pw.SizedBox(height: 24),
//               pw.Text(
//                 'ADMISSION CONFIRMATION',
//                 style: pw.TextStyle(
//                   fontSize: 22,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.blue900,
//                 ),
//               ),

//               pw.SizedBox(height: 20),
//               // Student photo
//               pw.Container(
//                 width: 120,
//                 height: 120,
//                 decoration: pw.BoxDecoration(
//                   shape: pw.BoxShape.circle,
//                   border: pw.Border.all(color: PdfColors.blue200, width: 2),
//                 ),
//                 child: studentImage != null
//                     ? pw.ClipOval(
//                         child: pw.Image(studentImage, fit: pw.BoxFit.cover))
//                     : pw.Center(child: pw.Text('PHOTO')),
//               ),

//               pw.SizedBox(height: 20),
//               // Student information table
//               pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.blue100),
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Table(
//                   border: pw.TableBorder.symmetric(
//                     inside: const pw.BorderSide(color: PdfColors.blue100),
//                   ),
//                   columnWidths: const {
//                     0: pw.FlexColumnWidth(1.2),
//                     1: pw.FlexColumnWidth(2),
//                   },
//                   children: [
//                     PdfTables.buildHeaderRow(['Field', 'Value']),
//                     PdfTables.buildRow(['Student Name', widget.student.name]),
//                     PdfTables.buildRow(
//                         ['Registration/ID', widget.student.registrationNumber]),
//                     PdfTables.buildRow([
//                       'Class',
//                       '${widget.student.className} - ${widget.student.assignedSection}'
//                     ]),
//                     PdfTables.buildStatusRow('Account Status', 'Active'),
//                     PdfTables.buildRow(['Username', widget.student.username]),
//                     PdfTables.buildRow(['Password', '••••••••']),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 40),
//               custom_signature.PdfSignature.build(),

//               pw.SizedBox(height: 40),
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(10),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.lightBlue50,
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Text('Important Note:',
//                         style: pw.TextStyle(
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColors.blue900)),
//                     pw.SizedBox(height: 5),
//                     pw.Text(
//                       'Please keep this admission letter for your records...',
//                       textAlign: pw.TextAlign.center,
//                       style: const pw.TextStyle(color: PdfColors.blue900),
//                     ),
//                   ],
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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/student/admission/admission_letter.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/pages/services/profile_service.dart';
import 'package:sms/widgets/pdf_widgets/pdf_header.dart';
import 'package:sms/widgets/pdf_widgets/pdf_tables.dart';
import 'package:sms/widgets/pdf_widgets/pdf_signature.dart' as custom_signature;
import 'package:sms/widgets/pdf_widgets/pdf_utils.dart';
import 'package:sms/widgets/pdf_widgets/pdf_photo.dart';
import 'package:sms/widgets/pdf_widgets/pdf_info_table.dart';
import 'package:sms/widgets/pdf_widgets/school_header.dart';

class AdmissionConfirmationPage extends StatefulWidget {
  final Student student;
  static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  const AdmissionConfirmationPage({super.key, required this.student});

  @override
  _AdmissionConfirmationPageState createState() =>
      _AdmissionConfirmationPageState();
}

class _AdmissionConfirmationPageState extends State<AdmissionConfirmationPage> {
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
            final cleanBaseUrl = AdmissionConfirmationPage.baseeUrl
                    .endsWith('/')
                ? AdmissionConfirmationPage.baseeUrl
                    .substring(0, AdmissionConfirmationPage.baseeUrl.length - 1)
                : AdmissionConfirmationPage.baseeUrl;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admission Confirmation',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // School header
                  SchoolHeader(
                    instituteName: instituteName,
                    logoUrl: logoUrlFull,
                    logoSize: 72,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ADMISSION CONFIRMATION',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Student photo
                  ProfilePhoto(
                    photoUrl: widget.student.studentPhoto,
                    baseUrl: AdmissionConfirmationPage.baseeUrl,
                    size: 120,
                  ),
                  const SizedBox(height: 20),
                  // Student information table
                  InfoTable(
                    context: context,
                    rows: [
                      {
                        'text': 'Student Name',
                        'value': widget.student.name,
                        'isHeader': true,
                      },
                      {
                        'text': 'Registration/ID',
                        'value': widget.student.registrationNumber,
                        'isHeader': false,
                      },
                      {
                        'text': 'Class',
                        'value':
                            '${widget.student.className} - ${widget.student.assignedSection}',
                        'isHeader': false,
                      },
                      {
                        'text': 'Admission Date',
                        'value': DateFormat('dd MMMM, yyyy')
                            .format(widget.student.admissionDate),
                        'isHeader': false,
                      },
                      {
                        'text': 'Account Status',
                        'value': 'Active',
                        'isHeader': false,
                        'status': true,
                      },
                      {
                        'text': 'Username',
                        'value': widget.student.username,
                        'isHeader': false,
                        'copyEnabled': true,
                      },
                      {
                        'text': 'Password',
                        'value': widget.student.password,
                        'isHeader': false,
                        'copyEnabled': true,
                        'isPassword': true,
                      },
                    ],
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Print',
                    icon: Icons.print,
                    width: 150,
                    onPressed: () => _generatePdf(context),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final instituteName = await PdfUtils.fetchInstituteName();
    final logoUrl = await PdfUtils.fetchLogoUrl();
    final logoImage =
        logoUrl != null ? await PdfUtils.fetchImage(logoUrl) : null;

    // Load student photo
    pw.MemoryImage? studentImage;
    if (widget.student.studentPhoto.isNotEmpty) {
      final photoUrl = widget.student.studentPhoto.startsWith('http')
          ? widget.student.studentPhoto
          : '${AdmissionConfirmationPage.baseeUrl}/Uploads/${widget.student.studentPhoto}';
      studentImage = await PdfUtils.fetchImage(photoUrl);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              PdfHeader.build(
                instituteName: instituteName!,
                logoImage: logoImage,
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'ADMISSION CONFIRMATION',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 20),
              // Student photo
              pw.Container(
                width: 120,
                height: 120,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.blue200, width: 2),
                ),
                child: studentImage != null
                    ? pw.ClipOval(
                        child: pw.Image(studentImage, fit: pw.BoxFit.cover))
                    : pw.Center(child: pw.Text('PHOTO')),
              ),
              pw.SizedBox(height: 20),
              // Student information table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue100),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: const pw.BorderSide(color: PdfColors.blue100),
                  ),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(1.2),
                    1: pw.FlexColumnWidth(2),
                  },
                  children: [
                    PdfTables.buildHeaderRow(['Field', 'Value']),
                    PdfTables.buildRow(['Student Name', widget.student.name]),
                    PdfTables.buildRow(
                        ['Registration/ID', widget.student.registrationNumber]),
                    PdfTables.buildRow([
                      'Class',
                      '${widget.student.className} - ${widget.student.assignedSection}'
                    ]),
                    PdfTables.buildStatusRow('Account Status', 'Active'),
                    PdfTables.buildRow(['Username', widget.student.username]),
                    PdfTables.buildRow(['Password', '••••••••']),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              custom_signature.PdfSignature.build(),
              pw.SizedBox(height: 40),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.lightBlue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Important Note:',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Please keep this admission letter for your records...',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(color: PdfColors.blue900),
                    ),
                  ],
                ),
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
}
