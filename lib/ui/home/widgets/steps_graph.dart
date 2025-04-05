import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../view_model/home_viewmodel.dart';

class StepsGraph extends StatelessWidget {
  final HomeViewModel viewModel;

  const StepsGraph({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color(0xFFFFF1D6),
        child: Column(
          children: [
            // Filter buttons
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => viewModel.selectedFilter = 'Daily',
                    child: const Text(
                      'Daily',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  OutlinedButton(
                    onPressed: () => viewModel.selectedFilter = 'Monthly',
                    child: const Text(
                      'Monthly',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  OutlinedButton(
                    onPressed: () => viewModel.selectedFilter = 'Yearly',
                    child: const Text(
                      'Yearly',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Average and best display
            ListenableBuilder(
              listenable: viewModel,
              builder: (_, _) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            FutureBuilder(
                              future: viewModel.average,
                              builder: (_, snapshot) {
                                final average = snapshot.data ?? 0;
                                return Text('Average\n$average steps');
                              },
                            ),
                          ],
                        ),
                        VerticalDivider(color: Colors.grey.withAlpha(127)),
                        Column(
                          children: [
                            FutureBuilder(
                              future: viewModel.best,
                              builder: (_, snapshot) {
                                final best = snapshot.data ?? 0;
                                return Text('Best\n$best steps');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Cyclical menu
            ListenableBuilder(
              listenable: viewModel,
              builder: (_, _) {
                return Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left),
                            onPressed: viewModel.previousPeriod,
                          ),
                          Text(
                            viewModel.cycleMenuLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_right),
                            onPressed: viewModel.nextPeriod,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Steps bar graph
            ListenableBuilder(
              listenable: viewModel,
              builder: (_, _) {
                return FutureBuilder(
                  future: Future.wait([viewModel.barGroups, viewModel.yMax]),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      final barGroups =
                          snapshot.data![0] as List<BarChartGroupData>;
                      final yMax = snapshot.data![1] as double;

                      return Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: BarChart(
                              BarChartData(
                                barGroups: barGroups,
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      maxIncluded: false,
                                      reservedSize: 53,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4.0,
                                          ),
                                          child: Text(
                                            '${value.toInt()}',
                                            style: const TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) {
                                        // Hours are 0-24 while days
                                        // and months start from 1.
                                        int intValue =
                                            (viewModel.selectedFilter ==
                                                    'Daily')
                                                ? value.toInt()
                                                : value.toInt() + 1;

                                        if (!viewModel.xInterval.contains(
                                          intValue,
                                        )) {
                                          return Container();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                          ),
                                          child: Text('$intValue'),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                ),
                                borderData: FlBorderData(show: false),
                                maxY: yMax,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
