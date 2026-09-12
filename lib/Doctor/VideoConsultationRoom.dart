import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoConsultationRoom extends StatefulWidget {
  final int appointmentId;
  final String patientName;
  final bool isDoctor;

  const VideoConsultationRoom({
    Key? key,
    required this.appointmentId,
    required this.patientName,
    required this.isDoctor,
  }) : super(key: key);

  @override
  State<VideoConsultationRoom> createState() =>
      _VideoConsultationRoomState();
}

class _VideoConsultationRoomState
    extends State<VideoConsultationRoom> {
  bool _isLoading = true;
  bool _canJoinCall = false;
  String? _errorMessage;

  Map<String, dynamic>? _appointmentDetails;

  String _userName = '';
  int _userId = 0;

  static const int appID = 1484647939;

  static const String appSign =
      '3055c2ac285ab6c3dd9b7562c5c780b96d0bb4ba7cf5279b0c0b0c8b70cf8a3e';

  @override
  void initState() {
    super.initState();
    _initializeVideoRoom();
  }

  Future<void> _initializeVideoRoom() async {
    try {
      await _getUserData();
      await _fetchAppointmentDetails();
      await _validateVideoConsultation();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId');
    final username = prefs.getString('username');

    if (userId == null || username == null) {
      throw Exception(
        'User authentication data not found',
      );
    }

    final parsedUserId = int.tryParse(userId);

    if (parsedUserId == null) {
      throw Exception(
        'Invalid user ID',
      );
    }

    _userId = parsedUserId;
    _userName = username;
  }

  Future<void> _fetchAppointmentDetails() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token = prefs.getString('jwtToken');

      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found',
        );
      }

      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/appointments/${widget.appointmentId}',
        ),
        headers: {
          'Auth': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load appointment details: '
          '${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid appointment response',
        );
      }

      _appointmentDetails = data;
    } catch (e) {
      throw Exception(
        'Error fetching appointment: $e',
      );
    }
  }

  Future<void> _validateVideoConsultation() async {
    if (_appointmentDetails == null) {
      throw Exception(
        'Appointment details not found',
      );
    }

    final appointmentType =
        _appointmentDetails!['appointmentType'];

    if (appointmentType != 'VIDEO') {
      throw Exception(
        'This is not a video consultation appointment',
      );
    }

    final status = _appointmentDetails!['status'];

    if (status != 'CONFIRMED') {
      throw Exception(
        'Appointment is not confirmed. '
        'Current status: $status',
      );
    }

    final appointmentDate =
        _appointmentDetails!['appointmentDate'];

    final today = DateTime.now();

    final todayString =
        '${today.year}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    if (appointmentDate != todayString) {
      throw Exception(
        'Video consultation is only available '
        'on the appointment date',
      );
    }

    final slotTime =
        _appointmentDetails!['slotTime'];

    if (slotTime != null &&
        !_isWithinCallWindow(
          slotTime.toString(),
        )) {
      throw Exception(
        'Video call is only available during '
        'the scheduled time window',
      );
    }

    if (!mounted) return;

    setState(() {
      _canJoinCall = true;
      _isLoading = false;
    });
  }

  bool _isWithinCallWindow(String slotTime) {
    try {
      final now = DateTime.now();

      final parts = slotTime.split(':');

      if (parts.length < 2) {
        return true;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final appointmentDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      final startWindow =
          appointmentDateTime.subtract(
        const Duration(minutes: 15),
      );

      final endWindow =
          appointmentDateTime.add(
        const Duration(hours: 1),
      );

      return now.isAfter(startWindow) &&
          now.isBefore(endWindow);
    } catch (e) {
      debugPrint(
        'Error parsing slot time: $e',
      );

      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    if (_canJoinCall) {
      return _buildVideoCallScreen();
    }

    return _buildWaitingScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Video Consultation',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Preparing video consultation...',
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: errorColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Video Consultation',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: errorColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to join video call',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  'Go Back',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Video Consultation',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 64,
                color: warningColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Video call not available yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The video consultation will be available '
                '15 minutes before the scheduled appointment time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  'Go Back',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCallScreen() {
    final roomID =
        'appointment_${widget.appointmentId}';

    final config =
        ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          ..audioVideoViewConfig =
              ZegoPrebuiltAudioVideoViewConfig(
            showAvatarInAudioMode: true,
            showSoundWavesInAudioMode: true,
          )
          ..topMenuBarConfig =
              ZegoTopMenuBarConfig(
            isVisible: true,
            buttons: [
              ZegoMenuBarButtonName.minimizingButton,
              ZegoMenuBarButtonName
                  .showMemberListButton,
            ],
          )
          ..bottomMenuBarConfig =
              ZegoBottomMenuBarConfig(
            buttons: [
              ZegoMenuBarButtonName
                  .toggleCameraButton,
              ZegoMenuBarButtonName
                  .toggleMicrophoneButton,
              ZegoMenuBarButtonName.hangUpButton,
              ZegoMenuBarButtonName
                  .switchAudioOutputButton,
              ZegoMenuBarButtonName
                  .switchCameraButton,
            ],
          );

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: appID,
        appSign: appSign,
        userID: _userId.toString(),
        userName: _userName,
        callID: roomID,
        config: config,
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (
            ZegoCallEndEvent event,
            VoidCallback defaultAction,
          ) {
            _handleCallEnd(event.reason);
            defaultAction();
          },
        ),
      ),
    );
  }

  Widget _buildWaitingForOtherParty() {
    final otherPartyName =
        widget.isDoctor
            ? widget.patientName
            : 'Doctor';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.video_call,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Waiting for $otherPartyName to join...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are in the video consultation room.\n'
              'The other party will be notified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color:
                    primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Room ID: appointment_${widget.appointmentId}',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCallEnd(
    ZegoCallEndReason reason,
  ) {
    if (widget.isDoctor &&
        reason !=
            ZegoCallEndReason.localHangUp) {
      _markAppointmentAsCompleted();
    }

    _showCallSummary();
  }

  Future<void> _markAppointmentAsCompleted() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString('jwtToken');

      if (token == null || token.isEmpty) {
        return;
      }

      await http.put(
        Uri.parse(
          '${ApiService.baseUrl}/api/appointments/'
          '${widget.appointmentId}/complete',
        ),
        headers: {
          'Auth': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'completedAt':
              DateTime.now().toIso8601String(),
          'completedBy':
              widget.isDoctor
                  ? 'DOCTOR'
                  : 'PATIENT',
        }),
      );
    } catch (e) {
      debugPrint(
        'Error marking appointment as completed: $e',
      );
    }
  }

  void _showCallSummary() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: successColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Consultation Completed',
              ),
            ],
          ),
          content: Text(
            'The video consultation has ended successfully. '
            '${widget.isDoctor ? "The appointment has been marked as completed." : "Thank you for using our service."}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }
}