import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const TrackTheBusApp());
}

class TrackTheBusApp extends StatelessWidget {
  const TrackTheBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track The Bus',

      home: FirebaseAuth.instance.currentUser != null
          ? const DashboardScreen()
          : const WelcomeScreen(),
    );
  }
}
