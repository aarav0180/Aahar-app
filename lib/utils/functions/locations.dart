import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';

Future<Position?> checkAndUpdateLocation(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    bool shouldExit = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.background,
          title: const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary),
              SizedBox(width: 8),
              Text("Enable Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          content: const Text("This app requires location services to function properly. Please enable it.", style: TextStyle(color: AppColors.secondary)),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text("Exit")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text("Enable")),
            ),
          ],
        );
      },
    );

    if (shouldExit) return null;
    return checkAndUpdateLocation(context); // Retry
  }

  // Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    // Get the user's location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("✅ Location updated: ${position.latitude}, ${position.longitude}");
    return position;
  } catch (e) {
    print("❌ Error fetching location: $e");
    return null;
  }
}
