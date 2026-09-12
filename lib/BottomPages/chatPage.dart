import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:O2ISkinSense/Components/color.dart';
import 'dart:convert';
import 'package:O2ISkinSense/Otherspages/ChatRoommain.dart';
import 'package:O2ISkinSense/Otherspages/NotificationPage.dart';
import 'package:O2ISkinSense/Otherspages/ScheduledMeetingsPage.dart';
import 'package:O2ISkinSense/Otherspages/chatroompage.dart';
import 'package:O2ISkinSense/Otherspages/temp.dart';

class Chats extends StatefulWidget {
  Chats({Key? key}) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List<Map<String, String>> chatList = [];

  @override
  void initState() {
    super.initState();
    fetchChatRooms();
  }

  Future<void> fetchChatRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwtToken");
    String? username = prefs.getString("username");
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/chat/rooms?user=$username'),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print("Decoded Data: $data");

      setState(() {
        chatList = data
            .map((chat) {
              bool isReceiver = username == chat['receiver'].toString();

              return {
                'chatRoomId': chat['chatRoomId'].toString(),
                'receiver': isReceiver
                    ? chat['sender'].toString()
                    : chat['receiver'].toString(),
                'sender': isReceiver
                    ? chat['receiver'].toString()
                    : chat['sender'].toString(),
                'lastMessageDate': chat['timestamp'].toString().split(' ')[0],
                'lastMessageTime': chat['timestamp'].toString().split(' ')[1],
              };
            })
            .toList()
            .cast<Map<String, String>>();
// Ensure the correct type
      });
    } else {
      print('Failed to load chat rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            _buildModernHeader(),
            Expanded(
              child: chatList.isEmpty
                  ? _buildEmptyState()
                  : _getChatList(),
            ),
            _buildScheduledMeetingsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Messages",
            style: TextStyle(
              color: textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: textPrimary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No conversations yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Start a conversation with a doctor\nto get medical advice",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getChatList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ChatCard(
              userId: chat['chatRoomId'] ?? 'No id',
              profileUrl: 'assets/person.jpg',
              receiver: chat['receiver'] ?? 'Unknown',
              sender: chat['sender'] ?? 'Unknown',
              lastMessageDate: chat['lastMessageDate'] ?? 'Unknown',
              lastMessageTime: chat['lastMessageTime'] ?? 'Unknown',
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduledMeetingsCard() {
    return Container(
      margin: EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScheduledMeetingsPage()),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.video_call,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled Meetings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your upcoming doctor consultations',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final String userId;
  final String profileUrl;
  final String receiver;
  final String sender;
  final String lastMessageDate;
  final String lastMessageTime;

  const ChatCard({
    Key? key,
    required this.userId,
    required this.profileUrl,
    required this.receiver,
    required this.sender,
    required this.lastMessageDate,
    required this.lastMessageTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              chatroomid: userId,
              sender: sender,
              receiver: receiver,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Avatar with Online Status
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(profileUrl),
                    backgroundColor: backgroundColor,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: successColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(width: 16),
            
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receiver,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Tap to continue conversation",
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Time and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lastMessageTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    lastMessageDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
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
}
