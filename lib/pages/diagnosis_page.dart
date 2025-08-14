import 'package:flutter/material.dart';
import '../services/diagnosis_service.dart';

class DiagnosisPage extends StatefulWidget {
  final String patientID;

  const DiagnosisPage({super.key, required this.patientID});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  late Future<List<Map<String, dynamic>>> diagnosisList;

  @override
  void initState() {
    super.initState();
    diagnosisList = DiagnosisService.getDiagnosisByPatient(widget.patientID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diagnosis Records")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: diagnosisList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No diagnosis found."));
          } else {
            final diagnoses = snapshot.data!;
            return ListView.builder(
              itemCount: diagnoses.length,
              itemBuilder: (context, index) {
                final item = diagnoses[index];
                final isRecent = item['encounterStatus'] == 'Current/ Most Recent Encounter';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(
                      "${item['icd_10_description'] ?? 'No Description'} (ICD: ${item['ICD_10_code'] ?? 'N/A'})",
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Case #: ${item['Case_nr']}"),
                        Text("Encounter #: ${item['encounter_nr']}"),
                        Text("Doctor: ${item['doctor_Name'] ?? 'Unknown'}"),
                        Text("Status: ${item['patientStatus']}"),
                        Text(
                          "Encounter: ${item['encounterStatus']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRecent ? Colors.green : const Color.fromARGB(255, 255, 103, 1),
                          ),
                        ),
                        Text("Date: ${item['timestamp'] != null ? item['timestamp'].toString().split('T')[0] : 'N/A'}"),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}