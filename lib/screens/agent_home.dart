import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_solution/core/data/user_local.dart';
import 'package:google_solution/screens/Donations/available_orders.dart';
import '../utils/app_colors.dart';
import '../utils/functions/locations.dart';

class AgentHomeScreen extends StatefulWidget {
  final String mail;
  const AgentHomeScreen({super.key, required this.mail});

  @override
  _AgentHomeScreenState createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int totalFoodSaved = 0;
  int totalEventsHosted = 0;
  //String totalOrders = '0';
  int pendingOrders = 0;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchUserData();
  }

  Future<void> _getUserLocation() async {
    Position? position = await checkAndUpdateLocation(context);
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
    }
  }



  Future<void> _fetchUserData() async {
    final userData = await UserLocalStorage.getUser(widget.mail);

    setState(() {
      totalFoodSaved = userData.totalFoodSaved ?? 0;
      totalEventsHosted = userData.totalEventsHosted ?? 0;
      //totalOrders = userData.totalOrders ?? '50';
      pendingOrders = userData.pendingOrders ?? '12';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Agent Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        totalFoodSaved.toString(),
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Total Foods Collected',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 150,
                    width: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Events',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        totalEventsHosted.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // _OrderInfoRow(title: 'Total Orders', value: totalOrders),
                  // const Divider(),
                  _OrderInfoRow(title: 'Pending Orders', value: pendingOrders),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Manage Orders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OrderOption(title: 'Available Orders', icon: Icons.list_alt, onTap: () {
                  if (_currentPosition != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DonationsPage(latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Location is not available. Please try again.")),
                    );
                  }
                }),
                _OrderOption(title: 'Completed Orders', icon: Icons.hourglass_top, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  final String title;
  final int value;

  const _OrderInfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _OrderOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _OrderOption({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}