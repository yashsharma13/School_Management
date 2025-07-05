import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/services/teacher_service.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/user_photo_widget.dart';
import 'package:sms/widgets/pdf_viewer_widget.dart';
import 'teacher_model.dart';
import 'edit_teacher.dart';
import 'delete_teacher.dart';

final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
final String uploadBaseUrl = '$baseeUrl/uploads';

class TeacherProfileManagementPage extends StatefulWidget {
  const TeacherProfileManagementPage({super.key});

  @override
  _TeacherProfileManagementPageState createState() =>
      _TeacherProfileManagementPageState();
}

class _TeacherProfileManagementPageState
    extends State<TeacherProfileManagementPage> {
  List<Teacher> teachers = [];
  List<Teacher> filteredTeachers = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
    if (token != null) {
      await _fetchTeachers();
    }
  }

  Future<void> _fetchTeachers() async {
    try {
      setState(() => _isLoading = true);
      final fetchedTeachers = await TeacherService.fetchTeachers();
      setState(() {
        teachers = fetchedTeachers;
        filteredTeachers = fetchedTeachers;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading teachers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _filterTeachers() {
    setState(() {
      filteredTeachers = teachers.where((teacher) {
        final nameMatch = teacher.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        return nameMatch;
      }).toList();
    });
  }

  Future<void> _editTeacher(Teacher teacher) async {
    await showDialog(
      context: context,
      builder: (context) => EditTeacherDialog(
        teacher: teacher,
        onTeacherUpdated: _fetchTeachers,
      ),
    );
  }

  Future<void> _deleteTeacher(int index) async {
    final teacher = filteredTeachers[index];
    final confirmed = await showDeleteTeacherDialog(context, teacher.name);

    if (!confirmed) return;

    final error = await TeacherService.deleteTeacher(teacher.id.toString());

    if (error == null) {
      setState(() {
        teachers.removeWhere((t) => t.id == teacher.id);
        filteredTeachers.removeWhere((t) => t.id == teacher.id); // ✅ Safe
      });

      _showSuccessSnackBar('Teacher deleted successfully');
    } else {
      _showErrorSnackBar(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Teacher Details'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.deepPurple[800]!),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Teachers',
                              labelStyle:
                                  TextStyle(color: Colors.deepPurple[800]),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.deepPurple[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.deepPurple[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.deepPurple[800]!, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.deepPurple[800]),
                                onPressed: () {
                                  searchController.clear();
                                  _filterTeachers();
                                },
                              ),
                              filled: true,
                              fillColor: Colors.deepPurple[50],
                            ),
                            onChanged: (value) => _filterTeachers(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filteredTeachers.isEmpty
                        ? _buildEmptyState()
                        : _buildTeacherList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            searchController.text.isEmpty
                ? 'No teachers found'
                : 'No teachers match your search',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  filteredTeachers = teachers;
                });
              },
              child: Text('Clear Search',
                  style: TextStyle(color: Colors.deepPurple[800])),
            ),
        ],
      ),
    );
  }

  Widget _buildTeacherList() {
    return ListView.builder(
      itemCount: filteredTeachers.length,
      itemBuilder: (context, index) {
        final teacher = filteredTeachers[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurple[100]!,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: buildUserPhoto(teacher.teacherPhoto, uploadBaseUrl),
              ),
            ),
            title: Text(
              teacher.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher.email}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${teacher.qualification}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.deepPurple[800]),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepPurple[800]),
                      SizedBox(width: 8),
                      Text('Edit',
                          style: TextStyle(color: Colors.deepPurple[900])),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[400]),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red[600])),
                    ],
                  ),
                ),
                if (teacher.qualificationCertificate.isNotEmpty)
                  PopupMenuItem(
                    value: 'view_certificate',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.green[600]),
                        SizedBox(width: 8),
                        Text('View Certificate',
                            style: TextStyle(color: Colors.green[800])),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editTeacher(teacher);
                } else if (value == 'delete') {
                  await _deleteTeacher(index);
                } else if (value == 'view_certificate') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        pdfData: teacher.qualificationCertificate,
                        baseUrl: uploadBaseUrl,
                        title: 'Qualification Certificate',
                        label: 'Qualification Certificate PDF',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
