// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
//import 'package:medical_app/pages/home_page.dart';
//import 'package:medical_app/pages/login_page.dart';
import 'package:medical_app/pages/account_selection.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //useMaterial3: false, 
      //home: const HomePage(),
      //home: const LoginPage(),
      home: const  LoginOptionPage(),
    );
  }
}
