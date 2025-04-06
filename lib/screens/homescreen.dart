import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_solution/screens/donation_form.dart';
import 'package:google_solution/widgets/snack_bar.dart';
import '../utils/app_colors.dart';
import '../utils/functions/locations.dart';


class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position? position = await checkAndUpdateLocation(context);
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'AAHAR',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.gift, size: 30,),
                  onPressed: () {},
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Center(
                      child: Text(
                        'Rewards 🎁',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spotlight Card
              _buildSpotlightCard(size),

              const SizedBox(height: 20),

              // // Donation Balance
              // _buildDonationBalanceCard(),

              const SizedBox(height: 20),

              // Food Donor Section
              const Text(
                'Become a Food Donor Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildDonorOptions(context),

              const SizedBox(height: 20),

              // Latest Campaigns
              const Text(
                'Latest Campaigns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildCampaignList(),
            ],
          ),
        ),
      ),
    );
  }

  // Spotlight Card
  Widget _buildSpotlightCard(Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://plus.unsplash.com/premium_photo-1682092585257-58d1c813d9b4?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',  // Replace with actual image
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 12),
          const Text(
            'Help families in village by donating food',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_currentPosition != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DonationScreen(latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude),
                  ),
                );
              } else {
                showCustomSnackBar(context, "Fetching location, please wait...", true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Donate Now'),
          ),
          const SizedBox(height: 8),
          const Text(
            'More than 200 Kgs of food donated.',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.25,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  // // Donation Balance Card
  // Widget _buildDonationBalanceCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColors.background,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 6,
  //           spreadRadius: 2,
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         const Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               ,
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             SizedBox(height: 4),
  //             Text(
  //               '\$215.00',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //           ],
  //         ),
  //         ElevatedButton.icon(
  //           onPressed: () {},
  //           icon: const Icon(Icons.add, color: Colors.black),
  //           label: const Text('Top up Balance', style: TextStyle(color: Colors.black)),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: AppColors.primary,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Donor Options Section
  Widget _buildDonorOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _donorOptionCard(
          'Donate Food',
          Icons.food_bank,
              () {
            if (_currentPosition != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DonationScreen(latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude),
                ),
              );
            } else {
              showCustomSnackBar(context, "Fetching location, please wait...", true);
            }
          },
        ),
        //_donorOptionCard('Request Food', Icons.local_dining, (){}),
        //_donorOptionCard('NGO Agent', Icons.groups, (){}),
      ],
    );
  }


  Widget _donorOptionCard(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.2),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(icon, size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Latest Campaigns
  Widget _buildCampaignList() {
    return Column(
      children: [
        _campaignCard(),
        const SizedBox(height: 12),
        _campaignCard(),
      ],
    );
  }

  Widget _campaignCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              'https://plus.unsplash.com/premium_photo-1682092585257-58d1c813d9b4?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Placeholder image
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Your Food, Share Your Love',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Shared: 50Kgs',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
