import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'dart:math';

class DoctorProfileDisplayPage extends StatefulWidget {
  @override
  _DoctorProfileDisplayPageState createState() =>
      _DoctorProfileDisplayPageState();
}

class _DoctorProfileDisplayPageState extends State<DoctorProfileDisplayPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _doctorProfile;

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/doctors/get-doctor-profile'),
        headers: {
          'Auth': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _doctorProfile = responseData;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? _buildLoadingState()
          : _doctorProfile == null
              ? _buildErrorState()
              : _buildDoctorProfile(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading doctor profile...',
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: errorColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchDoctorProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorProfile() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Header with Profile
            _buildModernHeader(),
            
            // Profile Info Cards
            _buildProfileInfo(),
            
            // Action Buttons
            _buildActionButtons(),
          ],
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
          // Top navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Text(
                'Doctor Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          // Doctor Avatar and Basic Info
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
                  child: _doctorProfile!['imageLink'] != null
                      ? CircleAvatar(
                          radius: 56,
                          backgroundImage: NetworkImage(
                            '${ApiService.baseUrl}${_doctorProfile!['imageLink']}',
                          ),
                        )
                      : CircleAvatar(
                          radius: 56,
                          backgroundColor: backgroundColor,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: textSecondary,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'Dr. ${_doctorProfile!['name'] ?? 'Unknown'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _doctorProfile!['specialization'] ?? 'Dermatologist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              if (_doctorProfile!['hospitalName'] != null) ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_hospital,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _doctorProfile!['hospitalName'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Experience and Rating Row
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Experience',
                  '${_doctorProfile!['experienceInYears'] ?? 'N/A'} Years',
                  Icons.work_outline,
                  primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Rating',
                  '${_doctorProfile!['rating']?.toString() ?? '5.0'} ⭐',
                  Icons.star_outline,
                  warningColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Consultation Details
          _buildConsultationCard(),
          
          SizedBox(height: 16),
          
          // Contact Information
          if (_doctorProfile!['mobileNumber'] != null || _doctorProfile!['email'] != null)
            _buildContactCard(),
          
          SizedBox(height: 16),
          
          // Hospital Address
          if (_doctorProfile!['hospitalAddress'] != null)
            _buildAddressCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
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
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard() {
    final onlineConsultation = _doctorProfile!['onlineConsultation'];
    final offlineConsultation = _doctorProfile!['offlineConsultation'];
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: successColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Consultation Fees',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          if (onlineConsultation != null) ...[
            _buildConsultationRow(
              'Online Consultation',
              '₹${onlineConsultation['charges']}',
              Icons.video_call,
              primaryColor,
            ),
            SizedBox(height: 12),
          ],
          
          if (offlineConsultation != null) ...[
            _buildConsultationRow(
              'Offline Consultation',
              '₹${offlineConsultation['charges']}',
              Icons.person,
              accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsultationRow(String type, String fee, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            type,
            style: TextStyle(
              fontSize: 16,
              color: textPrimary,
            ),
          ),
        ),
        Text(
          fee,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.contact_phone,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          if (_doctorProfile!['mobileNumber'] != null) ...[
            _buildContactRow(
              Icons.phone,
              _doctorProfile!['mobileNumber'],
              primaryColor,
            ),
            SizedBox(height: 12),
          ],
          
          if (_doctorProfile!['email'] != null)
            _buildContactRow(
              Icons.email,
              _doctorProfile!['email'],
              accentColor,
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: warningColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Hospital Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Text(
            _doctorProfile!['hospitalAddress'],
            style: TextStyle(
              fontSize: 16,
              color: textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Add edit functionality
              },
              icon: Icon(Icons.edit, size: 20),
              label: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 30),
        ],
      ),
    );
  }
}