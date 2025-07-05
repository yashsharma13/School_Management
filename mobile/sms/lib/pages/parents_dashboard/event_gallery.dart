// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sms/widgets/custom_appbar.dart';

// class EventGalleryPage extends StatefulWidget {
//   const EventGalleryPage({super.key});

//   @override
//   State<EventGalleryPage> createState() => _EventGalleryPageState();
// }

// class _EventGalleryPageState extends State<EventGalleryPage> {
//   final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
//   bool _loading = true;
//   String _error = '';
//   List<EventImage> _images = [];
//   EventImage? _selectedImage;

//   @override
//   void initState() {
//     super.initState();
//     fetchEventImages();
//   }

//   Future<void> fetchEventImages() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null) throw Exception('Authentication token not found.');

//       final res = await http.get(
//         Uri.parse('$baseUrl/api/parent/event-images'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       final data = jsonDecode(res.body);
//       if (res.statusCode != 200 || data['success'] != true) {
//         throw Exception(data['message'] ?? 'Failed to load images.');
//       }

//       final List list = data['data'];
//       setState(() {
//         _images = list.map((e) => EventImage.fromJson(e, baseUrl)).toList();
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }

//   // Future<void> downloadImage(String url, String title) async {
//   //   try {
//   //     final res = await http.get(Uri.parse(url));
//   //     if (res.statusCode != 200) throw Exception('Download failed');

//   //     final snackBar = SnackBar(content: Text('Image downloaded: $title'));
//   //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error downloading $title')),
//   //     );
//   //   }
//   // }

//   Future<void> downloadImage(String url, String title) async {
//     try {
//       // Request permission (especially important for Android)
//       var status = await Permission.storage.request();
//       if (!status.isGranted) {
//         throw Exception('Storage permission not granted.');
//       }

//       // Fetch image bytes
//       final res = await http.get(Uri.parse(url));
//       if (res.statusCode != 200) {
//         throw Exception('Failed to download image.');
//       }

//       // Get storage directory
//       final directory = await getExternalStorageDirectory(); // For Android
//       final path = directory?.path ?? '/storage/emulated/0/Download';

//       // Make sure directory exists
//       final savedDir = Directory(path);
//       if (!savedDir.existsSync()) {
//         savedDir.createSync(recursive: true);
//       }

