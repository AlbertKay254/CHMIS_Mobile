import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardsPage extends StatelessWidget {
  const DashboardsPage({super.key});

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Dashboards"),
        backgroundColor:  Colors.grey.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // ===== TOP SUMMARY CARDS =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 6)],
            ),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard("Pending Appointments", "12", Icons.calendar_today, Colors.blue),
                _buildStatCard("Patients Encountered", "45", Icons.people, Colors.green),
                _buildStatCard("Unopened Notifications", "5", Icons.notifications, Colors.orange),
                _buildStatCard("Pending Consultations", "7", Icons.chat, Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ====== PIE CHART ======
          _buildChartContainer(
            title: "Cases Handled",
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        value: 60,
                        title: "Outpatient",
                        color: Colors.blue,
                        radius: 50,
                        titleStyle:
                            const TextStyle(fontSize: 10, color: Colors.white)),
                    PieChartSectionData(
                        value: 40,
                        title: "Inpatient",
                        color: Colors.green,
                        radius: 50,
                        titleStyle:
                            const TextStyle(fontSize: 10, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ====== LINE CHART ======
          _buildChartContainer(
            title: "Patients Seen This Week",
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),   // 🔹 hide top
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // 🔹 hide right
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text("D${value.toInt()}",
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 5),
                        FlSpot(2, 7),
                        FlSpot(3, 6),
                        FlSpot(4, 9),
                        FlSpot(5, 8),
                        FlSpot(6, 11),
                        FlSpot(7, 7),
                      ],
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                )
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ====== BAR CHART ======
          _buildChartContainer(
            title: "Appointments Handled This Week",
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),   // 🔹 hide top
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // 🔹 hide right
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text("D${value.toInt()}",
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.teal)]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 12, color: Colors.teal)]),
                      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: Colors.teal)]),
                      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 9, color: Colors.teal)]),
                      BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 11, color: Colors.teal)]),
                      BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 7, color: Colors.teal)]),
                      BarChartGroupData(x: 7, barRods: [BarChartRodData(toY: 10, color: Colors.teal)]),
                    ],
                  )
                 ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helper Widgets =====
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
