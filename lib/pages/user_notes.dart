import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for date formatting

class UserNotesPage extends StatefulWidget {
  final String patientID;

  const UserNotesPage({Key? key, required this.patientID}) : super(key: key);

  @override
  State<UserNotesPage> createState() => _UserNotesPageState();
}

class _UserNotesPageState extends State<UserNotesPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _notes = [];
  bool _isLoading = true;

  final String baseUrl = "http://197.232.14.151:3030/api"; // adjust if needed

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);

    try {
      final res = await http.get(Uri.parse("$baseUrl/userNotes/${widget.patientID}"));
      if (res.statusCode == 200) {
        setState(() {
          _notes = json.decode(res.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No notes found")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching notes: $e")),
      );
    }
  }

  Future<void> _addNote() async {
    if (_controller.text.isEmpty) return;

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/saveUserNotes"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "patientID": widget.patientID,
          "notes": _controller.text,
          "date": DateTime.now().toUtc().toIso8601String(), // save in UTC
        }),
      );

      if (res.statusCode == 201) {
        _controller.clear();
        _fetchNotes(); // refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Note saved")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to save note: ${res.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving note: $e")),
      );
    }
  }

  String _formatDate(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate).toUtc(); // parse as UTC
      // Force convert to Kenya time (UTC+3)
      DateTime kenyaTime = dt.add(const Duration(hours: 3));
      return DateFormat("MMM d, yyyy – h:mm a").format(kenyaTime);
    } catch (e) {
      return rawDate; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Notes"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          // Input box (multi-line)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 3, // allow multi-line
                  decoration: InputDecoration(
                    labelText: "Write a note...",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 45, 134, 175),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Notes list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? const Center(
                        child: Text(
                          "No notes yet. Add one above!",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                note['notes'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                _formatDate(note['date'] ?? ''),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              leading: const Icon(Icons.note_alt, color: Color.fromARGB(255, 29, 114, 189)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
