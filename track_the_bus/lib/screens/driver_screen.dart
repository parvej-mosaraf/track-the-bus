import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
      appBar: AppBar(title: const Text("Driver Mode")),

      body: const Center(
        child: Text(
          "Sharing Live Bus Location...",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
