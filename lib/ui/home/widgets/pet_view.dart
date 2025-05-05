import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../view_model/home_viewmodel.dart';
import '../../core/ui/display_cosmetic.dart';
import 'evolution_bar.dart';


class PetView extends StatefulWidget {
  final HomeViewModel viewModel;
  final Size petSize;

  const PetView({super.key, required this.viewModel, required this.petSize});

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> with TickerProviderStateMixin {
  double _jumpOffset = 0;
  bool _isJumping = false;
  bool _showHi = false;

  void _triggerJump() async {
    if (_isJumping) return;

    setState(() {
      _jumpOffset = -20;
      _isJumping = true;
      _showHi = true;
    });

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      _jumpOffset = 0;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _showHi = false;
      _isJumping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final petSize = widget.petSize;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              FutureBuilder(
                future: viewModel.petName,
                builder: (_, snapshot) {
                  final petName = snapshot.data ?? '';
                  return Text(
                    petName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  );
                },
              ),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: viewModel,
                builder: (_, __) {
                  return Column(
                    children: [
                      FutureBuilder(
                        future: Future.wait([
                          viewModel.petType,
                          viewModel.loadCosmetics(),
                        ]),
                        builder: (_, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(width: petSize.width, height: petSize.height);
                          }

                          final petType = snapshot.data![0] as String;
                          if (petType == '') {
                            return SizedBox(width: petSize.width, height: petSize.height);
                          }

                          final petEvolutionName = viewModel.petEvolutionName;

                          return GestureDetector(
                            onTap: _triggerJump,
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  transform: Matrix4.translationValues(0, _jumpOffset, 0),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/${petType}_$petEvolutionName.png',
                                        width: petSize.width,
                                        height: petSize.height,
                                        fit: BoxFit.fill,
                                        alignment: Alignment.topLeft,
                                      ),
                                      for (final cosmetic in viewModel.placedCosmetics.values)
                                        DisplayCosmetic(
                                          cosmetic: cosmetic,
                                          newPetSize: petSize,
                                        ),
                                    ],
                                  ),
                                ),
                                if (_showHi)
                                  Positioned(
                                    top: 0,
                                    left: 20,
                                    child: _HiMessage(),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Builder(
                        builder: (_) {
                          final stepCount = viewModel.petEvolutionName == 'baby'
                              ? viewModel.totalSteps % viewModel.stepGoal
                              : viewModel.totalSteps;

                          return EvolutionBar(
                            stepCount: stepCount,
                            stepGoal: viewModel.stepGoal,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: ListenableBuilder(
                  listenable: viewModel,
                  builder: (_, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${NumberFormat.decimalPattern('en_us').format(viewModel.totalSteps)} steps',
                          style: const TextStyle(
                            color: Color(0xFF8E8971),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          viewModel.petEvolutionName == 'old'
                              ? 'Fully Evolved!'
                              : 'Goal ${viewModel.stepGoal} steps',
                          style: const TextStyle(
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

class _HiMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 190, 96),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Text(
        'Oi!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
