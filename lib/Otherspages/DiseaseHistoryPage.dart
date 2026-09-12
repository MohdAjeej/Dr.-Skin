import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Otherspages/preiviodiagdetailedpage.dart';
// Import the detail page

class DiseaseHistoryPage extends StatefulWidget {
  @override
  _DiseaseHistoryPageState createState() => _DiseaseHistoryPageState();
}

class _DiseaseHistoryPageState extends State<DiseaseHistoryPage> {
  late Future<List<Map<String, dynamic>>> diseaseHistory;

  @override
  void initState() {
    super.initState();
    diseaseHistory = ApiService().getDiseaseHistory(); // Fetch history on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Disease History',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: diseaseHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No history found.'));
          } else {
            List<Map<String, dynamic>> history = snapshot.data!;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: history.map((item) {
                  String imageUrl =
                      '${ApiService.baseUrl}${item['diseaseImg']}'; // Combine baseUrl and image path
                  return _buildHistoryCard(
                      item['disease'], item['createdAt'], imageUrl, context);
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  // Function to generate random colors for each card
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

  Widget _buildHistoryCard(
      String disease, String createdAt, String imageUrl, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to DiseaseDetailPage and pass the disease name and image URL
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseDetailPage(
              diseaseName: disease,
              diseaseImageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
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
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: getRandomColor(), // Assigning random color
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Date: $createdAt',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
