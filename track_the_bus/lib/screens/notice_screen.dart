import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_notice_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),

        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              final role = data['role'];

              if (role.toString().toLowerCase() == 'driver' ||
                  role.toString().toLowerCase() == 'admin') {
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateNoticeScreen(),
                      ),
                    );
                  },

                  icon: const Icon(Icons.add_alert),
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const CreateNoticeScreen()),
      //     );
      //   },

      //   child: const Icon(Icons.add),
      // ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notices = snapshot.data!.docs;

          if (notices.isEmpty) {
            return const Center(child: Text("No notices available"));
          }

          return ListView.builder(
            itemCount: notices.length,

            itemBuilder: (context, index) {
              final notice = notices[index];

              return Card(
                margin: const EdgeInsets.all(12),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Text(
                    notice['message'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
