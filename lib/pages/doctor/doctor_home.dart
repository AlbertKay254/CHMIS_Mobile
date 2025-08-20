import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/pages/doctor/outpatient_page.dart';
import 'package:medical_app/pages/doctor/inpatient_page.dart';
import 'package:medical_app/pages/doctor/pharmacy_page.dart';
import 'package:medical_app/pages/doctor/hrpage.dart';
import 'package:medical_app/util/category_card.dart';
import 'package:medical_app/pages/chat_page.dart';
import 'package:medical_app/pages/telemedicine_page.dart';
import 'package:medical_app/pages/option_page.dart';
import 'package:medical_app/pages/doctor/dashboard_page.dart';

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

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
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
          const SizedBox(height: 25),
          searchbar(),
          const SizedBox(height: 20),
          dashboardSection(),
          const SizedBox(height: 20),
          moreDashboardButton(context),
          const SizedBox(height: 10),
          //const SizedBox(height: 20),
          categorycard(),
          const SizedBox(height: 25),
          //chatbutton(context),
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

  /// SEARCH BAR
  Padding searchbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 202, 202, 202),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            hintText: 'Search patients or services...',
          ),
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
              MaterialPageRoute(builder: (_) => const PharmacyPage()),
            ),
            child: CategoryCard(
                categoryName: 'Pharmacy',
                iconImagePath: 'lib/icons/pharmacy.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HRPage()),
            ),
            child: CategoryCard(
                categoryName: 'HR', iconImagePath: 'lib/icons/hr.png'),
          ),
        ],
      ),
    );
  }

  /// CHAT BUTTON
  Padding chatbutton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ElevatedButton.icon(
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text("Chat"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(237, 255, 249, 139),
          foregroundColor: const Color.fromARGB(255, 55, 55, 55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// DASHBOARD (Upgraded Line Graph)
  Widget dashboardSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14), // smaller padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Patient Encounters (Last 10 Days)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), // smaller font
            ),
            const SizedBox(height: 12), // less spacing
            SizedBox(
              height: 170, // smaller height
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.white,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 2,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28, // smaller reserved size
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black87), // smaller font
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 18, // smaller reserved size
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "D${value.toInt()}",
                            style: const TextStyle(
                                fontSize: 9, color: Colors.black87), // smaller font
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  minX: 1,
                  maxX: 10,
                  minY: 0,
                  maxY: 14,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(1, 5),
                        FlSpot(2, 8),
                        FlSpot(3, 6),
                        FlSpot(4, 7),
                        FlSpot(5, 9),
                        FlSpot(6, 4),
                        FlSpot(7, 10),
                        FlSpot(8, 7),
                        FlSpot(9, 6),
                        FlSpot(10, 12),
                      ],
                      isCurved: true,
                      color: Colors.blueAccent,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.teal],
                      ),
                      barWidth: 2.5, // thinner line
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.2),
                            Colors.teal.withOpacity(0.07),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 2.5,
                          color: Colors.blueAccent,
                          strokeWidth: 0,
                        ),
                      ), // smaller dots
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

  /// MORE DASHBOARDS BUTTON
  Widget moreDashboardButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardsPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 254, 166),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        child: const Text(
          "More Dashboards",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 50, 50, 50)),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_call), label: 'Telemedicine'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Options'),
        ],
      ),
    );
  }
}
