import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms/pages/teacher/Job_letter/confirm_letter.dart';
import 'package:sms/widgets/custom_appbar.dart';
import 'package:sms/widgets/custom_snackbar.dart';
import 'package:sms/widgets/search_bar.dart';
import 'package:sms/widgets/user_photo_widget.dart';
import 'package:sms/pages/services/teacher_service.dart';
import 'package:sms/models/teacher_model.dart';

final String baseeUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
final String uploadBaseUrl = '$baseeUrl/uploads';
TextEditingController searchController = TextEditingController();

class TeacherAdmissionLetterPage extends StatefulWidget {
  const TeacherAdmissionLetterPage({super.key});

  @override
  State<TeacherAdmissionLetterPage> createState() =>
      _TeacherAdmissionLetterPageState();
}

class _TeacherAdmissionLetterPageState
    extends State<TeacherAdmissionLetterPage> {
  List<Teacher> teachers = [];
  List<Teacher> filteredTeachers = [];
  bool isLoading = true;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      setState(() => isLoading = true);
      final fetchedTeachers = await TeacherService.fetchTeachers();
      setState(() {
        teachers = fetchedTeachers;
        filteredTeachers = fetchedTeachers;
      });
    } catch (error) {
      if (!mounted) return;
      showCustomSnackBar(context, 'Error loading teachers: $error',
          backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterTeachers() {
    setState(() {
      if (searchQuery == null || searchQuery!.isEmpty) {
        filteredTeachers = List.from(teachers);
      } else {
        filteredTeachers = teachers.where((teacher) {
          return teacher.name
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase()) ||
              teacher.email
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase()) ||
              teacher.qualification
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase());
        }).toList();
      }
    });
  }

  void _viewAdmissionConfirmation(Teacher teacher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TeacherAdmissionConfirmationPage(teacher: teacher),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Teacher Job Letters',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Teachers',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800])),
                    const SizedBox(height: 12),
                    CustomSearchBar(
                      hintText: 'Search by name, email or qualification',
                      controller: searchController,
                      onChanged: (value) {
                        searchQuery = value;
                        _filterTeachers();
                      },
                      onClear: () {
                        searchQuery = '';
                        _filterTeachers();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Teacher List
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.deepPurple))
                  : filteredTeachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 48, color: Colors.deepPurple[800]),
                              const SizedBox(height: 16),
                              Text(
                                  searchQuery == null || searchQuery!.isEmpty
                                      ? 'No teachers found'
                                      : 'No teachers match your search',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.deepPurple[900])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = filteredTeachers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple[100],
                                  child: buildUserPhoto(
                                    teacher.teacherPhoto,
                                    uploadBaseUrl,
                                    // icon: Icon(Icons.person,
                                    //     color: Colors.deepPurple[800]),
                                  ),
                                ),
                                title: Text(teacher.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple[900])),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: ${teacher.email}',
                                        style: TextStyle(
                                            color: Colors.deepPurple[800])),
                                    Text(
                                        'Qualification: ${teacher.qualification}',
                                        style: TextStyle(
                                            color: Colors.deepPurple[800])),
                                    // Text(
                                    //     'Joined: ${TeacherService.formatDate(teacher.dateOfJoining)}',
                                    //     style: TextStyle(
                                    //         color: Colors.deepPurple[800])),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.arrow_forward,
                                      color: Colors.deepPurple[800], size: 20),
                                ),
                                onTap: () =>
                                    _viewAdmissionConfirmation(teacher),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
