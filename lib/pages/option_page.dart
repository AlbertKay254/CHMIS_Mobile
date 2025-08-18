import 'package:flutter/material.dart';
import 'package:medical_app/pages/login_page.dart';
//import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a typed list to avoid dynamic pitfalls.
    final List<Map<String, Object>> options = [
      {'icon': Icons.person, 'title': 'Profile'},
      {'icon': Icons.notifications, 'title': 'Notifications'},

     {
      'icon': Icons.help,
      'title': 'Help & Support',
      'action': () async {
        const url = 'https://chmis.cbslkenya.co.ke';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      },
    },

      {
        'icon': Icons.logout,
        'title': 'Logout',
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
        title: const Text('Options'),
      ),
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = options[index];
          final icon = option['icon'] as IconData;
          final title = option['title'] as String;
          final action = option['action'] as VoidCallback?;

          return ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (action != null) {
                action();
              } else {
                // Optional: feedback for items without actions yet
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
