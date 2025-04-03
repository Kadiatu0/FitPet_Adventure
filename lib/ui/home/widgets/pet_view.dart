import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../view_model/home_viewmodel.dart';
import 'evolution_bar.dart';
import '../../core/ui/display_cosmetic.dart';

class PetView extends StatelessWidget {
  final HomeViewModel viewModel;

  const PetView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Load cosmetics on entry.
    FutureBuilder(
      future: viewModel.loadCosmetics(),
      builder: (_, _) => Container(),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Pet name
              Text(
                // Pull pet name from database
                'FitPet Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              // Pet level
              ListenableBuilder(
                listenable: viewModel,
                builder: (_, _) {
                  return Column(
                    children: [
                      // Pet level.
                      FutureBuilder(
                        future: viewModel.petLevel,
                        builder: (_, snapshot) {
                          final petLevel = snapshot.data ?? 0;

                          return Text(
                            'Level $petLevel',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),

                      // Image of the pet with cosmetics.
                      Stack(
                        children: [
                          // Pull pet selection from database.
                          Image.asset(
                            'assets/pet.png',
                            width: viewModel.petSize.width,
                            height: viewModel.petSize.height,
                            fit: BoxFit.fill,
                            alignment: Alignment.topLeft,
                          ),

                          for (final cosmetic in viewModel.placedCosmetics)
                            DisplayCosmetic(
                              cosmetic: cosmetic,
                              newPetSize: viewModel.petSize,
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Evolution bar.
                      FutureBuilder(
                        future: viewModel.totalSteps,
                        builder: (_, snapshot) {
                          final totalSteps = snapshot.data ?? 0;

                          return EvolutionBar(
                            stepCount: totalSteps,
                            stepGoal: 1000,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              // Text below evolution bar.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListenableBuilder(
                      listenable: viewModel,
                      builder: (_, _) {
                        return FutureBuilder(
                          future: viewModel.totalSteps,
                          builder: (_, snapshot) {
                            final totalSteps = NumberFormat.decimalPattern(
                              'en_us',
                            ).format(snapshot.data ?? 0);

                            return Text(
                              '$totalSteps steps',
                              style: TextStyle(
                                color: Color(0xFF8E8971),
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Hardcoded goal value
                    Text(
                      'Goal 1,000 steps',
                      style: TextStyle(
                        color: Color(0xFF8E8971),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
