// ---------------- Appointments Page ----------------
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// ---------------- Appointments Page ----------------
class AppointmentsPageDoc extends StatefulWidget {
  final String? staffID;
  final String? doctorName;

  const AppointmentsPageDoc({super.key, this.staffID, this.doctorName});

  @override
  State<AppointmentsPageDoc> createState() => _AppointmentsPageDocState();
}

class _AppointmentsPageDocState extends State<AppointmentsPageDoc> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> appointments = [];
  Map<DateTime, List<dynamic>> _appointmentsMap = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    if (widget.staffID == null) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse(
          "http://197.232.14.151:3030/api/doctorAppointments/${widget.staffID}"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final now = DateTime.now();

        // Build appointments map (group by date)
        Map<DateTime, List<dynamic>> fetchedMap = {};
        for (var appt in data) {
          final dateStr = appt['date']?.toString() ?? '';
          final timeStr = appt['time']?.toString() ?? '';

          // parse date
          final dateOnly = DateTime.tryParse(dateStr);
          if (dateOnly == null) continue;

          // parse time
          int hour = 0, minute = 0;
          if (timeStr.isNotEmpty) {
            try {
              final t = DateFormat.Hm().parse(timeStr); // expects HH:mm
              hour = t.hour;
              minute = t.minute;
            } catch (_) {}
          }

          final apptDateTime = DateTime(
            dateOnly.year,
            dateOnly.month,
            dateOnly.day,
            hour,
            minute,
          );

          // ✅ Mark as Passed if before now
          if (apptDateTime.isBefore(now)) {
            appt['status'] = "Passed";
          }

          final key =
              DateTime.utc(dateOnly.year, dateOnly.month, dateOnly.day);
          fetchedMap.putIfAbsent(key, () => []);
          fetchedMap[key]!.add(appt);
        }

        setState(() {
          appointments = data;
          _appointmentsMap = fetchedMap;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // appointments for the selected day
  List<dynamic> get selectedAppointments {
    if (_selectedDay == null) return [];
    return _appointmentsMap[DateTime.utc(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        )] ??
        [];
  }

  // provide events to calendar
  List<dynamic> _getAppointmentsForDay(DateTime day) {
    return _appointmentsMap[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void openPatientList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentPatientListPage(
          staffID: widget.staffID ?? "",
          doctorName: widget.doctorName ?? "Dr. Unknown",
          onSaved: () => fetchAppointments(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Appointments"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAppointments,
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getAppointmentsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  "",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: openPatientList,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? const Center(
                        child: Text("Failed to load appointments",
                            style: TextStyle(color: Colors.red)),
                      )
                    : selectedAppointments.isEmpty
                        ? const Center(child: Text("No appointments"))
                        : ListView.builder(
                            itemCount: selectedAppointments.length,
                            itemBuilder: (context, index) {
                              final appt = selectedAppointments[index];
                              final time = appt['time'] ?? '';
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.event_note),
                                  title: Text(appt['title'] ?? "Untitled"),
                                  subtitle: Text(
                                      "${appt['name']} • ${time.toString()}"),
                                  trailing: Text(
                                    appt['status'] ?? "Upcoming",
                                    style: TextStyle(
                                      color: (appt['status'] == "Passed")
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

// ---------------- Patient List ----------------
class AppointmentPatientListPage extends StatefulWidget {
  final String staffID;
  final String doctorName;
  final VoidCallback onSaved;

  const AppointmentPatientListPage({
    super.key,
    required this.staffID,
    required this.doctorName,
    required this.onSaved,
  });

  @override
  State<AppointmentPatientListPage> createState() =>
      _AppointmentPatientListPageState();
}

class _AppointmentPatientListPageState
    extends State<AppointmentPatientListPage> {
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
          filteredPatients = patients;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching patients: $e");
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

  void selectPatient(dynamic patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentFormPage(
          patientID: patient['patientID'],
          patientName: patient['name'],
          staffID: widget.staffID,
          doctorName: widget.doctorName,
          onSaved: widget.onSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Patient")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    decoration: InputDecoration(
                      hintText: "Search patients...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
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
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text(initials,
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(patient['name'] ?? "Unknown"),
                          subtitle: Text("ID: ${patient['patientID']}"),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => selectPatient(patient),
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

// ---------------- Appointment Form ----------------
class AppointmentFormPage extends StatefulWidget {
  final String patientID;
  final String patientName;
  final String staffID;
  final String doctorName;
  final VoidCallback onSaved;

  const AppointmentFormPage({
    super.key,
    required this.patientID,
    required this.patientName,
    required this.staffID,
    required this.doctorName,
    required this.onSaved,
  });

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  String type = "Consultation";
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  bool isSaving = false;

  List<dynamic> patientAppointments = [];
  bool loadingAppointments = true;

  @override
  void initState() {
    super.initState();
    fetchPatientAppointments();
  }

  Future<void> fetchPatientAppointments() async {
  setState(() => loadingAppointments = true);
  try {
    final response = await http.get(Uri.parse(
        "http://197.232.14.151:3030/api/userAppointments/${widget.patientID}"));

    if (response.statusCode == 200) {
      final List<dynamic> allAppointments = json.decode(response.body);

      final now = DateTime.now();

      // Filter: only appointments today or in the future
      final upcoming = allAppointments.where((appt) {
        try {
          final apptDate = DateTime.parse(appt['date']);
          return !apptDate.isBefore(
            DateTime(now.year, now.month, now.day), // midnight today
          );
        } catch (e) {
          debugPrint("Invalid date for appointment: $appt");
          return false;
        }
      }).toList();

      setState(() {
        patientAppointments = upcoming;
        loadingAppointments = false;
      });
    } else {
      setState(() => loadingAppointments = false);
    }
  } catch (e) {
    debugPrint("Error fetching patient appointments: $e");
    setState(() => loadingAppointments = false);
  }
}

  Future<void> saveAppointment() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final timeStr =
        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

    final data = {
      "title": titleController.text,
      "date": DateFormat("yyyy-MM-dd").format(selectedDate!),
      "time": timeStr,
      "patientID": widget.patientID,
      "name": widget.patientName,
      "type": type,
      "staffID": widget.staffID,
      "doctorName": widget.doctorName,
      "status": "Upcoming",
    };

    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse("http://197.232.14.151:3030/api/saveAppointment"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment saved successfully")),
        );
        widget.onSaved();
        await fetchPatientAppointments(); // refresh list
        titleController.clear();
        setState(() {
          selectedDate = null;
          selectedTime = null;
          type = "Consultation";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Error saving appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    }

    setState(() => isSaving = false);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Appointment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Doctor: ${widget.doctorName}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Staff ID: ${widget.staffID}"),
                          const SizedBox(height: 6),
                          Text("Patient: ${widget.patientName}"),
                          Text("Patient ID: ${widget.patientID}"),
                        ],
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter a title" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ["Consultation", "Follow-up", "Treatment", "Other"]
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => type = val!),
                    decoration: const InputDecoration(
                      labelText: "Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(Icons.date_range),
                          label: Text(selectedDate == null
                              ? "Select Date"
                              : DateFormat("yyyy-MM-dd")
                                  .format(selectedDate!)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(selectedTime == null
                              ? "Select Time"
                              : selectedTime!.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : saveAppointment,
                      icon: isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: Text(isSaving ? "Saving..." : "Save Appointment"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Patient's Appointments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            loadingAppointments
                ? const Center(child: CircularProgressIndicator())
                : patientAppointments.isEmpty
                    ? const Text("No appointments found")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: patientAppointments.length,
                        itemBuilder: (context, index) {
                          final appt = patientAppointments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.event_note),
                              title: Text(appt['title'] ?? "Untitled"),
                              subtitle: Text(
                                  "${appt['date']} • ${appt['time']} "),
                              trailing: Text(
                                appt['type'] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}

