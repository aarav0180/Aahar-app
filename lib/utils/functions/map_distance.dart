import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Function to build the map with route & distance
Widget buildMapWithRoute({
  required double orderLatitude,
  required double orderLongitude,
  required double ngoLatitude,
  required double ngoLongitude,
}) {
  return FutureBuilder<Map<String, dynamic>>(
    future: fetchRoute(orderLatitude, orderLongitude, ngoLatitude, ngoLongitude),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return const Center(child: Text("❌ Error loading map"));
      }

      /// ✅ Correctly parsing `List<LatLng>`
      List<LatLng> routeCoordinates = (snapshot.data!['route'] as List)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      double distance = snapshot.data!['distance'] ?? 0.0;

      return Column(
        children: [
          SizedBox(
            height: 300, // Adjust map height as needed
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(orderLatitude, orderLongitude),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Start point (Order Location)
                    Marker(
                      point: LatLng(orderLatitude, orderLongitude),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                    // End point (NGO Location)
                    Marker(
                      point: LatLng(ngoLatitude, ngoLongitude),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.home, color: Colors.blue, size: 40),
                    ),
                    // Waypoints along the route
                    ...routeCoordinates.map((latLng) => Marker(
                      point: latLng,
                      width: 20,
                      height: 20,
                      child: const Icon(Icons.circle, color: Colors.green, size: 10),
                    )),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeCoordinates,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Distance: ${distance.toStringAsFixed(2)} km",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

/// Fetches route & distance using OSRM API
Future<Map<String, dynamic>> fetchRoute(
    double orderLat,
    double orderLon,
    double ngoLat,
    double ngoLon,
    ) async {
  try {
    // ✅ Ensure correct formatting (OSRM requires "lon,lat")
    String osrmUrl =
        "https://router.project-osrm.org/route/v1/driving/"
        "$orderLon,$orderLat;$ngoLon,$ngoLat?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(osrmUrl));

    print(osrmUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isEmpty) {
        throw Exception("No route found");
      }

      List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
      double distance = data['routes'][0]['distance'] / 1000; // Convert to km

      /// ✅ Correctly converting `List<dynamic>` to `List<LatLng>`
      List<LatLng> route = coords.map((point) {
        return LatLng(point[1], point[0]); // Convert lon/lat to `LatLng`
      }).toList();

      return {
        "route": route,
        "distance": distance,
      };
    } else {
      throw Exception("Failed to fetch route: HTTP ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("❌ Error fetching route: $e");
    return {"route": [], "distance": 0.0};
  }
}
