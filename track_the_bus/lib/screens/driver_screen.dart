import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'create_notice_screen.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();

    startLocationUpdates();
  }

  Future<void> startLocationUpdates() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          await FirebaseFirestore.instance
              .collection('bus_locations')
              .doc('bus_1')
              .set({
                'latitude': position.latitude,
                'longitude': position.longitude,
                'updatedAt': FieldValue.serverTimestamp(),
              });

          print(
            "Location Updated: "
            "${position.latitude}, "
            "${position.longitude}",
          );
        });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Mode"),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stop_requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),

        builder: (context, snapshot) {
          int requestCount = 0;

          if (snapshot.hasData) {
            requestCount = snapshot.data!.docs.length;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const Text(
                  "Sharing Live Bus Location",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                Text(
                  "Stop Requests: $requestCount",
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () async {
                    final requests = await FirebaseFirestore.instance
                        .collection('stop_requests')
                        .get();

                    for (var doc in requests.docs) {
                      await doc.reference.update({'status': 'completed'});
                    }
                  },

                  child: const Text("Clear Requests"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
