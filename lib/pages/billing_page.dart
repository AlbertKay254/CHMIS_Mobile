import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BillingPage extends StatefulWidget {
  final String patientID;

  const BillingPage({Key? key, required this.patientID}) : super(key: key);

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  bool isLoading = true;
  Map<String, List<dynamic>> groupedBills = {};
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchBills();
  }

  Future<void> fetchBills() async {
    final url = "http://197.232.14.151:3030/api/patientBills/${widget.patientID}";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Group by bill_number
        Map<String, List<dynamic>> grouped = {};
        for (var bill in data) {
          String billNo = bill['bill_number'].toString();
          if (!grouped.containsKey(billNo)) {
            grouped[billNo] = [];
          }
          grouped[billNo]!.add(bill);
        }

        setState(() {
          groupedBills = grouped;
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = "No bills found for this patient.";
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load bills (Error ${response.statusCode}).";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  /// Convert values safely to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Generate PDF for one invoice
  Future<void> generateInvoicePdf(String billNumber, List<dynamic> items) async {
    final pdf = pw.Document();

    final firstItem = items[0];
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + _toDouble(item['total']),
    );

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Invoice #$billNumber",
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Patient ID: ${firstItem['pid']}"),
            pw.Text("Encounter: ${firstItem['encounter_nr']}"),
            pw.Text("Class: ${firstItem['encounter_class']}"),
            pw.Text("Date: ${firstItem['bill_date']} ${firstItem['bill_time']}"),
            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: ["Description", "Service", "Qty", "Price", "Total"],
              data: items.map((bill) {
                return [
                  bill['description'] ?? "-",
                  bill['service_type'] ?? "-",
                  bill['qty'].toString(),
                  "Ksh ${bill['price']}",
                  "Ksh ${bill['total']}"
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Grand Total: Ksh $totalAmount",
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    // Show print/share dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing & Invoices"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView(
                  children: groupedBills.entries.map((entry) {
                    String billNumber = entry.key;
                    List<dynamic> items = entry.value;
                    final firstItem = items[0];
                    final totalAmount = items.fold<double>(
                      0,
                      (sum, item) => sum + _toDouble(item['total']),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: ExpansionTile(
                        title: Text(
                          "Invoice #$billNumber",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          "Date: ${firstItem['bill_date'].toString().split('T')[0]} "
                          "| Class: ${firstItem['encounter_class']} "
                          "| Status: ${firstItem['status']}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf,
                              color: Colors.red),
                          onPressed: () => generateInvoicePdf(billNumber, items),
                        ),
                        children: [
                          ...items.map((bill) => ListTile(
                                title: Text(
                                    bill['description'] ?? "No Description"),
                                subtitle:
                                    Text("Service: ${bill['service_type']}"),
                                trailing: Text(
                                  "Ksh ${bill['total']}",
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Total: Ksh $totalAmount",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
