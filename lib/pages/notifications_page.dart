import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': 'Appointment Reminder',
      'body': 'You have an appointment tomorrow at 10:00 AM.',
      'time': '2h ago',
    },
    {
      'title': 'Lab Results Ready',
      'body': 'Your recent lab results are now available.',
      'time': '5h ago',
    },
    {
      'title': 'New Message',
      'body': 'Dr. Smith sent you a new message.',
      'time': '1d ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Icon(Icons.notifications),
            title: Text(notification['title'] ?? ''),
            subtitle: Text(notification['body'] ?? ''),
            trailing: Text(
              notification['time'] ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}