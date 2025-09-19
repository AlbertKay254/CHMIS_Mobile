// ignore_for_file: sized_box_for_whitespace
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/pages/appointments_page.dart';
//import 'package:medical_app/pages/chat_page.dart';
import 'package:medical_app/pages/diagnosis_page.dart';
//import 'package:medical_app/pages/doctor/doctor_home.dart';
import 'package:medical_app/pages/loading_screen..dart';
import 'package:medical_app/pages/prescription_page.dart';
import 'package:medical_app/pages/user_notes.dart';
import 'package:medical_app/util/category_card.dart';
import 'package:medical_app/util/doctor_card.dart';
import 'package:medical_app/pages/billing_page.dart';
import 'package:medical_app/pages/labresults_page.dart';
import 'package:medical_app/pages/option_page.dart';
import 'package:medical_app/pages/telemedicine_page.dart';
import 'package:medical_app/pages/notifications_page.dart';
import 'package:medical_app/pages/patients_notes_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String patientID;

  const HomePage({
    super.key,
    required this.userName,
    required this.patientID,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  Map<String, dynamic>? vitals;
  int _selectedIndex = 0;
  int todaysNotesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedVitals = await fetchVitals(widget.patientID);
      final notesCount = await fetchTodaysNotesCount(widget.patientID);

      setState(() {
        vitals = fetchedVitals;
        todaysNotesCount = notesCount;
      });
    } catch (e) {
      setState(() {
        vitals = null;
        todaysNotesCount = 0;
      });
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> fetchVitals(String patientID) async {
    final url = Uri.parse('http://197.232.14.151:3030/api/vitals/$patientID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load vitals');
    }
  }

  Future<int> fetchTodaysNotesCount(String patientID) async {
    final url = Uri.parse('http://197.232.14.151:3030/api/notes/today/$patientID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('count')) {
        final count = data['count'];
        if (count is int) {
          return count;
        } else if (count is String) {
          return int.tryParse(count) ?? 0;
        }
      }
      return 0;
    } else {
      return 0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildHomeBody();
    } else if (_selectedIndex == 1) {
      return TelemedicinePage();
    } else {
      return OptionPage();
    }
  }

  Widget _buildHomeBody() {
    if (_isLoading) {
      return const LoadingScreen(message: "Preparing your dashboard...");
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          appbar(),
          const SizedBox(height: 25),
          card(),
          const SizedBox(height: 20),

          // --- Quick Actions label ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          statCard(),
          const SizedBox(height: 20),

          // --- Services label ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Services",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          categorycard(),
          const SizedBox(height: 25),

          quickinfo(),
          doctorslist(),
          const SizedBox(height: 20),
          Container(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DoctorCard(
                    doctorImagePath: 'lib/images/doc1.jpg',
                    rating: '4.9',
                    doctorName: 'Dr Julie Kupeka',
                    profession: 'Gynecologist 7 y.e.',
                  ),
                  DoctorCard(
                    doctorImagePath: 'lib/images/doc2.jpg',
                    rating: '4.6',
                    doctorName: 'Dr Eliya Evra',
                    profession: 'Dentist 3 y.e.',
                  ),
                  DoctorCard(
                    doctorImagePath: 'lib/images/doc3.jpg',
                    rating: '5.0',
                    doctorName: 'Dr Erastus K',
                    profession: 'Brain Surgeon 17 y.e.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
                    builder: (context) =>
                        AppointmentsPage(patientID: widget.patientID),
                  ),
                );
              },
              child: const StatCard(
                icon: Icons.event,
                title: "Upcoming Events",
                value: "3",
                color: Colors.deepPurple,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(),
                  ),
                );
              },
              child: const StatCard(
                icon: Icons.notifications,
                title: "Notifications",
                value: "5",
                color: Colors.teal,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PatientNotesPage(patientID: widget.patientID),
                  ),
                );
              },
              child: StatCard(
                icon: Icons.note,
                title: "Doctor Notes",
                value: todaysNotesCount > 0
                    ? todaysNotesCount.toString()
                    : "0",
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // bottom navigation bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 4, 84, 88),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Telemedicine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Options',
          ),
        ],
      ),
    );
  }

  Padding doctorslist() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Doctors List',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'See all',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          )
        ],
      ),
    );
  }

  Padding quickinfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: 320,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.blue[50],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: vitals == null
                ? const Text("No medical data available.")
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInfoText(
                          "Encounter Number: ", vitals!['EncounterNo']),
                      buildInfoText("Hypertension Status: ",
                          vitals!['hypertensionStatus']),
                      buildInfoText(
                          "Diabetic Status: ", vitals!['diabeticStatus']),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 62, 75),
          ),
          children: [
            TextSpan(
              text: value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 0, 144, 141),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container categorycard() {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DiagnosisPage(patientID: widget.patientID),
                ),
              );
            },
            child: CategoryCard(
              categoryName: 'Diagnosis',
              iconImagePath: 'lib/icons/diagnosis.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PrescriptionPage(patientID: widget.patientID),
                ),
              );
            },
            child: CategoryCard(
              categoryName: 'Prescription',
              iconImagePath: 'lib/icons/drugs.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AppointmentsPage(patientID: widget.patientID),
                ),
              );
            },
            child: CategoryCard(
              categoryName: 'My Calendar',
              iconImagePath: 'lib/icons/schedule.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LabResultsPage(patientID: widget.patientID)),
              );
            },
            child: CategoryCard(
              categoryName: 'Lab Results',
              iconImagePath: 'lib/icons/labresults.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserNotesPage(patientID: widget.patientID),
                ),
              );
            },
            child: CategoryCard(
              categoryName: 'My Notes',
              iconImagePath: 'lib/icons/notes2.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BillingPage()),
              );
            },
            child: CategoryCard(
              categoryName: 'Billing & Invoices',
              iconImagePath: 'lib/icons/bills.png',
            ),
          ),
        ],
      ),
    );
  }

  Padding card() {
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
            Image.asset(
              'lib/icons/medical-team.png',
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to CHMIS Mobile',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Explore our services and view your medical data',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 72, 157, 172),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 32, 32, 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding appbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hello,",
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(widget.userName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900])),
              const SizedBox(width: 15),
              const Text("PID,",
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(widget.patientID,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900])),
            ],
          ),
        ],
      ),
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
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
