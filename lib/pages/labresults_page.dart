import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class LabResultsPage extends StatefulWidget {
  final String patientID;

  const LabResultsPage({Key? key, required this.patientID}) : super(key: key);

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  List<dynamic> labRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLabRequests();
  }

  Future<void> fetchLabRequests() async {
    final url = Uri.parse(
        "http://197.232.14.151:3030/api/labResults/${widget.patientID}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          labRequests = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No lab requests found")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching lab requests: $e")),
      );
    }
  }

  Future<void> uploadResult(Map<String, dynamic> req) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf']);

    if (result != null) {
      File file = File(result.files.single.path!);

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://197.232.14.151:3030/api/uploadLabResult"),
      );

      // attach file
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      // attach fields
      request.fields['labID'] = req['labID'].toString();
      request.fields['testName'] = req['testName'] ?? '';
      request.fields['patientID'] = req['patientID'] ?? '';
      request.fields['patientName'] = req['patientName'] ?? '';
      request.fields['staffID'] = req['staffID'] ?? '';
      request.fields['doctorName'] = req['doctorName'] ?? '';

      var res = await request.send();

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Result uploaded successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Upload failed (code ${res.statusCode})")),
        );
      }
    }
  }

  void showUploadDialog(Map<String, dynamic> req) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            children: [
              const Text(
                "Upload Your Lab Result",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => uploadResult(req),
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Image or PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Requests"),
        backgroundColor: const Color.fromARGB(255, 246, 250, 255),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : labRequests.isEmpty
              ? const Center(child: Text("No lab requests available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: labRequests.length,
                  itemBuilder: (context, index) {
                    final req = labRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.science, color: Color.fromARGB(255, 58, 143, 183)),
                        title: Text(
                          req['testName'] ?? 'Unknown Test',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "Doctor: ${req['doctorName'] ?? 'N/A'}\nUrgency: ${req['urgency'] ?? 'Normal'}",
                        ),
                        trailing: const Icon(Icons.upload_file, color: Color.fromARGB(255, 58, 143, 183)),
                        onTap: () => showUploadDialog(req),
                      ),
                    );
                  },
                ),
    );
  }
}
