import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({super.key});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  @override
  void initState() {
    super.initState();

    getUserLocation();
  }

  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });
  }

  final TextEditingController searchController = TextEditingController();

  LatLng userPosition = const LatLng(0, 0);

  void goToBusLocation() {
    mapController?.animateCamera(CameraUpdate.newLatLng(busPosition));
  }

  Future<void> goToUserLocation() async {
    await getUserLocation();

    mapController?.animateCamera(CameraUpdate.newLatLng(userPosition));
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km

    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  GoogleMapController? mapController;

  LatLng busPosition = const LatLng(23.8103, 90.4125);

  final LatLng destination = const LatLng(23.8223, 90.3654);

  Set<Polyline> polylines = {};

  bool routeLoading = false;

  Future<void> createRoute() async {
    if (routeLoading) return;

    routeLoading = true;

    PolylinePoints polylinePoints = PolylinePoints(apiKey: 'api_key_here');

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(busPosition.latitude, busPosition.longitude),

        destination: PointLatLng(destination.latitude, destination.longitude),

        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = [];

      for (var point in result.points) {
        routePoints.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        polylines = {
          Polyline(
            polylineId: const PolylineId("route"),

            points: routePoints,

            width: 6,
          ),
        };
      });
    }

    routeLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,

        title: Padding(
          padding: const EdgeInsets.only(right: 12),

          child: Container(
            height: 46,

            decoration: BoxDecoration(
              color: Colors.grey.shade200,

              borderRadius: BorderRadius.circular(30),
            ),

            child: TextField(
              controller: searchController,

              decoration: const InputDecoration(
                hintText: "Search route...",

                prefixIcon: Icon(Icons.search),

                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisAlignment: MainAxisAlignment.end,

                children: const [
                  CircleAvatar(radius: 30, child: Icon(Icons.person)),

                  SizedBox(height: 12),

                  Text(
                    "Student User",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notice"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Feedback"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),

              onTap: () async {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(16),

              child: Text(
                "Version 2026.0.0",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     await FirebaseFirestore.instance.collection('stop_requests').add({
      //       'requestedAt': FieldValue.serverTimestamp(),

      //       'status': 'pending',
      //     });

      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(const SnackBar(content: Text("Stop Requested")));
      //   },

      //   label: const Text("Request Stop"),

      //   icon: const Icon(Icons.stop_circle),
      // ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bus_locations')
            .doc('bus_1')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            busPosition = LatLng(data['latitude'], data['longitude']);

            double distance = calculateDistance(
              busPosition.latitude,
              busPosition.longitude,
              destination.latitude,
              destination.longitude,
            );

            if (distance < 0.5) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🚨 Bus is near your stop!")),
                );
              });
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              createRoute();
            });
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: busPosition,
                  zoom: 15,
                ),

                markers: {
                  Marker(
                    markerId: const MarkerId('bus'),

                    position: busPosition,
                  ),

                  Marker(
                    markerId: const MarkerId('user'),

                    position: userPosition,

                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
                },

                polylines: polylines,

                myLocationEnabled: true,

                myLocationButtonEnabled: false,

                onMapCreated: (controller) {
                  mapController = controller;
                },
              ),

              Positioned(
                top: 20,
                left: 16,
                right: 16,

                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: TextField(
                    controller: searchController,

                    decoration: const InputDecoration(
                      hintText: "Search route...",

                      icon: Icon(Icons.search),

                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,

                child: Row(
                  children: [
                    FloatingActionButton(
                      heroTag: "stop",

                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('stop_requests')
                            .add({
                              'requestedAt': FieldValue.serverTimestamp(),

                              'status': 'pending',
                            });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Stop Requested")),
                        );
                      },

                      child: const Icon(Icons.stop_circle),
                    ),

                    const SizedBox(width: 12),

                    FloatingActionButton(
                      heroTag: "bus",

                      onPressed: goToBusLocation,

                      child: const Icon(Icons.directions_bus),
                    ),

                    const SizedBox(width: 12),

                    FloatingActionButton(
                      heroTag: "me",

                      onPressed: goToUserLocation,

                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
