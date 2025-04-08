// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:medical_app/pages/appointments_page.dart';
import 'package:medical_app/pages/chat_page.dart';
import 'package:medical_app/pages/diagnosis_page.dart';
import 'package:medical_app/pages/prescription_page.dart';
import 'package:medical_app/util/category_card.dart';
import 'package:medical_app/util/doctor_card.dart';
import 'package:medical_app/pages/billing_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 30),
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
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor: Dr. Jane Doe',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Next Appointment: 2025-04-10',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Health Status: Good',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Notes:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Continue with the prescribed medication.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
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
            label: const Text("Chat with Assistant"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(238, 255, 249, 130),
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
               //Name -->
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hello, ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  Text(
                      "George Maina",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue[900],
                        ),
                  )

                ],
              ),

              //profile picture -->
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 79, 217, 230),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 0, 0, 0),
                  )
                ),
            ], 
            ),
          );
  }
}