import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          children: [

            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user?.email ?? "No Email",

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text("Student ID"),
              subtitle: const Text("2026-XXXX"),
            ),

            ListTile(
              leading: const Icon(Icons.school),
              title: const Text("Department"),
              subtitle: const Text("IoT Engineering"),
            ),
          ],
        ),
      ),
    );
  }
}