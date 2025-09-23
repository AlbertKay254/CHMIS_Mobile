import 'package:flutter/material.dart';
import 'package:medical_app/pages/login_page.dart';
import 'package:medical_app/pages/notifications_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medical_app/pages/profile_page.dart'; // <-- new import

class OptionPage extends StatelessWidget {
  final String patientID;
  final String userName;

  const OptionPage({
    Key? key,
    required this.patientID,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> options = [
      {
        'icon': Icons.person,
        'iconColor': const Color(0xFF161d63),
        'title': 'Profile',
        'action': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfilePage(
                patientID: patientID,
                userName: userName,
              ),
            ),
          );
        },
      },
      {
        'icon': Icons.notifications,
        'iconColor': const Color(0xFF161d63),
        'title': 'Notifications',
        'action': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NotificationsPage()),
          );
        },
      },
      {
        'icon': Icons.help,
        'title': 'Help & Support',
        'iconColor': const Color(0xFF161d63),
        'action': () async {
          const phone = 'tel:+254702519938';
          if (await canLaunchUrl(Uri.parse(phone))) {
            await launchUrl(Uri.parse(phone),
                mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not call $phone';
          }
        },
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'iconColor': const Color.fromARGB(255, 229, 0, 0),
        'action': () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      },
    ];

    return Scaffold(
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = options[index];
          final icon = option['icon'] as IconData;
          final title = option['title'] as String;
          final action = option['action'] as VoidCallback?;
          final iconColor =
              option['iconColor'] as Color? ?? const Color(0xFF161d63);

          return ListTile(
            leading: Icon(icon, color: iconColor),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (action != null) {
                action();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title loading')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
