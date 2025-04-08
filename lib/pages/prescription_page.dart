// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PrescriptionPage extends StatelessWidget {
  final List<Map<String, dynamic>> prescriptions = [
    {
      "medicine": "Paracetamol",
      "cost": "10",
      "dosage": "500mg (2x per day)",
      "paid": true,
    },
    {
      "medicine": "Amoxicillin",
      "cost": "25",
      "dosage": "250mg (3x per day)",
      "paid": false,
    },
    {
      "medicine": "Ibuprofen",
      "cost": "15",
      "dosage": "200mg (2x per day)",
      "paid": true,
    },
    {
      "medicine": "Cough Syrup",
      "cost": "\$8",
      "dosage": "10ml (3x per day)",
      "paid": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescriptions"),
        backgroundColor: const Color.fromARGB(255, 99, 182, 188),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enables horizontal scrolling
              child: DataTable(
                columnSpacing: 20.0,
                dividerThickness: 1.0, // Line between rows
                headingRowHeight: 50, // Header height
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[200]!),
                dataRowHeight: 60, // Row height
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columns: [
                  DataColumn(
                    label: Container(
                      color: Colors.yellow[200], // Yellow background for Medicine Column
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Medicine',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Cost(ksh)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Dosage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Paid',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                rows: prescriptions.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> prescription = entry.value;
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return index.isEven ? Colors.grey[100] : null; // Alternate row color
                      },
                    ),
                    cells: [
                      DataCell(Container(
                        color: Colors.yellow[100],
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        child: Text(prescription["medicine"]),
                      )),
                      DataCell(Text(prescription["cost"])),
                      DataCell(Text(prescription["dosage"])),
                      DataCell(
                        Icon(
                          prescription["paid"] ? Icons.check_circle : Icons.cancel,
                          color: prescription["paid"] ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
