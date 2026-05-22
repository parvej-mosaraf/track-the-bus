import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices")),

      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Bus A delayed by 10 mins"),
          ),

          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Route changed today"),
          ),
        ],
      ),
    );
  }
}
