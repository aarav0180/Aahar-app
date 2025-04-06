import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_solution/screens/donation.dart';
import '../screens/homescreen.dart';
import '../utils/app_colors.dart';


class BottomNavBar extends StatefulWidget {
  final String email;
  final int? selectedIndex;
  const BottomNavBar({super.key, required this.email, this.selectedIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex = widget.selectedIndex ?? 0;
  late List<Widget> _screens;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _screens = [
      HomeScreen(email:  widget.email),
      const DonationsScreen(),
      HomeScreen(email:  widget.email),
      HomeScreen(email:  widget.email),
    ];
  }

  // List of screens


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: Colors.white,
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black54,
            activeColor: Colors.white,
            tabBackgroundColor: AppColors.primary,
            gap: 8,
            padding: const EdgeInsets.all(16),
            iconSize: 24,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.volunteer_activism,
                text: 'Donation',
              ),
              GButton(
                icon: Icons.notifications,
                text: 'Notification',
              ),
              GButton(
                icon: Icons.card_giftcard_rounded,
                text: 'Rewards',
                haptic: true,
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
