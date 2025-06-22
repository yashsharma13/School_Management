import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sms/pages/teacher/Job_letter/job_letter.dart';
import 'package:sms/widgets/button.dart';

class TeacherAdmissionConfirmationPage extends StatelessWidget {
  final Teacher teacher;
  static final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  const TeacherAdmissionConfirmationPage({Key? key, required this.teacher})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Letter', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                padding: EdgeInsets.symmetric(vertical: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.school, size: 48, color: Colors.blue[900]),
                    SizedBox(height: 8),
                    Text(
                      'ALMANET SCHOOL',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 4),
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

            SizedBox(height: 24),

            Text(
              'ADMISSION CONFIRMATION',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),

            SizedBox(height: 20),

            // Student photo
            Card(
              elevation: 2,
              shape: CircleBorder(),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[200]!, width: 2),
                ),
                child: ClipOval(
                  child: teacher.teacherPhoto.isNotEmpty
                      ? teacher.teacherPhoto.startsWith('http')
                          ? Image.network(teacher.teacherPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person,
                                      size: 48, color: Colors.blue[900]))
                          : Image.network(
                              '$baseeUrl/uploads/${teacher.teacherPhoto}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person,
                                      size: 48, color: Colors.blue[900]),
                            )
                      : Icon(Icons.person, size: 48, color: Colors.blue[900]),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Student information table
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
                  columnWidths: {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      children: [
                        _buildTableCell('Teacher Name', true, context: context),
                        _buildTableCell(teacher.name, false, context: context),
                      ],
                    ),
                    // TableRow(
                    //   children: [
                    //     _buildTableCell('Admission Date', true,
                    //         context: context),
                    //     _buildTableCell(
                    //         DateFormat('dd MMMM, yyyy')
                    //             .format(teacher.admissionDate),
                    //         false,
                    //         context: context),
                    //   ],
                    // ),
                    TableRow(
                      children: [
                        _buildTableCell('Account Status', true,
                            context: context),
                        _buildTableCell('Active', false,
                            status: true, context: context),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Username', true, context: context),
                        _buildTableCell(teacher.username, false,
                            copyEnabled: true, context: context),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      children: [
                        _buildTableCell('Password', true, context: context),
                        _buildTableCell(teacher.password, false,
                            copyEnabled: true,
                            isPassword: true,
                            context: context),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

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

  Widget _buildTableCell(String text, bool isHeader,
      {required BuildContext context,
      bool copyEnabled = false,
      bool isPassword = false,
      bool status = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue[50] : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isPassword ? '••••••••' : text,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.blue[900] : Colors.blue[800],
              ),
            ),
          ),
          if (status)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (copyEnabled)
            IconButton(
              icon: Icon(Icons.copy, size: 16, color: Colors.blue[800]),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied to clipboard'),
                    backgroundColor: Colors.blue[800],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Copy to clipboard',
            ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Add school logo
    final ByteData? logoData =
        await rootBundle.load('assets/images/almanet1.jpg');
    final Uint8List? logoBytes = logoData?.buffer.asUint8List();
    final pw.MemoryImage? logoImage =
        logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    // Add student photo
    pw.MemoryImage? teacherImage;
    if (teacher.teacherPhoto.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(
          teacher.teacherPhoto.startsWith('http')
              ? teacher.teacherPhoto
              : '$baseeUrl/uploads/${teacher.teacherPhoto}',
        ));
        if (response.statusCode == 200) {
          teacherImage = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        print('Failed to load student image: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header with logo
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 16),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: PdfColors.lightBlue50,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    if (logoImage != null)
                      pw.Image(logoImage, width: 60, height: 60)
                    else
                      pw.Container(
                        width: 60,
                        height: 60,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: PdfColors.lightBlue200,
                        ),
                        child: pw.Center(
                          child: pw.Text('AS',
                              style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900)),
                        ),
                      ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'ALMANET SCHOOL',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Excellence in Education',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              pw.Text(
                'Job CONFIRMATION',
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
                child: teacherImage != null
                    ? pw.ClipOval(
                        child: pw.Image(teacherImage, fit: pw.BoxFit.cover))
                    : pw.Center(
                        child: pw.Text('PHOTO',
                            style: pw.TextStyle(color: PdfColors.blue900)),
                      ),
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
                    inside: pw.BorderSide(color: PdfColors.blue100),
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.2),
                    1: pw.FlexColumnWidth(2),
                  },
                  children: [
                    _buildPdfTableHeaderRow('Teacher Name', teacher.name),
                    // _buildPdfTableRow(
                    //     'Admission Date',
                    //     DateFormat('dd MMMM, yyyy')
                    //         .format(teacher.admissionDate)),
                    // _buildPdfTableStatusRow('Account Status', 'Active'),
                    _buildPdfTableRow('Username', teacher.username),
                    _buildPdfTableRow('Password', teacher.password),
                    //     isPassword: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),

              // Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Principal Signature',
                          style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('School Stamp',
                          style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(10),
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
                      'Please keep this admission letter for your records. Your username and password will be required to access the student portal.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(color: PdfColors.blue900),
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

  pw.TableRow _buildPdfTableHeaderRow(String header, String value) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.only(
          topLeft: pw.Radius.circular(12),
          topRight: pw.Radius.circular(12),
        ),
      ),
      children: [
        _buildPdfTableCell(header, true),
        _buildPdfTableCell(value, false),
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(String header, String value,
      {bool isPassword = false}) {
    return pw.TableRow(
      children: [
        _buildPdfTableCell(header, true),
        _buildPdfTableCell(isPassword ? '••••••••' : value, false),
      ],
    );
  }

  // pw.TableRow _buildPdfTableStatusRow(String header, String value) {
  //   return pw.TableRow(
  //     children: [
  //       _buildPdfTableCell(header, true),
  //       pw.Container(
  //         padding: pw.EdgeInsets.all(12),
  //         child: pw.Container(
  //           padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.green100,
  //             borderRadius: pw.BorderRadius.circular(12),
  //           ),
  //           child: pw.Text(
  //             value,
  //             style: pw.TextStyle(
  //               color: PdfColors.green800,
  //               fontWeight: pw.FontWeight.bold,
  //               fontSize: 10,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  pw.Widget _buildPdfTableCell(String text, bool isHeader) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blue900 : PdfColors.blue800,
        ),
      ),
    );
  }
}
