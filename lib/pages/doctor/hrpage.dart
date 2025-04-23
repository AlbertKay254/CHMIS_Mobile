import 'package:flutter/material.dart';

class HRPage extends StatelessWidget {
  const HRPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Module'),
      ),
      body: Center(
        child: const Text(
          'Welcome to the HR Module',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}