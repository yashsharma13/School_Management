// student_photo_widget.dart
import 'package:flutter/material.dart';

Widget buildStudentPhoto(String? photoData, String baseUrl) {
  if (photoData == null || photoData.isEmpty) {
    return _buildDefaultAvatar();
  }

  // Clean up the photo path by removing any backslashes and ensuring it's a clean filename
  final cleanPhotoPath = photoData.replaceAll('\\', '/').split('/').last;

  // Ensure the baseUrl doesn't end with a slash
  final cleanBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  // Construct the full URL
  final fullUrl = '$cleanBaseUrl/$cleanPhotoPath';

  // print('Attempting to load image from: $fullUrl'); // Debug print to verify URL
  // print('Original photo data: $photoData');
  // print('Base URL: $baseUrl');
  // print('Clean base URL: $cleanBaseUrl');
  // print('Clean photo path: $cleanPhotoPath');

  return SizedBox(
    width: 60,
    height: 60,
    child: CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // print('Error loading network image: $exception');
        // print('Stack trace: $stackTrace');
        // print('URL that failed: $fullUrl');
        // print('Original photo data: $photoData');
        // print('Base URL: $baseUrl');
        // print('Clean base URL: $cleanBaseUrl');
        // print('Clean photo path: $cleanPhotoPath');
      },
      backgroundColor: Colors.grey[300],
      child: photoData.isNotEmpty ? null : Icon(Icons.person),
    ),
  );
}

Widget _buildDefaultAvatar() {
  return CircleAvatar(
    radius: 30,
    backgroundColor: Colors.grey[300],
    child: Icon(Icons.person, color: Colors.grey[600]),
  );
}
