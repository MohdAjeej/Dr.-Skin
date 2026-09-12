import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/app_theme.dart';
import 'package:O2ISkinSense/Otherspages/NotificationPage.dart';
import 'package:O2ISkinSense/Doctor/DoctorAppointments.dart';
import 'package:O2ISkinSense/Doctor/VideoConsultationRoom.dart';
import 'package:O2ISkinSense/Doctor/DoctorAvailability.dart';
import 'package:O2ISkinSense/Otherspages/DoctorProfilePage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Professional Doctor Dashboard
/// Shows today's appointments, stats, and quick actions
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  Map<String, dynamic>? _doctorProfile;
  List<dynamic> _todayAppointments = [];
  Map<String, int> _stats = {
    'today': 0,
    'upcoming': 0,
    'completed': 0,
    'total': 0,
  };
  bool _isLoading = true;
  String _doctorName = "Doctor";
  int _currentDoctorId = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);
    
    try {
      await _fetchDoctorProfile();
      await _fetchDashboardStats();
      await _fetchTodayAppointments();
    } catch (e) {
      debugPrint("Error loading doctor data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");
      final userId = prefs.getString("userId");
      
      if (userId != null) {
        _currentDoctorId = int.parse(userId);
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/doctors/get-doctor-profile'),
        headers: {'Auth': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _doctorProfile = data;
            _doctorName = data['name'] ?? 'Doctor';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching doctor profile: $e");
    }
  }

  Future<void> _fetchDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/appointments/doctor/$_currentDoctorId'),
        headers: {'Auth': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointments = json.decode(response.body);
        final now = DateTime.now();
        final today = DateFormat('yyyy-MM-dd').format(now);

        if (mounted) {
          setState(() {
            _stats['today'] = appointments.where((apt) => 
              apt['appointmentDate'] == today && 
              (apt['status'] == 'CONFIRMED' || apt['status'] == 'SCHEDULED')
            ).length;
            
            _stats['upcoming'] = appointments.where((apt) {
              try {
                final aptDate = DateTime.parse(apt['appointmentDate'] ?? '');
                return aptDate.isAfter(now) && 
                       (apt['status'] == 'CONFIRMED' || apt['status'] == 'SCHEDULED');
              } catch (e) {
                return false;
              }
            }).length;
            
            _stats['completed'] = appointments.where((apt) => 
              apt['status'] == 'COMPLETED'
            ).length;
            
            _stats['total'] = appointments.length;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    }
  }

  Future<void> _fetchTodayAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/appointments/doctor/$_currentDoctorId'),
        headers: {'Auth': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> allAppointments = json.decode(response.body);
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        
        if (mounted) {
          setState(() {
            _todayAppointments = allAppointments.where((apt) => 
              apt['appointmentDate'] == today
            ).toList();
            
            // Sort by time
            _todayAppointments.sort((a, b) {
              final timeA = a['slotTime'] ?? '';
              final timeB = b['slotTime'] ?? '';
              return timeA.compareTo(timeB);
            });
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching today's appointments: $e");
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading 
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadDoctorData,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildStatsCards(),
                    _buildTodayQueue(),
                    _buildQuickActions(),
                    const SizedBox(height: AppTheme.spacing24),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXXLarge),
          bottomRight: Radius.circular(AppTheme.radiusXXLarge),
        ),
        boxShadow: AppTheme.shadowPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Doctor Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.textWhite.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppTheme.textWhite,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()},',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Dr. $_doctorName',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.textWhite,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.textWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textWhite,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textWhite.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            'Dermatology Practice Dashboard',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textWhite.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spacing12,
        mainAxisSpacing: AppTheme.spacing12,
        childAspectRatio: 1.4,
        children: [
          _buildStatCard(
            'Today',
            '${_stats['today']}',
            Icons.today,
            AppTheme.primaryColor,
          ),
          _buildStatCard(
            'Upcoming',
            '${_stats['upcoming']}',
            Icons.schedule,
            AppTheme.healthGreen,
          ),
          _buildStatCard(
            'Completed',
            '${_stats['completed']}',
            Icons.check_circle,
            AppTheme.statusCompleted,
          ),
          _buildStatCard(
            'Total',
            '${_stats['total']}',
            Icons.people,
            AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.headingLarge.copyWith(fontSize: 28),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayQueue() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Appointments',
                style: AppTheme.headingMedium,
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorAppointments(),
                  ),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          _todayAppointments.isEmpty
            ? _buildEmptyQueue()
            : Column(
                children: _todayAppointments.take(4).map((appointment) => 
                  _buildAppointmentTile(appointment)
                ).toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'No appointments scheduled for today',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(Map<String, dynamic> appointment) {
    final isVideo = appointment['appointmentType'] == 'VIDEO';
    final time = appointment['slotTime'] ?? 'Time not set';
    final patientName = appointment['patientName'] ?? 'Unknown Patient';
    final status = appointment['status'] ?? 'SCHEDULED';
    final concern = appointment['concern'] as String?;
    final appointmentId = appointment['id'] as int?;
    
    final statusColor = AppTheme.getStatusColor(status);
    final statusText = AppTheme.getStatusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: isVideo 
                    ? AppTheme.primaryColor.withOpacity(0.1) 
                    : AppTheme.healthGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  isVideo ? Icons.videocam : Icons.person,
                  color: isVideo ? AppTheme.primaryColor : AppTheme.healthGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: AppTheme.titleMedium,
                    ),
                    Text(
                      patientName,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (concern != null && concern.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        concern,
                        style: AppTheme.captionLarge.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  statusText,
                  style: AppTheme.captionLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (isVideo && status == 'CONFIRMED' && appointmentId != null) ...[
            const SizedBox(height: AppTheme.spacing12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startVideoCall(appointment),
                icon: const Icon(Icons.videocam, size: 18),
                label: const Text('Start Consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.healthGreen,
                  foregroundColor: AppTheme.textWhite,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: AppTheme.spacing16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.spacing12,
            mainAxisSpacing: AppTheme.spacing12,
            childAspectRatio: 2.5,
            children: [
              _buildActionButton(
                'Availability',
                Icons.schedule,
                AppTheme.primaryColor,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorAvailability(),
                  ),
                ),
              ),
              _buildActionButton(
                'My Profile',
                Icons.person,
                AppTheme.secondaryColor,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorProfileDisplayPage(),
                  ),
                ),
              ),
              _buildActionButton(
                'All Appointments',
                Icons.calendar_today,
                AppTheme.healthGreen,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorAppointments(),
                  ),
                ),
              ),
              _buildActionButton(
                'Reports',
                Icons.assessment,
                AppTheme.statusCompleted,
                () => _showComingSoon(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: AppTheme.cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppTheme.spacing8),
            Flexible(
              child: Text(
                title,
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startVideoCall(Map<String, dynamic> appointment) {
    final appointmentId = appointment['id'] as int?;
    final patientName = appointment['patientName'] as String? ?? 'Patient';

    if (appointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid appointment ID'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConsultationRoom(
          appointmentId: appointmentId,
          patientName: patientName,
          isDoctor: true,
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon'),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }
}
