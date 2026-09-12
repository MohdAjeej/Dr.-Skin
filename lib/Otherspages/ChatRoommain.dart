import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class Message {
  final String message;
  final String senderId;
  final String time;

  Message({required this.message, required this.senderId, required this.time});
}

class ChatRoom extends StatefulWidget {
  ChatRoom({Key? key}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String userUid = 'sampleUserId'; // Static user ID
  final String userName = 'Sample User'; // Static user name

  List<Message> messages = [
    Message(
        message: "Hello!",
        senderId: 'sampleUserId',
        time: DateTime.now().toUtc().toString()),
    Message(
        message: "How are you?",
        senderId: 'user2Id',
        time: DateTime.now().toUtc().toString()),
  ];

  bool _canSendMessage() {
    return _messageController.text.isNotEmpty;
  }

  void _sendMessage() {
    if (_canSendMessage()) {
      var currTime = DateTime.now().toUtc().toString();
      final message = Message(
        message: _messageController.text,
        senderId: userUid,
        time: currTime,
      );
      setState(() {
        messages.add(message);
      });
      _messageController.clear();
      _scrollController.jumpTo(_scrollController
          .position.maxScrollExtent); // Scroll to bottom after sending message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Typicons.chevron_left), // Change back icon using Typicons
          onPressed: () {
            Navigator.pop(context); // Return to previous screen
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/414.jpg"),
            ),
            const SizedBox(width: 10),
            Text("User Two"), // Replace with dynamic name
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(2.0),
        //   child: Container(
        //     height: 2.0, // Thickness of the border
        //     color: Colors.grey.shade300, // Border color
        //   ),
        // ),
      ),
      body: Column(
        children: [
          _getMessageList(),
        ],
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              offset: Offset(0, -2), // Shadow position (top shadow)
              blurRadius: 5, // Blur radius for a softer shadow
            ),
          ],
          color: Colors.white,
        ), // Set the background color to white
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 60,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 10),
                      const Icon(Icons.insert_emoticon),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type a message...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMessageList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return MessageWidget(
            message: message.message,
            time: message.time,
            isMe: message.senderId == userUid,
          );
        },
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const MessageWidget({
    Key? key,
    required this.message,
    required this.time,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.fromLTRB(isMe ? 60 : 8, 5, isMe ? 8 : 60, 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: isMe ? const Radius.circular(15) : Radius.zero,
            topRight: isMe ? Radius.zero : const Radius.circular(15),
            bottomLeft: const Radius.circular(15),
            bottomRight: const Radius.circular(15),
          ),
          color: isMe ? Colors.blue[300] : Color.fromARGB(255, 141, 209, 150),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time.substring(11, 16), // Only display the time part (HH:MM)
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
