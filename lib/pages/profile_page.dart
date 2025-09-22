import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Example initial data (you will probably load this from backend)
  String name = "John Doe";
  String department = "Telemedicine";
  String staffID = "DOC12345";
  String phone = "+254700000000";
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // TODO: Send updated data + profile photo to backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color.fromARGB(255, 20, 201, 207),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile photo
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage("assets/profile_placeholder.png")
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.camera_alt,
                              color: Color(0xFF161d63)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => name = val ?? "",
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              // Department
              TextFormField(
                initialValue: department,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => department = val ?? "",
              ),
              const SizedBox(height: 16),

              // Staff ID
              TextFormField(
                initialValue: staffID,
                decoration: const InputDecoration(
                  labelText: "Staff ID",
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => staffID = val ?? "",
              ),
              const SizedBox(height: 16),

              // Phone number
              TextFormField(
                initialValue: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => phone = val ?? "",
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161d63),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
