import 'package:flutter/material.dart';

class AnnotationPainter extends CustomPainter {
  final List<Map<String, dynamic>> annotations;
  AnnotationPainter(this.annotations);

  @override
  void paint(Canvas canvas, Size size) {
    for (var item in annotations) {
      // 1. Check karein ke data DB se hai (nested) ya new draw (flat)
      final bool isSaved = item.containsKey('coordinates_json');
      final Map<String, dynamic> data = isSaved
          ? item['coordinates_json'] as Map<String, dynamic>
          : item;

      // 2. Safe Parsing for Color
      Color drawColor = Colors.blue;
      try {
        drawColor = Color(int.parse(data['color'].toString()));
      } catch (e) {
        drawColor = Colors.blue;
      }

      final paint = Paint()
        ..color = drawColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // 3. Coordinate extraction (double conversion zaroori hai)
      double x = double.tryParse(data['x'].toString()) ?? 0.0;
      double y = double.tryParse(data['y'].toString()) ?? 0.0;
      Offset pos = Offset(x, y);

      // 4. Tool Type selection
      String tool = (item['tool_type'] ?? data['tool'] ?? 'circle')
          .toString().toLowerCase();

      if (tool.contains('circle')) {
        canvas.drawCircle(pos, 35, paint);
      } else if (tool.contains('square') || tool.contains('rectangle')) {
        canvas.drawRect(Rect.fromCenter(center: pos, width: 55, height: 55), paint);
      }

      // 🔥 NAYA CODE: Comment Draw karne ki logic
      // Comment ya to seedha data mein hoga ya item mein (API structure ke mutabiq)
      // ... (Shape drawing wala purana code wahi rahega)

      String comment = (data['comment'] ?? item['comment'] ?? "").toString();

      if (comment.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: comment,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        // Max width set karein taake bohot lamba comment screen se bahar na jaye
        textPainter.layout(maxWidth: size.width * 0.4);

        //  Initial position (Center align)
        double textX = pos.dx - (textPainter.width / 2);
        double textY = pos.dy - 50; // Thora mazeed upar kar diya taake shape se gap rahe

        // Text ko screen ke edges ke andar rakhein
        // Left boundary check
        if (textX < 5) textX = 5;
        // Right boundary check
        if (textX + textPainter.width > size.width - 5) {
          textX = size.width - textPainter.width - 5;
        }
        // Top boundary check (Agar annotation bilkul top par ho)
        if (textY < 5) textY = pos.dy + 40; // Agar upar jagah nahi to niche dikhao

        Offset finalLevelPos = Offset(textX, textY);

        // 4. Background Box
        final bgPaint = Paint()
          ..color = drawColor.withOpacity(0.8)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                finalLevelPos.dx - 4,
                finalLevelPos.dy - 2,
                textPainter.width + 8,
                textPainter.height + 4
            ),
            const Radius.circular(4),
          ),
          bgPaint,
        );

        // 5. Paint Text
        textPainter.paint(canvas, finalLevelPos);
      }
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;
}