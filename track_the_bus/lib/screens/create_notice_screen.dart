import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final noticeController = TextEditingController();

  Future<void> publishNotice() async {
    if (noticeController.text.trim().isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('notices').add({
      'message': noticeController.text.trim(),

      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Notice Published")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Notice")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: noticeController,

              maxLines: 5,

              decoration: InputDecoration(
                hintText: "Write notice here...",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: publishNotice,

              child: const Text("Publish"),
            ),
          ],
        ),
      ),
    );
  }
}
