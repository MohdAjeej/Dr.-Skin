import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Otherspages/DoctorPageforSelectedDisease.dart';
import 'package:O2ISkinSense/Otherspages/DoctorProfilePage.dart';

class DermatologyDoctorSearch extends StatefulWidget {
  const DermatologyDoctorSearch({Key? key}) : super(key: key);

  @override
  State<DermatologyDoctorSearch> createState() =>
      _DermatologyDoctorSearchState();
}

class _DermatologyDoctorSearchState extends State<DermatologyDoctorSearch> {
  List<dynamic> _allDoctors = [];
  List<dynamic> _filteredDoctors = [];

  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  final TextEditingController _searchController = TextEditingController();

  // Dermatology-focused specialties
  final List<String> _specialties = [
    'All',
    'Dermatology',
    'Cosmetic Dermatology',
    'Pediatric Dermatology',
    'Dermatopathology',
    'Mohs Surgery',
    'Aesthetic Medicine',
    'Hair Restoration',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllDoctors();
  }

  Future<void> _fetchAllDoctors() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/doctors/get-all-doctors',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> doctors = [];

        if (decodedData is List) {
          doctors = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData['doctors'] is List) {
            doctors = decodedData['doctors'];
          } else if (decodedData['data'] is List) {
            doctors = decodedData['data'];
          }
        }

        if (!mounted) return;

        setState(() {
          _allDoctors = doctors;
          _filteredDoctors = doctors;
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load doctors. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _allDoctors = [];
        _filteredDoctors = [];
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
    final String searchLower = _searchQuery.trim().toLowerCase();

    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        if (doctor is! Map) {
          return false;
        }

        final String doctorName =
            (doctor['name'] ?? '').toString().toLowerCase();

        final dynamic specialData = doctor['special'];

        String specialization = '';

        if (specialData is List) {
          specialization = specialData
              .map((item) => item.toString())
              .join(', ')
              .toLowerCase();
        } else {
          specialization =
              (specialData ?? doctor['specialization'] ?? '')
                  .toString()
                  .toLowerCase();
        }

        final bool matchesSearch =
            searchLower.isEmpty ||
            doctorName.contains(searchLower) ||
            specialization.contains(searchLower);

        bool matchesSpecialty = true;

        if (_selectedSpecialty != 'All') {
          if (specialData is List) {
            matchesSpecialty = specialData.any(
              (spec) => spec
                  .toString()
                  .toLowerCase()
                  .contains(_selectedSpecialty.toLowerCase()),
            );
          } else {
            final String singleSpecialty =
                (specialData ?? doctor['specialization'] ?? '')
                    .toString()
                    .toLowerCase();

            matchesSpecialty = singleSpecialty.contains(
              _selectedSpecialty.toLowerCase(),
            );
          }
        }

        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B73FF),
            Color(0xFF9575FF),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
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
      padding: const EdgeInsets.all(20),
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
                  offset: const Offset(0, 5),
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
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6B73FF),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });

                          _filterDoctors();
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF6B73FF),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Near you',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B73FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_filteredDoctors.length} specialists found',
                  style: const TextStyle(
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final String specialty = _specialties[index];
          final bool isSelected = _selectedSpecialty == specialty;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSpecialty = specialty;
              });

              _filterDoctors();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF6B73FF),
                          Color(0xFF9575FF),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6B73FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade600,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6B73FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF6B73FF),
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF6B73FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.search_off,
                size: 50,
                color: Color(0xFF6B73FF),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No dermatologists found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or specialty filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedSpecialty = 'All';
                  _searchController.clear();
                });

                _filterDoctors();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B73FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    return RefreshIndicator(
      onRefresh: _fetchAllDoctors,
      color: const Color(0xFF6B73FF),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _filteredDoctors[index];

          if (doctor is! Map) {
            return const SizedBox.shrink();
          }

          return _buildDermatologistCard(
            Map<String, dynamic>.from(doctor),
          );
        },
      ),
    );
  }

  Widget _buildDermatologistCard(Map<String, dynamic> doctor) {
    final String doctorName =
        (doctor['name'] ?? 'Unknown Doctor').toString();

    final dynamic specialData = doctor['special'];

    final String specialties = specialData is List
        ? specialData.map((item) => item.toString()).join(', ')
        : (doctor['specialization'] ?? 'Dermatology').toString();

    final String experience =
        (doctor['experience'] ?? 'Not specified').toString();

    final double rating = _getDoubleValue(
      doctor['rating'] ?? doctor['ratings'],
      fallback: 4.5,
    );

    final Map<String, dynamic>? hospital =
        doctor['hospital'] is Map
            ? Map<String, dynamic>.from(doctor['hospital'])
            : null;

    final String hospitalName =
        (hospital?['name'] ?? 'Skin Care Clinic').toString();

    final dynamic onlineData = doctor['onlineConsultation'];

    final dynamic offlineData = doctor['offlineConsultation'];

    final String onlineConsultation = _getConsultationPrice(
      onlineData,
      fallback: doctor['onlineConsultation'] ?? 300,
    );

    final String offlineConsultation = _getConsultationPrice(
      offlineData,
      fallback: doctor['offlineConsultation'] ?? 500,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDoctorPage(doctor),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Doctor Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B73FF),
                          Color(0xFF9575FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. $doctorName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialties.isEmpty
                              ? 'Dermatology'
                              : specialties,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B73FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.work_outline,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$experience exp',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
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
              const SizedBox(height: 16),

              // Hospital information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_hospital,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hospitalName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Consultation options
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_call,
                            color: Color(0xFF6B73FF),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Video Call',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B73FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹$onlineConsultation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B73FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Clinic Visit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹$offlineConsultation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B73FF),
                          Color(0xFF9575FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => _openDoctorPage(doctor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
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

  // ------------------------------------------------------------
  // Doctor navigation
  // ------------------------------------------------------------

  void _openDoctorPage(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorProfileDisplayPage(),
      ),
    );
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  double _getDoubleValue(
    dynamic value, {
    double fallback = 0.0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? fallback;
  }

  String _getConsultationPrice(
    dynamic value, {
    dynamic fallback = 300,
  }) {
    dynamic price = value;

    if (value is Map) {
      price = value['charges'] ??
          value['charge'] ??
          value['price'] ??
          value['amount'];
    }

    if (price == null) {
      price = fallback;
    }

    if (price is num) {
      if (price % 1 == 0) {
        return price.toInt().toString();
      }

      return price.toString();
    }

    return price.toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}