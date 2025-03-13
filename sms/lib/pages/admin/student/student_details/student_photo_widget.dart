// student_photo_widget.dart
import 'package:flutter/material.dart';

Widget buildStudentPhoto(String? photoData, String baseUrl) {
  if (photoData == null || photoData.isEmpty) {
    return CircleAvatar(
      radius: 30,
      child: Icon(Icons.person),
      backgroundColor: Colors.grey[300],
    );
  }

  final urlPath = 'uploads/${photoData.replaceAll('\\', '/')}';
  final fullUrl = '$baseUrl/$urlPath';

  return Container(
    width: 60,
    height: 60,
    child: CircleAvatar(
      radius: 30,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (exception, stackTrace) {
        print('Error loading network image: $exception');
      },
      backgroundColor: Colors.grey[300],
    ),
  );
}
