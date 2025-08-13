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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tasks Completion",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 80,
                height: 80,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: highCompleted.toDouble(),
                        title: '',
                        color: Colors.red,
                        radius: 25, // shrink slice radius
                      ),
                      PieChartSectionData(
                        value: mediumCompleted.toDouble(),
                        title: '',
                        color: Colors.orange,
                        radius: 25,
                      ),
                      PieChartSectionData(
                        value: lowCompleted.toDouble(),
                        title: '',
                        color: Colors.green,
                        radius: 25,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 12, // smaller donut hole
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),
            // Percentages directly below chart
            Column(
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
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Progress Over Time",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 80,
                width: 80,
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
                        barWidth: 2,
                      ),
                    ],
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ],
          ),
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




