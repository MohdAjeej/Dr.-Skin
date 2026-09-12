import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Otherspages/AppointmentSlotsAndPayment.dart';

class AppointmentTypeSelection extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const AppointmentTypeSelection({Key? key, required this.doctor}) : super(key: key);

  @override
  _AppointmentTypeSelectionState createState() => _AppointmentTypeSelectionState();
}

class _AppointmentTypeSelectionState extends State<AppointmentTypeSelection> {
  String selectedAppointmentType = 'IN_PERSON';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Select Consultation Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Doctor Info Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${widget.doctor['name']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.doctor['special']?.join(', ') ?? 'General Practice',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your preferred consultation type:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // In-Person Consultation Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAppointmentType = 'IN_PERSON';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: selectedAppointmentType == 'IN_PERSON'
                            ? primaryColor.withOpacity(0.1)
                            : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedAppointmentType == 'IN_PERSON'
                              ? primaryColor
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedAppointmentType == 'IN_PERSON'
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clinic Visit',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: selectedAppointmentType == 'IN_PERSON'
                                        ? primaryColor
                                        : textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Visit doctor at clinic',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '₹${widget.doctor['offlineConsultation'] ?? 500}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: selectedAppointmentType == 'IN_PERSON'
                                        ? primaryColor
                                        : accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedAppointmentType == 'IN_PERSON')
                            Icon(
                              Icons.check_circle,
                              color: primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Video Consultation Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAppointmentType = 'VIDEO';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: selectedAppointmentType == 'VIDEO'
                            ? primaryColor.withOpacity(0.1)
                            : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedAppointmentType == 'VIDEO'
                              ? primaryColor
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedAppointmentType == 'VIDEO'
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.video_call,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Video Consultation',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: selectedAppointmentType == 'VIDEO'
                                            ? primaryColor
                                            : textPrimary,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: successColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'POPULAR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: successColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Consult from home',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '₹${widget.doctor['onlineConsultation'] ?? 300}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: selectedAppointmentType == 'VIDEO'
                                        ? primaryColor
                                        : accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedAppointmentType == 'VIDEO')
                            Icon(
                              Icons.check_circle,
                              color: primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Benefits Section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text(
                              selectedAppointmentType == 'VIDEO' ? 'Video Consultation Benefits:' : 'Clinic Visit Benefits:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (selectedAppointmentType == 'VIDEO') ...[
                          _buildBenefitItem('No travel required'),
                          _buildBenefitItem('Safe & convenient'),
                          _buildBenefitItem('Instant consultation'),
                        ] else ...[
                          _buildBenefitItem('Physical examination'),
                          _buildBenefitItem('Direct interaction'),
                          _buildBenefitItem('Complete diagnosis'),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentPage(
                              doctor: widget.doctor,
                              appointmentType: selectedAppointmentType,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue to Select Date & Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, color: successColor, size: 16),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}