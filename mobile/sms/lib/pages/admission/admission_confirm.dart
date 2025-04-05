import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sms/pages/admission/admission_letter.dart';

class AdmissionConfirmationPage extends StatelessWidget {
  final Student student;

  const AdmissionConfirmationPage({Key? key, required this.student})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admission Confirmation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // School logo or header
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              color: Colors.blue.shade100,
              child: Column(
                children: [
                  Icon(Icons.school, size: 48, color: Colors.blue.shade900),
                  SizedBox(height: 8),
                  Text(
                    'ALMANET SCHOOL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Excellence in Education',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Text(
              'ADMISSION CONFIRMATION',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),

            SizedBox(height: 20),

            // Student photo
            if (student.studentPhoto.isNotEmpty)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.rectangle,
                ),
                child: student.studentPhoto.startsWith('http')
                    ? Image.network(student.studentPhoto, fit: BoxFit.cover)
                    : Image.network(
                        'http://localhost:1000/uploads/${student.studentPhoto}',
                        fit: BoxFit.cover,
                      ),
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.rectangle,
                ),
                child: Icon(Icons.person, size: 80, color: Colors.grey),
              ),

            SizedBox(height: 20),

            // Student information table
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    _buildTableCell('Student Name', true),
                    _buildTableCell(student.name, false),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Registration/ID', true),
                    _buildTableCell(student.registrationNumber, false),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Class', true),
                    _buildTableCell(
                        '${student.className} - ${student.assignedSection}',
                        false),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Admission Date', true),
                    _buildTableCell(
                        DateFormat('dd MMMM, yyyy')
                            .format(student.admissionDate),
                        false),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Account Status', true),
                    _buildTableCell('Active', false),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Username', true),
                    _buildTableCell(student.username, false, copyEnabled: true),
                  ],
                ),
                TableRow(
                  children: [
                    _buildTableCell('Password', true),
                    _buildTableCell(student.password, false, copyEnabled: true),
                  ],
                ),
              ],
            ),

            SizedBox(height: 30),

            // Print Admission Letter button
            ElevatedButton.icon(
              icon: Icon(Icons.print),
              label: Text('Print Admission Letter'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue.shade900,
              ),
              onPressed: () => _generatePdf(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHeader,
      {bool copyEnabled = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      color: isHeader ? Colors.grey.shade100 : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (copyEnabled)
            IconButton(
              icon: Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
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
    pw.MemoryImage? studentImage;
    if (student.studentPhoto.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(
          student.studentPhoto.startsWith('http')
              ? student.studentPhoto
              : 'http://localhost:1000/uploads/${student.studentPhoto}',
        ));
        if (response.statusCode == 200) {
          studentImage = pw.MemoryImage(response.bodyBytes);
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
                color: PdfColors.lightBlue50,
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
                      ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Almanet SCHOOL',
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
                'ADMISSION CONFIRMATION',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),

              pw.SizedBox(height: 20),

              // Student photo
              if (studentImage != null)
                pw.Container(
                  width: 120,
                  height: 120,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Image(studentImage, fit: pw.BoxFit.cover),
                )
              else
                pw.Container(
                  width: 120,
                  height: 120,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                ),

              pw.SizedBox(height: 20),

              // Student information table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: pw.FlexColumnWidth(1.2),
                  1: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Student Name', true),
                      _buildPdfTableCell(student.name, false),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Registration/ID', true),
                      _buildPdfTableCell(student.registrationNumber, false),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Class', true),
                      _buildPdfTableCell(
                          '${student.className} - ${student.assignedSection}',
                          false),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Admission Date', true),
                      _buildPdfTableCell(
                          DateFormat('dd MMMM, yyyy')
                              .format(student.admissionDate),
                          false),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Account Status', true),
                      _buildPdfTableCell('Active', false),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Username', true),
                      _buildPdfTableCell(student.username, false),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell('Password', true),
                      _buildPdfTableCell(student.password, false),
                    ],
                  ),
                ],
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
                      pw.Text('Principal Signature'),
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
                      pw.Text('School Stamp'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(10),
                color: PdfColors.lightBlue50,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Important Note:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Please keep this admission letter for your records. Your username and password will be required to access the student portal.',
                      textAlign: pw.TextAlign.center,
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

  pw.Widget _buildPdfTableCell(String text, bool isHeader) {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      color: isHeader ? PdfColors.grey100 : PdfColors.white,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
