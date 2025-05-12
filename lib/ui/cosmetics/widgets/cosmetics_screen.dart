import 'package:flutter/material.dart';

import '../view_model/cosmetics_viewmodel.dart';
import '../../../ui/core/ui/nav_bar.dart';
import 'modify.dart';
import 'cosmetic_picker.dart';
import 'interactive_cosmetic.dart';
import 'clear_cosmetics_button.dart';
import 'edit_pet_name_button.dart';

class CosmeticsScreen extends StatelessWidget {
  final CosmeticsViewmodel viewModel;
  // Used to find the render box of the pet.
  final GlobalKey petKey = GlobalKey();

  CosmeticsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5D7A1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {
            // Square.
            final petSize = Size(constraints.maxWidth, constraints.maxWidth);

            return FutureBuilder(
              future: Future.wait([
                viewModel.petType,
                viewModel.petEvolutionName,
                viewModel.loadCosmetics(),
              ]),
              builder: (_, snapshot) {
                if (!(snapshot.hasData)) {
                  return SizedBox(width: petSize.width, height: petSize.height);
                }

                final petType = snapshot.data![0] as String;

                if (petType == '') {
                  return SizedBox(width: petSize.width, height: petSize.height);
                }

                final petEvolutionName = snapshot.data![1] as String;

                return ListenableBuilder(
                  listenable: viewModel,
                  builder: (_, _) {
                    return Column(
                      children: [
                        // To position the clear button on the left.
                        Stack(
                          children: [
                            ClearCosmeticsButton(viewModel: viewModel),

                            // Pet name and edit button.
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 35.0),

                                  FutureBuilder(
                                    future: viewModel.petName,
                                    builder: (_, snapshot) {
                                      final petName = snapshot.data ?? '';

                                      return Text(
                                        petName,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    },
                                  ),

                                  EditPetNameButton(viewModel: viewModel),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Pet plus cosmetics.
                        Stack(
                          key: petKey,
                          children: [
                            Image.asset(
                              'assets/${petType}_$petEvolutionName.png',
                              width: petSize.width,
                              height: petSize.height,
                              fit: BoxFit.fill,
                              alignment: Alignment.topLeft,
                            ),
                            for (final cosmetic
                                in viewModel.placedCosmetics.values)
                              InteractiveCosmetic(
                                viewModel: viewModel,
                                cosmetic: cosmetic,
                              ),
                          ],
                        ),

                        // For padding.
                        SizedBox(height: 20),

                        // Cosemetics selection menu.
                        CosmeticPicker(
                          viewModel: viewModel,
                          petKey: petKey,
                          petSize: petSize,
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
