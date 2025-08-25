import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OutpatientPage extends StatefulWidget {
  const OutpatientPage({super.key});

  @override
  State<OutpatientPage> createState() => _OutpatientPageState();
}

class _OutpatientPageState extends State<OutpatientPage> {
  List<dynamic> outpatients = [];
  List<dynamic> filteredOutpatients = [];
  bool isLoading = true;
  int itemsToShow = 10;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOutpatients();
  }

  Future<void> fetchOutpatients() async {
    try {
      final response = await http.get(
        Uri.parse("http://197.232.14.151:3030/api/outpatients"),
      );

      if (response.statusCode == 200) {
        setState(() {
          outpatients = json.decode(response.body);
          filteredOutpatients = outpatients; // initially show all
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load outpatients");
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
      if (query.isEmpty) {
        filteredOutpatients = outpatients;
      } else {
        filteredOutpatients = outpatients
            .where((p) => (p["patientName"] ?? "")
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      itemsToShow = 10; // reset pagination on search
    });
  }

  void showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          patient["patientName"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
    final visiblePatients = filteredOutpatients.take(itemsToShow).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Outpatients")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterPatients,
                    decoration: InputDecoration(
                      hintText: "Search patient by name...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: visiblePatients.length,
                    itemBuilder: (context, index) {
                      final patient = visiblePatients[index];

                      // Get initials
                      String name = patient["patientName"] ?? "";
                      List<String> parts = name.split(" ");
                      String initials = parts.length > 1
                          ? "${parts[0][0]}${parts[1][0]}"
                          : (parts.isNotEmpty && parts[0].isNotEmpty
                              ? parts[0][0]
                              : "?");

                      return Card(
                        color: const Color.fromARGB(255, 235, 255, 250),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              initials.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patient["patientName"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle:
                              Text("Date: ${patient["encounter_date"] ?? ""}"),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => showPatientDetails(patient),
                        ),
                      );
                    },
                  ),
                ),
                if (itemsToShow < filteredOutpatients.length)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 254, 255, 254),
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
                  ),
              ],
            ),
    );
  }
}
