// ignore: file_names
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color.fromARGB(255, 250, 248, 223),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 18, 202, 190),
              strokeWidth: 4,
            ),
            const SizedBox(height: 20),
            Text(
              message ?? 'Loading...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(137, 47, 47, 47),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
