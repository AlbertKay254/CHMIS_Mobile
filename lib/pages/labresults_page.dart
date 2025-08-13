import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LabResultsPage extends StatefulWidget {
  final String patientID;

  const LabResultsPage({super.key, required this.patientID});

  @override
  _LabResultsPageState createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  bool isLoading = true;
  String? errorMessage;
  List<dynamic> labResults = [];

  @override
  void initState() {
    super.initState();
    fetchLabResults();
  }

  Future<void> fetchLabResults() async {
    final url =
        'http://197.232.14.151:3030/api/labresults/${widget.patientID}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both single object and array responses
        if (data is List) {
          labResults = data;
        } else if (data is Map) {
          labResults = [data];
        }

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load lab results (Status: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching lab results: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildLabResultCard(Map<String, dynamic> result) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Lab Test", result['labtest']),
            _buildInfoRow("Price", "Ksh ${result['price']}"),
            _buildInfoRow("Request Time", result['RequestTime']),
            _buildInfoRow("Sample", result['SampleName']),
            _buildInfoRow("Time Collected", result['time collected'] ?? "Not collected"),
            _buildInfoRow("Results Verified", result['resultsVerifiedTime'] ?? "Not verified"),
            _buildInfoRow("Approved Time", result['ApprovedTime'] ?? "Not approved"),
            _buildStatusBadge(result['TestStatus']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "requested":
        color = Colors.orange;
        break;
      case "completed":
        color = Colors.green;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Results"),
        backgroundColor: const Color.fromARGB(255, 50, 219, 205),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : labResults.isEmpty
              ? const Center(child: Text("No lab results found."))
              : ListView.builder(
                  itemCount: labResults.length,
                  itemBuilder: (context, index) {
                    return _buildLabResultCard(labResults[index]);
                  },
                ),
    );
  }
}
