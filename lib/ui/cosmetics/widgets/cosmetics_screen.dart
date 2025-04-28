import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view_model/cosmetics_viewmodel.dart';
import '../../../ui/core/ui/nav_bar.dart';
import 'modify.dart';
import 'cosmetic_picker.dart';
import 'interactive_cosmetic.dart';

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
                viewModel.petName,
                viewModel.petEvolutionName,
                viewModel.loadCosmetics(),
              ]),
              builder: (_, snapshot) {
                if (!(snapshot.hasData)) {
                  return SizedBox(width: petSize.width, height: petSize.height);
                }

                final petName = snapshot.data![0] as String;

                if (petName == '') {
                  return SizedBox(width: petSize.width, height: petSize.height);
                }

                final petEvolutionName = snapshot.data![1] as String;

                return ListenableBuilder(
                  listenable: viewModel,
                  builder: (_, _) {
                    return Column(
                      children: [
                        // Pet plus cosmetics.
                        Stack(
                          key: petKey,
                          children: [
                            Image.asset(
                              'assets/${petName}_$petEvolutionName.png',
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
                        ElevatedButton(
                          onPressed: () {
                            showCupertinoDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (_) {
                                return CupertinoAlertDialog(
                                  content: Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                    'Clear All Cosmetics',
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          viewModel.removeAllCosmetics();
                                          context.pop();
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () => context.pop(),
                                        child: Text('No'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Clear'),
                        ),

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
