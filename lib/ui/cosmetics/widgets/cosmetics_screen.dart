import 'package:flutter/material.dart';

import '../view_model/cosmetics_viewmodel.dart';
import '../../../ui/core/ui/nav_bar.dart';
import 'modify.dart';
import 'cosmetic_picker.dart';
import 'interactive_cosmetic.dart';

class CosmeticsScreen extends StatelessWidget {
  final CosmeticsViewmodel viewModel;
  // Used to uniquely identify each cosmetic.
  final GlobalKey petKey = GlobalKey();

  CosmeticsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Load cosmetics on entry.
    FutureBuilder(
      future: viewModel.loadCosmetics(),
      builder: (_, _) => Container(),
    );

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (_, _) {
            return Column(
              children: [
                // Pet plus cosmetics.
                Stack(
                  key: petKey,
                  children: [
                    Image.asset(
                      'assets/pet.png',
                      width: viewModel.petSize.width,
                      height: viewModel.petSize.height,
                      fit: BoxFit.fill,
                      alignment: Alignment.topLeft,
                    ),
                    for (final cosmetic in viewModel.placedCosmetics)
                      InteractiveCosmetic(
                        viewModel: viewModel,
                        cosmetic: cosmetic,
                      ),
                  ],
                ),

                // For padding.
                SizedBox(height: 20),

                // Cosemetics selection menu.
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  child: CosmeticPicker(viewModel: viewModel, petKey: petKey),
                ),

                // Resize, rotate, and flip.
                if (viewModel.selectedCosmetic.imagePath != '')
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Modify(viewmodel: viewModel)],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
