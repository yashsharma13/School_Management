// import 'package:flutter/material.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final void Function()?
//       onPressed; // <-- Changed from Future<void> Function()? to void Function()?
//   final bool isLoading;
//   final Color color;
//   final Color textColor;
//   final IconData? icon;
//   final double? width;
//   final double? height;

//   const CustomButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//     this.color = Colors.deepPurple,
//     this.textColor = Colors.white,
//     this.icon,
//     this.width,
//     this.height,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width ?? double.infinity,
//       height: height ?? 50,
//       child: ElevatedButton(
//         onPressed: isLoading || onPressed == null ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//         ),
//         child: isLoading
//             ? const SizedBox(
//                 height: 24,
//                 width: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (icon != null) ...[
//                     Icon(icon, color: textColor),
//                     const SizedBox(width: 8),
//                   ],
//                   Text(
//                     text,
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: textColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
// //  ye upr wala code jo simple design wala hai or niche wala gradient color hai shi hai dono
// import 'package:flutter/material.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   final List<Color> gradientColors;
//   final Color textColor;
//   final IconData? icon;
//   final double? width;
//   final double? height;
//   final double borderRadius;
//   final List<Color>? hoverColors;
//   final List<Color>? splashColors;

//   const CustomButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//     this.gradientColors = const [Colors.purple, Colors.blue],
//     this.textColor = Colors.white,
//     this.icon,
//     this.width,
//     this.height,
//     this.borderRadius = 30,
//     this.hoverColors,
//     this.splashColors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDisabled = isLoading || onPressed == null;

//     return MouseRegion(
//       cursor:
//           isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
//       child: GestureDetector(
//         onTap: isDisabled ? null : onPressed,
//         child: SizedBox(
//           width: width ?? double.infinity,
//           height: height ?? 50,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             curve: Curves.easeInOut,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isDisabled
//                     ? [Colors.grey.shade400, Colors.grey.shade600]
//                     : gradientColors,
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(borderRadius),
//               boxShadow: [
//                 if (!isDisabled)
//                   BoxShadow(
//                     color: gradientColors.last.withOpacity(0.4),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//               ],
//             ),
//             child: ElevatedButton(
//               onPressed: isDisabled ? null : onPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(borderRadius),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 // Splash effect
//                 foregroundColor: Colors.white,
//                 splashFactory: InkRipple.splashFactory,
//                 // overlayColor: MaterialStateProperty.resolveWith<Color?>(
//                 //   (states) {
//                 //     if (states.contains(MaterialState.pressed)) {
//                 //       return splashColors?.last ??
//                 //           gradientColors.last.withOpacity(0.2);
//                 //     }
//                 //     if (states.contains(MaterialState.hovered)) {
//                 //       return hoverColors?.last ??
//                 //           gradientColors.last.withOpacity(0.1);
//                 //     }
//                 //     return null;
//                 //   },
//                 // ),
//               ),
//               child: isLoading
//                   ? const SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 3,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (icon != null) ...[
//                           Icon(icon, color: textColor, size: 20),
//                           const SizedBox(width: 8),
//                         ],
//                         Text(
//                           text,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: textColor,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color> gradientColors;
  final Color textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final double borderRadius;
  final List<Color>? hoverColors;
  final List<Color>? splashColors;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradientColors = const [Colors.deepPurple, Colors.purple],
    this.textColor = Colors.white,
    this.icon,
    this.width,
    this.height,
    this.borderRadius = 30,
    this.hoverColors,
    this.splashColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: gradientColors.last.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            splashFactory: InkRipple.splashFactory,
            // overlayColor: MaterialStateProperty.resolveWith<Color?>(
            //   (states) {
            //     if (states.contains(MaterialState.pressed)) {
            //       return splashColors?.last ??
            //           gradientColors.last.withOpacity(0.2);
            //     }
            //     if (states.contains(MaterialState.hovered)) {
            //       return hoverColors?.last ??
            //           gradientColors.last.withOpacity(0.1);
            //     }
            //     return null;
            //   },
            // ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
