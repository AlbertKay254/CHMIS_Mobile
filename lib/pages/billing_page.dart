import 'package:flutter/material.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final List<Map<String, dynamic>> invoices = [
    {
      "title": "Consultation Fee",
      "amount": 1500,
      "date": "2025-03-25",
      "paid": true,
    },
    {
      "title": "Lab Tests",
      "amount": 2200,
      "date": "2025-03-28",
      "paid": false,
    },
    {
      "title": "X-Ray Charges",
      "amount": 1800,
      "date": "2025-03-29",
      "paid": true,
    },
    {
      "title": "Medication",
      "amount": 950,
      "date": "2025-03-30",
      "paid": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing & Invoices"),
        backgroundColor: const Color.fromARGB(255, 99, 182, 188),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  invoice["title"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text("Date: ${invoice["date"]}"),
                    Text("Amount: Ksh ${invoice["amount"]}"),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    invoice["paid"] ? "Paid" : "Unpaid",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: invoice["paid"] ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
