import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ---------------- Prescription Page ----------------
class PrescriptionsPage extends StatefulWidget {
  final String? staffID;
  final String? doctorName;

  const PrescriptionsPage({super.key, this.staffID, this.doctorName});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
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
      final response =
          await http.get(Uri.parse("http://197.232.14.151:3030/api/userlist"))
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
        errorMessage = 'Failed to load patients. Please check your connection.';
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    final results = patients.where((patient) {
      final name = (patient['name'] ?? '').toString().toLowerCase();
      final id = (patient['patientID'] ?? '').toString().toLowerCase();
      return name.contains(query.toLowerCase()) || id.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredPatients = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescriptions"),
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
                    Text(errorMessage, style: const TextStyle(color: Colors.red)),
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
                                    style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(
                                patient['name'] ?? "Unknown",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("ID: ${patient['patientID']}"),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PrescriptionFormPage(
                                      patientID: patient['patientID'],
                                      patientName: patient['name'],
                                      staffID: widget.staffID ?? "S001",
                                      doctorName: widget.doctorName ?? "Dr. Unknown",
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

// ---------------- Prescription Form Page ----------------
class PrescriptionFormPage extends StatefulWidget {
  final String patientID;
  final String patientName;
  final String staffID;
  final String doctorName;

  const PrescriptionFormPage({
    super.key,
    required this.patientID,
    required this.patientName,
    required this.staffID,
    required this.doctorName,
  });

  @override
  State<PrescriptionFormPage> createState() => _PrescriptionFormPageState();
}

class _PrescriptionFormPageState extends State<PrescriptionFormPage> {
  final TextEditingController drugController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController timesController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController totalDoseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  List<dynamic> allDrugs = [];
  List<dynamic> filteredDrugs = [];
  bool loadingDrugs = false;
  List<dynamic> previousPrescriptions = [];
  bool loadingPrescriptions = true;
  bool isSaving = false;
  String saveError = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchDrugs();
    fetchPreviousPrescriptions();
  }

  Future<void> fetchDrugs() async {
    setState(() => loadingDrugs = true);
    try {
      final response =
          await http.get(Uri.parse("http://197.232.14.151:3030/api/getdrugs"))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        setState(() {
          allDrugs = json.decode(response.body);
          filteredDrugs = allDrugs;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load drugs: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("Error fetching drugs: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load drugs')),
      );
    }
    setState(() => loadingDrugs = false);
  }

  Future<void> fetchPreviousPrescriptions() async {
    setState(() => loadingPrescriptions = true);
    try {
      final response = await http.get(Uri.parse(
          "http://197.232.14.151:3030/api/getuserprescription/${widget.patientID}"))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        setState(() {
          previousPrescriptions = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('loading history')),
        );
      }
    } catch (e) {
      debugPrint("Error fetching prescriptions: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load prescription history')),
      );
    }
    setState(() => loadingPrescriptions = false);
  }

  void calculateTotalDose() {
    int dose = int.tryParse(doseController.text) ?? 0;
    int times = int.tryParse(timesController.text) ?? 0;
    int days = int.tryParse(daysController.text) ?? 0;
    totalDoseController.text = (dose * times * days).toString();
  }

  Future<void> savePrescription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      isSaving = true;
      saveError = '';
    });

    final data = {
      "patientID": widget.patientID,
      "name": widget.patientName,
      "staffID": widget.staffID,
      "doctorName": widget.doctorName,
      "drug": drugController.text,
      "price": priceController.text,
      "dose": doseController.text,
      "timesPerDay": timesController.text,
      "days": daysController.text,
      "totalDose": totalDoseController.text,
      "notes": notesController.text,
      "datePrescribed": DateTime.now().toIso8601String(),
    };

    debugPrint('Sending prescription data: $data');

    try {
      final response = await http.post(
        Uri.parse("http://197.232.14.151:3030/api/saveprescription"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prescription saved successfully")),
        );
        // Clear form
        drugController.clear();
        priceController.clear();
        doseController.clear();
        timesController.clear();
        daysController.clear();
        totalDoseController.clear();
        notesController.clear();
        
        // Refresh previous prescriptions
        fetchPreviousPrescriptions();
      } else {
        setState(() {
          saveError = 'Server error: ${response.statusCode}. Response: ${response.body}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Error saving prescription: $e");
      setState(() {
        saveError = 'Network error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save prescription. Check connection.")),
      );
    }
    
    setState(() => isSaving = false);
  }

  void searchDrug(String query) {
    final results = allDrugs.where((drug) {
      final desc = (drug['item_description'] ?? '').toString().toLowerCase();
      return desc.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredDrugs = results);
  }

  void selectDrug(dynamic drug) {
    drugController.text = drug['item_description'];
    priceController.text = drug['unit_price'].toString();
    setState(() => filteredDrugs = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Patient Info Card
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
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Drug search
              TextFormField(
                controller: drugController,
                onChanged: searchDrug,
                decoration: const InputDecoration(
                  labelText: "Drug (search or enter manually)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a drug name';
                  }
                  return null;
                },
              ),
              if (filteredDrugs.isNotEmpty)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: filteredDrugs.length,
                    itemBuilder: (context, index) {
                      final drug = filteredDrugs[index];
                      return ListTile(
                        title: Text(drug['item_description']),
                        subtitle: Text("Price: ${drug['unit_price']}"),
                        onTap: () => selectDrug(drug),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Price field
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                 
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dose, Times, Days row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: doseController,
                      decoration: const InputDecoration(
                        labelText: "Dose",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateTotalDose(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: timesController,
                      decoration: const InputDecoration(
                        labelText: "Times/Day",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateTotalDose(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: daysController,
                      decoration: const InputDecoration(
                        labelText: "Days",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateTotalDose(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total dose (readonly)
              TextFormField(
                controller: totalDoseController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Total Dose",
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),

              // Notes
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

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : savePrescription,
                  icon: isSaving 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? "Saving..." : "Save Prescription"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(),
              const Text("Previous Prescriptions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              loadingPrescriptions
                  ? const Center(child: CircularProgressIndicator())
                  : previousPrescriptions.isEmpty
                      ? const Text("No previous prescriptions found")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: previousPrescriptions.length,
                          itemBuilder: (context, index) {
                            final presc = previousPrescriptions[index];
                            final date = DateTime.tryParse(presc['datePrescribed'] ?? '');
                            final formattedDate = date != null 
                                ? DateFormat('MMM dd, yyyy - HH:mm').format(date)
                                : 'Unknown date';
                                
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(presc['drug'] ?? "Unknown drug",
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Dose: ${presc['dose']} x ${presc['timesPerDay']} for ${presc['days']} days"),
                                    Text("By ${presc['doctorName']} on $formattedDate"),
                                    if (presc['notes'] != null && presc['notes'].isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text("Notes: ${presc['notes']}"),
                                      ),
                                  ],
                                ),
                                trailing: Text("₵${presc['price']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
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