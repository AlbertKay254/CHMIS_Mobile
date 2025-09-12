import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class AppointmentsPage extends StatefulWidget {
  final String patientID;

  const AppointmentsPage({super.key, required this.patientID});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> _prescriptions = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await Future.wait([
        _fetchAppointments(),
        _fetchPrescriptions(),
      ]);
    } catch (e) {
      print("❌ Error loading data: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchAppointments() async {
    final url = Uri.parse(
        "http://197.232.14.151:3030/api/userAppointments/${widget.patientID}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (var appt in data) {
        DateTime dateKey = DateTime.utc(
          DateTime.parse(appt['date']).year,
          DateTime.parse(appt['date']).month,
          DateTime.parse(appt['date']).day,
        );

        Map<String, dynamic> details = {
          "type": "appointment",
          "title": appt['title'] ?? '',
          "time": appt['time'] ?? '',
          "doctor": appt['doctorName'] ?? '',
        };

        _events.putIfAbsent(dateKey, () => []);
        _events[dateKey]!.add(details);
      }
    } else {
      throw Exception("Failed to load appointments");
    }
  }

  Future<void> _fetchPrescriptions() async {
    final url = Uri.parse(
        "http://197.232.14.151:3030/api/prescriptiondates/${widget.patientID}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (var pres in data) {
        if (pres['startDate'] != null && pres['endDate'] != null) {
          DateTime start = DateTime.parse(pres['startDate']).toUtc();
          DateTime end = DateTime.parse(pres['endDate']).toUtc();

          _prescriptions.add({
            "id": pres['id'],
            "drug": pres['drug'],
            "start": start,
            "end": end,
            "type": "prescription",
          });

          for (DateTime d = start;
              !d.isAfter(end);
              d = d.add(const Duration(days: 1))) {
            DateTime dateKey = DateTime.utc(d.year, d.month, d.day);

            Map<String, dynamic> details = {
              "type": "prescription",
              "drug": pres['drug'],
              "start": start,
              "end": end,
            };

            _events.putIfAbsent(dateKey, () => []);
            _events[dateKey]!.add(details);
          }
        }
      }
    } else {
      throw Exception("Failed to load prescriptions");
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments & Prescriptions"),
        backgroundColor: const Color.fromARGB(255, 99, 182, 188),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Highlight prescription days
                bool isPrescription = _prescriptions.any((p) =>
                    !day.isBefore(p["start"]) && !day.isAfter(p["end"]));

                if (isPrescription) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                // Only show blue dot if appointment exists
                bool hasAppointment = events.any((e) {
                  final event = e as Map<String, dynamic>;
                  return event['type'] == "appointment";
                });

                if (hasAppointment) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 8, 
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue, // 🔵 appointment dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink(); // 
              },
            ),
            calendarStyle: const CalendarStyle(
              markersMaxCount: 0, // 🔥 disable default black markers
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: _getEventsForDay(_selectedDay).isEmpty
                ? const Center(
                    child: Text("No Appointments or Prescriptions"),
                  )
                : ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay)[index];

                      if (event['type'] == "appointment") {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Color.fromARGB(255, 8, 217, 207)),
                            title: Text(event["title"] ?? ""),
                            subtitle: Text(
                              "Time: ${event["time"] ?? ""}\nDoctor: ${event["doctor"] ?? ""}",
                            ),
                          ),
                        );
                      } else if (event['type'] == "prescription") {
                        return Card(
                          color: Colors.orange.shade50,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.local_pharmacy,
                                color: Color.fromARGB(255, 18, 158, 81)),
                            title: Text(
                              "Prescription: ${event["drug"] ?? ""}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 84, 84, 84)),
                            ),
                            subtitle: Text(
                              "From: ${event['start'].toString().split(' ')[0]} "
                              "To: ${event['end'].toString().split(' ')[0]}",
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
