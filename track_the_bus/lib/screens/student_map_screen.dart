import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({super.key});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  GoogleMapController? mapController;

  LatLng busPosition = const LatLng(23.8103, 90.4125);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Bus Tracking")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await FirebaseFirestore.instance.collection('stop_requests').add({
            'requestedAt': FieldValue.serverTimestamp(),

            'status': 'pending',
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Stop Requested")));
        },

        label: const Text("Request Stop"),

        icon: const Icon(Icons.stop_circle),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bus_locations')
            .doc('bus_1')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            busPosition = LatLng(data['latitude'], data['longitude']);
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: busPosition,
              zoom: 15,
            ),

            markers: {
              Marker(
                markerId: const MarkerId('bus'),

                position: busPosition,

                infoWindow: const InfoWindow(title: "University Bus"),
              ),
            },

            onMapCreated: (controller) {
              mapController = controller;
            },
          );
        },
      ),
    );
  }
}
