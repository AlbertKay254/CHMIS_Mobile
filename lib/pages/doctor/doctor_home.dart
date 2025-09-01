import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/pages/doctor/outpatient_page.dart';
import 'package:medical_app/pages/doctor/inpatient_page.dart';
import 'package:medical_app/util/category_card.dart';
import 'package:medical_app/pages/telemedicine_page.dart';
import 'package:medical_app/pages/option_page.dart';
import 'package:medical_app/pages/doctor/dashboard_page.dart';
import 'package:medical_app/pages/doctor/appointments_page_doc.dart';
import 'package:medical_app/pages/notifications_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:medical_app/pages/doctor/doctor_notes.dart';
import 'package:medical_app/pages/doctor/prescriptions_page.dart';
import 'package:http/http.dart' as http;


class DoctorHomePage extends StatefulWidget {
  final String? doctorName;
  final String? staffID;

  const DoctorHomePage({
    super.key,
    required this.staffID,
    required this.doctorName,
  });

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool _isLoading = true;
  int _selectedIndex = 0;
  List<EncounterData> _encounterData = [];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
    _fetchEncounterData();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchEncounterData() async {
    try {
      final response = await http.get(
        Uri.parse('http://197.232.14.151:3030/api/encounters10days'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _encounterData = data.map((item) => EncounterData.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load encounter data');
      }
    } catch (e) {
      print('Error fetching encounter data: $e');
      // Fallback to mock data if API fails
      setState(() {
        _encounterData = _getMockEncounterData();
      });
    }
  }

  List<EncounterData> _getMockEncounterData() {
    // Generate mock data for demonstration
    return List.generate(10, (index) {
      final date = DateTime.now().subtract(Duration(days: 9 - index));
      return EncounterData(
        date: date,
        encounterCount: 50 + (index * 5) + (index % 3 * 10),
        uniquePatients: 40 + (index * 4) + (index % 2 * 8),
        admissions: (5 + index).toString(),
        diagnosisUpdates: (2 + index % 3).toString(),
        drugsIssued: (20 + index * 2).toString(),
        labRequests: (index % 4).toString(),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildDoctorHomeBody();
    } else if (_selectedIndex == 1) {
      return const DashboardsPage();
    } else if (_selectedIndex == 2) {
      return const TelemedicinePage();
    } else {
      return const OptionPage();
    }
  }

  Widget _buildDoctorHomeBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          appbar(),
          const SizedBox(height: 25),
          welcomeCard(),
          const SizedBox(height: 20),
          statCard(),
          const SizedBox(height: 20),
          dashboardSection(),
          const SizedBox(height: 20),
          categorycard(),
          const SizedBox(height: 25),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// APPBAR WITH DOCTOR NAME
  Padding appbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Dr. ${widget.doctorName ?? ''}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Staff ID: ${widget.staffID ?? ''}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// WELCOME CARD
  Padding welcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 244, 236, 141),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset('lib/icons/surgeon.png', height: 100, width: 100),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Welcome to the Doctor Dashboard",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Manage the patients, monitor prescriptions and see appointments.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CATEGORY CARD ROW
  Container categorycard() {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OutpatientPage()),
            ),
            child: CategoryCard(
                categoryName: 'Outpatient',
                iconImagePath: 'lib/icons/outpatient.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InpatientPage()),
            ),
            child: CategoryCard(
                categoryName: 'Inpatient',
                iconImagePath: 'lib/icons/inpatient.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => 
               PrescriptionsPage(staffID: widget.staffID, doctorName: widget.doctorName)),
            ),
            child: CategoryCard(
                categoryName: 'Prescription',
                iconImagePath: 'lib/icons/pharmacy.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AppointmentsPageDoc(staffID: widget.staffID)),
            ),
            child: CategoryCard(
                categoryName: 'Appointments',
                iconImagePath: 'lib/icons/schedule.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      DoctorNotesPage(staffID: widget.staffID, doctorName: widget.doctorName)),
            ),
            child: CategoryCard(
                categoryName: 'Notes',
                iconImagePath: 'lib/icons/notes2.png'),
          ),
        ],
      ),
    );
  }

  /// STAT CARDS (Events + Notifications)
  Padding statCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppointmentsPageDoc(staffID: widget.staffID),
                  ),
                );
              },
              child: const StatCard(
                icon: Icons.event,
                title: "Events",
                value: "3",
                color: Colors.deepPurple,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationsPage()),
                );
              },
              child: const StatCard(
                icon: Icons.notifications,
                title: "Notifications",
                value: "5",
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DASHBOARD SECTION with "More →"
  Widget dashboardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Patient Encounters (Last 10 Days)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardsPage()),
                    );
                  },
                  child: const Text(
                    "More →",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: _encounterData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: _encounterData
                                .map((e) => e.encounterCount)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2, // Add 20% padding to top
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        LineSeries<EncounterData, String>(
                          dataSource: _encounterData,
                          xValueMapper: (EncounterData data, _) =>
                              'Day ${_encounterData.indexOf(data) + 1}',
                          yValueMapper: (EncounterData data, _) =>
                              data.encounterCount,
                          name: 'Encounters',
                          color: Colors.blueAccent,
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                        LineSeries<EncounterData, String>(
                          dataSource: _encounterData,
                          xValueMapper: (EncounterData data, _) =>
                              'Day ${_encounterData.indexOf(data) + 1}',
                          yValueMapper: (EncounterData data, _) =>
                              data.uniquePatients,
                          name: 'Unique Patients',
                          color: Colors.green,
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// MAIN SCAFFOLD WITH NAVBAR
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 4, 84, 88),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_call), label: 'Telemedicine'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Options'),
        ],
      ),
    );
  }
}

// Data model for encounter data
class EncounterData {
  final DateTime date;
  final int encounterCount;
  final int uniquePatients;
  final String admissions;
  final String diagnosisUpdates;
  final String drugsIssued;
  final String labRequests;

  EncounterData({
    required this.date,
    required this.encounterCount,
    required this.uniquePatients,
    required this.admissions,
    required this.diagnosisUpdates,
    required this.drugsIssued,
    required this.labRequests,
  });

  factory EncounterData.fromJson(Map<String, dynamic> json) {
    return EncounterData(
      date: DateTime.parse(json['date']),
      encounterCount: json['encounter_count'],
      uniquePatients: json['unique_patients'],
      admissions: json['admissions'],
      diagnosisUpdates: json['diagnosis_updates'],
      drugsIssued: json['drugs_issued'],
      labRequests: json['lab_requests'],
    );
  }
}

// ------------------ REUSABLE STAT CARD ------------------
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const Spacer(),
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}