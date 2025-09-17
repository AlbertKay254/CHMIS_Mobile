import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ---------------- Lab Requests Page ----------------
class LabRequestsPage extends StatefulWidget {
  final String? staffID;
  final String? doctorName;

  const LabRequestsPage({super.key, this.staffID, this.doctorName});

  @override
  State<LabRequestsPage> createState() => _LabRequestsPageState();
}

class _LabRequestsPageState extends State<LabRequestsPage> {
  List<dynamic> patients = [];
  List<dynamic> filteredPatients = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http
          .get(Uri.parse("http://197.232.14.151:3030/api/userlist"))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          patients = json.decode(response.body);
          filteredPatients = patients;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching patients: $e");
      setState(() {
        hasError = true;
        errorMessage =
            'Failed to load patients. Please check your connection.';
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    final results = patients.where((patient) {
      final name = (patient['name'] ?? '').toString().toLowerCase();
      final id = (patient['patientID'] ?? '').toString().toLowerCase();
      return name.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredPatients = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Requests"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPatients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchPatients,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSearch,
                        decoration: InputDecoration(
                          hintText: "Search patients by name or ID...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (filteredPatients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "No patients found",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            String initials = (patient['name'] ?? "?")
                                .toString()
                                .trim()
                                .split(" ")
                                .where((e) => e.isNotEmpty)
                                .map((e) => e[0])
                                .take(2)
                                .join()
                                .toUpperCase();

                            if (initials.isEmpty) initials = "?";

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text(initials,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ),
                                title: Text(
                                  patient['name'] ?? "Unknown",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text("ID: ${patient['patientID']}"),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LabRequestFormPage(
                                        patientID: patient['patientID'],
                                        patientName: patient['name'],
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

// ---------------- Lab Request Form Page ----------------
class LabRequestFormPage extends StatefulWidget {
  final String patientID;
  final String patientName;
  final String staffID;
  final String doctorName;

  const LabRequestFormPage({
    super.key,
    required this.patientID,
    required this.patientName,
    required this.staffID,
    required this.doctorName,
  });

  @override
  State<LabRequestFormPage> createState() => _LabRequestFormPageState();
}

class _LabRequestFormPageState extends State<LabRequestFormPage> {
  final TextEditingController testController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController urgencyController = TextEditingController();

  List<dynamic> allTests = [];
  List<dynamic> filteredTests = [];
  List<dynamic> previousRequests = [];
  bool loadingTests = false;
  bool loadingRequests = true;
  bool isSaving = false;
  String saveError = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchTests();
    fetchPreviousRequests();
  }

  Future<void> fetchTests() async {
    setState(() => loadingTests = true);
    try {
      final response = await http
          .get(Uri.parse("http://197.232.14.151:3030/api/getLabTests"))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        setState(() {
          allTests = json.decode(response.body);
          filteredTests = allTests;
        });
      }
    } catch (e) {
      debugPrint("Error fetching lab tests: $e");
    }
    setState(() => loadingTests = false);
  }

  Future<void> fetchPreviousRequests() async {
    setState(() => loadingRequests = true);
    try {
      final response = await http.get(Uri.parse(
          "http://197.232.14.151:3030/api/getLabRequests/${widget.patientID}"));
      if (response.statusCode == 200) {
        setState(() {
          previousRequests = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    }
    setState(() => loadingRequests = false);
  }

  Future<void> saveLabRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
      saveError = '';
    });

    final data = {
      "patientID": widget.patientID,
      "patientName": widget.patientName,
      "staffID": widget.staffID,
      "doctorName": widget.doctorName,
      "testName": testController.text,
      "price": priceController.text,
      "notes": notesController.text,
      "urgency": urgencyController.text,
      "dateRequested": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse("http://197.232.14.151:3030/api/saveLabRequests"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lab request saved successfully")),
        );
        testController.clear();
        priceController.clear();
        notesController.clear();
        urgencyController.clear();
        fetchPreviousRequests();
      } else {
        setState(() {
          saveError =
              'Server error: ${response.statusCode}. Response: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        saveError = 'Network error: $e';
      });
    }

    setState(() => isSaving = false);
  }

  void searchTest(String query) {
    final results = allTests.where((test) {
      final desc = (test['item_description'] ?? '').toString().toLowerCase();
      return desc.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredTests = results);
  }

  void selectTest(dynamic test) {
    testController.text = test['item_description'];
    priceController.text = test['unit_price'].toString();
    setState(() => filteredTests = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Request"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade50,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Doctor: ${widget.doctorName}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Staff ID: ${widget.staffID}"),
                    ],
                  ),
                ),
              ),

              if (saveError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    saveError,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Test search
              TextFormField(
                controller: testController,
                onChanged: searchTest,
                decoration: const InputDecoration(
                  labelText: "Test",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.science),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a test' : null,
              ),
              if (filteredTests.isNotEmpty)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: filteredTests.length,
                    itemBuilder: (context, index) {
                      final test = filteredTests[index];
                      return ListTile(
                        title: Text(test['item_description']),
                        subtitle: Text("Price: ${test['unit_price']}"),
                        onTap: () => selectTest(test),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter a price'
                    : double.tryParse(value) == null
                        ? 'Invalid number'
                        : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: urgencyController,
                decoration: const InputDecoration(
                  labelText: "Urgency",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : saveLabRequest,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? "Saving..." : "Save Request"),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(),
              const Text("Previous Lab Requests",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              loadingRequests
                  ? const Center(child: CircularProgressIndicator())
                  : previousRequests.isEmpty
                      ? const Text("No previous lab requests found")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: previousRequests.length,
                          itemBuilder: (context, index) {
                            final req = previousRequests[index];
                            final date = DateTime.tryParse(
                                req['dateRequested'] ?? '');
                            final formattedDate = date != null
                                ? DateFormat('MMM dd, yyyy - HH:mm')
                                    .format(date)
                                : '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                    req['testName'] ?? "Unknown test",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text("By ${req['doctorName']} on $formattedDate"),
                                    if (req['notes'] != null &&
                                        req['notes'].isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4),
                                        child: Text("Notes: ${req['notes']}"),
                                      ),
                                  ],
                                ),
                                trailing: Text("₵${req['price']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
