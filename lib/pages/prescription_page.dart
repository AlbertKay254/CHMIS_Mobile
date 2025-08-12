import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrescriptionPage extends StatefulWidget {
  final String patientID;

  const PrescriptionPage({super.key, required this.patientID});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List<Map<String, dynamic>> prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    final url = Uri.parse(
        "http://197.232.14.151:3030/api/prescription/${widget.patientID}");
    try {
      final response = await http.get(url);

      print("📡 API Response: ${response.body}"); // Debug print

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          data = [decoded];
        } else {
          data = [];
        }

        // Sort by prescribe_date (latest first)
        data.sort((a, b) => DateTime.parse(b['prescribe_date'])
            .compareTo(DateTime.parse(a['prescribe_date'])));

        // Mark first as Active
        for (int i = 0; i < data.length; i++) {
          data[i]['status'] = (i == 0) ? 'Active' : 'Previous';
        }

        setState(() {
          prescriptions = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load prescriptions");
      }
    } catch (e) {
      print("❌ Error fetching prescriptions: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPrescriptionDetails(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Prescription Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //_buildDetailRow("Prescription ID", prescription['id']),
            _buildDetailRow("Date", prescription['prescribe_date']),
            _buildDetailRow("Drug Name", prescription['article']),
            _buildDetailRow("Dosage", prescription['dosage']),
            _buildDetailRow("Times Per Day", prescription['times_per_day']),
            _buildDetailRow("Days", prescription['days']),
            _buildDetailRow("Quantity Issued", prescription['qtyIssued']),
            if (prescription['notes'] != null &&
                prescription['notes'].toString().isNotEmpty)
              _buildDetailRow("Notes", prescription['notes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: Icon(
          prescription['status'] == 'Active'
              ? Icons.medication
              : Icons.history,
          color:
              prescription['status'] == 'Active' ? Colors.green : Colors.grey,
        ),
        title: Text(
          "Prescription: ${prescription['article'] ?? 'N/A'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Date: ${prescription['prescribe_date'] ?? 'N/A'}",
        ),
        trailing: Text(
          prescription['status'] ?? '',
          style: TextStyle(
            color: prescription['status'] == 'Active'
                ? Colors.green
                : const Color.fromARGB(255, 255, 12, 12),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showPrescriptionDetails(prescription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Prescriptions"),
        backgroundColor: const Color.fromARGB(255, 69, 182, 172),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : prescriptions.isEmpty
              ? const Center(child: Text("No prescriptions found"))
              : ListView.builder(
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    return _buildPrescriptionCard(prescriptions[index]);
                  },
                ),
    );
  }
}
