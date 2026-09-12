import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Otherspages/AppointmentSlotsAndPayment.dart';

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _allDoctors = [];
  List<dynamic> _filteredDoctors = [];

  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  final TextEditingController _searchController =
      TextEditingController();

  final List<String> _specialties = [
    'All',
    'General Dermatology',
    'Cosmetic Dermatology',
    'Pediatric Dermatology',
    'Dermatopathology',
    'Mohs Surgery',
    'Hair Restoration',
    'Laser Dermatology',
    'Aesthetic Dermatology',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllDoctors();
  }

  Future<void> _fetchAllDoctors() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/doctors/get-all-doctors',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List<dynamic> doctors =
            decoded is List ? decoded : [];

        setState(() {
          _allDoctors = doctors;
          _filteredDoctors = doctors;
          _isLoading = false;
        });

        _filterDoctors();
      } else {
        throw Exception(
          'Failed to load doctors: ${response.statusCode}',
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
    final searchLower =
        _searchQuery.trim().toLowerCase();

    final selectedLower =
        _selectedSpecialty.toLowerCase();

    final filtered = _allDoctors.where((doctor) {
      if (doctor is! Map) return false;

      final doctorName =
          doctor['name']?.toString().toLowerCase() ?? '';

      final specialValue = doctor['special'];

      final List<String> specialties = [];

      if (specialValue is List) {
        for (final item in specialValue) {
          specialties.add(item.toString());
        }
      } else if (specialValue != null) {
        specialties.add(specialValue.toString());
      }

      final specialization =
          specialties.join(', ').toLowerCase();

      final matchesSearch =
          searchLower.isEmpty ||
          doctorName.contains(searchLower) ||
          specialization.contains(searchLower);

      final matchesSpecialty =
          _selectedSpecialty == 'All' ||
          specialties.any(
            (spec) => spec
                .toLowerCase()
                .contains(selectedLower),
          );

      return matchesSearch && matchesSpecialty;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredDoctors = filtered;
    });
  }

  void _openDoctorDetails(
    Map<String, dynamic> doctor,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsPage(
          doctor: doctor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
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
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                hintText:
                    'Search doctors by name or specialization...',
                prefixIcon: Icon(
                  Icons.search,
                  color: textSecondary,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Showing doctors near you',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredDoctors.length} doctors found',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];

          final isSelected =
              _selectedSpecialty == specialty;

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
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
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
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(
              primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading doctors...',
            style: TextStyle(
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedSpecialty = 'All';
                  _searchController.clear();
                });

                _filterDoctors();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    return RefreshIndicator(
      onRefresh: _fetchAllDoctors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _filteredDoctors[index];

          if (doctor is! Map) {
            return const SizedBox.shrink();
          }

          return _buildDoctorCard(
            Map<String, dynamic>.from(doctor),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(
    Map<String, dynamic> doctor,
  ) {
    final doctorName =
        doctor['name']?.toString() ??
            'Unknown Doctor';

    final specialties =
        _getSpecialties(doctor);

    final experience =
        doctor['experience']?.toString() ??
            'Not specified';

    final rating = _getRating(doctor);

    final hospital = _getHospitalName(doctor);

    final onlineConsultation =
        _getConsultationCharges(
      doctor['onlineConsultation'],
    );

    final offlineConsultation =
        _getConsultationCharges(
      doctor['offlineConsultation'],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: InkWell(
        onTap: () => _openDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          primaryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // FIXED:
                        // specialties is List<String>,
                        // so convert it to String.
                        Text(
                          specialties.join(', '),
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: warningColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    textSecondary,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.work_outline,
                              color: textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$experience exp',
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      textSecondary,
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
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          successColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 12,
                        color: successColor,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    color: textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      hospital,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _consultationPrice(
                      title:
                          'Video Consultation',
                      price:
                          onlineConsultation,
                      icon:
                          Icons.video_call_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _consultationPrice(
                      title: 'Clinic Visit',
                      price:
                          offlineConsultation,
                      icon:
                          Icons.local_hospital_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () =>
                        _openDoctorDetails(
                      doctor,
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryColor,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consultationPrice({
    required String title,
    required String price,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '₹$price',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  List<String> _getSpecialties(
    Map<String, dynamic> doctor,
  ) {
    final value = doctor['special'];

    if (value is List) {
      return value
          .map((e) => e.toString())
          .toList();
    }

    if (value != null) {
      return [value.toString()];
    }

    return ['General Practice'];
  }

  String _getHospitalName(
    Map<String, dynamic> doctor,
  ) {
    final hospital = doctor['hospital'];

    if (hospital is Map) {
      return hospital['name']?.toString() ??
          'Unknown Hospital';
    }

    if (hospital != null) {
      return hospital.toString();
    }

    return 'Unknown Hospital';
  }

  double _getRating(
    Map<String, dynamic> doctor,
  ) {
    final value = doctor['rating'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        4.0;
  }

  String _getConsultationCharges(
    dynamic consultation,
  ) {
    if (consultation is Map) {
      final charges = consultation['charges'];

      if (charges is num) {
        return charges.toString();
      }

      return charges?.toString() ?? '0';
    }

    if (consultation is num) {
      return consultation.toString();
    }

    return consultation?.toString() ?? '0';
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select a specialty from the tabs above.',
                style: TextStyle(
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,
                    foregroundColor:
                        Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class DoctorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailsPage({
    super.key,
    required this.doctor,
  });

  List<String> _getSpecialties() {
    final value = doctor['special'];

    if (value is List) {
      return value
          .map((e) => e.toString())
          .toList();
    }

    if (value != null) {
      return [value.toString()];
    }

    return ['General Practice'];
  }

  String _getHospital() {
    final hospital = doctor['hospital'];

    if (hospital is Map) {
      return hospital['name']?.toString() ??
          'Hospital not specified';
    }

    return hospital?.toString() ??
        'Hospital not specified';
  }

  String _getCharges(
    dynamic consultation,
  ) {
    if (consultation is Map) {
      return consultation['charges']
              ?.toString() ??
          '0';
    }

    return consultation?.toString() ?? '0';
  }

  void _openAppointment(
    BuildContext context,
    String type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentPage(
          doctor: doctor,
          appointmentType: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        doctor['name']?.toString() ??
            'Doctor';

    final experience =
        doctor['experience']?.toString() ??
            'Not specified';

    final rating =
        doctor['rating']?.toString() ??
            '4.0';

    final specialties =
        _getSpecialties();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Doctor Details',
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor:
                        primaryColor
                            .withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    specialties.join(', '),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        rating,
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.work_outline,
                        color: textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$experience exp',
                        style: TextStyle(
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _infoCard(
              title: 'Hospital',
              value: _getHospital(),
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 12),
            _infoCard(
              title: 'Specialization',
              value:
                  specialties.join(', '),
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Consultation Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _consultationButton(
              context: context,
              title: 'Video Consultation',
              subtitle:
                  'Consult with the doctor online',
              price: _getCharges(
                doctor['onlineConsultation'],
              ),
              icon:
                  Icons.video_call_outlined,
              onPressed: () =>
                  _openAppointment(
                context,
                'VIDEO',
              ),
            ),
            const SizedBox(height: 12),
            _consultationButton(
              context: context,
              title: 'Clinic Visit',
              subtitle:
                  'Visit the doctor in person',
              price: _getCharges(
                doctor['offlineConsultation'],
              ),
              icon:
                  Icons.local_hospital_outlined,
              onPressed: () =>
                  _openAppointment(
                context,
                'IN_PERSON',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  primaryColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _consultationButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  primaryColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '₹$price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  primaryColor,
              foregroundColor:
                  Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}