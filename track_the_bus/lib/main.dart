import 'package:flutter/material.dart';

void main() {
  runApp(const TrackTheBusApp());
}

class TrackTheBusApp extends StatelessWidget {
  const TrackTheBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track The Bus',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track The Bus")),
      body: const Center(
        child: Text(
          "Project Started Successfully",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
