import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InpatientPage extends StatefulWidget {
  const InpatientPage({super.key});

  @override
  State<InpatientPage> createState() => _InpatientPageState();
}

class _InpatientPageState extends State<InpatientPage> {
  List<dynamic> inpatients = [];
  List<dynamic> filteredPatients = [];
  bool isLoading = true;
  int itemsToShow = 10;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchInpatients();
  }

  Future<void> fetchInpatients() async {
    try {
      final response =
          await http.get(Uri.parse("http://197.232.14.151:3030/api/inpatients"));
      if (response.statusCode == 200) {
        setState(() {
          inpatients = json.decode(response.body);
          filteredPatients = inpatients;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load inpatients");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("❌ Error: $e");
    }
  }

  void filterPatients(String query) {
    setState(() {
      searchQuery = query;
      filteredPatients = inpatients
          .where((patient) => patient["patientName"]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(patient["patientName"],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: patient.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text("${entry.key}: ${entry.value}"),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visiblePatients = filteredPatients.take(itemsToShow).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inpatients"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search patient...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filterPatients,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: visiblePatients.length,
                    itemBuilder: (context, index) {
                      final patient = visiblePatients[index];
                      String patientName = patient["patientName"] ?? "Unknown";
                      String initials = patientName.isNotEmpty
                          ? patientName.trim().split(" ").map((e) => e[0]).take(2).join()
                          : "?";

                      return Card(
                        color: const Color.fromARGB(255, 253, 255, 243),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text(initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(
                            patientName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text("PID: ${patient["pid"]}"),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => showPatientDetails(patient),
                        ),
                      );
                    },
                  ),
                ),
                if (itemsToShow < filteredPatients.length)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          itemsToShow += 10;
                        });
                      },
                      child: const Text("Read More"),
                    ),
                  )
              ],
            ),
    );
  }
}
