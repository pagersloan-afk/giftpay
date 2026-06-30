import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatementDownloadScreen extends StatefulWidget {
  const StatementDownloadScreen({super.key});

  @override
  State<StatementDownloadScreen> createState() =>
      _StatementDownloadScreenState();
}

class _StatementDownloadScreenState extends State<StatementDownloadScreen> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E88E5), // GiftPay blue
              onPrimary: Colors.white,
              surface: Color(0xFF0F1115),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F1115),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => startDate = date);
    }
  }

  Future<void> pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E88E5),
              onPrimary: Colors.white,
              surface: Color(0xFF0F1115),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F1115),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => endDate = date);
    }
  }

  void generateStatement() {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select both start and end dates")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      "/statement-pdf",
      arguments: {"start": startDate, "end": endDate},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        title: const Text("Download Statement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              tileColor: const Color(0xFF0F1115),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Start Date",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                startDate == null
                    ? "Select start date"
                    : DateFormat("dd MMM yyyy").format(startDate!),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.white54),
              onTap: pickStartDate,
            ),

            const SizedBox(height: 20),

            ListTile(
              tileColor: const Color(0xFF0F1115),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "End Date",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                endDate == null
                    ? "Select end date"
                    : DateFormat("dd MMM yyyy").format(endDate!),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.white54),
              onTap: pickEndDate,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: generateStatement,
                child: const Text(
                  "Generate PDF Statement",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
