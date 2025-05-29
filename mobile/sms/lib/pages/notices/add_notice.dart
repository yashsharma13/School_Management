// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';

// class AddNoticePage extends StatefulWidget {
//   @override
//   _AddNoticePageState createState() => _AddNoticePageState();
// }

// class _AddNoticePageState extends State<AddNoticePage> {
//   final _formKey = GlobalKey<FormState>();

//   String title = '';
//   String content = '';
//   String category = '';
//   String priority = 'medium';
//   DateTime selectedDate = DateTime.now();

//   bool isSubmitting = false;
//   String error = '';
//   String success = '';

//   Future<void> submitNotice() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       isSubmitting = true;
//       error = '';
//       success = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) {
//         setState(() => error = 'You must be logged in.');
//         return;
//       }

//       final body = {
//         'title': title,
//         'content': content,
//         'category': category,
//         'priority': priority,
//         'notice_date': selectedDate.toIso8601String().split('T')[0],
//       };
//       print('Sending Notice: $body');

//       final response = await http.post(
//         Uri.parse('http://localhost:1000/api/notices'),
//         headers: {
//           'Authorization': token,
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(body),
//       );

//       final resData = json.decode(response.body);

//       if (response.statusCode < 200 || response.statusCode >= 300) {
//         throw Exception(resData['error'] ?? 'Failed to create notice.');
//       }

//       setState(() {
//         success = 'Notice created successfully!';
//       });

//       Future.delayed(Duration(seconds: 2), () {
//         Navigator.pop(context); // go back to notice list
//       });
//     } catch (e) {
//       setState(() => error = e.toString());
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }

//   Future<void> pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2023),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) setState(() => selectedDate = picked);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create New Notice'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             if (error.isNotEmpty)
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                     color: Colors.red[50],
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.red),
//                     SizedBox(width: 8),
//                     Expanded(
//                         child:
//                             Text(error, style: TextStyle(color: Colors.red))),
//                   ],
//                 ),
//               ),
//             if (success.isNotEmpty)
//               Container(
//                 padding: EdgeInsets.all(12),
//                 margin: EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green),
//                     SizedBox(width: 8),
//                     Expanded(
//                         child: Text(success,
//                             style: TextStyle(color: Colors.green[800]))),
//                   ],
//                 ),
//               ),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Title
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Title'),
//                     onChanged: (val) => setState(() => title = val),
//                     validator: (val) =>
//                         val == null || val.isEmpty ? 'Title is required' : null,
//                   ),

//                   SizedBox(height: 16),

//                   // Content
//                   TextFormField(
//                     decoration: InputDecoration(labelText: 'Content'),
//                     maxLines: 4,
//                     onChanged: (val) => setState(() => content = val),
//                     validator: (val) => val == null || val.isEmpty
//                         ? 'Content is required'
//                         : null,
//                   ),

//                   SizedBox(height: 16),

//                   // Date
//                   ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: Text(
//                         "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
//                     trailing: Icon(Icons.calendar_today),
//                     onTap: pickDate,
//                   ),

//                   SizedBox(height: 16),

//                   // Category
//                   DropdownButtonFormField<String>(
//                     value: category.isEmpty ? null : category,
//                     hint: Text('Select Category'),
//                     items: [
//                       DropdownMenuItem(
//                           value: 'Holiday', child: Text('🎉 Holiday')),
//                       DropdownMenuItem(
//                           value: 'Meeting', child: Text('👥 Meeting')),
//                       DropdownMenuItem(value: 'Event', child: Text('🎪 Event')),
//                       DropdownMenuItem(value: 'Exam', child: Text('📝 Exam')),
//                       DropdownMenuItem(
//                           value: 'General', child: Text('📢 General')),
//                     ],
//                     onChanged: (val) => setState(() => category = val ?? ''),
//                     validator: (val) => val == null || val.isEmpty
//                         ? 'Please select a category'
//                         : null,
//                   ),

//                   SizedBox(height: 16),

