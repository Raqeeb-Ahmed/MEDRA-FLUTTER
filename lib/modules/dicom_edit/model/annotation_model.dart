import 'package:flutter/material.dart';

class AnnotationModel {
  final Offset position;
  final Color color;
  final String type;

  AnnotationModel({
    required this.position,
    required this.color,
    required this.type,
  });
}
