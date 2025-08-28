import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientNotesPage extends StatefulWidget {
  final String patientID;

  const PatientNotesPage({super.key, required this.patientID});

  @override
  State<PatientNotesPage> createState() => _PatientNotesPageState();
}

class _PatientNotesPageState extends State<PatientNotesPage> {
  bool loading = true;
  List notes = [];

  @override
  void initState() {
    super.initState();
    fetchAllNotes();
  }

  Future<void> fetchAllNotes() async {
    final url = Uri.parse('http://192.168.1.10:3030/api/notes/${widget.patientID}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        notes = data;
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Notes")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(child: Text("No notes found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(note['notes'] ?? ""),
                        subtitle: Text(
                          "By ${note['doctorName']} on ${note['date']}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
