import 'package:flutter/material.dart';
import 'dart:math';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Contact Us',
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
          children: [
            // Contact Header
            Center(
              child: Icon(
                Icons.support_agent,
                size: 80,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 20),

            // Contact Information
            _buildContactInfoContainer(
              Icons.email,
              "Email",
              "support@yourapp.com",
            ),
            _buildContactInfoContainer(
              Icons.phone,
              "Phone",
              "+1 234 567 890",
            ),
            _buildContactInfoContainer(
              Icons.location_on,
              "Address",
              "1234 Street Name, City, Country",
            ),
            _buildContactInfoContainer(
              Icons.web,
              "Website",
              "www.yourapp.com",
            ),
          ],
        ),
      ),
    );
  }

  // Function to generate random colors
  Color getRandomColor() {
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

  Widget _buildContactInfoContainer(IconData icon, String label, String value) {
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
            height: 27,
            width: 27,
            decoration: BoxDecoration(
              color: getRandomColor(), // Assigning random color
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
