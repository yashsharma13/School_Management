// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class ViewHomeworkPage extends StatefulWidget {
//   @override
//   _ViewHomeworkPageState createState() => _ViewHomeworkPageState();
// }

// class _ViewHomeworkPageState extends State<ViewHomeworkPage> {
//   bool isLoading = true;
//   String error = '';
//   List<dynamic> homeworkList = [];
//   static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

//   @override
//   void initState() {
//     super.initState();
//     fetchHomework();
//   }

//   Future<void> fetchHomework() async {
//     setState(() {
//       isLoading = true;
//       error = '';
//     });

//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/gethomework'), // adjust your API endpoint here
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       final data = json.decode(response.body);

//       if (response.statusCode == 200 && data['success'] == true) {
//         setState(() {
//           homeworkList = data['data'];
//         });
//       } else {
//         setState(() {
//           error = data['message'] ?? 'Failed to fetch homework.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = 'Error fetching homework: $e';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Widget _buildHomeworkItem(dynamic hw) {
//     final startDate =
//         DateTime.tryParse(hw['start_date'] ?? '') ?? DateTime.now();
//     final endDate = DateTime.tryParse(hw['end_date'] ?? '') ?? DateTime.now();

//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: ListTile(
//         title: Text('Class: ${hw['class_id']}'),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 4),
//             Text(hw['homework'] ?? ''),
//             SizedBox(height: 8),
//             Text(
//               'From: ${DateFormat.yMMMd().format(startDate)}  To: ${DateFormat.yMMMd().format(endDate)}',
//               style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//             ),
//           ],
//         ),
//         isThreeLine: true,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Assigned Homework'),
//         backgroundColor: Colors.teal,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : error.isNotEmpty
//               ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
//               : homeworkList.isEmpty
//                   ? Center(child: Text('No homework assigned yet.'))
//                   : RefreshIndicator(
//                       onRefresh: fetchHomework,
//                       child: ListView.builder(
//                         itemCount: homeworkList.length,
//                         itemBuilder: (context, index) {
//                           final hw = homeworkList[index];
//                           return _buildHomeworkItem(hw);
//                         },
//                       ),
//                     ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ViewHomeworkPage extends StatefulWidget {
  @override
  _ViewHomeworkPageState createState() => _ViewHomeworkPageState();
}

class _ViewHomeworkPageState extends State<ViewHomeworkPage> {
  bool isLoading = true;
  String error = '';
  List<dynamic> homeworkList = [];
  static final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchHomework();
  }

  Future<void> fetchHomework() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/gethomework'), // Your API endpoint to fetch homework
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          homeworkList = data['data'];
        });
      } else {
        setState(() {
          error = data['message'] ?? 'Failed to fetch homework.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching homework: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteHomework(int homeworkId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/deletehomework/$homeworkId'), // Your delete endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          homeworkList.removeWhere((hw) => hw['id'] == homeworkId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Homework deleted successfully')),
        );
      } else {
        setState(() {
          error = data['message'] ?? 'Failed to delete homework.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error deleting homework: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(int homeworkId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Homework'),
        content: Text('Are you sure you want to delete this homework?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteHomework(homeworkId);
    }
  }

  Widget _buildHomeworkItem(dynamic hw) {
    final startDate =
        DateTime.tryParse(hw['start_date'] ?? '') ?? DateTime.now();
    final endDate = DateTime.tryParse(hw['end_date'] ?? '') ?? DateTime.now();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text('Class: ${hw['class_id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(hw['homework'] ?? ''),
            SizedBox(height: 8),
            Text(
              'From: ${DateFormat.yMMMd().format(startDate)}  To: ${DateFormat.yMMMd().format(endDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(hw['id']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Assigned Homework'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
              : homeworkList.isEmpty
                  ? Center(child: Text('No homework assigned yet.'))
                  : RefreshIndicator(
                      onRefresh: fetchHomework,
                      child: ListView.builder(
                        itemCount: homeworkList.length,
                        itemBuilder: (context, index) {
                          final hw = homeworkList[index];
                          return _buildHomeworkItem(hw);
                        },
                      ),
                    ),
    );
  }
}
