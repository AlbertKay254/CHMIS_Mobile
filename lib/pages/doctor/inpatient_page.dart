import 'package:flutter/material.dart';

class InpatientPage extends StatefulWidget {
  const InpatientPage({super.key});

  @override
  State<InpatientPage> createState() => _InpatientPageState();
}

class _InpatientPageState extends State<InpatientPage> {
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