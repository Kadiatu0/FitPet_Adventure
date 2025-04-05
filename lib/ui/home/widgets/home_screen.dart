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
      // Press spacebar to increment steps in debug mode.
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (event) async {
          if (kDebugMode &&
              event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.space) {
            await viewModel.incrementSteps();
          }
        },

        child: LayoutBuilder(
          builder: (context, constraints) {
            final petViewHeight = constraints.maxHeight / 3.0;
            // Square based on max height of box.
            final petSize = Size(petViewHeight, petViewHeight);

            return Column(
              children: [
                Container(
                  color: Color(0xFFFDFBD4),
                  child: SafeArea(
                    child: PetView(viewModel: viewModel, petSize: petSize),
                  ),
                ),

                const Divider(color: Colors.grey, thickness: 2.0, height: 1.0),
                StepsGraph(viewModel: viewModel),
                const Divider(color: Colors.grey, thickness: 2.0, height: 10.0),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
