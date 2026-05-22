import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_notice_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateNoticeScreen(),
                ),
              );
            },

            icon: const Icon(Icons.add_alert),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: dashboardCard(
                    title: "Users",
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: dashboardCard(
                    title: "Stop Requests",
                    stream: FirebaseFirestore.instance
                        .collection('stop_requests')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,

                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),

                          title: Text(user['email']),

                          subtitle: Text("Role: ${user['role']}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,

    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,

      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }

        return Container(
          height: 140,

          decoration: BoxDecoration(
            color: Colors.blue,

            borderRadius: BorderRadius.circular(20),
          ),

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  title,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
