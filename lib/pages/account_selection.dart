import 'package:flutter/material.dart';
import 'package:medical_app/pages/doctor/doctor_login.dart';
import 'login_page.dart';

class LoginOptionPage extends StatelessWidget {
  const LoginOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar background to let image show
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/icons/grad_3_.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Add a slight overlay for readability
          //color: Colors.black.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Choose your role",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 28, 28, 28),
                  ),
                ),
                const SizedBox(height: 30),

                // Doctor Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorLoginPage()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      width: double.infinity,
                      child: Column(
                        children: const [
                          Icon(Icons.medical_services,
                              size: 50, color: Colors.teal),
                          SizedBox(height: 10),
                          Text(
                            "Doctor",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Patient Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      width: double.infinity,
                      child: Column(
                        children: const [
                          Icon(Icons.person_2_outlined,
                              size: 50, color: Color.fromARGB(255, 1, 140, 179)),
                          SizedBox(height: 10),
                          Text(
                            "Patient",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
