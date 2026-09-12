import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Otherspages/DoctorPageforSelectedDisease.dart';
import 'package:O2ISkinSense/Otherspages/DoctorProfilePage.dart';
import 'package:O2ISkinSense/Otherspages/AppointmentSlotsAndPayment.dart';
import 'dart:convert';

class DermatologyDoctorSearch extends StatefulWidget {
  @override
  _DermatologyDoctorSearchState createState() => _DermatologyDoctorSearchState();
}

class _DermatologyDoctorSearchState extends State<DermatologyDoctorSearch> {
  List<dynamic> _allDoctors = [];
  List<dynamic> _filteredDoctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  TextEditingController _searchController = TextEditingController();
  
  // Dermatology-focused specialties
  final List<String> _specialties = [
    'All',
    'Dermatology',
    'Cosmetic Dermatology', 
    'Pediatric Dermatology',
    'Dermatopathology',
    'Mohs Surgery',
    'Aesthetic Medicine',
    'Hair Restoration'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllDoctors();
  }

  Future<void> _fetchAllDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/doctors/get-all-doctors'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> doctors = json.decode(response.body);
        setState(() {
          _allDoctors = doctors;
          _filteredDoctors = doctors;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading doctors: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        final doctorName = doctor['name']?.toLowerCase() ?? '';
        final specialization = doctor['special']?.join(', ')?.toLowerCase() ?? '';
        final searchLower = _searchQuery.toLowerCase();
        
        final matchesSearch = doctorName.contains(searchLower) || 
                             specialization.contains(searchLower);
        
        final matchesSpecialty = _selectedSpecialty == 'All' ||
            (doctor['special']?.any((spec) => spec.toLowerCase().contains(_selectedSpecialty.toLowerCase())) ?? false);
        
        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildDermatologyHeader(),
            _buildSearchSection(),
            _buildSpecialtyTabs(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredDoctors.isEmpty
                      ? _buildEmptyState()
                      : _buildDoctorsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDermatologyHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B73FF), // Dermatology purple
            Color(0xFF9575FF), // Lighter purple
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6B73FF).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Dermatologist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Skin, Hair & Nail Specialists',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.spa_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _filterDoctors();
              },
              decoration: InputDecoration(
                hintText: 'Search skin specialists...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6B73FF)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterDoctors();
                        },
                        child: Icon(Icons.clear, color: Colors.grey.shade400),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF6B73FF), size: 18),
              SizedBox(width: 4),
              Text(
                'Near you',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_filteredDoctors.length} specialists found',
                  style: TextStyle(
                    color: Color(0xFF6B73FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSpecialtyTabs() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = _selectedSpecialty == specialty;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSpecialty = specialty;
              });
              _filterDoctors();
            },
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Color(0xFF6B73FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ] : [],
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF6B73FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B73FF)),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Finding skin specialists...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color(0xFF6B73FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.search_off,
              size: 50,
              color: Color(0xFF6B73FF),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No dermatologists found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or specialty filter',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedSpecialty = 'All';
                _searchController.clear();
              });
              _filterDoctors();
            },
            icon: Icon(Icons.refresh),
            label: Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6B73FF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return RefreshIndicator(
      onRefresh: _fetchAllDoctors,
      color: Color(0xFF6B73FF),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredDoctors.length,
        itemBuilder: (context, index) {
          return _buildDermatologistCard(_filteredDoctors[index]);
        },
      ),
    );
  }
  Widget _buildDermatologistCard(Map<String, dynamic> doctor) {
    final doctorName = doctor['name'] ?? 'Unknown Doctor';
    final specialties = doctor['special'] is List ? 
        (doctor['special'] as List).join(', ') : 'Dermatology';
    final experience = doctor['experience'] ?? 'Not specified';
    final rating = doctor['rating']?.toDouble() ?? 4.5;
    final hospital = doctor['hospital']?['name'] ?? 'Skin Care Clinic';
    final onlineConsultation = doctor['onlineConsultation'] ?? 300;
    final offlineConsultation = doctor['offlineConsultation'] ?? 500;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileDisplayPage(),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Doctor Avatar with dermatology theme
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. $doctorName',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          specialties,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B73FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.orange, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.work_outline, color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '$experience exp',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Hospital info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital, color: Colors.grey.shade600, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hospital,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Consultation options and book button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF6B73FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.video_call, color: Color(0xFF6B73FF), size: 20),
                          SizedBox(height: 4),
                          Text(
                            'Video Call',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B73FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹$onlineConsultation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B73FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital, color: Colors.green, size: 20),
                          SizedBox(height: 4),
                          Text(
                            'Clinic Visit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹$offlineConsultation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentPage(doctor: doctor),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}