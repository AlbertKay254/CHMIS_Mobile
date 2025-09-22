import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class TelemedicinePageDoc extends StatefulWidget {
  final String doctorName;
  final String staffID;

  const TelemedicinePageDoc({
    super.key,
    required this.doctorName,
    required this.staffID,
  });

  @override
  State<TelemedicinePageDoc> createState() => _TelemedicinePageDocState();
}

class _TelemedicinePageDocState extends State<TelemedicinePageDoc> {
  List<dynamic> users = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// Fetch patients from backend
  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://197.232.14.151:3030/api/userlist'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load users. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching users: $e';
        isLoading = false;
      });
    }
  }

  /// Create meeting via backend
  Future<Map<String, dynamic>?> _createWherebyMeeting(
      String patientName, String patientID, String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://197.232.14.151:3030/api/create-meeting'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'doctorName': widget.doctorName,
          'staffID': widget.staffID,
          'patientName': patientName,
          'patientID': patientID,
          'email': email,
          'duration': 60,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create meeting: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create meeting: $e')),
      );
      return null;
    }
  }

  /// Open external URL
  Future<void> _openMeetingUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  /// Show a blocking loading dialog
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromARGB(255, 234, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  /// Start a call and show links
  void _startVideoCall(Map<String, dynamic> user) async {
    _showLoadingDialog("Creating meeting, please wait...");

    try {
      final meetingData = await _createWherebyMeeting(
        user['name'],
        user['patientID'],
        user['email'],
      );

      Navigator.pop(context); // close loading dialog

      if (meetingData != null &&
          meetingData['hostUrl'] != null &&
          meetingData['meetingUrl'] != null) {
        _showMeetingLinks(meetingData['hostUrl'], meetingData['meetingUrl']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting data incomplete')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // close loading dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting video call: $e')),
      );
    }
  }

  /// Show both doctor + patient links in a dialog
  void _showMeetingLinks(String hostUrl, String meetingUrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Meeting Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Doctor (Host) Link:\n$hostUrl',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectableText('Patient Link:\n$meetingUrl'),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: meetingUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Patient link copied')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _openMeetingUrl(hostUrl),
            child: const Text('Join as Doctor'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet with patient list
  void _showUserList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select a Patient',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildUserList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(child: Text('No patients available'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              user['name'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(user['name']),
          subtitle: Text('${user['email']} | ID: ${user['patientID']}'),
          trailing: const Icon(Icons.video_call),
          onTap: () {
            Navigator.pop(context);
            _startVideoCall(user);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Telemedicine - Dr. ${widget.doctorName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dr. ${widget.doctorName} (Staff ID: ${widget.staffID})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Book a video consultation with a certified medical professional from the comfort of your home.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.video_call),
              label: const Text('Start Video Consultation'),
              onPressed: _showUserList,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Chat with a Doctor'),
              onPressed: () {
                // TODO: Implement chat logic
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('View Consultation History'),
              onPressed: () {
                // TODO: Implement history logic
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
