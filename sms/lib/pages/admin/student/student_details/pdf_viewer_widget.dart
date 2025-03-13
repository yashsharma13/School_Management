// pdf_viewer_widget.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfData;
  final String baseUrl;

  PDFViewerScreen({required this.pdfData, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Birth Certificate')),
      body: _buildPDFViewer(context),
    );
  }

  Widget _buildPDFViewer(BuildContext context) {
    if (pdfData.isEmpty) {
      return Center(child: Text('No PDF available'));
    }

    final urlPath = 'uploads/${pdfData.replaceAll('\\', '/')}';
    final fullUrl = '$baseUrl/$urlPath';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Birth Certificate PDF'),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.open_in_new),
            label: Text('View PDF'),
            onPressed: () async {
              try {
                final Uri url = Uri.parse(fullUrl);
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Could not open PDF. Please check if you have a PDF viewer installed.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                print('Error launching URL: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error opening PDF: $e'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
