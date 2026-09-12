import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorAvailability extends StatefulWidget {
  @override
  _DoctorAvailabilityState createState() => _DoctorAvailabilityState();
}

class _DoctorAvailabilityState extends State<DoctorAvailability> {
  Map<String, Map<String, dynamic>> _weeklySchedule = {
    'Monday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
    'Tuesday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
    'Wednesday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
    'Thursday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
    'Friday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
    'Saturday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
    'Sunday': {'enabled': false, 'startTime': '09:00', 'endTime': '17:00'},
  };
  
  int _appointmentDuration = 30; // Default 30 minutes
  bool _isLoading = true;
  bool _isSaving = false;
  int _currentDoctorId = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoad();
  }

  Future<void> _checkAuthenticationAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");
      final userId = prefs.getString("userId");
      
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please login again to manage availability'),
              backgroundColor: errorColor,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
        return;
      }
      
      if (userId != null) {
        _currentDoctorId = int.parse(userId);
      }
      
      await _loadAvailability();
    } catch (e) {
      print('Error in initialization: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAvailability() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/doctors/$_currentDoctorId/availability'),
        headers: {'Auth': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _parseAvailabilityData(data);
      } else if (response.statusCode == 404) {
        // No availability set yet, use defaults
        print('No availability found, using defaults');
      }
    } catch (e) {
      print('Error loading availability: $e');
      // Use default schedule if API call fails
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseAvailabilityData(Map<String, dynamic> data) {
    // Parse availability data from backend
    final schedule = data['schedule'] as Map<String, dynamic>?;
    if (schedule != null) {
      setState(() {
        _weeklySchedule.forEach((day, dayData) {
          if (schedule.containsKey(day.toLowerCase())) {
            final daySchedule = schedule[day.toLowerCase()];
            _weeklySchedule[day] = {
              'enabled': daySchedule['enabled'] ?? false,
              'startTime': daySchedule['startTime'] ?? '09:00',
              'endTime': daySchedule['endTime'] ?? '17:00',
            };
          }
        });
        _appointmentDuration = data['appointmentDuration'] ?? 30;
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwtToken");

      // Check if token exists
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Validate that at least one day is enabled
      final hasEnabledDays = _weeklySchedule.values.any((day) => day['enabled'] == true);
      if (!hasEnabledDays) {
        throw Exception('Please enable at least one day of availability');
      }

      final scheduleData = <String, dynamic>{};
      _weeklySchedule.forEach((day, data) {
        scheduleData[day.toLowerCase()] = data;
      });

      final requestBody = {
        'doctorId': _currentDoctorId,
        'schedule': scheduleData,
        'appointmentDuration': _appointmentDuration,
        'timeZone': 'Asia/Kolkata', // Default timezone
      };

      print('Saving availability with token: ${token.substring(0, 20)}...');
      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/doctors/availability'),
        headers: {
          'Auth': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Availability saved successfully!'),
              backgroundColor: successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please logout and login again.');
      } else {
        throw Exception('Failed to save: ${response.body}');
      }
    } catch (e) {
      print('Error saving availability: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: errorColor,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveAvailability,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
          'Manage Availability',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveAvailability,
              child: _isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppointmentDurationCard(),
                  SizedBox(height: 20),
                  _buildWeeklyScheduleCard(),
                  SizedBox(height: 20),
                  _buildPreviewCard(),
                  SizedBox(height: 20),
                  _buildTipsCard(),
                ],
              ),
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
            'Loading availability...',
            style: TextStyle(color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDurationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointment Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Set the duration for each appointment slot',
              style: TextStyle(color: textSecondary),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _appointmentDuration,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _appointmentDuration = value!;
                          });
                        },
                        items: [15, 30, 45, 60, 90, 120].map((duration) {
                          return DropdownMenuItem<int>(
                            value: duration,
                            child: Text('$duration minutes'),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.schedule, color: primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Configure your availability for each day of the week',
              style: TextStyle(color: textSecondary),
            ),
            SizedBox(height: 20),
            ..._weeklySchedule.entries.map((entry) => 
              _buildDayScheduleRow(entry.key, entry.value)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayScheduleRow(String day, Map<String, dynamic> dayData) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dayData['enabled'] ? primaryColor.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dayData['enabled'] ? primaryColor.withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              Switch(
                value: dayData['enabled'],
                onChanged: (value) {
                  setState(() {
                    _weeklySchedule[day]!['enabled'] = value;
                  });
                },
                activeColor: primaryColor,
              ),
            ],
          ),
          if (dayData['enabled']) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _selectTime(day, 'startTime'),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dayData['startTime']),
                              Icon(Icons.access_time, size: 16, color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _selectTime(day, 'endTime'),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dayData['endTime']),
                              Icon(Icons.access_time, size: 16, color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final enabledDays = _weeklySchedule.entries
        .where((entry) => entry.value['enabled'])
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 16),
            if (enabledDays.isEmpty)
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.schedule_outlined, size: 48, color: textSecondary),
                    SizedBox(height: 8),
                    Text(
                      'No availability set',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...enabledDays.map((entry) {
                final day = entry.key;
                final data = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        child: Text(
                          day.substring(0, 3),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${data['startTime']} - ${data['endTime']}',
                        style: TextStyle(color: textSecondary),
                      ),
                      Spacer(),
                      Text(
                        '${_calculateSlots(data['startTime'], data['endTime'])} slots',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: warningColor),
                SizedBox(width: 8),
                Text(
                  'Tips for Managing Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildTipItem('Set realistic appointment durations to avoid rushing'),
            _buildTipItem('Leave buffer time between appointments for notes'),
            _buildTipItem('Block out lunch breaks and personal time'),
            _buildTipItem('Update availability when you\'re away or on vacation'),
            _buildTipItem('Patients can only book during your available hours'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: warningColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(String day, String timeType) async {
    final currentTime = _weeklySchedule[day]![timeType] as String;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:'
                         '${selectedTime.minute.toString().padLeft(2, '0')}';
      
      setState(() {
        _weeklySchedule[day]![timeType] = timeString;
      });

      // Validate time ranges
      if (timeType == 'startTime') {
        _validateTimeRange(day);
      }
    }
  }

  void _validateTimeRange(String day) {
    final startTime = _weeklySchedule[day]!['startTime'] as String;
    final endTime = _weeklySchedule[day]!['endTime'] as String;
    
    if (_timeToMinutes(startTime) >= _timeToMinutes(endTime)) {
      // If start time is after or equal to end time, adjust end time
      final startMinutes = _timeToMinutes(startTime);
      final newEndMinutes = startMinutes + 60; // Add 1 hour minimum
      final newEndTime = _minutesToTime(newEndMinutes);
      
      setState(() {
        _weeklySchedule[day]!['endTime'] = newEndTime;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End time adjusted to maintain minimum 1-hour window'),
          backgroundColor: warningColor,
        ),
      );
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToTime(int minutes) {
    final hours = (minutes ~/ 60) % 24;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  int _calculateSlots(String startTime, String endTime) {
    final startMinutes = _timeToMinutes(startTime);
    final endMinutes = _timeToMinutes(endTime);
    final totalMinutes = endMinutes - startMinutes;
    return (totalMinutes / _appointmentDuration).floor();
  }
}