import 'package:flutter/material.dart';

import '../view_model/cosmetics_viewmodel.dart';
import '../../../domain/models/cosmetic.dart';

class InteractiveCosmetic extends StatelessWidget {
  final CosmeticsViewmodel viewModel;
  final Cosmetic cosmetic;

  const InteractiveCosmetic({
    super.key,
    required this.viewModel,
    required this.cosmetic,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: cosmetic.position.dx,
      top: cosmetic.position.dy,

      child: GestureDetector(
        onTap: () => viewModel.selectCosmetic(cosmetic),
        onDoubleTap: () async {
          viewModel.selectCosmetic(cosmetic);
          viewModel.removeCosmetic();
          await viewModel.saveCosmetics();
        },
        onPanUpdate: (details) {
          viewModel.selectCosmetic(cosmetic);
          viewModel.updateCosmetic(position: cosmetic.position + details.delta);
        },
        onPanEnd: (_) async => await viewModel.saveCosmetics(),
        child: Transform(
          transform:
              Matrix4.identity()
                ..scale(cosmetic.isFlipped ? -1.0 : 1.0, 1.0)
                ..scale(cosmetic.scale)
                ..rotateZ(cosmetic.rotation),
          alignment: Alignment.center,
          child: Image.asset(
            cosmetic.imagePath,
            width: cosmetic.width,
            height: cosmetic.height,
          ),
        ),
      ),
    );
  }
}
