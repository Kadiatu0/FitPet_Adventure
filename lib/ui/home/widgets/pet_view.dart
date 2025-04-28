import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../view_model/home_viewmodel.dart';
import '../../core/ui/display_cosmetic.dart';
import 'evolution_bar.dart';

class PetView extends StatelessWidget {
  final HomeViewModel viewModel;
  final Size petSize;

  const PetView({super.key, required this.viewModel, required this.petSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Pet name
              FutureBuilder(
                future: viewModel.petName,
                builder: (_, snapshot) {
                  final petName = snapshot.data ?? '';

                  return Text(
                    petName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  );
                },
              ),

              // Pet level
              ListenableBuilder(
                listenable: viewModel,
                builder: (_, _) {
                  return Column(
                    children: [
                      // Pet level.
                      // Text(
                      //   'Level ${viewModel.petLevel}',
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),

                      // Image of the pet with cosmetics.
                      FutureBuilder(
                        future: Future.wait([
                          viewModel.petType,
                          viewModel.loadCosmetics(),
                        ]),
                        builder: (_, snapshot) {
                          if (!(snapshot.hasData)) {
                            return SizedBox(
                              width: petSize.width,
                              height: petSize.height,
                            );
                          }

                          final petType = snapshot.data![0] as String;

                          if (petType == '') {
                            return SizedBox(
                              width: petSize.width,
                              height: petSize.height,
                            );
                          }

                          final petEvolutionName = viewModel.petEvolutionName;

                          return Stack(
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
                                DisplayCosmetic(
                                  cosmetic: cosmetic,
                                  newPetSize: petSize,
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Evolution bar.
                      Builder(
                        builder: (_) {
                          switch (viewModel.petEvolutionName) {
                            case 'egg':
                              return EvolutionBar(
                                stepCount: viewModel.totalSteps,
                                stepGoal: viewModel.stepGoal,
                              );
                            case 'baby':
                              final barSteps =
                                  viewModel.totalSteps % viewModel.stepGoal;

                              return EvolutionBar(
                                stepCount: barSteps,
                                stepGoal: viewModel.stepGoal,
                              );
                            default:
                              return EvolutionBar(
                                stepCount: viewModel.stepGoal,
                                stepGoal: viewModel.stepGoal,
                              );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),

              // Text below evolution bar.
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder: (_, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${NumberFormat.decimalPattern('en_us').format(viewModel.totalSteps)} steps',
                          style: TextStyle(
                            color: Color(0xFF8E8971),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (viewModel.petEvolutionName == 'old')
                          Text(
                            'Fully Evolved!',
                            style: TextStyle(
                              color: Color(0xFF8E8971),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            'Goal ${viewModel.stepGoal} steps',
                            style: TextStyle(
                              color: Color(0xFF8E8971),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
