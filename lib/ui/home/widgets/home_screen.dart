import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;

import '../view_model/home_viewmodel.dart';
import '../../core/ui/nav_bar.dart';
import 'pet_view.dart';
import 'steps_graph.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5D7A1),
      // Press spacebar to increment steps in debug mode.
      body: FutureBuilder(
        future: Future.wait([
          viewModel.loadEvolutionNum(),
          viewModel.loadSteps(),
        ]),
        builder: (_, _) {
          return KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            autofocus: true,
            onKeyEvent: (event) {
              if (kDebugMode &&
                  event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.space) {
                viewModel.incrementSteps();
              }
            },

            child: LayoutBuilder(
              builder: (context, constraints) {
                final petViewHeight = constraints.maxHeight / 3.0;
                // Square based on max height of box.
                final petSize = Size(petViewHeight, petViewHeight);

                return Column(
                  children: [
                    SafeArea(
                      child: PetView(viewModel: viewModel, petSize: petSize),
                    ),

                    const Divider(
                      color: Color(0xFF8E8971),
                      thickness: 2.0,
                      height: 0.0,
                    ),
                    StepsGraph(viewModel: viewModel),
                    // const Divider(
                    //   color: Color(0xFF8E8971),
                    //   thickness: 2.0,
                    //   height: 0.0,
                    // ),
                  ],
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
