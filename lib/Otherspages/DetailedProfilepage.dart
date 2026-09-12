import 'package:flutter/material.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final data = await ApiService().getUserProfilenew();
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'User  Profile',
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData == null
              ? Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/person.jpg'),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Profile Information
                      _buildProfileInfoContainer(
                        Icons.person,
                        "Name",
                        "${profileData!['firstName']} ${profileData!['lastName']}",
                      ),
                      _buildProfileInfoContainer(
                        Icons.email,
                        "Email",
                        "${profileData!['email']}",
                      ),
                      _buildProfileInfoContainer(
                        Icons.person,
                        "Gender",
                        "${profileData!['gender']}",
                      ),
                      _buildProfileInfoContainer(
                        Icons.cake,
                        "Age",
                        "${profileData!['age']}",
                      ),
                      _buildProfileInfoContainer(
                        Icons.phone,
                        "Mobile",
                        "${profileData!['mobile']}",
                      ),
                      _buildProfileInfoContainer(
                        Icons.height,
                        "Height",
                        "${profileData!['heightFt']}' ${profileData!['heightIn']}\"",
                      ),
                      _buildProfileInfoContainer(
                        Icons.fitness_center,
                        "Weight",
                        "${profileData!['weight']} kg",
                      ),
                      _buildProfileInfoContainer(
                        Icons.calendar_today,
                        "DOB",
                        "${profileData!['dateOfBirth']}",
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

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

  Widget _buildProfileInfoContainer(IconData icon, String label, String value) {
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
            offset: Offset(0, 3), // changes position of shadow
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
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
