import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:O2ISkinSense/BottomPages/CameraIconPage.dart';
import 'package:O2ISkinSense/BottomPages/chatPage.dart';
import 'package:O2ISkinSense/BottomPages/mainhomepage.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/BottomPages/searchCompPage.dart';
import 'package:O2ISkinSense/BottomPages/profilepage.dart';
import 'package:typicons_flutter/typicons_flutter.dart'; // Ensure this package is added for Typicons

//contains bottom navigators
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Track the selected index

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Function to change the tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Pages for the bottom navigation
  final List<Widget> _pages = [
    MainHomePage(),
    ArticlePage(),
    TakeOrUploadScreen(),
    Chats(),
    MyProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: GNav(
                curve: Curves.easeOutExpo,
                rippleColor: Colors.grey.shade300,
                hoverColor: Colors.grey.shade100,
                haptic: true,
                tabBorderRadius: 20,
                gap: 5,
                activeColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 200),
                tabBackgroundColor: primaryColor,
                textStyle: TextStyle(
                  color: Colors.white,
                ),
                tabs: const [
                  GButton(
                    iconSize: 28,
                    icon: Icons.home,
                  ),
                  GButton(
                    icon: Icons.search,
                  ),
                  GButton(
                    iconSize: 28,
                    icon: Icons.camera, // Changed to camera icon
                  ),
                  GButton(
                    iconSize: 28,
                    icon: Icons.chat,
                  ),
                  GButton(
                    iconSize: 28,
                    icon: Typicons.user,
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
