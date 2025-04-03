import 'package:flutter/material.dart';

class Cosmetic {
  final String imagePath;
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
    this.width = 0.0,
    this.height = 0.0,
    this.position = const Offset(0.0, 0.0),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.isFlipped = false,
    this.petWidth = 0.0,
    this.petHeight = 0.0,
  });

  // Convert cosmetic to a map for saving to firestore.
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'width': width,
      'height': height,
      'dx': position.dx,
      'dy': position.dy,
      'scale': scale,
      'rotation': rotation,
      'isFlipped': isFlipped,
      'petWidth': petWidth,
      'petHeight': petHeight,
    };
  }

  // Load cosmetic from firestore.
  factory Cosmetic.fromMap(Map<String, dynamic> map) {
    return Cosmetic(
      imagePath: map['imagePath'],
      width: map['width'],
      height: map['height'],
      position: Offset(map['dx'], map['dy']),
      scale: map['scale'],
      rotation: map['rotation'],
      isFlipped: map['isFlipped'],
      petWidth: map['petWidth'],
      petHeight: map['petHeight'],
    );
  }
}
