// ignore_for_file: sized_box_for_whitespace
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/pages/appointments_page.dart';
import 'package:medical_app/pages/chat_page.dart';
import 'package:medical_app/pages/diagnosis_page.dart';
import 'package:medical_app/pages/doctor/doctor_home.dart';
import 'package:medical_app/pages/loading_screen..dart';
import 'package:medical_app/pages/login_page.dart';
import 'package:medical_app/pages/prescription_page.dart';
import 'package:medical_app/util/category_card.dart';
import 'package:medical_app/util/doctor_card.dart';
import 'package:medical_app/pages/billing_page.dart';

class HomePage extends StatefulWidget {

  //db fetches
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


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedVitals = await fetchVitals(widget.patientID);
      setState(() {
        vitals = fetchedVitals;
      });
    } catch (e) {
      print("Vitals fetch error: $e");
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, dynamic>> fetchVitals(String patientID) async {
    final url = Uri.parse('http://192.168.1.10:3030/api/vitals/$patientID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load vitals');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(message: "Preparing your dashboard...");
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            //------appbar -----------------------------------------------------------------------
            appbar(),
            const SizedBox(height: 25),
            //-------card ------------------------------------------------------------------------
            card(),
            const SizedBox(height:25),
            //-------searchbar--------------------------------------------------------------------
            searchbar(),
            const SizedBox(height:20),
            //-------categories-------------------------------------------------------------------
            categorycard(),
            const SizedBox(height:25),
            //--------info panel -----------------------------------------------------------------
            quickinfo(),
            //-------doctor list------------------------------------------------------------------
            doctorslist(),
            const SizedBox(height: 20,),
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
                      doctorName: 'Dr Julie Kupeka' ,
                      profession: 'Gynecologist 7 y.e.',
                    ),
                    DoctorCard(
                      doctorImagePath: 'lib/images/doc2.jpg',
                      rating: '4.6',
                      doctorName: 'Dr Eliya Evra' ,
                      profession: 'Dentist 3 y.e.',
                    ),
                    DoctorCard(
                      doctorImagePath: 'lib/images/doc3.jpg',
                      rating: '5.0',
                      doctorName: 'Dr Erastus K' ,
                      profession: 'Brain Surgeon 17 y.e.',
                    ),
                  ],
                ),
              ),
            ),         
            const SizedBox(height:20),
            //--------chat button -------------------------------------------------------------
            chatbutton(context),
            const SizedBox(height: 20),
          ],
        ),
      ) //main body container

          
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                  ),
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600]
                  ),
                )
            ],),
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
              offset: Offset(0, 3),
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
                    buildInfoText("Encounter Number: ", vitals!['EncounterNo']),
                    buildInfoText("Hypertension Status: ", vitals!['hypertensionStatus']),
                    buildInfoText("Diabetic Status: ", vitals!['diabeticStatus']),
                    buildInfoText("Notes: ", vitals!['notes']),
                    buildInfoText("Next Appointment: ", vitals!['nextAppointment'] ?? 'N/A'),
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



  Padding chatbutton(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Chat"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(237, 255, 249, 139),
              foregroundColor: const Color.fromARGB(255, 55, 55, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  DiagnosisPage()),
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
                MaterialPageRoute(builder: (context) =>  PrescriptionPage()),
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
                MaterialPageRoute(builder: (context) =>  AppointmentsPage()),
              );
            },
            child:  CategoryCard(
              categoryName: 'Appointments',
              iconImagePath: 'lib/icons/schedule.png',
            ),
          ),
           GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  BillingPage()),
              );
            },
            child:  CategoryCard(
              categoryName: 'Billing & Invoices',
              iconImagePath: 'lib/icons/bills.png',
            ),
          ),
        ],
      ),
    );
  }

  Padding searchbar() {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 202, 202, 202),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: 'How may we help you?'
                ),
              ),
            ),
          );
  }

  Padding card() {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 244, 236, 141),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(children: [
               Image.asset(
                  'lib/icons/medical-team.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover, // Adjust fit as needed
                ),
                const SizedBox(width: 20), //gap
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to CHMIS Mobile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Explore our services and view your medical data',
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:Color.fromARGB(255, 72, 157, 172),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 32, 32, 32)
                            ),
                          ),
                        ),
                      )
                  ],),
                )
              ],),
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
            const Text("Hello,", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            SizedBox(width: 15),
            const Text("PID,", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.patientID, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorHomePage()),
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

}