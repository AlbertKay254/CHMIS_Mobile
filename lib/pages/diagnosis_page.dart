import 'package:flutter/material.dart';

class DiagnosisPage extends StatelessWidget {
  final List<Map<String, dynamic>> diagnoses = [
    {
      "condition": "Hypertension",
      "severity": "High",
      "doctor": "Dr. Kamau",
      "date": "2025-03-20",
    },
    {
      "condition": "Diabetes Type 2",
      "severity": "Moderate",
      "doctor": "Dr. Achieng",
      "date": "2025-02-15",
    },
    {
      "condition": "Migraine",
      "severity": "Low",
      "doctor": "Dr. Mutiso",
      "date": "2025-01-10",
    },
    {
      "condition": "Asthma",
      "severity": "Moderate",
      "doctor": "Dr. Wanjiku",
      "date": "2024-12-05",
    },
    {
      "condition": "Pneumonia",
      "severity": "High",
      "doctor": "Dr. Ochieng",
      "date": "2024-11-22",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis"),
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
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: Radius.circular(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 20.0,
                    dividerThickness: 1.0, // Line between rows
                    headingRowHeight: 50, // Header height
                    headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blue[200]!),
                    // ignore: deprecated_member_use
                    dataRowHeight: 60, // Row height
                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                    columns: [
                      DataColumn(
                        label: Container(
                          color: Colors.orange[200], // Orange background for Condition Column
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Condition',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Severity',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Doctor',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    rows: diagnoses.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> diagnosis = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            return index.isEven ? Colors.grey[100] : null; // Alternate row color
                          },
                        ),
                        cells: [
                          DataCell(Container(
                            color: Colors.orange[100],
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: Text(diagnosis["condition"]!),
                          )),
                          DataCell(Text(diagnosis["severity"]!)),
                          DataCell(Text(diagnosis["doctor"]!)),
                          DataCell(Text(diagnosis["date"]!)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
