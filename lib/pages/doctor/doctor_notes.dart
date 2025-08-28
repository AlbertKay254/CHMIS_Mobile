import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ---------------- Doctor Notes Page ----------------
class DoctorNotesPage extends StatefulWidget {
  final String? staffID;
  final String? doctorName;

  const DoctorNotesPage({super.key, this.staffID, this.doctorName});

  @override
  State<DoctorNotesPage> createState() => _DoctorNotesPageState();
}

class _DoctorNotesPageState extends State<DoctorNotesPage> {
  List<dynamic> patients = [];
  List<dynamic> filteredPatients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      final response =
          await http.get(Uri.parse("http://197.232.14.151:3030/api/userlist"));
      if (response.statusCode == 200) {
        setState(() {
          patients = json.decode(response.body);
          filteredPatients = patients; // initially show all
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load patients");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching patients: $e");
    }
  }

  void filterSearch(String query) {
    final results = patients.where((patient) {
      final name = (patient['name'] ?? '').toString().toLowerCase();
      final email = (patient['email'] ?? '').toString().toLowerCase();
      final id = (patient['patientID'] ?? '').toString().toLowerCase();
      final searchLower = query.toLowerCase();
      return name.contains(searchLower) ||
          email.contains(searchLower) ||
          id.contains(searchLower);
    }).toList();

    setState(() {
      filteredPatients = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Notes"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- Search Bar ---
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    decoration: InputDecoration(
                      hintText: "Search by name, email, or ID...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // --- Patient List ---
                Expanded(
                  child: filteredPatients.isEmpty
                      ? const Center(child: Text("No patients found"))
                      : ListView.builder(
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            String initials =
                                patient['name'] != null &&
                                        patient['name'].toString().isNotEmpty
                                    ? patient['name']
                                        .trim()
                                        .split(" ")
                                        .map((e) => e[0])
                                        .take(2)
                                        .join()
                                        .toUpperCase()
                                    : "?";

                            return Card(
                              color: Colors.blue[50], // light blue background
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(255, 39, 153, 159),
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  patient['name'] ?? "Unknown",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  patient['email'] ?? "",
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Text(
                                  patient['patientID'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(221, 0, 72, 74),
                                    fontSize: 15,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotesFormPage(
                                        name: patient['name'],
                                        patientID: patient['patientID'],
                                        staffID: widget.staffID ?? "S001",
                                        doctorName:
                                            widget.doctorName ?? "Dr. Unknown",
                                      ),
                                    ),
                                  );
                                },
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

// ---------------- Notes Form Page ----------------
class NotesFormPage extends StatefulWidget {
  final String name;
  final String patientID;
  final String staffID;
  final String doctorName;

  const NotesFormPage({
    super.key,
    required this.name,
    required this.patientID,
    required this.staffID,
    required this.doctorName,
  });

  @override
  State<NotesFormPage> createState() => _NotesFormPageState();
}

class _NotesFormPageState extends State<NotesFormPage> {
  final TextEditingController notesController = TextEditingController();
  late String dateTime;
  List<dynamic> previousNotes = [];
  bool loadingNotes = true;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now().toString();
    fetchPreviousNotes();
  }

  Future<void> fetchPreviousNotes() async {
    try {
      final response = await http.get(Uri.parse(
          "http://197.232.14.151:3030/api/notes/${widget.patientID}"));
      if (response.statusCode == 200) {
        setState(() {
          previousNotes = json.decode(response.body);
          loadingNotes = false;
        });
      } else {
        setState(() {
          loadingNotes = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      setState(() {
        loadingNotes = false;
      });
    }
  }

  Future<void> saveNotes() async {
  final notes = notesController.text.trim();
  if (notes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter notes")),
    );
    return;
  }

  final data = {
    "patientID": widget.patientID,
    "name": widget.name,
    "staffID": widget.staffID,
    "doctorName": widget.doctorName,
    "date": dateTime,
    "notes": notes,
  };

  try {
    final response = await http.post(
      Uri.parse("http://197.232.14.151:3030/api/savenotes"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notes saved for ${widget.name}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved, but server responded with ${response.statusCode}")),
      );
    }

    // ✅ Clear the input field after save attempt
    notesController.clear();

    // ✅ Refresh notes list
    fetchPreviousNotes();

  } catch (e) {
    debugPrint("Error saving notes: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error saving notes")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Name: ",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  TextSpan(
                    text: widget.name,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Patient ID: ",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  TextSpan(
                    text: widget.patientID,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Doctor: ",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  TextSpan(
                    text: "${widget.doctorName} (ID: ${widget.staffID})",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Date & Time: ",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  TextSpan(
                    text: dateTime,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctor Notes Input
            TextField(
              controller: notesController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Doctor's Notes",
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 253, 240),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: saveNotes,
                icon: const Icon(Icons.save),
                label: const Text("Save Notes"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Previous Notes:",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: loadingNotes
                  ? const Center(child: CircularProgressIndicator())
                  : previousNotes.isEmpty
                      ? const Text("No previous notes found",
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                      : ListView.builder(
                          itemCount: previousNotes.length,
                          itemBuilder: (context, index) {
                            final note = previousNotes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 4),
                              child: ListTile(
                                title: Text(note['notes'] ?? "",
                                    style: const TextStyle(fontSize: 16)),
                                subtitle: Text(
                                  "By: ${note['doctorName']} on ${note['date']}",
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      )

    );
  }
}
