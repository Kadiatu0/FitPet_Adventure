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
      backgroundColor: Color(0xFFF5D7A1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {
            // Square.
            final petSize = Size(constraints.maxWidth, constraints.maxWidth);

            return FutureBuilder(
              future: viewModel.petName,
              builder: (_, snapshot) {
                final petName = snapshot.data ?? '';

                if (petName == '') {
                  return SizedBox(width: petSize.width, height: petSize.height);
                }

                return ListenableBuilder(
                  listenable: viewModel,
                  builder: (_, _) {
                    return Column(
                      children: [
                        // Pet plus cosmetics.
                        Stack(
                          key: petKey,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/${petName}_egg.png',
                              width: petSize.width,
                              height: petSize.height,
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
                          child: CosmeticPicker(
                            viewModel: viewModel,
                            petKey: petKey,
                            petSize: petSize,
                          ),
                        ),

                        // For padding.
                        SizedBox(height: 20),

                        // Resize, rotate, and flip.
                        Expanded(
                          child: Center(child: Modify(viewmodel: viewModel)),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
