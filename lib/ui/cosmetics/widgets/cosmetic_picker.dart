import 'package:flutter/material.dart';

import '../view_model/cosmetics_viewmodel.dart';

class CosmeticPicker extends StatelessWidget {
  final CosmeticsViewmodel viewModel;
  final GlobalKey petKey;

  const CosmeticPicker({
    super.key,
    required this.viewModel,
    required this.petKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.grey.shade200,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.availableCosmetics.length,
        itemBuilder: (_, index) {
          final imagePath = viewModel.availableCosmetics[index];
          final cosmeticWidth = 160.0;
          final cosmeticHeight = 160.0;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Draggable<String>(
              data: imagePath,

              feedback: Image.asset(
                imagePath,
                width: cosmeticWidth,
                height: cosmeticHeight,
              ),

              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  imagePath,
                  width: cosmeticWidth,
                  height: cosmeticHeight,
                ),
              ),

              onDraggableCanceled: (_, offset) async {
                final RenderBox? box =
                    petKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  final localOffset = box.globalToLocal(offset);
                  viewModel.addCosmetic(
                    imagePath,
                    cosmeticWidth,
                    cosmeticHeight,
                    localOffset,
                  );
                  await viewModel.saveCosmetics();
                }
              },

              child: Image.asset(
                imagePath,
                width: cosmeticWidth,
                height: cosmeticHeight,
              ),
            ),
          );
        },
      ),
    );
  }
}
