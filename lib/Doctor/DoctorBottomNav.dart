import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Doctor/DoctorDashboard.dart';
import 'package:O2ISkinSense/Doctor/DoctorAppointments.dart';
import 'package:O2ISkinSense/Doctor/DoctorAvailability.dart';
import 'package:O2ISkinSense/BottomPages/profilepage.dart';
import 'package:O2ISkinSense/BottomPages/chatPage.dart';

class DoctorBottomNav extends StatefulWidget {
  @override
  _DoctorBottomNavState createState() => _DoctorBottomNavState();
}

class _DoctorBottomNavState extends State<DoctorBottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DoctorDashboard(),
    DoctorAppointments(),
    DoctorAvailability(),
    Chats(), // Reuse chat functionality
    MyProfile(), // Reuse profile with doctor-specific options
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: GNav(
                curve: Curves.easeOutExpo,
                rippleColor: Colors.grey.shade300,
                hoverColor: Colors.grey.shade100,
                haptic: true,
                tabBorderRadius: 20,
                gap: 5,
                activeColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                duration: const Duration(milliseconds: 200),
                tabBackgroundColor: primaryColor,
                textStyle: TextStyle(color: Colors.white),
                tabs: const [
                  GButton(
                    iconSize: 24,
                    icon: Icons.dashboard,
                    text: 'Dashboard',
                  ),
                  GButton(
                    iconSize: 24,
                    icon: Icons.calendar_today,
                    text: 'Appointments',
                  ),
                  GButton(
                    iconSize: 24,
                    icon: Icons.schedule,
                    text: 'Availability',
                  ),
                  GButton(
                    iconSize: 24,
                    icon: Icons.chat,
                    text: 'Chat',
                  ),
                  GButton(
                    iconSize: 24,
                    icon: Icons.person,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}