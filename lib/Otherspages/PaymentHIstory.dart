import 'package:flutter/material.dart';
import 'dart:math';

class PaymentHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> paymentHistory = [
    {
      "icon": Icons.payment,
      "title": "Subscription",
      "amount": "\₹49.99",
      "date": "Feb 10, 2025",
      "status": "Completed",
    },
    {
      "icon": Icons.shopping_cart,
      "title": "In-App Purchase",
      "amount": "\₹9.99",
      "date": "Jan 22, 2025",
      "status": "Pending",
    },
    {
      "icon": Icons.credit_card,
      "title": "Premium Plan",
      "amount": "\₹99.99",
      "date": "Dec 15, 2024",
      "status": "Completed",
    },
    {
      "icon": Icons.receipt_long,
      "title": "Renewal",
      "amount": "\₹29.99",
      "date": "Nov 30, 2024",
      "status": "Failed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Payment History',
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
          children: paymentHistory.map((payment) {
            return _buildPaymentContainer(
              payment["icon"],
              payment["title"],
              payment["amount"],
              payment["date"],
              payment["status"],
            );
          }).toList(),
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

  Widget _buildPaymentContainer(
      IconData icon, String title, String amount, String date, String status) {
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
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: status == "Completed"
                      ? Colors.green
                      : status == "Pending"
                          ? Colors.orange
                          : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
