import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;

class ProfilePageDoc extends StatefulWidget {
  final String staffID;
  
  const ProfilePageDoc({Key? key, required this.staffID, required String doctorName}) : super(key: key);

  @override
  State<ProfilePageDoc> createState() => _ProfilePageDocState();
}

class _ProfilePageDocState extends State<ProfilePageDoc> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Variables to store doctor data
  String name = "";
  String email = "";
  String phone = "";
  String staffID = "";
  File? _profileImage;
  bool _isLoading = true;
  String _errorMessage = "";
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    staffID = widget.staffID;
    _fetchDoctorData();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorData() async {
  try {
    final response = await http.get(
      Uri.parse('http://197.232.14.151:3030/api/doctorInfo/$staffID'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // data is a List, so take the first element
      if (data is List && data.isNotEmpty) {
        final doctor = data[0];

        setState(() {
          staffID = doctor['staffID'] ?? '';
          name = doctor['doctorName'] ?? '';
          email = doctor['email'] ?? '';
          phone = doctor['mobile']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No doctor data found';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load doctor data';
      });
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error: $e';
    });
  }
}


  Future<void> _fetchDoctorProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://197.232.14.151:3030/api/doctorProfile/$staffID'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _profileImageUrl = 'http://197.232.14.151:3030/uploads/doctor_profiles/${data['filePath']}';
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
      _fetchDoctorProfile();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://197.232.14.151:3030/api/uploadDoctorProfile'),
      );

      request.fields['staffID'] = staffID;
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
                'http://197.232.14.151:3030/uploads/doctor_profiles/${jsonResponse['filePath']}';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Failed to upload: ${jsonResponse['error'] ?? 'Unknown error'}")),
          );
        }
      } catch (e) {
        // If parsing fails, show raw response
        print("Upload raw response: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: Could not parse server response")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }


  Widget _buildProfileImage() {
  // If no profile image and no uploaded image, show initials
  if (_profileImage == null && _profileImageUrl.isEmpty) {
    String initials = "";
    if (name.isNotEmpty) {
      // Take first letter of each word in name, up to 2 chars
      final parts = name.trim().split(" ");
      initials = parts.map((e) => e[0]).take(2).join().toUpperCase();
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: const Color(0xFF161d63),
      child: Text(
        initials.isNotEmpty ? initials : "?",
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // If picked image (local file) exists
  if (_profileImage != null) {
    return CircleAvatar(
      radius: 60,
      backgroundImage: FileImage(_profileImage!),
    );
  }

  // If profile URL exists, load from network
  return CircleAvatar(
    radius: 60,
    backgroundColor: Colors.grey.shade200,
    backgroundImage: NetworkImage(_profileImageUrl),
    onBackgroundImageError: (_, __) {
      // fallback if network image fails
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color.fromARGB(255, 194, 237, 239),
      ),
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
                        // Profile photo
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
                                    child: Icon(Icons.camera_alt, color: Color.fromARGB(255, 14, 76, 108)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Name Field (Read-only)
                        TextFormField(
                          initialValue: name,
                          decoration: const InputDecoration(
                            labelText: "Doctor Name",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 251, 228),
                          ),
                          readOnly: true,
                          enabled: false,
                          style: const TextStyle( 
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field (Read-only)
                        TextFormField(
                          initialValue: email,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 251, 228),
                          ),
                          readOnly: true,
                          enabled: false,
                          style: const TextStyle( 
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                        const SizedBox(height: 16),

                        // Staff ID Field (Read-only)
                        TextFormField(
                          initialValue: staffID,
                          decoration: const InputDecoration(
                            labelText: "Staff ID",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 251, 228),
                          ),
                          readOnly: true,
                          enabled: false,
                          style: const TextStyle( 
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                        const SizedBox(height: 16),

                        // Phone number Field (Read-only)
                        TextFormField(
                          initialValue: phone,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 251, 228),
                          ),
                          readOnly: true,
                          enabled: false,
                          style: const TextStyle( 
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                        const SizedBox(height: 24),

                        // Note for user
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Only profile picture can be updated. Contact admin for other changes.",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}