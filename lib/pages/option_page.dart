import 'package:flutter/material.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = [
      {'icon': Icons.person, 'title': 'Profile'},
      {'icon': Icons.notifications, 'title': 'Notifications'},
      {'icon': Icons.lock, 'title': 'Privacy'},
      {'icon': Icons.help, 'title': 'Help & Support'},
      {'icon': Icons.logout, 'title': 'Logout'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Options'),
      ),
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final option = options[index];
          return ListTile(
            leading: Icon(option['icon'] as IconData),
            title: Text(option['title'] as String),
            onTap: () {
              // Handle option tap
            },
          );
        },
      ),
    );
  }
}