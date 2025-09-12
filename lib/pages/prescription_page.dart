import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
        "http://197.232.14.151:3030/api/getuserprescription/${widget.patientID}");
    try {
      final response = await http.get(url);

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

        // Sort by datePrescribed (latest first)
        data.sort((a, b) => DateTime.parse(b['datePrescribed'])
            .compareTo(DateTime.parse(a['datePrescribed'])));

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

  Future<void> _cancelPrescription(int id) async {
    final url = Uri.parse("http://197.232.14.151:3030/api/cancelprescription/$id");
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close dialog
        _fetchPrescriptions(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prescription cancelled successfully")),
        );
      } else {
        throw Exception("Failed to cancel prescription");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _setStartDate(int id, DateTime startDate) async {
    final url = Uri.parse("http://197.232.14.151:3030/api/updatestartdate/$id");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"startDate": startDate.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close dialog
        _fetchPrescriptions(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Start date updated successfully")),
        );
      } else {
        throw Exception("Failed to update start date");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showPrescriptionDetails(Map<String, dynamic> prescription) {
    DateTime? selectedStartDate;
    final alreadyStarted = prescription['startDate'] != null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("Prescription: ${prescription['drug']}"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Drug", prescription['drug']),
                  _buildDetailRow("Date Prescribed",
                      _formatDate(prescription['datePrescribed'])),
                  _buildDetailRow("Dose", prescription['dose']),
                  _buildDetailRow("Times Per Day", prescription['timesPerDay']),
                  _buildDetailRow("Days", prescription['days']),
                  _buildDetailRow("Total Dose", prescription['totalDose']),
                  _buildDetailRow("Price", "KES ${prescription['price']}"),
                  _buildDetailRow("Doctor", prescription['doctorName']),
                  if (prescription['notes'] != null &&
                      prescription['notes'].toString().isNotEmpty)
                    _buildDetailRow("Notes", prescription['notes']),
                  if (prescription['startDate'] != null)
                    _buildDetailRow("Start Date",
                        _formatDate(prescription['startDate'])),
                  const SizedBox(height: 16),
                  if (!alreadyStarted) // Only allow setting start date if not set
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(selectedStartDate == null
                          ? "Set Start Date"
                          : "Start Date: ${DateFormat('dd MMM yyyy').format(selectedStartDate!)}"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedStartDate = picked;
                          });
                          _setStartDate(prescription['id'], picked);
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: alreadyStarted
                    ? null // disable button if prescription started
                    : () => _cancelPrescription(prescription['id']),
                child: Text(
                  "Cancel Prescription",
                  style: TextStyle(
                    color: alreadyStarted ? Colors.grey : Colors.red,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: "${value ?? 'N/A'}",
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("dd MMM yyyy").format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final drug = prescription['drug'] ?? 'Unknown';
    final initials =
        drug.length >= 2 ? drug.substring(0, 2).toUpperCase() : drug;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Text(
            initials,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          drug,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Date: ${_formatDate(prescription['datePrescribed'])}",
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
        backgroundColor: Colors.teal,
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
