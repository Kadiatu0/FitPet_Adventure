import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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

  // Function to show background picker
  void _showBackgroundPicker() async {
    final backgrounds = [
      'assets/back1.JPG',
      'assets/back2.JPG',
      'assets/back3.JPG',
      'assets/back4.JPG',
      'assets/back5.JPG',
      'assets/back6.JPG',
      'assets/back7.JPG',
      'assets/back8.JPG',
      'assets/back9.JPG',
      'assets/back10.JPG',
      'assets/back11.JPG',
      'assets/back12.JPG',
      'assets/back13.JPG',
    ];

    final selected = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Choose Background'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children:
                    backgrounds.map((path) {
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, path),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(path, fit: BoxFit.cover),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
    );

    if (selected != null) {
      widget.viewModel.setBackground(selected);
    }
  }

  // Trigger jump animation and show "Hi" message
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
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

                          return GestureDetector(
                            onTap: _triggerJump, // Tapping on pet triggers jump
                            onDoubleTap:
                                _showBackgroundPicker, // Double tap for background picker
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    viewModel.backgroundImage,
                                    width:
                                        petSize.width * 2.5, // Increased size
                                    height:
                                        petSize.height * 1, // Increased size
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  transform: Matrix4.translationValues(
                                    0,
                                    _jumpOffset,
                                    0,
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.asset(
                                          'assets/${petType}_$petEvolutionName.png',
                                          width:
                                              petSize.width, // Increased size
                                          height:
                                              petSize.height, // Increased size
                                          fit: BoxFit.fill,
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      for (final cosmetic
                                          in viewModel.placedCosmetics.values)
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
                      GestureDetector(
                        onTap: () async {
                          if (kDebugMode) {
                            await viewModel.incrementSteps();
                          }
                        },
                        child: Builder(
                          builder: (_) {
                            if (viewModel.petEvolutionName == 'old') {
                              return EvolutionBar(
                                stepCount: viewModel.stepGoal,
                                stepGoal: viewModel.stepGoal,
                              );
                            }

                            final stepCount =
                                viewModel.totalSteps % viewModel.stepGoal;

                            return EvolutionBar(
                              stepCount: stepCount,
                              stepGoal: viewModel.stepGoal,
                            );
                          },
                        ),
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
          BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 3),
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