//                   // Priority
//                   DropdownButtonFormField<String>(
//                     value: priority,
//                     decoration: InputDecoration(labelText: 'Priority'),
//                     items: [
//                       DropdownMenuItem(
//                           value: 'low', child: Text('🟢 Low Priority')),
//                       DropdownMenuItem(
//                           value: 'medium', child: Text('🟡 Medium Priority')),
//                       DropdownMenuItem(
//                           value: 'high', child: Text('🔴 High Priority')),
//                     ],
//                     onChanged: (val) =>
//                         setState(() => priority = val ?? 'medium'),
//                   ),

//                   SizedBox(height: 24),

//                   // Submit Button
//                   ElevatedButton.icon(
//                     onPressed: isSubmitting ? null : submitNotice,
//                     icon: isSubmitting
//                         ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white),
//                           )
//                         : Icon(Icons.send),
//                     label:
//                         Text(isSubmitting ? 'Submitting...' : 'Create Notice'),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(double.infinity, 50),
//                       backgroundColor: Colors.blueAccent,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddNoticePage extends StatefulWidget {
  @override
  _AddNoticePageState createState() => _AddNoticePageState();
}

class _AddNoticePageState extends State<AddNoticePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String title = '';
  String content = '';
  String category = '';
  String priority = 'medium';
  DateTime selectedDate = DateTime.now();

  bool isSubmitting = false;
  String error = '';
  String success = '';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> submitNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      error = '';
      success = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => error = 'You must be logged in to create a notice.');
        return;
      }

      final body = {
        'title': title,
        'content': content,
        'category': category,
        'priority': priority,
        'notice_date': selectedDate.toIso8601String().split('T')[0],
      };

      final response = await http.post(
        Uri.parse('http://localhost:1000/api/notices'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final resData = json.decode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(resData['error'] ?? 'Failed to create notice.');
      }

      setState(() {
        success = 'Notice created successfully!';
      });

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context, true); // Return true to indicate success
      });
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Notice', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16),

                // Status Messages
                if (error.isNotEmpty)
                  _buildStatusCard(
                    context,
                    message: error,
                    isError: true,
                  ),
                if (success.isNotEmpty)
                  _buildStatusCard(
                    context,
                    message: success,
                    isError: false,
                  ),

                SizedBox(height: 16),

                // Title Field
                Text(
                  'Notice Title',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter notice title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: theme.textTheme.bodyLarge,
                  onChanged: (val) => setState(() => title = val),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Title is required' : null,
                ),

                SizedBox(height: 20),

                // Content Field
                Text(
                  'Notice Content',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Enter notice details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: 5,
                  style: theme.textTheme.bodyLarge,
                  onChanged: (val) => setState(() => content = val),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Content is required' : null,
                ),

                SizedBox(height: 20),

                // Date Picker
                Text(
                  'Notice Date',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(10),
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(selectedDate),
                          style: theme.textTheme.bodyLarge,
                        ),
                        Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Category Dropdown
                Text(
                  'Category',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: category.isEmpty ? null : category,
                  hint: Text('Select a category'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'Holiday', child: Text('🎉 Holiday')),
                    DropdownMenuItem(
                        value: 'Meeting', child: Text('👥 Meeting')),
                    DropdownMenuItem(value: 'Event', child: Text('🎪 Event')),
                    DropdownMenuItem(value: 'Exam', child: Text('📝 Exam')),
                    DropdownMenuItem(
                        value: 'General', child: Text('📢 General')),
                  ],
                  onChanged: (val) => setState(() => category = val ?? ''),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please select a category'
                      : null,
                  style: theme.textTheme.bodyLarge,
                ),

                SizedBox(height: 20),

                // Priority Dropdown
                Text(
                  'Priority',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'low',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text('Low Priority'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Text('Medium Priority'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('High Priority'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) =>
                      setState(() => priority = val ?? 'medium'),
                  style: theme.textTheme.bodyLarge,
                ),

                SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: isSubmitting ? null : submitNotice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Publish Notice',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context,
      {required String message, required bool isError}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? Colors.redAccent.withOpacity(0.1)
            : Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError ? Colors.redAccent : Colors.greenAccent,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: isError ? Colors.redAccent : Colors.green,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isError ? Colors.redAccent : Colors.green,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
