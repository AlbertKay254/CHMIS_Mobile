import 'package:flutter/material.dart';
import 'package:medical_app/pages/doctor/outpatient_patient.dart';
import 'package:medical_app/pages/doctor/inpatient_page.dart';
import 'package:medical_app/pages/doctor/pharmacy_page.dart';
import 'package:medical_app/pages/doctor/hrpage.dart';
import 'package:medical_app/pages/home_page.dart';
import 'package:medical_app/pages/login_page.dart';
import 'package:medical_app/util/category_card.dart';
import 'package:medical_app/pages/chat_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              appbar(),
              const SizedBox(height: 25),
              welcomeCard(),
              const SizedBox(height: 25),
              searchbar(),
              const SizedBox(height: 20),
              categorycard(),
              const SizedBox(height: 25),
              patientListTitle(),
              const SizedBox(height: 20),
              patientList(), // Replace with your actual patient list widget
              const SizedBox(height: 20),
              chatbutton(context),
              const SizedBox(height: 20),
            ],
          ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome,", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Dr. Jose Kupeka", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage(userName: '', patientID: '',)), //-----------**********//
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 79, 217, 230),
                ),
                child: const Icon(Icons.switch_account_sharp, color: Color.fromARGB(255, 2, 70, 62)),
              ),
            ),
            SizedBox(width: 10),
             GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.redAccent,
                        ),
                        child: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ),
          ],
        ),
        
      ],
    ),
  );
}


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
                  Text("Welcome to the Doctor Dashboard", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Manage the patients, monitor prescriptions and see appointments.", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Container categorycard() {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OutpatientPage())),
            child:  CategoryCard(categoryName: 'Outpatient', iconImagePath: 'lib/icons/outpatient.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InpatientPage())),
            child:  CategoryCard(categoryName: 'Inpatient', iconImagePath: 'lib/icons/inpatient.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyPage())),
            child:  CategoryCard(categoryName: 'Pharmacy', iconImagePath: 'lib/icons/pharmacy.png'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HRPage())),
            child:  CategoryCard(categoryName: 'HR', iconImagePath: 'lib/icons/hr.png'),
          ),
        ],
      ),
    );
  }

  Padding patientListTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Patient List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('See all', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget patientList() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        children: const [
          PatientCard(name: "John Doe", status: "In Treatment", imagePath: "lib/images/patient1.jpg"),
          PatientCard(name: "Jane Smith", status: "Recovered", imagePath: "lib/images/patient2.jpg"),
        ],
      ),
    );
  }

  Padding chatbutton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text("Chat"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(237, 255, 249, 139),
          foregroundColor: const Color.fromARGB(255, 55, 55, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final String name;
  final String status;
  final String imagePath;

  const PatientCard({
    super.key,
    required this.name,
    required this.status,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 5)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(imagePath, height: 100, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
