import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class UserSelectionPage extends StatefulWidget {
  @override
  _UserSelectionPageState createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();

  void _startChat() {
    String sender = _senderController.text.trim();
    String receiver = _receiverController.text.trim();

    if (sender.isNotEmpty && receiver.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(sender: sender, receiver: receiver),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both usernames")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Enter Usernames")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _senderController,
              decoration: InputDecoration(labelText: "Your Username"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _receiverController,
              decoration: InputDecoration(labelText: "Receiver Username"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startChat,
              child: Text("Start Chat"),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String sender;
  final String receiver;

  const ChatPage({Key? key, required this.sender, required this.receiver})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late StompClient _stompClient;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  late String roomId;
  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url:
            "http://142.93.221.34:7078/websocket", // Replace with your backend URL
        onConnect: _onWebSocketConnected,
        onDisconnect: (frame) => print("Disconnected"),
        onWebSocketError: (dynamic error) => print("Error: $error"),
      ),
    );
    _stompClient.activate();
  }

  void _onWebSocketConnected(StompFrame frame) {
    setState(() {
      roomId = _generateChatRoomId(widget.sender, widget.receiver);
    });

    _stompClient.subscribe(
      destination: "/topic/private/$roomId",
      callback: (StompFrame frame) {
        if (frame.body != null) {
          Map<String, dynamic> receivedMessage = jsonDecode(frame.body!);

          // Only add the message if it's from the other user
          if (receivedMessage["sender"] != widget.sender) {
            setState(() {
              _messages.add({
                "sender": receivedMessage["sender"],
                "content": receivedMessage["content"],
              });
            });
          }
        }
      },
    );
  }

  // void _onWebSocketConnected(StompFrame frame) {
  //   setState(() {
  //     roomId = _generateChatRoomId(widget.sender, widget.receiver);
  //   });

  //   _stompClient.subscribe(
  //     destination: "/topic/private/$roomId",
  //     callback: (StompFrame frame) {
  //       if (frame.body != null) {
  //         final message = {
  //           "sender": widget.receiver,
  //           "content": frame.body!,
  //         };
  //         setState(() {
  //           _messages.add(message);
  //         });
  //       }
  //     },
  //   );
  // }
// Add this at the top

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    String roomId = _generateChatRoomId(widget.sender, widget.receiver);

    final message = {
      "sender": widget.sender,
      "receiver": widget.receiver,
      "content": _messageController.text,
      "type": "CHAT",
      "chatRoomId": roomId
    };

    String jsonMessage = jsonEncode(message); // Convert Map to JSON string

    print("Sending message: $jsonMessage");

    _stompClient.send(
      destination: "/app/chat.send",
      body: jsonMessage, // Send as JSON
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
  }

  // void _sendMessage() {
  //   if (_messageController.text.isEmpty) return;
  //   print("dsgfdhgfjhgfjghkhjkjh ${(widget.sender, widget.receiver)}");
  //   String roomId = _generateChatRoomId(widget.sender, widget.receiver);

  //   final message = {
  //     "sender": "${widget.sender}",
  //     "receiver": "${widget.receiver}",
  //     "content": "${_messageController.text}",
  //     "type": "CHAT",
  //     "chatRoomId": "abhi_raj"
  //   };
  //   print("dgdgdhdhhdhdjdj ${message} $roomId");
  //   _stompClient.send(
  //     destination: "/app/chat.send",
  //     body: message.toString(),
  //   );

  //   setState(() {
  //     _messages.add(message);
  //   });

  //   _messageController.clear();
  // }

  String _generateChatRoomId(String user1, String user2) {
    return (user1.compareTo(user2) < 0) ? "$user1\_$user2" : "$user2\_$user1";
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chat with ${widget.receiver}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isMe = message["sender"] == widget.sender;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["content"]!,
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
