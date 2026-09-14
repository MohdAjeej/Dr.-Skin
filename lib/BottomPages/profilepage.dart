import 'package:O2ISkinSense/Otherspages/DoctorProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Signup/LoginPage.dart';
import 'package:O2ISkinSense/Otherspages/Contactus.dart';
import 'package:O2ISkinSense/Otherspages/EditProfilePage.dart';
import 'package:O2ISkinSense/Otherspages/DiseaseHistoryPage.dart';
import 'package:O2ISkinSense/Otherspages/NotificationPage.dart';
import 'package:O2ISkinSense/Otherspages/PaymentHIstory.dart';
import 'package:O2ISkinSense/Otherspages/Privacypolice.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
    fetchProfile();
    _loadUserProfileStatus();
  }

  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String _userRole = "ROLE_NORMAL";

  Future<void> fetchProfile() async {
    try {
      // CRITICAL: Load correct profile based on user role
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString("roles") ?? "ROLE_NORMAL";
      
      debugPrint('Fetching profile for role: $_userRole');
      
      if (_userRole == "ROLE_DOCTOR") {
        // Load doctor profile
        final data = await ApiService().getDoctorProfileData();
        setState(() {
          profileData = data;
          isLoading = false;
        });
      } else {
        // Load patient profile
        final data = await ApiService().getPatientProfile();
        setState(() {
          profileData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching profile: $e');
    }
  }

  String Userusername = "";
  String customerid = "";
  bool isDoctor = false;
  
  Future<void> _loadUserProfileStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwtToken");
    String? username = prefs.getString("username");
    String? userId = prefs.getString("userId");

    isDoctor = prefs.getString("roles") == "ROLE_DOCTOR";
    setState(() {
      Userusername = username ?? "Guest";
      customerid = userId?.toString() ?? "";
    });
    
    if (token != null) {
      ApiService apiService = ApiService();
      final a = await apiService.getUserProfile(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // Modern Header with Profile Info
                _buildModernHeader(),
                
                // Profile Actions Section
                _buildProfileActions(),
                
                // Logout Section
                _buildLogoutSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Top Row with Title and Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          // Profile Avatar and Info
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: AssetImage('assets/person.jpg'),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Column(
                      children: [
                        Text(
                          profileData != null
                              ? _userRole == "ROLE_DOCTOR"
                                  ? "Dr. ${profileData!['name'] ?? ''}"
                                  : "${profileData!['firstName'] ?? ''} ${profileData!['lastName'] ?? ''}"
                              : "Guest User",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _userRole == "ROLE_DOCTOR"
                              ? (profileData?['specialization'] ?? 'Dermatologist')
                              : Userusername,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Contact Info Cards
                        if (profileData != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildContactInfoCard(
                                Icons.email_outlined,
                                profileData!['email'] ?? '',
                              ),
                              if (_userRole != "ROLE_DOCTOR")
                                _buildContactInfoCard(
                                  Icons.phone_outlined,
                                  profileData!['mobile'] ?? '',
                                ),
                              if (_userRole == "ROLE_DOCTOR")
                                _buildContactInfoCard(
                                  Icons.medical_services,
                                  '${profileData!['experienceInYears'] ?? 0} yrs',
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            text.length > 15 ? '${text.substring(0, 15)}...' : text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          if (isDoctor) ...[
            _buildActionCard(
              icon: Icons.medical_services,
              title: 'Doctor Profile',
              subtitle: 'Manage your medical practice',
              color: primaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DoctorProfileDisplayPage()),
              ),
            ),
            SizedBox(height: 16),
          ],
          
          _buildActionCard(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            color: successColor,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
              // Reload profile if edited
              if (result == true) {
                fetchProfile();
              }
            },
          ),
          
          SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.history,
            title: 'Diagnosis History',
            subtitle: 'View your past skin analysis',
            color: warningColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiseaseHistoryPage()),
            ),
          ),
          
          SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.payment,
            title: 'Payment History',
            subtitle: 'Track your consultation payments',
            color: primaryColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentHistoryScreen()),
            ),
          ),
          
          SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy guidelines',
            color: textSecondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
            ),
          ),
          
          SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.support_agent,
            title: 'Contact Us',
            subtitle: 'Get help and support',
            color: accentColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactUsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          // Logout Button
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor.withOpacity(0.1),
                foregroundColor: errorColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: errorColor.withOpacity(0.3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: _performLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // CRITICAL: Clear ALL session data to prevent cross-account data leakage
      await prefs.remove("jwtToken");
      await prefs.remove("refreshToken");
      await prefs.remove("username");
      await prefs.remove("userId");
      await prefs.remove("roles");
      
      // Clear any cached profile data
      await prefs.clear();
      
      debugPrint('Logout: All session data cleared');
      
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }
}