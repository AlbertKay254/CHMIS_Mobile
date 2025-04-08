import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<String>> _appointments = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;

    // Sample appointment data
    _appointments = {
      DateTime.utc(2025, 3, 10): ['Doctor Consultation - 10:00 AM'],
      DateTime.utc(2025, 3, 15): ['Dental Checkup - 2:00 PM'],
      DateTime.utc(2025, 3, 20): ['Eye Specialist - 11:30 AM'],
    };
  }

  List<String> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
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
            eventLoader: _getAppointmentsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _getAppointmentsForDay(_selectedDay).isEmpty
                ? Center(child: Text("No Appointments"))
                : ListView.builder(
                    itemCount: _getAppointmentsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.blue),
                          title: Text(_getAppointmentsForDay(_selectedDay)[index]),
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
