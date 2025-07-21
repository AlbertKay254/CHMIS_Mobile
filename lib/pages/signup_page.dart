import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pidController = TextEditingController();

 void _signUp() async {
  if (_formKey.currentState!.validate()) {
    //final url = Uri.parse('http://192.168.1.10:3030/api/signup');
    final url = Uri.parse('http://197.232.14.151:3030/api/signup');

      final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'patientID': _pidController.text.trim(), 
      }),
    );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created!')),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${response.body}')),
        );
      }
  }
}

  @override
  Widget build(BuildContext context) {
    const borderRadius = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    return Scaffold(
      // appBar: AppBar(
      //   //title: const Text('Sign Up'),
      //   backgroundColor: const Color.fromARGB(255, 130, 232, 195),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
               const Icon(Icons.local_hospital_rounded, size: 80, color: Color.fromARGB(255, 3, 179, 167)),
                const SizedBox(height: 20),
                const Text(
                  'Sign Up to to CHMIS Mobile Today',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),

              // Full Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: borderRadius,
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your user name' : null,
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: borderRadius,
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: borderRadius,
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 30),

              //PID
              // Password Field
              TextFormField(
                controller: _pidController,
                decoration: const InputDecoration(
                  labelText: 'Patient ID',
                  border: borderRadius,
                  prefixIcon: Icon(Icons.person_remove),
                ),
                  validator: (value) =>
                    value!.isEmpty ? 'Please enter your PID' : null,
                
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 250, 240, 149),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 49, 45),
                  ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
