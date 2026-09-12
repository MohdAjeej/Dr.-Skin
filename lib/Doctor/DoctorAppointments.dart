import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Doctor/VideoConsultationRoom.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DoctorAppointments extends StatefulWidget {
  @override
  _DoctorAppointmentsState createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allAppointments = [];
  List<dynamic> _todayAppointments = [];
  List<dynamic> _upcomingAppointments = [];
  List<dynamic> _pastAppointments = [];
  bool _isLoading = true;
  int _currentDoctorId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getCurrentDoctorId();
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    if (userId != null) {
      _currentDoctorId = int.parse(userId);
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");

      // Try doctor-specific endpoint first
      http.Response response;
      try {
        response = await http.get(
          Uri.parse('${ApiService.baseUrl}/api/appointments/doctor/$_currentDoctorId'),
          headers: {'Auth': 'Bearer $token'},
        );
      } catch (e) {
        // Fallback to general appointment endpoint
        response = await http.get(
          Uri.parse('${ApiService.baseUrl}/api/appointments/get-all-appoinment'),
          headers: {'Auth': 'Bearer $token'},
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> appointments = json.decode(response.body);
        
        // Filter appointments for current doctor only
        final doctorAppointments = appointments.where((apt) => 
          apt['doctorId'] == _currentDoctorId
        ).toList();

        _categorizeAppointments(doctorAppointments);
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print("Error fetching appointments: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading appointments: $e'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _categorizeAppointments(List<dynamic> appointments) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    setState(() {
      _allAppointments = appointments;
      
      _todayAppointments = appointments.where((apt) => 
        apt['appointmentDate'] == today
      ).toList()..sort((a, b) => 
        (a['slotTime'] ?? '').compareTo(b['slotTime'] ?? ''));
      
      _upcomingAppointments = appointments.where((apt) => 
        DateTime.parse(apt['appointmentDate']).isAfter(now) ||
        (apt['appointmentDate'] == today && apt['status'] != 'COMPLETED')
      ).toList()..sort((a, b) => 
        DateTime.parse(a['appointmentDate']).compareTo(DateTime.parse(b['appointmentDate'])));
      
      _pastAppointments = appointments.where((apt) => 
        DateTime.parse(apt['appointmentDate']).isBefore(now) &&
        apt['status'] == 'COMPLETED'
      ).toList()..sort((a, b) => 
        DateTime.parse(b['appointmentDate']).compareTo(DateTime.parse(a['appointmentDate'])));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchAppointments,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'All (${_allAppointments.length})'),
            Tab(text: 'Today (${_todayAppointments.length})'),
            Tab(text: 'Upcoming (${_upcomingAppointments.length})'),
            Tab(text: 'Past (${_pastAppointments.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(_allAppointments, 'No appointments found'),
                _buildAppointmentList(_todayAppointments, 'No appointments today'),
                _buildAppointmentList(_upcomingAppointments, 'No upcoming appointments'),
                _buildAppointmentList(_pastAppointments, 'No past appointments'),
              ],
            ),
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
            'Loading appointments...',
            style: TextStyle(color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<dynamic> appointments, String emptyMessage) {
    if (appointments.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final appointmentDate = appointment['appointmentDate'] ?? '';
    final slotTime = appointment['slotTime'] ?? 'Time not specified';
    final patientName = appointment['patientName'] ?? 'Unknown Patient';
    final appointmentType = appointment['appointmentType'] ?? 'IN_PERSON';
    final status = appointment['status'] ?? 'SCHEDULED';
    final consultationFee = appointment['consultationFee'] ?? 0;
    final appointmentId = appointment['appointmentId'];

    Color statusColor = _getStatusColor(status);
    IconData typeIcon = appointmentType == 'VIDEO' ? Icons.video_call : Icons.person;
    Color typeColor = appointmentType == 'VIDEO' ? primaryColor : accentColor;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${_formatDate(appointmentDate)} at $slotTime',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: successColor),
                Text(
                  '₹$consultationFee',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: successColor,
                  ),
                ),
                Spacer(),
                Text(
                  appointmentType.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildAppointmentActions(appointment),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentActions(Map<String, dynamic> appointment) {
    final status = appointment['status'] ?? 'SCHEDULED';
    final appointmentType = appointment['appointmentType'] ?? 'IN_PERSON';
    final appointmentDate = appointment['appointmentDate'] ?? '';
    final now = DateTime.now();
    final appointmentDateTime = DateTime.parse(appointmentDate);
    final isToday = DateFormat('yyyy-MM-dd').format(appointmentDateTime) == 
                   DateFormat('yyyy-MM-dd').format(now);

    List<Widget> actions = [];

    // Video call button for video appointments
    if (appointmentType == 'VIDEO' && status == 'CONFIRMED' && isToday) {
      actions.add(
        ElevatedButton.icon(
          onPressed: () => _startVideoCall(appointment),
          icon: Icon(Icons.video_call, size: 18),
          label: Text('Join Call'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Mark as completed button
    if (status == 'CONFIRMED' && isToday) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => _markAsCompleted(appointment),
          icon: Icon(Icons.check, size: 18),
          label: Text('Complete'),
          style: OutlinedButton.styleFrom(
            foregroundColor: successColor,
            side: BorderSide(color: successColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Cancel button for future appointments
    if (status != 'COMPLETED' && status != 'CANCELLED' && 
        appointmentDateTime.isAfter(now)) {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => _showCancelDialog(appointment),
          icon: Icon(Icons.cancel, size: 18),
          label: Text('Cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: errorColor,
            side: BorderSide(color: errorColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Reschedule button
    if (status != 'COMPLETED' && status != 'CANCELLED') {
      actions.add(
        TextButton.icon(
          onPressed: () => _showRescheduleDialog(appointment),
          icon: Icon(Icons.schedule, size: 18),
          label: Text('Reschedule'),
          style: TextButton.styleFrom(
            foregroundColor: warningColor,
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return primaryColor;
      case 'COMPLETED':
        return successColor;
      case 'CANCELLED':
        return errorColor;
      case 'RESCHEDULED':
        return warningColor;
      default:
        return textSecondary;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDay = DateTime(date.year, date.month, date.day);
      
      if (appointmentDay == today) {
        return 'Today';
      } else if (appointmentDay == today.add(Duration(days: 1))) {
        return 'Tomorrow';
      } else if (appointmentDay == today.subtract(Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  void _startVideoCall(Map<String, dynamic> appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoConsultationRoom(
          appointmentId: appointment['appointmentId'],
          patientName: appointment['patientName'] ?? 'Unknown Patient',
          isDoctor: true,
        ),
      ),
    );
  }

  void _markAsCompleted(Map<String, dynamic> appointment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");
      
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/appointments/${appointment['appointmentId']}/complete'),
        headers: {
          'Auth': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: successColor,
          ),
        );
        _fetchAppointments(); // Refresh the list
      } else {
        throw Exception('Failed to complete appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing appointment: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this appointment?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Cancellation Reason (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Appointment'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointment, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");
      
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/appointments/${appointment['appointmentId']}/cancel'),
        headers: {
          'Auth': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'cancellationReason': reason,
          'cancelledBy': 'DOCTOR'
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: successColor,
          ),
        );
        _fetchAppointments(); // Refresh the list
      } else {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling appointment: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  void _showRescheduleDialog(Map<String, dynamic> appointment) {
    // Implement reschedule functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule Appointment'),
        content: Text('Rescheduling feature will be available soon. Please contact the patient directly to reschedule.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}