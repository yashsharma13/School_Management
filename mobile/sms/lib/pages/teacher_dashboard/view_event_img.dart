import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms/widgets/custom_appbar.dart';

class TeacherEventImagesPage extends StatefulWidget {
  const TeacherEventImagesPage({super.key});

  @override
  _TeacherEventImagesPageState createState() => _TeacherEventImagesPageState();
}

class _TeacherEventImagesPageState extends State<TeacherEventImagesPage> {
  bool _loading = true;
  String _error = '';
  List<EventImage> _images = [];
  String? _selectedImage;

  final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    fetchTeacherImages();
  }

  Future<void> fetchTeacherImages() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('User not authenticated');

      final res = await http.get(
        Uri.parse('$baseUrl/api/teacher/event-images'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to fetch images');
      }

      final List list = data['data'];
      setState(() {
        _images = list.map((e) => EventImage.fromJson(e)).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Uploaded Event Images'),
      // ),
      appBar: CustomAppBar(title: 'Uploaded Event Images'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Text(_error,
                            style: const TextStyle(color: Colors.red)))
                    : _images.isEmpty
                        ? const Center(child: Text('No images uploaded yet.'))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, i) {
                              final img = _images[i];
                              final fullUrl = '$baseUrl${img.imageUrl}';
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImage = fullUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(fullUrl, fit: BoxFit.cover),
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black54
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: Text(
                                          img.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          if (_selectedImage != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _selectedImage = null),
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Center(
                        child:
                            Image.network(_selectedImage!, fit: BoxFit.contain),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              size: 32, color: Colors.white),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EventImage {
  final int id;
  final String title;
  final String imageUrl;

  EventImage({required this.id, required this.title, required this.imageUrl});

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'], // adjust if key differs
    );
  }
}
