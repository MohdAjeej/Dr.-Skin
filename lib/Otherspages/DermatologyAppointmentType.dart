import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Otherspages/AppointmentSlotsAndPayment.dart';

class DermatologyAppointmentType extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DermatologyAppointmentType({Key? key, required this.doctor}) : super(key: key);

  @override
  _DermatologyAppointmentTypeState createState() => _DermatologyAppointmentTypeState();
}

class _DermatologyAppointmentTypeState extends State<DermatologyAppointmentType> {
  String selectedAppointmentType = 'IN_PERSON';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Dermatology Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
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
                              'Consultation Type',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Choose your preferred consultation',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Doctor Info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${widget.doctor['name']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.doctor['special']?.join(', ') ?? 'Dermatology',
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
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    
                    // Video Consultation Card
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAppointmentType = 'VIDEO';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedAppointmentType == 'VIDEO'
                                ? Color(0xFF6B73FF)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: selectedAppointmentType == 'VIDEO' ? [
                            BoxShadow(
                              color: Color(0xFF6B73FF).withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: selectedAppointmentType == 'VIDEO'
                                    ? LinearGradient(
                                        colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                                      )
                                    : null,
                                color: selectedAppointmentType == 'VIDEO' ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.video_call,
                                color: Colors.white,
                                size: 32,
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
                                              ? Color(0xFF6B73FF)
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'RECOMMENDED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Consult from comfort of your home',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '₹${widget.doctor['onlineConsultation'] ?? 300}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: selectedAppointmentType == 'VIDEO'
                                          ? Color(0xFF6B73FF)
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedAppointmentType == 'VIDEO')
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6B73FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Color(0xFF6B73FF),
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // In-Person Consultation Card  
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAppointmentType = 'IN_PERSON';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selectedAppointmentType == 'IN_PERSON'
                                ? Color(0xFF6B73FF)
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: selectedAppointmentType == 'IN_PERSON' ? [
                            BoxShadow(
                              color: Color(0xFF6B73FF).withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: selectedAppointmentType == 'IN_PERSON'
                                    ? LinearGradient(
                                        colors: [Colors.green, Colors.greenAccent],
                                      )
                                    : null,
                                color: selectedAppointmentType == 'IN_PERSON' ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.local_hospital,
                                color: Colors.white,
                                size: 32,
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
                                          ? Colors.green
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Visit doctor at clinic for detailed examination',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '₹${widget.doctor['offlineConsultation'] ?? 500}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: selectedAppointmentType == 'IN_PERSON'
                                          ? Colors.green
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedAppointmentType == 'IN_PERSON')
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    Spacer(),
                    
                    // Continue Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6B73FF), Color(0xFF9575FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6B73FF).withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
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
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue to Select Time Slot',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}