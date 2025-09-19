import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class LabResultsPage extends StatefulWidget {
  final String patientID;

  const LabResultsPage({Key? key, required this.patientID}) : super(key: key);

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  List<dynamic> labRequests = [];
  List<dynamic> uploadedResults = [];
  bool isLoading = true;
  bool isLoadingResults = true;

  @override
  void initState() {
    super.initState();
    fetchLabRequests();
    fetchUploadedResults();
  }

  Future<void> fetchLabRequests() async {
    final url = Uri.parse(
        "http://197.232.14.151:3030/api/getlabRequests/${widget.patientID}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          labRequests = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No lab requests found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching lab requests: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUploadedResults() async {
    final url = Uri.parse(
        "http://197.232.14.151:3030/api/getLabResults/${widget.patientID}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          uploadedResults = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No uploaded results found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching uploaded results: $e")),
      );
    } finally {
      setState(() {
        isLoadingResults = false;
      });
    }
  }

  Future<void> uploadResult(Map<String, dynamic> req) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false
      );

      if (result == null || result.files.isEmpty) return;

      File file = File(result.files.single.path!);
      
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://197.232.14.151:3030/api/uploadLabResult"),
      );

      // Attach file
      request.files.add(await http.MultipartFile.fromPath(
        "file", 
        file.path,
        filename: result.files.single.name
      ));

      // Add current date
      String currentDate = DateTime.now().toIso8601String();

      // Attach fields
      request.fields['labID'] = req['labID']?.toString() ?? '';
      request.fields['testName'] = req['testName']?.toString() ?? '';
      request.fields['patientID'] = req['patientID']?.toString() ?? '';
      request.fields['patientName'] = req['patientName']?.toString() ?? '';
      request.fields['staffID'] = req['staffID']?.toString() ?? '';
      request.fields['doctorName'] = req['doctorName']?.toString() ?? '';
      request.fields['date'] = currentDate;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Uploading file..."),
              ],
            ),
          );
        },
      );

      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      Navigator.of(context).pop(); // Dismiss loading indicator

      print("Server response status: ${response.statusCode}");
      print("Server response body: $responseBody");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Result uploaded successfully")),
        );
        // Refresh the uploaded results list
        fetchUploadedResults();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Upload failed: ${response.statusCode}\n$responseBody")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading indicator if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error during upload: $e")),
      );
    }
  }

  Future<void> downloadAndOpenFile(String filePath, String fileName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Downloading file..."),
              ],
            ),
          );
        },
      );

      // Download the file
      final response = await http.get(
        Uri.parse("http://197.232.14.151:3030/uploads/lab_results/$filePath")
      );

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (response.statusCode == 200) {
        // Get the document directory path
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        
        // Write the file
        await file.writeAsBytes(response.bodyBytes);
        
        // Open the file
        OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to download file")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading indicator if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e")),
      );
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
                  backgroundColor: const Color.fromARGB(255, 58, 150, 183),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lab Results"),
          backgroundColor: const Color.fromARGB(255, 246, 250, 255),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Requests", icon: Icon(Icons.list_alt)),
              Tab(text: "Uploaded", icon: Icon(Icons.cloud_done)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Lab Requests Tab
            isLoading
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
            
            // Uploaded Results Tab
            isLoadingResults
                ? const Center(child: CircularProgressIndicator())
                : uploadedResults.isEmpty
                    ? const Center(child: Text("No uploaded results available"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: uploadedResults.length,
                        itemBuilder: (context, index) {
                          final result = uploadedResults[index];
                          final fileName = result['filePath']?.split('/').last ?? 'Unknown';
                          final fileExtension = fileName.split('.').last.toLowerCase();
                          
                          IconData icon;
                          if (fileExtension == 'pdf') {
                            icon = Icons.picture_as_pdf;
                          } else if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
                            icon = Icons.image;
                          } else {
                            icon = Icons.insert_drive_file;
                          }
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ListTile(
                              leading: Icon(icon, color: Colors.blue),
                              title: Text(
                                result['testName'] ?? 'Unknown Test',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Doctor: ${result['doctorName'] ?? 'N/A'}"),
                                  Text("Uploaded: ${result['date'] != null ? 
                                    DateTime.parse(result['date']).toLocal().toString().split(' ')[0] : 
                                    'Unknown date'}"),
                                  Text("File: $fileName"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () => downloadAndOpenFile(
                                  result['filePath'], 
                                  fileName
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}