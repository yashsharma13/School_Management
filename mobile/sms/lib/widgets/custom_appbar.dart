// import 'package:flutter/material.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool centerTitle;
//   final double elevation;

//   const CustomAppBar({
//     Key? key,
//     required this.title,
//     this.centerTitle = false,
//     this.elevation = 4.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: const TextStyle(color: Colors.white),
//       ),
//       centerTitle: centerTitle,
//       backgroundColor: Colors.blue.shade900,
//       elevation: elevation,
//       iconTheme: const IconThemeData(color: Colors.white),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// import 'package:flutter/material.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool centerTitle;
//   final double elevation;
//   final List<Widget>? actions;

//   const CustomAppBar({
//     Key? key,
//     required this.title,
//     this.centerTitle = false,
//     this.elevation = 4.0,
//     this.actions,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: const TextStyle(color: Colors.white),
//       ),
//       centerTitle: centerTitle,
//       backgroundColor: Colors.blue.shade900,
//       elevation: elevation,
//       iconTheme: const IconThemeData(color: Colors.white),
//       actions: actions,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// import 'package:flutter/material.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool centerTitle;
//   final double elevation;
//   final List<Widget>? actions;
//   final Widget? leading;

//   const CustomAppBar({
//     Key? key,
//     required this.title,
//     this.centerTitle = false,
//     this.elevation = 4.0,
//     this.actions,
//     this.leading,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: centerTitle,
//       // backgroundColor: Colors.blue.shade900,
//       backgroundColor: Colors.deepPurple,
//       elevation: elevation,
//       iconTheme: const IconThemeData(color: Colors.white),
//       actions: actions,
//       leading: leading,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final double elevation;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.elevation = 4.0,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Curved background behind the AppBar
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: preferredSize.height + 40, // Extra height for wave
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Actual AppBar on top
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: centerTitle,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: actions,
          leading: leading,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

/// Custom clipper to create the wave shape at the bottom of the AppBar
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
