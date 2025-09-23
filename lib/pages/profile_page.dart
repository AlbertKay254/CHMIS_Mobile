import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  final String patientID;
  final String userName;

  const ProfilePage({Key? key, required this.patientID, required this.userName})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String name = "";
  String email = "";
  String patientID = "";
  File? _profileImage;
  bool _isLoading = true;
  String _errorMessage = "";
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    patientID = widget.patientID;
    _fetchPatientData();
    _fetchPatientProfile();
  }

  Future<void> _fetchPatientData() async {
    try {
      final response = await http.get(
        Uri.parse('http://197.232.14.151:3030/api/userInfo/$patientID'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final patient = data[0];
          setState(() {
            patientID = patient['patientID'] ?? '';
            name = patient['name'] ?? '';
            email = patient['email'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load patient data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _fetchPatientProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://197.232.14.151:3030/api/patientProfile/$patientID'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _profileImageUrl =
              'http://197.232.14.151:3030/uploads/patient_profiles/${data['filePath']}';
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
      _fetchPatientProfile();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://197.232.14.151:3030/api/uploadPatientProfile'),
      );

      request.fields['patientID'] = patientID;
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          _profileImage!.path,
          filename: path.basename(_profileImage!.path),
        ),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      try {
        final jsonResponse = json.decode(responseBody);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated successfully!")),
          );
          setState(() {
            _profileImageUrl =
                'http://197.232.14.151:3030/uploads/patient_profiles/${jsonResponse['filePath']}';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Failed: ${jsonResponse['error'] ?? 'Unknown'}")),
          );
        }
      } catch (e) {
        print("Upload raw response: $responseBody");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading: $e")),
      );
    }
  }

  Widget _buildProfileImage() {
    if (_profileImage == null && _profileImageUrl.isEmpty) {
      String initials = name.isNotEmpty
          ? name.trim().split(" ").map((e) => e[0]).take(2).join().toUpperCase()
          : "?";

      return CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFF161d63),
        child: Text(initials,
            style: const TextStyle(fontSize: 40, color: Colors.white)),
      );
    }

    if (_profileImage != null) {
      return CircleAvatar(radius: 60, backgroundImage: FileImage(_profileImage!));
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(_profileImageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile"), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              _buildProfileImage(),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                    child: Icon(Icons.camera_alt,
                                        color: Colors.teal),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          initialValue: name,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: email,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: patientID,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Patient ID",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}