import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class StudentMapScreen extends StatefulWidget {
  const StudentMapScreen({super.key});

  @override
  State<StudentMapScreen> createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
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
