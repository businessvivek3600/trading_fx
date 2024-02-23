import 'package:flutter/material.dart';

class OvalLeftBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(15, 0);
    path.quadraticBezierTo(0, size.height / 4, 0, size.height / 2);
    path.quadraticBezierTo(0, size.height - (size.height / 4), 15, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
