import 'package:flutter/material.dart';

class Cosmetic {
  final String imagePath;
  String uuid;
  double width;
  double height;
  Offset position;
  double scale;
  double rotation;
  bool isFlipped;
  double petWidth;
  double petHeight;

  Cosmetic({
    required this.imagePath,
    this.uuid = '',
    this.width = 0.0,
    this.height = 0.0,
    this.position = const Offset(0.0, 0.0),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.isFlipped = false,
    this.petWidth = 0.0,
    this.petHeight = 0.0,
  });
}
