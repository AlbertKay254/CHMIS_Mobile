import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Appointment {
  final String title;
  final DateTime date;
  final TimeOfDay time;

  Appointment({required this.title, required this.date, required this.time});
}

class AppointmentsPageDoc extends StatefulWidget {
  const AppointmentsPageDoc({super.key, String? staffID});

  @override
  State<AppointmentsPageDoc> createState() => _AppointmentsPageDocState();
}

class _AppointmentsPageDocState extends State<AppointmentsPageDoc> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<Appointment> _appointments = [];

  List<Appointment> get _selectedAppointments {
    return _appointments
        .where((appt) =>
            appt.date.year == _selectedDay?.year &&
            appt.date.month == _selectedDay?.month &&
            appt.date.day == _selectedDay?.day)
        .toList();
  }

  void _addAppointment(Appointment appt) {
    setState(() {
      _appointments.add(appt);
    });
  }

  void _openCreateAppointmentDialog() {
    String title = '';
    TimeOfDay time = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create Appointment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Title"),
                onChanged: (value) {
                  title = value;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    time = pickedTime;
                  }
                },
                child: const Text("Select Time"),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && _selectedDay != null) {
                  _addAppointment(Appointment(
                    title: title,
                    date: _selectedDay!,
                    time: time,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _selectedDay = _focusedDay;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointments'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Appointments:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _openCreateAppointmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedAppointments.isEmpty
                ? const Center(child: Text('No appointments'))
                : ListView.builder(
                    itemCount: _selectedAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = _selectedAppointments[index];
                      return ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text(appt.title),
                        subtitle: Text('${appt.time.format(context)}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
