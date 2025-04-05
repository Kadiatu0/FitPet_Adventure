import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class EvolutionBar extends StatelessWidget {
  final int stepCount;
  final int stepGoal;
  final double barRadius = 50.0;

  const EvolutionBar({
    super.key,
    required this.stepCount,
    required this.stepGoal,
  }) : assert(
         stepCount >= 0 && stepCount <= stepGoal,
         'Steps must be between 0 and $stepGoal',
       );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final progress = (stepCount / stepGoal); 

        return Container(
          alignment: Alignment.centerLeft,
          width: maxWidth,
          // Slighty larger because of outline.
          height: 17.0,

          // Outline.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(barRadius),
            border: Border.all(color: Colors.black, width: 1),
          ),

          child: LinearPercentIndicator(
            width: maxWidth - 2,
            lineHeight: 15.0,
            percent: progress,
            backgroundColor: Colors.grey.shade400,
            progressColor: Colors.green.shade600,
            barRadius: Radius.circular(barRadius),
            padding: const EdgeInsets.all(0.0),
          ),
        );
      },
    );
  }
}
