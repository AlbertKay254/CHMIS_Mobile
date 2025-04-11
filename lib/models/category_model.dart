import 'package:medical_app/pages/doctor/hr_page.dart';
import 'package:medical_app/pages/doctor/inpatient_page.dart';
import 'package:medical_app/pages/doctor/outpatient_patient.dart';
import 'package:medical_app/pages/doctor/pharmacy_page.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;
  Widget destination;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
    required this.destination,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: 'Outpatient',
        iconPath: 'assets/icons/i-outpatient-svgrepo-com.svg',
        boxColor: const Color.fromARGB(255, 240, 210, 157),
        destination: OutpatientPage(),
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Inpatient',
        iconPath: 'assets/icons/i-inpatient-svgrepo-com.svg',
        boxColor: const Color.fromARGB(255, 119, 244, 255),
        destination: InpatientPage(),
      ),
    );

    categories.add(
      CategoryModel(
        name: 'Pharmacy',
        iconPath: 'assets/icons/pharmacy-clinic-hospital-svgrepo-com.svg',
        boxColor: const Color.fromARGB(255, 240, 210, 157),
        destination: PharmacyPage(),
      ),
    );

    categories.add(
      CategoryModel(
        name: 'HR',
        iconPath: 'assets/icons/hr-svgrepo-com.svg',
        boxColor: const Color.fromARGB(255, 119, 244, 255),
        destination: HRPage(),
      ),
    );

    // To enable the Appointments page, just uncomment and ensure it's imported correctly.
    // categories.add(
    //   CategoryModel(
    //     name: 'Appointments',
    //     iconPath: 'assets/icons/appointments-svgrepo-com.svg',
    //     boxColor: const Color.fromARGB(255, 240, 210, 157),
    //     destination: AppointmentsPage(),
    //   ),
    // );

    return categories;
  }
}
