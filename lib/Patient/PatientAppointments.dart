import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Components/app_theme.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Doctor/VideoConsultationRoom.dart';
import 'package:intl/intl.dart';

/// Professional Patient Appointments Page
/// Shows upcoming and past appointments with proper status lifecycle
class PatientAppointments extends StatefulWidget {
  const PatientAppointments({Key? key}) : super(key: key);

  @override
  _PatientAppointmentsState createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  List<dynamic> _allAppointments = [];
  List<dynamic> _upcomingAppointments = [];
  List<dynamic> _pastAppointments = [];
  
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAppointments() async {
    await _getCurrentUserId();
    await _fetchAppointments();
  }

  Future<void> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId != null) {
        _currentUserId = int.parse(userId);
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final appointments = await _apiService.getPatientAppointments();
      
      if (mounted) {
        _categorizeAppointments(appointments);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load appointments';
          _isLoading = false;
        });
      }
      debugPrint('Error fetching appointments: $e');
    }
  }

  void _categorizeAppointments(List<dynamic> appointments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = <dynamic>[];
    final past = <dynamic>[];

    for (var appointment in appointments) {
      try {
        final dateStr = appointment['appointmentDate'] as String?;
        if (dateStr == null) continue;

        final appointmentDate = _parseAppointmentDate(dateStr);
        final status = (appointment['status'] ?? '').toString().toUpperCase();

        // Categorize based on date and status
        if (appointmentDate.isAfter(today) ||
            (appointmentDate.isAtSameMomentAs(today) &&
                (status == 'SCHEDULED' ||
                    status == 'CONFIRMED' ||
                    status == 'PENDING'))) {
          upcoming.add(appointment);
        } else {
          past.add(appointment);
        }
      } catch (e) {
        debugPrint('Error categorizing appointment: $e');
      }
    }

    // Sort upcoming by date ascending
    upcoming.sort((a, b) {
      try {
        final dateA = _parseAppointmentDate(a['appointmentDate']);
        final dateB = _parseAppointmentDate(b['appointmentDate']);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    // Sort past by date descending
    past.sort((a, b) {
      try {
        final dateA = _parseAppointmentDate(a['appointmentDate']);
        final dateB = _parseAppointmentDate(b['appointmentDate']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      _allAppointments = appointments;
      _upcomingAppointments = upcoming;
      _pastAppointments = past;
      _isLoading = false;
    });
  }

  DateTime _parseAppointmentDate(String dateStr) {
    try {
      // Handle format: yyyy-MM-dd
      final parts = dateStr.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.cancelAppointment(
        appointmentId,
        reason: 'Cancelled by patient',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: AppTheme.healthGreen,
          ),
        );
        _fetchAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _joinVideoConsultation(Map<String, dynamic> appointment) async {
    final appointmentId = appointment['id'] as int?;
    final doctorName = appointment['doctorName'] as String? ?? 'Doctor';

    if (appointmentId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConsultationRoom(
          appointmentId: appointmentId,
          patientName: _currentUserId.toString(),
          isDoctor: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: AppTheme.headingMedium,
        ),
        backgroundColor: AppTheme.cardColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: AppTheme.titleMedium,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTab(),
                    _buildPastTab(),
                  ],
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              _errorMessage,
              style: AppTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: _fetchAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.textWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24,
                  vertical: AppTheme.spacing12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        title: 'No Upcoming Appointments',
        message: 'Book a consultation with a dermatologist to get started.',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _upcomingAppointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(
            _upcomingAppointments[index],
            isUpcoming: true,
          );
        },
      ),
    );
  }

  Widget _buildPastTab() {
    if (_pastAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Past Appointments',
        message: 'Your completed appointments will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _pastAppointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(
            _pastAppointments[index],
            isUpcoming: false,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              title,
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    {required bool isUpcoming}
  ) {
    final doctorName = appointment['doctorName'] as String? ?? 'Doctor';
    final dateStr = appointment['appointmentDate'] as String? ?? '';
    final slotTime = appointment['slotTime'] as String? ?? '';
    final status = appointment['status'] as String? ?? 'SCHEDULED';
    final appointmentType = appointment['appointmentType'] as String? ?? 'IN_PERSON';
    final concern = appointment['concern'] as String?;
    final appointmentId = appointment['id'] as int?;

    final statusColor = AppTheme.getStatusColor(status);
    final statusText = AppTheme.getStatusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. $doctorName',
                        style: AppTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dermatologist',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
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
            
            const SizedBox(height: AppTheme.spacing12),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spacing12),
            
            // Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    Icons.calendar_today,
                    _formatDate(dateStr),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    Icons.access_time,
                    slotTime,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacing8),
            
            _buildDetailItem(
              appointmentType == 'VIDEO' ? Icons.videocam : Icons.location_on,
              appointmentType == 'VIDEO' ? 'Video Consultation' : 'In-Person Visit',
            ),
            
            if (concern != null && concern.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing8),
              _buildDetailItem(
                Icons.medical_services_outlined,
                concern,
              ),
            ],
            
            // Actions
            if (isUpcoming && appointmentId != null) ...[
              const SizedBox(height: AppTheme.spacing16),
              Row(
                children: [
                  if (appointmentType == 'VIDEO' && status == 'CONFIRMED')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _joinVideoConsultation(appointment),
                        icon: const Icon(Icons.videocam, size: 18),
                        label: const Text('Join Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.healthGreen,
                          foregroundColor: AppTheme.textWhite,
                        ),
                      ),
                    ),
                  if (appointmentType == 'VIDEO' && status == 'CONFIRMED')
                    const SizedBox(width: AppTheme.spacing8),
                  if (status == 'SCHEDULED' || status == 'CONFIRMED')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelAppointment(appointmentId),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(color: AppTheme.errorRed),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacing8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = _parseAppointmentDate(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
