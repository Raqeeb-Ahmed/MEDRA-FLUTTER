import 'package:flutter/material.dart';
import 'dart:math' as math;

class Vec3 {
  final double x, y, z;
  Vec3(this.x, this.y, this.z);

  factory Vec3.fromList(List<dynamic> list) {
    return Vec3(
      list.isNotEmpty ? (list[0] as num).toDouble() : 0.0,
      list.length > 1 ? (list[1] as num).toDouble() : 0.0,
      list.length > 2 ? (list[2] as num).toDouble() : 0.0,
    );
  }

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);

  double dot(Vec3 v) => x * v.x + y * v.y + z * v.z;
  Vec3 cross(Vec3 v) => Vec3(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
  double length() => math.sqrt(x * x + y * y + z * z);

  Vec3 normalized() {
    double len = math.max(length(), 0.000001);
    return Vec3(x / len, y / len, z / len);
  }
}

class SliceGeometry {
  final Vec3 ipp, row, col, normal;
  final double spacingX, spacingY, cols, rows;
  final String frameUID;

  SliceGeometry._(this.ipp, this.row, this.col, this.normal, this.spacingX, this.spacingY, this.cols, this.rows, this.frameUID);

  static SliceGeometry? fromReference(Map<String, dynamic>? ref) {
    if (ref == null) return null;
    try {
      List<dynamic> pos = ref['ImagePositionPatient'];
      List<dynamic> iop = ref['ImageOrientationPatient'];
      List<dynamic>? px = ref['PixelSpacing'];

      double spY = (px != null && px.isNotEmpty) ? (px[0] as num).toDouble() : 1.0;
      double spX = (px != null && px.length > 1) ? (px[1] as num).toDouble() : 1.0;
      double c = ref['Columns'] != null ? (ref['Columns'] as num).toDouble() : 512.0;
      double r = ref['Rows'] != null ? (ref['Rows'] as num).toDouble() : 512.0;
      String uid = ref['FrameOfReferenceUID'] ?? "1";

      Vec3 ipp = Vec3.fromList(pos);
      Vec3 row = Vec3.fromList([iop[0], iop[1], iop[2]]).normalized();
      Vec3 col = Vec3.fromList([iop[3], iop[4], iop[5]]).normalized();
      Vec3 normal = row.cross(col).normalized();

      return SliceGeometry._(ipp, row, col, normal, spX, spY, c, r, uid);
    } catch (e) {
      return null;
    }
  }
}

class ReferenceLinePainter extends CustomPainter {
  final Map<String, dynamic>? sourceRef;
  final Map<String, dynamic>? targetRef;

  ReferenceLinePainter({required this.sourceRef, required this.targetRef});

  @override
  void paint(Canvas canvas, Size size) {
    if (sourceRef == null || targetRef == null) return;

    SliceGeometry? src = SliceGeometry.fromReference(sourceRef);
    SliceGeometry? trg = SliceGeometry.fromReference(targetRef);

    if (src == null || trg == null) return;

    // 1. Dono planes ke normals ka Cross Product le kar intersection line ki direction nikali
    Vec3 dir = src.normal.cross(trg.normal);
    double dirLenSq = dir.dot(dir);

    // Agar direction 0 hai to planes parallel hain (Line nahi banegi)
    if (dirLenSq < 0.0001) return;

    // 2. Wo point nikalna jo perfectly dono 3D planes par exist karta ho
    double ds = src.ipp.dot(src.normal);
    double dt = trg.ipp.dot(trg.normal);
    Vec3 p0 = (trg.normal.cross(dir) * ds + dir.cross(src.normal) * dt) * (1.0 / dirLenSq);

    // 3. Line ki lambai ko 500 se 5000 kar diya hai taake kabhi short na ho!
    Vec3 p1 = p0 - (dir * 5000.0);
    Vec3 p2 = p0 + (dir * 5000.0);

    // 2D Screen par map karna
    Offset? a = worldToScreen(p1, trg, size);
    Offset? b = worldToScreen(p2, trg, size);

    if (a == null || b == null) return;

    // Line Clipping
    List<Offset>? points = clipLineToRect(a, b, Rect.fromLTWH(0, 0, size.width, size.height));
    if (points == null || points.length < 2) return;

    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, points[0], points[1], paint);
  }

  Offset? worldToScreen(Vec3 point, SliceGeometry target, Size canvasSize) {
    Vec3 diff = point - target.ipp;
    double xMM = diff.dot(target.row);
    double yMM = diff.dot(target.col);

    double px = xMM / target.spacingX;
    double py = yMM / target.spacingY;

    double screenX = (px / target.cols) * canvasSize.width;
    double screenY = (py / target.rows) * canvasSize.height;

    return Offset(screenX, screenY);
  }

  List<Offset>? clipLineToRect(Offset a, Offset b, Rect rect) {
    List<Offset> pts = [];
    List<List<Offset>> borders = [
      [rect.topLeft, rect.topRight],
      [rect.topRight, rect.bottomRight],
      [rect.bottomRight, rect.bottomLeft],
      [rect.bottomLeft, rect.topLeft]
    ];

    for (var edge in borders) {
      Offset? p = lineIntersection(a, b, edge[0], edge[1]);
      if (p != null) pts.add(p);
    }
    if (pts.length >= 2) return [pts[0], pts[1]];
    return null;
  }

  Offset? lineIntersection(Offset p1, Offset p2, Offset p3, Offset p4) {
    double d = (p1.dx - p2.dx) * (p3.dy - p4.dy) - (p1.dy - p2.dy) * (p3.dx - p4.dx);
    if (d.abs() < 0.001) return null;

    double x = ((p1.dx * p2.dy - p1.dy * p2.dx) * (p3.dx - p4.dx) - (p1.dx - p2.dx) * (p3.dx * p4.dy - p3.dy * p4.dx)) / d;
    double y = ((p1.dx * p2.dy - p1.dy * p2.dx) * (p3.dy - p4.dy) - (p1.dy - p2.dy) * (p3.dx * p4.dy - p3.dy * p4.dx)) / d;

    // Boundaries mein 1.0 margin diya hai taake corner cutting fail na ho
    if (x < math.min(p3.dx, p4.dx) - 1.0 || x > math.max(p3.dx, p4.dx) + 1.0) return null;
    if (y < math.min(p3.dy, p4.dy) - 1.0 || y > math.max(p3.dy, p4.dy) + 1.0) return null;

    return Offset(x, y);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 6, dashSpace = 4;
    double distance = (p2 - p1).distance;
    if (distance == 0) return;

    Offset direction = (p2 - p1) / distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      Offset start = p1 + direction * currentDistance;
      currentDistance += dashWidth;
      Offset end = p1 + direction * math.min(currentDistance, distance);
      canvas.drawLine(start, end, paint);
      currentDistance += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}