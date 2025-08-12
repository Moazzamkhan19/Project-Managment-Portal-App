import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/Task.dart';

class Charts {
  Widget createPieChartForTasks(List<Task> tasks) {
    int highCompleted =
        tasks.where((t) => t.priority == 1 && t.isCompleted).length;
    int mediumCompleted =
        tasks.where((t) => t.priority == 2 && t.isCompleted).length;
    int lowCompleted =
        tasks.where((t) => t.priority == 3 && t.isCompleted).length;

    int total = highCompleted + mediumCompleted + lowCompleted;

    double highPercent = total == 0 ? 0 : (highCompleted / total * 100);
    double mediumPercent = total == 0 ? 0 : (mediumCompleted / total * 100);
    double lowPercent = total == 0 ? 0 : (lowCompleted / total * 100);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tasks Completion",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: highCompleted.toDouble(),
                      title: '',
                      color: Colors.red,
                    ),
                    PieChartSectionData(
                      value: mediumCompleted.toDouble(),
                      title: '',
                      color: Colors.orange,
                    ),
                    PieChartSectionData(
                      value: lowCompleted.toDouble(),
                      title: '',
                      color: Colors.green,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Percentages directly below chart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.red, "High", highPercent),
                _buildLegendItem(Colors.orange, "Medium", mediumPercent),
                _buildLegendItem(Colors.green, "Low", lowPercent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget createLineChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Progress Over Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 2.5),
                        FlSpot(3, 4),
                        FlSpot(4, 3.5),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            "$label = ${percent.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

}




