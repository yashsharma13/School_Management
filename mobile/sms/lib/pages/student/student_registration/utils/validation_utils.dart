// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ValidationUtils {
//   static String? validateName(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'This field is required';
//     }
//     return null;
//   }

//   static String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter email';
//     }
//     String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
//     RegExp regex = RegExp(pattern);
//     if (!regex.hasMatch(value)) {
//       return 'Enter a valid email address';
//     }
//     return null;
//   }

//   static String? validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter phone number';
//     }
//     if (value.length != 10) {
//       return 'Phone number must be 10 digits';
//     }
//     return null;
//   }

//   static bool validateAge(String birthDateString, BuildContext context) {
//     try {
//       // Parse the date string
//       DateTime birthDate = DateFormat('dd-MM-yyyy').parse(birthDateString);

//       // Calculate age
//       DateTime today = DateTime.now();
//       int age = today.year - birthDate.year;
//       if (today.month < birthDate.month ||
//           (today.month == birthDate.month && today.day < birthDate.day)) {
//         age--;
//       }

//       // Check if age is at least 5 years
//       if (age < 5) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Student must be at least 5 years old')));
//         return false;
//       }

//       return true;
//     } catch (e) {
//       print('Error parsing date: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Invalid date format')));
//       return false;
//     }
//   }

//   static String formatDateForDatabase(String userDateString) {
//     // Convert from dd-MM-yyyy to yyyy-MM-dd
//     DateTime date = DateFormat('dd-MM-yyyy').parse(userDateString);
//     return DateFormat('yyyy-MM-dd').format(date);
//   }
// }
