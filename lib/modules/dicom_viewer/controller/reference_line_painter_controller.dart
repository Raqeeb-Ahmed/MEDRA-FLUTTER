import 'package:flutter/material.dart';

class ReferenceLinePainter extends CustomPainter {
  final double slicePosition; // Current slice ki position

  ReferenceLinePainter({required this.slicePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow // Reference line aksar yellow hoti hai
      ..strokeWidth = 2.0;

    // Line ko draw karne ka logic (Simplify kiya hai)
    // Asal PACS mein ye position mathematically calculate hoti hai
    double yOffset = size.height * slicePosition;

    canvas.drawLine(
        Offset(0, yOffset),
        Offset(size.width, yOffset),
        paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}