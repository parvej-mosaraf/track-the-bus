import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

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
      home: const WelcomeScreen(),
    );
  }
}
