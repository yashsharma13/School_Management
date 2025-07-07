import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/pages/admin/admin_dashboard.dart';
import 'package:sms/pages/principle/principle_dashboard.dart';
import 'package:sms/pages/services/profile_service.dart';
import 'dart:io';

import 'package:sms/pages/stud_dashboard/student_dashboard.dart';
import 'package:sms/widgets/button.dart';
import 'package:sms/widgets/custom_appbar.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _instituteNameController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  XFile? _logoFile;
  Uint8List? _logoBytes;
  String? logoUrlFull; // holds full logo image URL from API

  bool isLoading = false;
  String error = '';
  String? token;
  String? userEmail;

  // Change this to your actual backend base URL
  final String baseeUrl = "http://localhost:1000";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userEmail = prefs.getString('user_email');

    if (token == null || userEmail == null) {
      setState(() {
        error = 'User not authenticated.';
        isLoading = false;
      });
      return;
    }

    await _loadProfileFromApi();
  }

  Future<void> _loadProfileFromApi() async {
    try {
      final result = await ProfileService.getProfile();

      if (result['success'] == true) {
        final data = result['data'];
        _instituteNameController.text = data['institute_name'] ?? '';
        _addressController.text = data['address'] ?? '';

        final logoUrl = data['logo_url'] as String?;
        if (logoUrl != null && logoUrl.isNotEmpty) {
          final cleanBaseUrl = baseeUrl.endsWith('/')
              ? baseeUrl.substring(0, baseeUrl.length - 1)
              : baseeUrl;
          final cleanLogoUrl = logoUrl.startsWith('/') ? logoUrl : '/$logoUrl';

          setState(() {
            logoUrlFull = cleanBaseUrl + cleanLogoUrl;
            _logoBytes = null; // Clear local bytes, show network image instead
            _logoFile = null; // Clear picked file as well
          });
        } else {
          setState(() {
            logoUrlFull = null;
            _logoBytes = null;
            _logoFile = null;
          });
        }
      } else {
        setState(() => error = result['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      setState(() => error = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickLogoImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        if (bytes.length < 100) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected image is too small')),
          );
          return;
        }

        setState(() {
          _logoFile = pickedFile;
          _logoBytes = bytes;
          logoUrlFull =
              null; // Clear network image because user picked new image
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_instituteNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        (_logoBytes == null && _logoFile == null && logoUrlFull == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields including logo are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ProfileService.saveProfile(
          instituteName: _instituteNameController.text.trim(),
          address: _addressController.text.trim(),
          logo: _logoFile != null
              ? (kIsWeb ? _logoBytes! : File(_logoFile!.path))
              : null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Profile saved successfully'),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role') ?? '';

        // ✅ Navigate to appropriate dashboard
        Widget nextPage;
        switch (role.toLowerCase()) {
          case 'student':
            nextPage = const StudentDashboard();
            break;
          case 'principal':
          case 'operator':
            nextPage = const PrincipleDashboard();
            break;
          case 'admin':
          default:
            nextPage = const AdminDashboard();
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Set Up Institue Profile'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickLogoImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.blue.shade300, width: 2),
                          ),
                          child: Stack(
                            children: [
                              if (_logoBytes != null)
                                ClipOval(
                                  child: Image.memory(
                                    _logoBytes!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else if (logoUrlFull != null &&
                                  logoUrlFull!.isNotEmpty)
                                ClipOval(
                                  child: Image.network(
                                    logoUrlFull!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 40, color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Institute Logo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _instituteNameController,
                        decoration: const InputDecoration(
                          labelText: 'Institute Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Institute Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'Save Profile',
                        onPressed: _saveProfile,
                      ),
                    ],
                  ),
                ),
    );
  }
}
