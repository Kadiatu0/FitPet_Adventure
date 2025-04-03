import 'package:flutter/material.dart';

import '../../../domain/models/cosmetic.dart';

class DisplayCosmetic extends StatelessWidget {
  final Cosmetic cosmetic;
  final Size newPetSize;

  const DisplayCosmetic({
    super.key,
    required this.cosmetic,
    required this.newPetSize,
  });

  @override
  Widget build(BuildContext context) {
    // Assuming square dimensions.
    final scaleFactor = (newPetSize.width) / (cosmetic.petWidth);

    return Positioned(
      left: (cosmetic.position.dx * scaleFactor),
      top: (cosmetic.position.dy * scaleFactor),
      child: Transform(
        transform:
            Matrix4.identity()
              ..scale(cosmetic.isFlipped ? -1.0 : 1.0, 1.0)
              ..scale(cosmetic.scale)
              ..rotateZ(cosmetic.rotation),
        alignment: Alignment.center,
        child: Image.asset(
          cosmetic.imagePath,
          width: cosmetic.width * scaleFactor,
          height: cosmetic.height * scaleFactor,
        ),
      ),
    );
  }
}