//       // Create file
//       final file = File('$path/$title.jpg');
//       await file.writeAsBytes(res.bodyBytes);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image downloaded to: ${file.path}')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error downloading image: ${e.toString()}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Event Gallery')),
//       appBar: CustomAppBar(title: 'Event Gallery'),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: _loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _error.isNotEmpty
//                     ? Center(
//                         child: Text(_error,
//                             style: const TextStyle(color: Colors.red)))
//                     : _images.isEmpty
//                         ? const Center(child: Text('No images available.'))
//                         : GridView.builder(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 8,
//                               mainAxisSpacing: 8,
//                             ),
//                             itemCount: _images.length,
//                             itemBuilder: (context, index) {
//                               final img = _images[index];
//                               return GestureDetector(
//                                 onTap: () =>
//                                     setState(() => _selectedImage = img),
//                                 child: Stack(
//                                   children: [
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.stretch,
//                                       children: [
//                                         Text(
//                                           img.title,
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.blueAccent,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Expanded(
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             child: Image.network(
//                                               img.imageUrl,
//                                               fit: BoxFit.cover,
//                                               errorBuilder: (context, error,
//                                                       stackTrace) =>
//                                                   const Icon(
//                                                       Icons.broken_image),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Positioned(
//                                       top: 6,
//                                       right: 6,
//                                       child: GestureDetector(
//                                         onTap: () => downloadImage(
//                                             img.imageUrl, img.title),
//                                         child: Container(
//                                           decoration: const BoxDecoration(
//                                             color: Colors.blueAccent,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           padding: const EdgeInsets.all(6),
//                                           child: const Icon(Icons.download,
//                                               size: 18, color: Colors.white),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//           ),

//           // Fullscreen Image View
//           if (_selectedImage != null)
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: () => setState(() => _selectedImage = null),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.9),
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: Image.network(
//                           _selectedImage!.imageUrl,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       Positioned(
//                         top: 40,
//                         right: 20,
//                         child: IconButton(
//                           icon: const Icon(Icons.close,
//                               color: Colors.white, size: 32),
//                           onPressed: () =>
//                               setState(() => _selectedImage = null),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class EventImage {
//   final int id;
//   final String title;
//   final String imageUrl;

//   EventImage({required this.id, required this.title, required this.imageUrl});

//   factory EventImage.fromJson(Map<String, dynamic> json, String baseUrl) {
//     return EventImage(
//       id: json['id'],
//       title: json['title'] ?? '',
//       imageUrl: '$baseUrl${json['image_url']}',
//     );
//   }
// }
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

// class EventGalleryPage extends StatefulWidget {
//   const EventGalleryPage({super.key});

//   @override
//   State<EventGalleryPage> createState() => _EventGalleryPageState();
// }

// class _EventGalleryPageState extends State<EventGalleryPage> {
//   final String baseUrl = dotenv.env['NEXT_PUBLIC_API_BASE_URL'] ?? '';
//   bool _loading = true;
//   String _error = '';
//   List<EventImage> _images = [];
//   EventImage? _selectedImage;
//   String? _selectedFilter; // For dropdown filter
//   List<String> _uniqueTitles = []; // Store unique titles for filter

//   @override
//   void initState() {
//     super.initState();
//     fetchEventImages();
//   }

//   Future<void> fetchEventImages() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null) throw Exception('Authentication token not found.');

//       final res = await http.get(
//         Uri.parse('$baseUrl/api/parent/event-images'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       final data = jsonDecode(res.body);
//       if (res.statusCode != 200 || data['success'] != true) {
//         throw Exception(data['message'] ?? 'Failed to load images.');
//       }

//       final List list = data['data'];
//       setState(() {
//         _images = list.map((e) => EventImage.fromJson(e, baseUrl)).toList();
//         // Extract unique titles for filter
//         _uniqueTitles = _images.map((e) => e.title).toSet().toList();
//         _uniqueTitles.insert(0, 'All Images'); // Add "All" option
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _loading = false;
//       });
//     }
//   }

//   Future<void> downloadImage(EventImage image) async {
//     try {
//       if (kIsWeb) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Saving is not supported on web')),
//         );
//         return;
//       }

//       final response = await http.get(Uri.parse(image.imageUrl));
//       if (response.statusCode != 200) {
//         throw Exception('Failed to download image.');
//       }

//       final Uint8List bytes = response.bodyBytes;

//       final status = await Permission.storage.request();
//       if (!status.isGranted) {
//         throw Exception('Storage permission not granted.');
//       }

//       io.Directory? directory;
//       if (io.Platform.isAndroid) {
//         directory = await getExternalStorageDirectory();
//       } else if (io.Platform.isIOS) {
//         directory = await getApplicationDocumentsDirectory();
//       }

//       final path = directory?.path ?? '/storage/emulated/0/Download';
//       final savedDir = io.Directory('$path/EventImages');
//       if (!savedDir.existsSync()) {
//         savedDir.createSync(recursive: true);
//       }

//       final file = io.File('${savedDir.path}/${image.title}.jpg');
//       await file.writeAsBytes(bytes);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image saved to: ${file.path}')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving image: ${e.toString()}')),
//       );
//     }
//   }

//   // Get filtered images based on selected title
//   List<EventImage> getFilteredImages() {
//     if (_selectedFilter == null || _selectedFilter == 'All Images') {
//       return _images;
//     }
//     return _images.where((image) => image.title == _selectedFilter).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: 'Event Gallery'),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Filter dropdown
//                 if (_uniqueTitles.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedFilter ?? 'All Images',
//                       items: _uniqueTitles.map((String title) {
//                         return DropdownMenuItem<String>(
//                           value: title,
//                           child: Text(title),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedFilter = newValue;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Filter by Title',
//                         border: OutlineInputBorder(),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   child: _loading
//                       ? const Center(child: CircularProgressIndicator())
//                       : _error.isNotEmpty
//                           ? Center(
//                               child: Text(_error,
//                                   style: TextStyle(
//                                     color: Theme.of(context).colorScheme.error,
//                                     fontSize: 16,
//                                   )),
//                             )
//                           : getFilteredImages().isEmpty
//                               ? Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.photo_library,
//                                           size: 64, color: Colors.grey[400]),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         'No images found for selected filter',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : GridView.builder(
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 2,
//                                     crossAxisSpacing: 12,
//                                     mainAxisSpacing: 12,
//                                     childAspectRatio: 0.8,
//                                   ),
//                                   itemCount: getFilteredImages().length,
//                                   itemBuilder: (context, index) {
//                                     final img = getFilteredImages()[index];
//                                     return GestureDetector(
//                                       onTap: () =>
//                                           setState(() => _selectedImage = img),
//                                       child: Card(
//                                         elevation: 2,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: Stack(
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.stretch,
//                                               children: [
//                                                 Expanded(
//                                                   child: ClipRRect(
//                                                     borderRadius:
//                                                         const BorderRadius
//                                                             .vertical(
//                                                             top:
//                                                                 Radius.circular(
//                                                                     12)),
//                                                     child: Image.network(
//                                                       img.imageUrl,
//                                                       fit: BoxFit.cover,
//                                                       loadingBuilder: (context,
//                                                           child,
//                                                           loadingProgress) {
//                                                         if (loadingProgress ==
//                                                             null) return child;
//                                                         return Center(
//                                                           child:
//                                                               CircularProgressIndicator(
//                                                             value: loadingProgress
//                                                                         .expectedTotalBytes !=
//                                                                     null
//                                                                 ? loadingProgress
//                                                                         .cumulativeBytesLoaded /
//                                                                     loadingProgress
//                                                                         .expectedTotalBytes!
//                                                                 : null,
//                                                           ),
//                                                         );
//                                                       },
//                                                       errorBuilder: (context,
//                                                               error,
//                                                               stackTrace) =>
//                                                           const Icon(Icons
//                                                               .broken_image),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: Text(
//                                                     img.title,
//                                                     textAlign: TextAlign.center,
//                                                     style: const TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                     ),
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             Positioned(
//                                               top: 8,
//                                               right: 8,
//                                               child: GestureDetector(
//                                                 onTap: () => downloadImage(img),
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: Theme.of(context)
//                                                         .primaryColor
//                                                         .withOpacity(0.9),
//                                                     shape: BoxShape.circle,
//                                                   ),
//                                                   padding:
//                                                       const EdgeInsets.all(6),
//                                                   child: const Icon(
//                                                     Icons.download,
//                                                     size: 18,
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                 ),
//               ],
//             ),
//           ),
//           if (_selectedImage != null)
//             Dialog.fullscreen(
//               backgroundColor: Colors.black.withOpacity(0.95),
//               child: Stack(
//                 children: [
//                   Center(
//                     child: InteractiveViewer(
//                       panEnabled: true,
//                       minScale: 0.5,
//                       maxScale: 3,
//                       child: Image.network(
//                         _selectedImage!.imageUrl,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 40,
//                     right: 20,
//                     child: IconButton(
//                       icon: const Icon(Icons.close, size: 30),
//                       color: Colors.white,
//                       onPressed: () => setState(() => _selectedImage = null),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 20,
//                     right: 20,
//                     child: FloatingActionButton(
//                       heroTag: 'download_fullscreen',
//                       onPressed: () => downloadImage(_selectedImage!),
//                       child: const Icon(Icons.download),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class EventImage {
//   final int id;
//   final String title;
//   final String imageUrl;

//   EventImage({required this.id, required this.title, required this.imageUrl});

//   factory EventImage.fromJson(Map<String, dynamic> json, String baseUrl) {
//     return EventImage(
//       id: json['id'],
//       title: json['title'] ?? 'Untitled',
//       imageUrl: '$baseUrl${json['image_url']}',
//     );
//   }
// }
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
                                                        .withOpacity(0.9),
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
              backgroundColor: Colors.black.withOpacity(0.95),
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
