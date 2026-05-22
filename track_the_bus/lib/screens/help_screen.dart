import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Feedback")),

      body: const Padding(
        padding: EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Support Email:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text("support@trackthebus.com"),

            SizedBox(height: 30),

            Text("Version 2026.0.0"),
          ],
        ),
      ),
    );
  }
}
