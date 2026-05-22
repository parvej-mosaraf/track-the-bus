import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'notice_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'welcome_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  GoogleMapController? mapController;

  LatLng adminPosition = const LatLng(23.8103, 90.4125);

  bool isStreaming = false;

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();

    getAdminLocation();
  }

  Future<void> getAdminLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      adminPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void goToMyLocation() {
    mapController?.animateCamera(CameraUpdate.newLatLng(adminPosition));
  }

  Future<void> startStreaming() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return;
    }

    setState(() {
      isStreaming = true;
    });

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          await FirebaseFirestore.instance
              .collection('bus_locations')
              .doc('bus_1')
              .set({
                'latitude': position.latitude,

                'longitude': position.longitude,
              });

          setState(() {
            adminPosition = LatLng(position.latitude, position.longitude);
          });
        });
  }

  Future<void> stopStreaming() async {
    await positionStream?.cancel();

    setState(() {
      isStreaming = false;
    });
  }

  Future<void> handleStreaming() async {
    if (!isStreaming) {
      showDialog(
        context: context,

        builder: (_) => AlertDialog(
          title: const Text("Start Bus Streaming?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await startStreaming();
              },

              child: const Text("Start"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,

        builder: (_) => AlertDialog(
          title: const Text("Stop Bus Streaming?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await stopStreaming();
              },

              child: const Text("Stop"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  CircleAvatar(radius: 30, child: Icon(Icons.person)),

                  SizedBox(height: 10),

                  Text(
                    "Admin Panel",

                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),

              title: const Text("Profile"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),

              title: const Text("Notices"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoticeScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),

              title: const Text("Settings"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.help),

              title: const Text("Help & Feedback"),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),

              title: const Text("Logout"),

              onTap: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,

                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),

                  (route) => false,
                );
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(16),

              child: Text("Version 2026.0.0"),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: adminPosition,
              zoom: 15,
            ),

            myLocationEnabled: true,

            onMapCreated: (controller) {
              mapController = controller;
            },

            markers: {
              Marker(
                markerId: const MarkerId('admin'),

                position: adminPosition,
              ),
            },
          ),

          Positioned(
            bottom: 20,
            left: 20,

            child: Row(
              children: [
                FloatingActionButton(
                  heroTag: "requests",

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NoticeScreen()),
                    );
                  },

                  child: const Icon(Icons.stop_circle),
                ),

                const SizedBox(width: 12),

                FloatingActionButton(
                  heroTag: "stream",

                  backgroundColor: isStreaming ? Colors.red : Colors.green,

                  onPressed: handleStreaming,

                  child: Icon(isStreaming ? Icons.stop : Icons.play_arrow),
                ),

                const SizedBox(width: 12),

                FloatingActionButton(
                  heroTag: "location",

                  onPressed: goToMyLocation,

                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
