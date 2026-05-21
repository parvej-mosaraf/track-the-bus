import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({super.key});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
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

    PolylinePoints polylinePoints = PolylinePoints(
      apiKey: 'AIzaSyB_RcwAZhW0mJhkNVApmNoBE1hgoGMXYog',
    );

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

            double distance = calculateDistance(
              busPosition.latitude,
              busPosition.longitude,
              destination.latitude,
              destination.longitude,
            );
            bool hasAlertShown = false;

            if (distance < 0.5 && !hasAlertShown) {
              hasAlertShown = true;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🚨 Bus is near your stop!")),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              createRoute();
            });
          }

          return Column(
            children: [
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                color: Colors.blue,

                child: const Column(
                  children: [
                    Text(
                      "Bus A",

                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Estimated Arrival: 5 mins",

                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: busPosition,
                    zoom: 15,
                  ),

                  polylines: polylines,

                  markers: {
                    Marker(
                      markerId: const MarkerId('bus'),

                      position: busPosition,

                      infoWindow: const InfoWindow(title: "University Bus"),
                    ),
                  },

                  myLocationEnabled: true,

                  myLocationButtonEnabled: true,

                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
