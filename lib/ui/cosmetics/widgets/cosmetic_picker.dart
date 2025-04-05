import 'package:flutter/material.dart';

import '../view_model/cosmetics_viewmodel.dart';

class CosmeticPicker extends StatelessWidget {
  final CosmeticsViewmodel viewModel;
  final GlobalKey petKey;
  final Size petSize;

  const CosmeticPicker({
    super.key,
    required this.viewModel,
    required this.petKey,
    required this.petSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Color(0xFFFFF1D6),

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.availableCosmetics.length,
        itemBuilder: (_, index) {
          final imagePath = viewModel.availableCosmetics[index];
          final cosmeticWidth = viewModel.cosmeticSize.width;
          final cosmeticHeight = viewModel.cosmeticSize.height;

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
                    petSize.width,
                    petSize.height,
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
