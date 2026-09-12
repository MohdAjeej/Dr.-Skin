// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:O2ISkinSense/Api/ApiService.dart';
// import 'package:O2ISkinSense/Scheduled%20and%20videocall/Callpage.dart';

// class ScheduledMeetingsPage extends StatefulWidget {
//   const ScheduledMeetingsPage({Key? key}) : super(key: key);

//   @override
//   _ScheduledMeetingsPageState createState() => _ScheduledMeetingsPageState();
// }

// class _ScheduledMeetingsPageState extends State<ScheduledMeetingsPage> {
//   List<dynamic> appointments = [];
//   bool isLoading = true;

//   // Fetch appointments from the API
//   Future<void> fetchAppointments() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Clear stored tokens

//     // String userid =(await prefs.remove("userId")) as String;
//     final response = await http.get(
//       Uri.parse(
//           '${ApiService.baseUrl}/api/appointments/get-all-appoinment/${await prefs.getString("userId").toString()}'),
//       headers: {'Content-Type': 'application/json'},
//     );
//     print(
//         'Failed to load appointments  ${response.body}  ${await prefs.getString("userId").toString()} ');
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       setState(() {
//         appointments = data;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       // Handle the error
//       print('Failed to load appointments');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchAppointments();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? Center(
//               child:
//                   CircularProgressIndicator()) // Show loader while fetching data
//           : ListView.builder(
//               itemCount: appointments.length,
//               itemBuilder: (context, index) {
//                 final appointment = appointments[index];
//                 final doctorName = appointment['doctorName'];
//                 final startTime = appointment['startTime'];
//                 final endTime = appointment['endTime'];
//                 final appointmentId = appointment['appointmentId'];

//                 return _buildMeetingCard(
//                   context,
//                   doctorName,
//                   startTime,
//                   endTime,
//                   appointmentId,
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildMeetingCard(
//     BuildContext context,
//     String doctorName,
//     String startTime,
//     String endTime,
//     int appointmentId,
//   ) {
//     // Get the current time
//     final currentTime = DateTime.now();
//     // Parse the appointment start time to a DateTime object
//     final appointmentDateTime = DateTime.parse(
//         '2025-02-11 $startTime'); // Assuming the date format is 'YYYY-MM-DD HH:mm'

//     // Check if the current time is greater than or equal to the start time
//     bool canJoinMeeting = currentTime.isAfter(appointmentDateTime) ||
//         currentTime.isAtSameMomentAs(appointmentDateTime);

//     return Card(
//       color: Colors.blueGrey[50],
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//       child: ListTile(
//         title: Text(
//           doctorName,
//         ),
//         subtitle: Text(
//           'Time: $startTime - $endTime',
//           style: TextStyle(
//             color: Color.fromARGB(255, 174, 27, 22),
//           ),
//         ),
//         trailing: Icon(
//           Icons.video_call,
//           color: Colors.blue.withOpacity(0.7),
//           size: 30,
//         ),
//         onTap: canJoinMeeting
//             ? () async {
//                 final prefs = await SharedPreferences.getInstance();

//                 final username = prefs.getString("username");
//                 final userId = prefs.getString("userId");
//                 // Navigate to video call screen, passing the appointmentId, userId, and userName
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CallScreen(
//                       callID: appointmentId.toString(),
//                       userID:
//                           '${userId}', // Static userID as per the requirement
//                       userName:
//                           "${username}", // Static userName as per the requirement
//                     ),
//                   ),
//                 );
//               }
//             : null, // Disable the tap if the current time is not valid
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Scheduled%20and%20videocall/Callpage.dart';

class ScheduledMeetingsPage extends StatefulWidget {
  const ScheduledMeetingsPage({Key? key}) : super(key: key);

  @override
  _ScheduledMeetingsPageState createState() => _ScheduledMeetingsPageState();
}

class _ScheduledMeetingsPageState extends State<ScheduledMeetingsPage> {
  List<dynamic> appointments = [];
  bool isLoading = true;

  // Fetch appointments from API
  Future<void> fetchAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = await prefs.getString("jwtToken");
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/appointments/get-all-appoinment'),
      headers: {'Auth': 'Bearer $token'},
    );
    print('Failed to load dsvgfhgkjukuiloiuoldfhf  ${response.body}  $token');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        appointments = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load appointments');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Scheduled Meetings',
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
          : appointments.isEmpty
              ? Center(
                  child: Text(
                    "No scheduled meetings",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final doctorName = appointment['username'];
                    final startTime = appointment['startTime'];
                    final endTime = appointment['endTime'];
                    final appointmentId = appointment['appointmentId'];
                    print("FDBHfghfgjghjkhgk ${'Time: $startTime - $endTime'}");
                    return _buildMeetingCard(
                      context,
                      doctorName,
                      startTime,
                      endTime,
                      appointmentId,
                    );
                  },
                ),
    );
  }

// Function to get a random color from a fixed list
  Color getRandomFixedColor() {
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

  Widget _buildMeetingCard(
    BuildContext context,
    String doctorName,
    String startTime,
    String endTime,
    int appointmentId,
  ) {
    final currentTime = DateTime.now();
    final appointmentDateTime = DateTime.parse('2025-02-11 $startTime');

    bool canJoinMeeting = currentTime.isAfter(appointmentDateTime) ||
        currentTime.isAtSameMomentAs(appointmentDateTime);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: getRandomFixedColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.video_call,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Time: $startTime - $endTime',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canJoinMeeting
                ? () async {
                    final prefs = await SharedPreferences.getInstance();
                    final username = prefs.getString("username");
                    final userId = prefs.getString("userId");
                    print(
                        "vfdghbfdhnfgjgfjmf id ${appointmentId.toString()} , ${userId ?? ''}, ${username ?? ''}");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallScreen(
                          callID: appointmentId.toString(),
                          userID: userId ?? '',
                          userName: username ?? '',
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canJoinMeeting ? Colors.blue : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Join"),
          ),
        ],
      ),
    );
  }
}
