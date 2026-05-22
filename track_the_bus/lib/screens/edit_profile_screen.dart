import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();

  final idController = TextEditingController();

  final deptController = TextEditingController();

  final sessionController = TextEditingController();

  final addressController = TextEditingController();

  final contactController = TextEditingController();

  final bloodController = TextEditingController();

  final guardianController = TextEditingController();

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();

    if (data != null) {
      nameController.text = data['name'] ?? '';

      idController.text = data['studentId'] ?? '';

      deptController.text = data['department'] ?? '';

      sessionController.text = data['session'] ?? '';

      addressController.text = data['address'] ?? '';

      contactController.text = data['contact'] ?? '';

      bloodController.text = data['bloodGroup'] ?? '';

      guardianController.text = data['guardianNumber'] ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text,
      'studentId': idController.text,
      'department': deptController.text,
      'session': sessionController.text,
      'address': addressController.text,
      'contact': contactController.text,
      'bloodGroup': bloodController.text,
      'guardianNumber': guardianController.text,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated")));

    Navigator.pop(context);
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            buildField("Name", nameController),

            buildField("Student ID", idController),

            buildField("Department", deptController),

            buildField("Session", sessionController),

            buildField("Address", addressController),

            buildField("Contact", contactController),

            buildField("Blood Group", bloodController),

            buildField("Guardian Number", guardianController),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: saveProfile, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
