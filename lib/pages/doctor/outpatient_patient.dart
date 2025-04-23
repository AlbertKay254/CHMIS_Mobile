import 'package:flutter/material.dart';

class OutpatientPage extends StatefulWidget {
  const OutpatientPage({super.key});

  @override
  State<OutpatientPage> createState() => _OutpatientPageState();
}

class _OutpatientPageState extends State<OutpatientPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outpatient Patient Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: const Text(
          'Outpatient Patient Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }
}