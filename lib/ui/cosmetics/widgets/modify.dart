import "dart:math" show pi;

import 'package:flutter/material.dart';

import '../view_model/cosmetics_viewmodel.dart';

class Modify extends StatelessWidget {
  final CosmeticsViewmodel viewmodel;

  const Modify({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            // Resize Slider
            const Text(
              "Resize",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: viewmodel.selectedCosmetic.scale,
              min: 0.5,
              max: 3.0,
              onChanged:
                  (changedScale) =>
                      viewmodel.updateCosmetic(scale: changedScale),
              onChangeEnd: (_) async => await viewmodel.saveCosmetics(),
              label: "Resize",
            ),

            // Rotate Slider
            const Text(
              "Rotate",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: viewmodel.selectedCosmetic.rotation,
              min: 0,
              // 360 degrees.
              max: 2 * pi,
              onChanged:
                  (changedRotation) =>
                      viewmodel.updateCosmetic(rotation: changedRotation),
              onChangeEnd: (_) async => await viewmodel.saveCosmetics(),
              label: "Rotate",
            ),

            // Flip Button
            ElevatedButton(
              onPressed: () async {
                viewmodel.flipCosmetic();
                await viewmodel.saveCosmetics();
              },
              child: const Text("Flip"),
            ),
          ],
        ),
      ],
    );
  }
}
