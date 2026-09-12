import 'package:O2ISkinSense/BottomPages/BottomNav.dart';
import 'package:flutter/material.dart';

class BookedDetailsPage extends StatelessWidget {
  final String paymentId;
  final String orderId;
  final String slotTime;
  final double amount;

  const BookedDetailsPage({
    Key? key,
    required this.paymentId,
    required this.orderId,
    required this.slotTime,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Booking Details")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow("Payment ID:", paymentId),
                  _buildDetailRow("Order ID:", orderId),
                  _buildDetailRow("Slot Time:", slotTime),
                  _buildDetailRow("Amount Paid:", "₹$amount"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                    child: const Text("Back to Home"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
