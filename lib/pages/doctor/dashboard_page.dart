import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardsPage extends StatefulWidget {
  const DashboardsPage({super.key});

  @override
  State<DashboardsPage> createState() => _DashboardsPageState();
}

class _DashboardsPageState extends State<DashboardsPage> {
  List<InOutData> inOutData = [];
  List<WardOccupancy> wardData = [];
  List<TopDisease> diseaseData = [];

  @override
  void initState() {
    super.initState();
    fetchInOutData();
    fetchWardOccupancy();
    fetchTopDiseases();
  }

  Future<void> fetchInOutData() async {
    final response = await http.get(Uri.parse('http://197.232.14.151:3030/api/inoutchart'));
    if (response.statusCode == 200) {
      setState(() {
        inOutData = (json.decode(response.body) as List)
            .map((data) => InOutData.fromJson(data))
            .toList();
      });
    }
  }

  Future<void> fetchWardOccupancy() async {
    final response = await http.get(Uri.parse('http://197.232.14.151:3030/api/wardoccupancy'));
    if (response.statusCode == 200) {
      setState(() {
        wardData = (json.decode(response.body) as List)
            .map((data) => WardOccupancy.fromJson(data))
            .toList();
      });
    }
  }

  Future<void> fetchTopDiseases() async {
    final response = await http.get(Uri.parse('http://197.232.14.151:3030/api/topdiseases'));
    if (response.statusCode == 200) {
      setState(() {
        diseaseData = (json.decode(response.body) as List)
            .map((data) => TopDisease.fromJson(data))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // appBar: AppBar(
      //   title: const Text("Dashboards"),
      //   backgroundColor: Colors.grey.shade100,
      // ),
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

          // ====== DOUGHNUT CHART ======
          _buildChartContainer(
            title: "Cases Handled",
            child: SizedBox(
              height: 250,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<InOutData, String>(
                    dataSource: inOutData,
                    xValueMapper: (InOutData data, _) => data.encounterType,
                    yValueMapper: (InOutData data, _) => data.totalEncounters,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    name: 'Cases',
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ====== WARD OCCUPANCY BAR CHART ======
          _buildChartContainer(
            title: "Ward Occupancy",
            child: SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: <CartesianSeries>[
                  ColumnSeries<WardOccupancy, String>(
                    dataSource: wardData,
                    xValueMapper: (WardOccupancy data, _) => data.wardName,
                    yValueMapper: (WardOccupancy data, _) => data.occupiedBeds,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    name: 'Occupied Beds',
                    color: Colors.blue,
                  ),
                  ColumnSeries<WardOccupancy, String>(
                    dataSource: wardData,
                    xValueMapper: (WardOccupancy data, _) => data.wardName,
                    yValueMapper: (WardOccupancy data, _) => int.parse(data.availableBeds),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    name: 'Available Beds',
                    color: Colors.green,
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ====== TOP DISEASES LINE CHART ======
          _buildChartContainer(
            title: "Top Diseases This Week",
            child: SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: _getDiseaseLineSeries(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate line series for each disease
  List<LineSeries<TopDisease, String>> _getDiseaseLineSeries() {
    // This is a simplified example - you might need to adjust based on your actual data structure
    // For a real implementation, you would need data points over time for each disease
    return diseaseData.map((disease) {
      return LineSeries<TopDisease, String>(
        dataSource: [disease], // Just using the single data point for demonstration
        xValueMapper: (TopDisease data, _) => disease.diagnosisDescription,
        yValueMapper: (TopDisease data, _) => disease.totalPatients.toDouble(),
        name: disease.diagnosisDescription,
        markerSettings: const MarkerSettings(isVisible: true),
      );
    }).toList();
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

// Data model classes
class InOutData {
  final String encounterType;
  final int totalEncounters;

  InOutData({required this.encounterType, required this.totalEncounters});

  factory InOutData.fromJson(Map<String, dynamic> json) {
    return InOutData(
      encounterType: json['encounter_type'],
      totalEncounters: json['total_encounters'],
    );
  }
}

class WardOccupancy {
  final int wardNumber;
  final String wardName;
  final String totalBeds;
  final int occupiedBeds;
  final String availableBeds;
  final String percentageOccupied;

  WardOccupancy({
    required this.wardNumber,
    required this.wardName,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.availableBeds,
    required this.percentageOccupied,
  });

  factory WardOccupancy.fromJson(Map<String, dynamic> json) {
    return WardOccupancy(
      wardNumber: json['wardNumber'],
      wardName: json['wardName'],
      totalBeds: json['totalBeds'],
      occupiedBeds: json['occupiedBeds'],
      availableBeds: json['availableBeds'],
      percentageOccupied: json['percentageOccupied'],
    );
  }
}

class TopDisease {
  final String icd10Code;
  final String diagnosisDescription;
  final String description;
  final int totalPatients;

  TopDisease({
    required this.icd10Code,
    required this.diagnosisDescription,
    required this.description,
    required this.totalPatients,
  });

  factory TopDisease.fromJson(Map<String, dynamic> json) {
    return TopDisease(
      icd10Code: json['ICD_10_code'],
      diagnosisDescription: json['DiagnosisDescription'],
      description: json['description'],
      totalPatients: json['totalPatients'],
    );
  }
}