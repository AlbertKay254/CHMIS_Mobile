import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:medical_app/services/notification_service.dart';

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
  Map<DateTime, List<Map<String, String>>> _appointments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final url = Uri.parse("http://197.232.14.151:3030/api/userAppointments/${widget.patientID}");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("✅ API Response: $data");

        Map<DateTime, List<Map<String, String>>> fetchedAppointments = {};

        for (var appt in data) {
          // Convert to UTC to match TableCalendar's default
          DateTime dateKey = DateTime.utc(
            DateTime.parse(appt['date']).year,
            DateTime.parse(appt['date']).month,
            DateTime.parse(appt['date']).day,
          );

          Map<String, String> details = {
            "purpose": appt['title'] ?? '',
            "time": appt['time'] ?? '',
            "urgency": appt['doctorName'] ?? '',
          };

          fetchedAppointments.putIfAbsent(dateKey, () => []);
          fetchedAppointments[dateKey]!.add(details);
        }

        print("📅 Parsed Appointments: $fetchedAppointments"); 

        setState(() {
          _appointments = fetchedAppointments;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load appointments");
      }
    } catch (e) {
      print("❌ Error fetching appointments: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, String>> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
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
        title: const Text("Appointments"),
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
            eventLoader: (day) => _getAppointmentsForDay(day),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color.fromARGB(255, 8, 217, 207),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _getAppointmentsForDay(_selectedDay).isEmpty
                ? const Center(child: Text("No Appointments"))
                : ListView.builder(
                    itemCount: _getAppointmentsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final appt = _getAppointmentsForDay(_selectedDay)[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today, color: const Color.fromARGB(255, 8, 217, 207),),
                          title: Text(appt["purpose"] ?? ""),
                          subtitle: Text(
                            "Time: ${appt["time"] ?? ""}\nDr Name: ${appt["urgency"] ?? ""}",
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