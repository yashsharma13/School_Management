import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sms/widgets/custom_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class EventGalleryPage extends StatefulWidget {
  const EventGalleryPage({super.key});

  @override
  State<EventGalleryPage> createState() => _EventGalleryPageState();
}

class _EventGalleryPageState extends State<EventGalleryPage> {
  final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
  bool _loading = true;
  String _error = '';
  List<EventImage> _images = [];
  EventImage? _selectedImage;
  String? _selectedFilter;
  DateTime? _selectedDate;
  List<String> _uniqueTitles = [];
  List<String> _uniqueDates = [];

  @override
  void initState() {
    super.initState();
    fetchEventImages();
  }

  Future<void> fetchEventImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Authentication token not found.');

      final res = await http.get(
        Uri.parse('$baseUrl/api/parent/event-images'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to load images.');
      }

      final List list = data['data'] ?? [];
      setState(() {
        _images = list.map((e) => EventImage.fromJson(e, baseUrl)).toList();
        _uniqueTitles = _images.map((e) => e.title).toSet().toList();
        _uniqueTitles.insert(0, 'All Images');
        _uniqueDates = _images
            .map((e) {
              try {
                return DateFormat('MMM dd, yyyy')
                    .format(DateTime.parse(e.createdAt));
              } catch (e) {
                return 'Unknown Date';
              }
            })
            .toSet()
            .toList();
        _uniqueDates.insert(0, 'All Dates');
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading images: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> downloadImage(EventImage image) async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving is not supported on web')),
        );
        return;
      }

      final response = await http.get(Uri.parse(image.imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image.');
      }

      final Uint8List bytes = response.bodyBytes;

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted.');
      }

      io.Directory? directory;
      if (io.Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (io.Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw Exception('Unsupported platform for file download.');
      }

      if (directory == null) {
        throw Exception('Unable to access storage directory.');
      }

      final path = directory.path;
      final savedDir = io.Directory('$path/EventImages');
      if (!savedDir.existsSync()) {
        savedDir.createSync(recursive: true);
      }

      final file = io.File(
          '${savedDir.path}/${image.title}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: ${e.toString()}')),
      );
    }
  }

  List<EventImage> getFilteredImages() {
    var filteredImages = _images;

    if (_selectedDate != null) {
      filteredImages = filteredImages.where((image) {
        try {
          final imageDate = DateTime.parse(image.createdAt).toLocal();
          return imageDate.year == _selectedDate!.year &&
              imageDate.month == _selectedDate!.month &&
              imageDate.day == _selectedDate!.day;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (_selectedFilter != null && _selectedFilter != 'All Images') {
      filteredImages = filteredImages
          .where((image) => image.title == _selectedFilter)
          .toList();
    }

    return filteredImages;
  }

  List<String> getTitlesForSelectedDate() {
    if (_selectedDate == null) return _uniqueTitles;

    final titles = _images
        .where((image) {
          try {
            final imageDate = DateTime.parse(image.createdAt).toLocal();
            return imageDate.year == _selectedDate!.year &&
                imageDate.month == _selectedDate!.month &&
                imageDate.day == _selectedDate!.day;
          } catch (e) {
            return false;
          }
        })
        .map((e) => e.title)
        .toSet()
        .toList();

    titles.insert(0, 'All Images');
    return titles;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedFilter = 'All Images'; // Reset title filter when date changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Event Gallery'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title filter
                if (getTitlesForSelectedDate().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter ?? 'All Images',
                      items: getTitlesForSelectedDate().map((String title) {
                        return DropdownMenuItem<String>(
                          value: title,
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Filter by Event',
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      isExpanded: true,
                    ),
                  ),
                // Date filter
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedDate == null
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'Pick Date',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                              _selectedFilter = 'All Images';
                            });
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                          ? Center(
                              child: Text(
                                _error,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : getFilteredImages().isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No images found for selected filter',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: getFilteredImages().length,
                                  itemBuilder: (context, index) {
                                    final img = getFilteredImages()[index];
                                    return GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedImage = img),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                            top:
                                                                Radius.circular(
                                                                    12)),
                                                    child: FadeInImage
                                                        .memoryNetwork(
                                                      placeholder:
                                                          kTransparentImage,
                                                      image: img.imageUrl,
                                                      fit: BoxFit.cover,
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  300),
                                                      imageErrorBuilder:
                                                          (context, error,
                                                                  stackTrace) =>
                                                              Container(
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        img.title,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        DateFormat(
                                                                'MMM dd, yyyy')
                                                            .format(DateTime
                                                                .parse(img
                                                                    .createdAt)),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () => downloadImage(img),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withAlpha(229),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: const Icon(
                                                    Icons.download,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
          if (_selectedImage != null)
            Dialog.fullscreen(
              backgroundColor: Colors.black.withAlpha((242)),
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4,
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: _selectedImage!.imageUrl,
                        fit: BoxFit.contain,
                        fadeInDuration: const Duration(milliseconds: 300),
                        imageErrorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 32),
                        color: Colors.white,
                        onPressed: () => setState(() => _selectedImage = null),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'download_fullscreen',
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () => downloadImage(_selectedImage!),
                      child: const Icon(Icons.download, color: Colors.white),
                    ),
                  ),
                ],
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
  final String createdAt;

  EventImage({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
  });

  factory EventImage.fromJson(Map<String, dynamic> json, String baseUrl) {
    return EventImage(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      imageUrl: '$baseUrl${json['image_url'] ?? ''}',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io' as io;
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:sms/widgets/custom_appbar.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';
// import 'package:transparent_image/transparent_image.dart';
// import 'package:url_launcher/url_launcher.dart';

// class EventGalleryPage extends StatefulWidget {
//   const EventGalleryPage({super.key});

//   @override
//   State<EventGalleryPage> createState() => _EventGalleryPageState();
// }

// class EventImage {
//   final String id;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final String createdAt;
//   final String? className;
//   final String? section;

//   EventImage({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.imageUrl,
//     required this.createdAt,
//     this.className,
//     this.section,
//   });

//   factory EventImage.fromJson(Map<String, dynamic> json, String baseUrl) {
//     final cleanBaseUrl = baseUrl.endsWith('/')
//         ? baseUrl.substring(0, baseUrl.length - 1)
//         : baseUrl;
//     final imagePath = json['image_url'] ?? '';
//     final fullUrl = imagePath.startsWith('http')
//         ? imagePath
//         : '$cleanBaseUrl/${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';

//     return EventImage(
//       id: json['id']?.toString() ?? '',
//       title: json['title'] ?? 'Untitled',
//       description: json['description'] ?? '',
//       imageUrl: fullUrl,
//       createdAt: json['created_at'] ?? DateTime.now().toString(),
//       className: json['class_name'],
//       section: json['section'],
//     );
//   }
// }

// class _EventGalleryPageState extends State<EventGalleryPage> {
//   final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
//   bool _loading = true;
//   String _error = '';
//   List<EventImage> _images = [];
//   EventImage? _selectedImage;
//   String? _selectedFilter;
//   DateTime? _selectedDate;
//   List<String> _uniqueTitles = [];
//   List<String> _uniqueDates = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchEventImages();
//   }

//   Future<void> fetchEventImages() async {
//     setState(() {
//       _loading = true;
//       _error = '';
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null) throw Exception('Authentication token not found.');

//       final res = await http.get(
//         Uri.parse('$baseUrl/api/parent/event-images'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (res.statusCode != 200) {
//         throw Exception('Failed to load images. Status: ${res.statusCode}');
//       }

//       final data = jsonDecode(res.body);
//       if (data['success'] != true) {
//         throw Exception(data['message'] ?? 'Failed to load images.');
//       }

//       final List list = data['data'] ?? [];
//       setState(() {
//         _images = list.map((e) => EventImage.fromJson(e, baseUrl)).toList();
//         _updateFilters();
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = 'Error loading images: ${e.toString()}';
//         _loading = false;
//       });
//     }
//   }

//   void _updateFilters() {
//     _uniqueTitles = _images.map((e) => e.title).toSet().toList()
//       ..sort((a, b) => a.compareTo(b))
//       ..insert(0, 'All Images');

//     _uniqueDates = _images
//         .map((e) {
//           try {
//             return DateFormat('MMM dd, yyyy')
//                 .format(DateTime.parse(e.createdAt));
//           } catch (e) {
//             return 'Unknown Date';
//           }
//         })
//         .toSet()
//         .toList()
//       ..sort((a, b) => b.compareTo(a)) // Newest first
//       ..insert(0, 'All Dates');
//   }

//   Future<void> downloadImage(EventImage image) async {
//     try {
//       if (kIsWeb) {
//         await _downloadImageWeb(image);
//       } else {
//         await _downloadImageMobile(image);
//       }
//     } catch (e) {
//       _showSnackBar('Error: ${e.toString()}', isError: true);
//     }
//   }

//   Future<void> _downloadImageWeb(EventImage image) async {
//     final uri = Uri.parse(image.imageUrl);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//       _showSnackBar('Image opened in new tab for download');
//     } else {
//       throw Exception('Could not launch URL');
//     }
//   }

//   Future<void> _downloadImageMobile(EventImage image) async {
//     final response = await http.get(Uri.parse(image.imageUrl));
//     if (response.statusCode != 200) {
//       throw Exception('Failed to download image.');
//     }

//     final Uint8List bytes = response.bodyBytes;
//     await saveImageToGallery(bytes, image.title);
//   }

//   Future<void> saveImageToGallery(Uint8List bytes, String title) async {
//     try {
//       if (io.Platform.isAndroid) {
//         await _saveImageAndroid(bytes, title);
//       } else if (io.Platform.isIOS) {
//         await _saveImageIOS(bytes, title);
//       } else {
//         throw Exception('Unsupported platform');
//       }
//     } catch (e) {
//       throw Exception('Failed to save image: $e');
//     }
//   }

//   Future<void> _saveImageAndroid(Uint8List bytes, String title) async {
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       status = await Permission.storage.request();
//       if (!status.isGranted) {
//         throw Exception('Storage permission not granted.');
//       }
//     }

//     final directory = io.Directory('/storage/emulated/0/Pictures/EventImages');
//     if (!directory.existsSync()) {
//       directory.createSync(recursive: true);
//     }

//     final fileName =
//         '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final file = io.File('${directory.path}/$fileName');
//     await file.writeAsBytes(bytes);

//     _showSnackBar('Image saved to Gallery/EventImages');
//   }

//   Future<void> _saveImageIOS(Uint8List bytes, String title) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final savedDir = io.Directory('${directory.path}/EventImages');
//     if (!savedDir.existsSync()) {
//       savedDir.createSync(recursive: true);
//     }

//     final fileName =
//         '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final file = io.File('${savedDir.path}/$fileName');
//     await file.writeAsBytes(bytes);

//     _showSnackBar('Image saved to app documents');
//   }

//   String _sanitizeFileName(String name) {
//     return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
//   }

//   List<EventImage> getFilteredImages() {
//     var filteredImages = _images;

//     if (_selectedDate != null && _selectedDate.toString() != 'All Dates') {
//       filteredImages = filteredImages.where((image) {
//         try {
//           final imageDate = DateTime.parse(image.createdAt).toLocal();
//           return imageDate.year == _selectedDate!.year &&
//               imageDate.month == _selectedDate!.month &&
//               imageDate.day == _selectedDate!.day;
//         } catch (e) {
//           return false;
//         }
//       }).toList();
//     }

//     if (_selectedFilter != null && _selectedFilter != 'All Images') {
//       filteredImages = filteredImages
//           .where((image) => image.title == _selectedFilter)
//           .toList();
//     }

//     return filteredImages;
//   }

//   List<String> getTitlesForSelectedDate() {
//     if (_selectedDate == null || _selectedDate.toString() == 'All Dates') {
//       return _uniqueTitles;
//     }

//     final titles = _images
//         .where((image) {
//           try {
//             final imageDate = DateTime.parse(image.createdAt).toLocal();
//             return imageDate.year == _selectedDate!.year &&
//                 imageDate.month == _selectedDate!.month &&
//                 imageDate.day == _selectedDate!.day;
//           } catch (e) {
//             return false;
//           }
//         })
//         .map((e) => e.title)
//         .toSet()
//         .toList()
//       ..sort((a, b) => a.compareTo(b))
//       ..insert(0, 'All Images');

//     return titles;
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black87,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _selectedFilter = 'All Images';
//       });
//     }
//   }

//   void _showImageDialog(EventImage image) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 image.title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             InteractiveViewer(
//               panEnabled: true,
//               minScale: 0.5,
//               maxScale: 4.0,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: FadeInImage.memoryNetwork(
//                   placeholder: kTransparentImage,
//                   image: image.imageUrl,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(image.description),
//             ),
//             if (image.className != null || image.section != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: Text(
//                   '${image.className ?? ''} ${image.section ?? ''}'.trim(),
//                   style: const TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 TextButton(
//                   onPressed: () => downloadImage(image),
//                   child: const Text('Download'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Close'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   Widget _buildFilterControls() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedDate?.toString() ?? 'All Dates',
//                   items: _uniqueDates.map((String date) {
//                     return DropdownMenuItem<String>(
//                       value: date,
//                       child: Text(
//                         date,
//                         style: const TextStyle(fontSize: 14),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       if (newValue == 'All Dates') {
//                         _selectedDate = null;
//                       } else {
//                         try {
//                           _selectedDate =
//                               DateFormat('MMM dd, yyyy').parse(newValue!);
//                         } catch (e) {
//                           _selectedDate = null;
//                         }
//                       }
//                       _selectedFilter = 'All Images';
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Filter by Date',
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 icon: const Icon(Icons.calendar_today),
//                 onPressed: () => _selectDate(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<String>(
//             value: _selectedFilter ?? 'All Images',
//             items: getTitlesForSelectedDate().map((String title) {
//               return DropdownMenuItem<String>(
//                 value: title,
//                 child: Text(
//                   title,
//                   style: const TextStyle(fontSize: 14),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedFilter = newValue;
//               });
//             },
//             decoration: InputDecoration(
//               labelText: 'Filter by Title',
//               border: const OutlineInputBorder(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageGrid() {
//     final filteredImages = getFilteredImages();

//     if (filteredImages.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.image_not_supported, size: 48),
//             const SizedBox(height: 16),
//             Text(
//               _selectedDate != null || _selectedFilter != null
//                   ? 'No images match your filters'
//                   : 'No images available',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             if (_selectedDate != null || _selectedFilter != null)
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedDate = null;
//                     _selectedFilter = null;
//                   });
//                 },
//                 child: const Text('Clear filters'),
//               ),
//           ],
//         ),
//       );
//     }

//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//         childAspectRatio: 0.8,
//       ),
//       itemCount: filteredImages.length,
//       itemBuilder: (context, index) {
//         final image = filteredImages[index];
//         return GestureDetector(
//           onTap: () => _showImageDialog(image),
//           child: Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(8)),
//                     child: FadeInImage.memoryNetwork(
//                       placeholder: kTransparentImage,
//                       image: image.imageUrl,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         image.title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       if (image.className != null || image.section != null)
//                         Text(
//                           '${image.className ?? ''} ${image.section ?? ''}'
//                               .trim(),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: 'Event Gallery'),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _error.isNotEmpty
//               ? Center(child: Text(_error))
//               : RefreshIndicator(
//                   onRefresh: fetchEventImages,
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         children: [
//                           _buildFilterControls(),
//                           const SizedBox(height: 8),
//                           SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.75,
//                             child: _buildImageGrid(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//     );
//   }
// }
