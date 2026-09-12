import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'package:O2ISkinSense/Otherspages/BookedDetailsPage.dart';

class AppointmentPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String? appointmentType;

  const AppointmentPage({
    super.key,
    required this.doctor,
    this.appointmentType,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late DateTime selectedDate;
  late DateTime firstDay;
  late DateTime lastDay;

  List<dynamic> availableSlots = [];

  bool isLoading = false;

  String selectedAppointmentType = 'IN_PERSON';

  @override
  void initState() {
    super.initState();

    if (widget.appointmentType != null &&
        widget.appointmentType!.trim().isNotEmpty) {
      selectedAppointmentType = widget.appointmentType!;
    }

    final now = DateTime.now();

    selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    firstDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    lastDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 90));

    fetchAvailableSlots();
  }

  Future<void> fetchAvailableSlots() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final date =
          DateFormat('yyyy-MM-dd').format(selectedDate);

      final doctorId = widget.doctor['userId'];

      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/appointments/slots'
          '?date=$date&doctorId=$doctorId',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          availableSlots =
              decoded is List ? decoded : [];
          isLoading = false;
        });
      } else {
        setState(() {
          availableSlots = [];
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error fetching slots: ${response.statusCode}',
            ),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        availableSlots = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to fetch slots: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Widget _buildAppointmentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _appointmentTypeCard(
                type: 'IN_PERSON',
                title: 'Clinic Visit',
                subtitle: 'Visit doctor at clinic',
                icon: Icons.local_hospital_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _appointmentTypeCard(
                type: 'VIDEO',
                title: 'Video Call',
                subtitle: 'Consult online',
                icon: Icons.video_call_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _appointmentTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected =
        selectedAppointmentType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAppointmentType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withOpacity(0.08)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? primaryColor
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? primaryColor.withOpacity(0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? primaryColor
                    : textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? primaryColor
                  : textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: TableCalendar(
            focusedDay: selectedDate,
            firstDay: firstDay,
            lastDay: lastDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              final today = DateTime.now();

              final selectedOnly = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );

              final todayOnly = DateTime(
                today.year,
                today.month,
                today.day,
              );

              if (selectedOnly.isBefore(todayOnly)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Cannot select past dates',
                    ),
                    backgroundColor: errorColor,
                  ),
                );
                return;
              }

              setState(() {
                selectedDate = selectedOnly;
              });

              fetchAvailableSlots();
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: textPrimary,
              ),
              holidayTextStyle: TextStyle(
                color: errorColor,
              ),
              selectedDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
              ),
              todayDecoration: BoxDecoration(
                color: primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: primaryColor,
              ),
              defaultTextStyle: TextStyle(
                color: textPrimary,
              ),
              markerDecoration: BoxDecoration(
                color: successColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: primaryColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: primaryColor,
              ),
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Available Slots',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ),
            if (!isLoading)
              IconButton(
                onPressed: fetchAvailableSlots,
                icon: Icon(
                  Icons.refresh,
                  color: primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  primaryColor,
                ),
              ),
            ),
          )
        else if (availableSlots.isEmpty)
          _buildNoSlotsState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final slot = availableSlots[index];

              final status =
                  slot is Map ? slot['status'] : null;

              final bool isBooked =
                  status == true ||
                  status == 'BOOKED' ||
                  status == 'booked' ||
                  status == 'Booked';

              final slotTime =
                  slot is Map
                      ? (slot['slot'] ??
                          slot['slotTime'] ??
                          '')
                      : '';

              return GestureDetector(
                onTap: isBooked
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookPay(
                              slot: Map<String, dynamic>.from(
                                slot,
                              ),
                              selectedDate: selectedDate,
                              doctor: widget.doctor,
                              appointmentType:
                                  selectedAppointmentType,
                            ),
                          ),
                        );
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isBooked
                        ? Colors.grey.shade200
                        : cardColor,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: isBooked
                          ? Colors.grey.shade400
                          : primaryColor.withOpacity(0.3),
                    ),
                    boxShadow: !isBooked
                        ? [
                            BoxShadow(
                              color: primaryColor
                                  .withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset:
                                  const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        slotTime.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isBooked
                              ? Colors.grey.shade600
                              : textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.grey.shade400
                              : successColor,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          isBooked
                              ? 'Booked'
                              : 'Available',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNoSlotsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No available slots for this date',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select another date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorName =
        widget.doctor['name'] ?? 'Doctor';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dr. $doctorName',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/person.jpg'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Show appointment type if coming from type selection
                    if (selectedAppointmentType != 'IN_PERSON')
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFF6B73FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedAppointmentType == 'VIDEO' ? Icons.video_call : Icons.local_hospital,
                              color: Color(0xFF6B73FF),
                            ),
                            SizedBox(width: 8),
                            Text(
                              selectedAppointmentType == 'VIDEO' ? 'Video Consultation' : 'Clinic Visit',
                              style: TextStyle(
                                color: Color(0xFF6B73FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Calendar Section  
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE')
                                    .format(selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(selectedDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAvailableSlotsSection(),
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

class BookPay extends StatefulWidget {
  final Map<String, dynamic> slot;
  final DateTime selectedDate;
  final Map<String, dynamic> doctor;
  final String appointmentType;

  const BookPay({
    super.key,
    required this.slot,
    required this.selectedDate,
    required this.doctor,
    required this.appointmentType,
  });

  @override
  State<BookPay> createState() => _BookPayState();
}

class _BookPayState extends State<BookPay> {
  bool isBooking = false;
  bool isSuccess = false;

  late StompClient _stompClient;

  String? token;
  String? username;
  int userid = 0;

  String roomId = '';

  late Razorpay _razorpay;

  final String apiUrl =
      '${ApiService.baseUrl}/api/appointments/book';

  final String razorpayKey =
      'rzp_test_ylWSg3ZmhzAKID';

  double charges = 0;

  String razorpayOrderId = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _connectWebSocket();
    bookroom();
    getdataofforpayment();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${ApiService.baseUrl}/websocket',
        onConnect: _onWebSocketConnected,
        onDisconnect: (frame) {
          debugPrint('Disconnected');
        },
        onWebSocketError: (dynamic error) {
          debugPrint('WebSocket Error: $error');
        },
      ),
    );

    _stompClient.activate();
  }

  String _generateChatRoomId(
    String user1,
    String user2,
  ) {
    final first =
        user1.compareTo(user2) < 0
            ? user1
            : user2;

    final second =
        user1.compareTo(user2) < 0
            ? user2
            : user1;

    return '${first}_$second';
  }

  void _onWebSocketConnected(
    StompFrame frame,
  ) {
    if (username == null ||
        username!.trim().isEmpty) {
      return;
    }

    roomId = _generateChatRoomId(
      username!,
      widget.doctor['name']?.toString() ??
          widget.doctor['username']?.toString() ??
          'doctor',
    );

    _stompClient.subscribe(
      destination: '/topic/private/$roomId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            jsonDecode(frame.body!);
          } catch (_) {}
        }
      },
    );
  }

  void _sendMessage() {
    if (username == null ||
        username!.trim().isEmpty) {
      return;
    }

    final doctorName =
        widget.doctor['name']?.toString() ??
            widget.doctor['username']
                ?.toString() ??
            'doctor';

    final generatedRoomId =
        _generateChatRoomId(
      username!,
      doctorName,
    );

    final message = {
      'sender': username,
      'receiver':
          widget.doctor['username'],
      'content': 'meeting Scheduled',
      'type': 'CHAT',
      'chatRoomId': generatedRoomId,
    };

    try {
      _stompClient.send(
        destination: '/app/chat.send',
        body: jsonEncode(message),
      );
    } catch (e) {
      debugPrint(
        'Unable to send WebSocket message: $e',
      );
    }
  }

  Future<void> bookroom() async {
    final prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      token = prefs.getString('jwtToken');
      username = prefs.getString('username');
    });
  }

  Future<void> getdataofforpayment() async {
    final prefs =
        await SharedPreferences.getInstance();

    final userIdString =
        prefs.getString('userId');

    if (userIdString == null ||
        userIdString.trim().isEmpty) {
      return;
    }

    final parsedUserId =
        int.tryParse(userIdString);

    if (parsedUserId == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      userid = parsedUserId;
    });
  }

  Future<void> bookAppointment() async {
    _sendMessage();
  }

  Future<void> bookAppointmentapi() async {
    if (userid <= 0) {
      _showError(
        'User information is unavailable. Please login again.',
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final date =
        DateFormat('yyyy-MM-dd')
            .format(widget.selectedDate);

    final doctorId = widget.doctor['userId'];

    final slot =
        widget.slot['slot'] ??
            widget.slot['slotTime'] ??
            '';

    final url = Uri.parse(
      '$apiUrl'
      '?userId=$userid'
      '&doctorId=$doctorId'
      '&slotTime=${Uri.encodeComponent(slot.toString())}'
      '&date=$date'
      '&appointmentType=${Uri.encodeComponent(widget.appointmentType)}',
    );

    try {
      final response = await http.post(url);

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data.containsKey('charges') &&
            data.containsKey('razorpayOrderId')) {
          final dynamic chargeValue =
              data['charges'];

          charges = chargeValue is num
              ? chargeValue.toDouble()
              : double.tryParse(
                    chargeValue.toString(),
                  ) ??
                  0;

          razorpayOrderId =
              data['razorpayOrderId']
                  .toString();

          if (charges <= 0 ||
              razorpayOrderId.isEmpty) {
            _showError(
              'Invalid payment details received from server.',
            );
          } else {
            startPayment();
          }
        } else {
          _showError(
            'Invalid response from server.',
          );
        }
      } else {
        _showError(
          'Failed to book appointment. Try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void startPayment() {
    if (charges <= 0 ||
        razorpayOrderId.isEmpty) {
      _showError(
        'Invalid payment details. Try again.',
      );
      return;
    }

    final options = {
      'key': razorpayKey,
      'amount': (charges * 100).toInt(),
      'order_id': razorpayOrderId,
      'name': 'Doctor Appointment',
      'description': 'Consultation Charges',
      'prefill': {
        'email': username ?? '',
      },
      'theme': {
        'color': '#F37254',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showError('Payment failed: $e');
    }
  }

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    final callbackUrl =
        '${ApiService.baseUrl}/api/allorders/paymentCallback';

    try {
      final res = await http.post(
        Uri.parse(callbackUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'razorpay_order_id':
              response.orderId ?? razorpayOrderId,
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200 ||
          res.statusCode == 201) {
        await bookAppointment();

        if (!mounted) return;

        setState(() {
          isSuccess = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Appointment booked successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookedDetailsPage(
              paymentId:
                  response.paymentId ?? 'N/A',
              orderId:
                  response.orderId ?? 'N/A',
              slotTime:
                  widget.slot['slot']
                          ?.toString() ??
                      widget.slot['slotTime']
                          ?.toString() ??
                      'N/A',
              amount: charges,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment confirmed, but booking failed!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentError(
    PaymentFailureResponse response,
  ) {
    _showError(
      'Payment Failed! Reason: ${response.message ?? 'Unknown error'}',
    );
  }

  void _handleExternalWallet(
    ExternalWalletResponse response,
  ) {
    debugPrint(
      'External Wallet Used: ${response.walletName}',
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  double _getConsultationFee() {
    final consultation =
        widget.appointmentType == 'VIDEO'
            ? widget.doctor['onlineConsultation']
            : widget.doctor['offlineConsultation'];

    if (consultation is Map) {
      final value = consultation['charges'];

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
            value?.toString() ?? '',
          ) ??
          0;
    }

    if (consultation is num) {
      return consultation.toDouble();
    }

    return double.tryParse(
          consultation?.toString() ?? '',
        ) ??
        0;
  }

  @override
  void dispose() {
    _razorpay.clear();

    try {
      _stompClient.deactivate();
    } catch (_) {}

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotTime =
        widget.slot['slot']?.toString() ??
            widget.slot['slotTime']?.toString() ??
            'N/A';

    final doctorName =
        widget.doctor['name']?.toString() ??
            'Doctor';

    final fee = _getConsultationFee();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment for Appointment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _detailRow(
                      'Doctor',
                      doctorName,
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      'Appointment Type',
                      widget.appointmentType ==
                              'VIDEO'
                          ? 'Video Consultation'
                          : 'Clinic Visit',
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      'Date',
                      DateFormat('dd MMMM yyyy')
                          .format(widget.selectedDate),
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      'Time',
                      slotTime,
                    ),
                    const SizedBox(height: 12),
                    _detailRow(
                      'Consulting Fee',
                      '₹${fee.toStringAsFixed(0)}',
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isBooking)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (isSuccess)
              Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your appointment has been successfully booked!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Text(
                    'Proceed to payment to confirm your appointment.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : bookAppointmentapi,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color:
                  valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}