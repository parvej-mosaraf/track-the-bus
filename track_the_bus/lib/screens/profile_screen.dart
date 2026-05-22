import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },

            icon: const Icon(Icons.edit),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          Widget infoTile(String title, String value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),

              child: Text(
                "$title: $value",

                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),

                const SizedBox(height: 30),

                infoTile("Name", data['name'] ?? ''),

                infoTile("ID", data['studentId'] ?? ''),

                infoTile("Dept", data['department'] ?? ''),

                infoTile("Session", data['session'] ?? ''),

                infoTile("Address", data['address'] ?? ''),

                infoTile("Contact", data['contact'] ?? ''),

                infoTile("Blood Group", data['bloodGroup'] ?? ''),

                infoTile("Guardian’s Number", data['guardianNumber'] ?? ''),
              ],
            ),
          );
        },
      ),
    );
  }
}
