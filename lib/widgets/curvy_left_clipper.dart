import 'package:flutter/widgets.dart';

class CurvyLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
   
 
    // path.lineTo(size.width * 0.7, 0); // Top left to 70% of width
    // path.quadraticBezierTo(
    //   size.width * 0.85, size.height * 0.25,
    //   size.width * 0.75, size.height * 0.5,
    // );
    // path.quadraticBezierTo(
    //   size.width * 0.65, size.height * 0.75,
    //   size.width, size.height,
    // );
    // path.lineTo(0, size.height); // Bottom left
    // path.close();

       path.lineTo(size.width * 0.75, 0); // Start from top left to 75% width

    path.quadraticBezierTo(
      size.width , size.height * 0.4, // bulge outward
      size.width * 0.8, size.height * 0.65,
    );

    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.87, // curve back inwards
      size.width * 0.85, size.height,
    );
    path.lineTo(0, size.height); // Bottom left

    path.close(); 

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 