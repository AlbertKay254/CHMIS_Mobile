import 'package:flutter/material.dart';
import 'package:medical_app/pages/login_page.dart';
import 'package:medical_app/pages/notifications_page.dart';
//import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a typed list to avoid dynamic pitfalls.
    final List<Map<String, Object>> options = [
      {
        'icon': Icons.person, 
        'iconColor': const Color(0xFF161d63),
        'title': 'Profile'
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
          await launchUrl(Uri.parse(phone), mode: LaunchMode.externalApplication);
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
        // Clears the whole stack, preventing back navigation into the app.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
    },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(252, 64, 174, 184),
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = options[index];
          final icon = option['icon'] as IconData;
          final title = option['title'] as String;
          final action = option['action'] as VoidCallback?;
          final iconColor = option['iconColor'] as Color? ?? const Color(0xFF161d63);

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
