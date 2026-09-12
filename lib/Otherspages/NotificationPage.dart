import 'package:flutter/material.dart';
import 'dart:math';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      "icon": Icons.notifications,
      "title": "New Update Available",
      "message": "Version 2.0 is now available. Update now!",
      "time": "2h ago",
    },
    {
      "icon": Icons.payment,
      "title": "Payment Successful",
      "message": "Your payment of \₹49.99 was successful.",
      "time": "Yesterday",
    },
    {
      "icon": Icons.warning,
      "title": "Security Alert",
      "message": "Unusual login detected from a new device.",
      "time": "3 days ago",
    },
    {
      "icon": Icons.check_circle,
      "title": "Subscription Renewed",
      "message": "Your premium subscription has been renewed.",
      "time": "1 week ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notifications.map((notification) {
            return _buildNotificationContainer(
              notification["icon"],
              notification["title"],
              notification["message"],
              notification["time"],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Function to generate random colors
  Color getRandomColor() {
    // final Random random = Random();
    // return Color.fromARGB(
    //   255, // Full opacity
    //   random.nextInt(256), // Red (0-255)
    //   random.nextInt(256), // Green (0-255)
    //   random.nextInt(256), // Blue (0-255)
    // );
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.amber,
    ];

    return colors[Random().nextInt(colors.length)]; // Pick a random color
  }

  Widget _buildNotificationContainer(
      IconData icon, String title, String message, String time) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: getRandomColor(), // Assigning random color
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
