import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatPage extends StatefulWidget {
  final String sender;
  final String receiver;

  const ChatPage({
    Key? key,
    required this.sender,
    required this.receiver,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late StompClient stompClient;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  String? _chatRoomId;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _chatRoomId = _generateChatRoomId(widget.sender, widget.receiver);
    _connectToWebSocket();
  }

  @override
  void dispose() {
    stompClient.deactivate();
    _messageController.dispose();
    super.dispose();
  }

  String _generateChatRoomId(String sender, String receiver) {
    List<String> users = [sender, receiver];
    users.sort();
    return '${users[0]}_${users[1]}';
  }

  void _connectToWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://192.168.29.166:7078/websocket',
        onConnect: (StompFrame frame) {
          setState(() {
            _isConnected = true;
          });

          // Subscribe to private chat topic
          stompClient.subscribe(
            destination: '/topic/private/$_chatRoomId',
            callback: (StompFrame frame) {
              final message = ChatMessage.fromJson(json.decode(frame.body!));
              setState(() {
                _messages.add(message);
              });
            },
          );
        },
        onDisconnect: (StompFrame frame) {
          setState(() {
            _isConnected = false;
          });
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket Error: $error');
        },
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
      ),
    );

    stompClient.activate();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      content: _messageController.text,
      sender: widget.sender,
      receiver: widget.receiver,
      chatRoomId: _chatRoomId!,
      type: 'TEXT',
      timestamp: DateTime.now().toIso8601String(),
    );

    _messageController.clear();

    // Send via STOMP
    stompClient.send(
      destination: '/app/chat.send',
      body: json.encode(message.toJson()),
      headers: {},
    );
  }

  Future<void> _sendFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final fileName = result.files.single.name;
      final fileSize = file.lengthSync();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // Convert file to base64
      final base64File = base64Encode(bytes);

      // Create message with file data
      final message = ChatMessage(
        content: '', // Will be replaced with file URL on server
        sender: widget.sender,
        receiver: widget.receiver,
        chatRoomId: _chatRoomId!,
        type: 'FILE',
        fileName: fileName,
        fileSize: fileSize,
        fileType: mimeType,
        timestamp: DateTime.now().toIso8601String(),
      );

      // Send via STOMP with file headers
      stompClient.send(
        destination: '/app/chat.send',
        body: json.encode(message.toJson()),
        headers: {
          'fileData': 'data:$mimeType;base64,$base64File',
          'fileName': fileName,
          'fileType': mimeType,
          'fileSize': fileSize.toString(),
        },
      );
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.sender == widget.sender;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == 'FILE')
              _buildFileMessage(message)
            else
              Text(
                message.content ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileMessage(ChatMessage message) {
    final fileUrl = message.content ?? '';
    final fileName = message.fileName ?? 'file';
    final fileSize = message.fileSize ?? 0;
    final fileType = message.fileType ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fileType.startsWith('image/'))
          GestureDetector(
            onTap: () => _showFullScreenImage(fileUrl),
            child: Image.network(
              'http://142.93.221.34:7078$fileUrl',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image);
              },
            ),
          )
        else
          Row(
            children: [
              const Icon(Icons.insert_drive_file, size: 40),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_formatFileSize(fileSize)),
                ],
              ),
            ],
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _downloadFile(fileUrl, fileName),
          child: const Text('Download'),
        ),
      ],
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _showFullScreenImage(String imageUrl) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.network(
              'http://142.93.221.34:7078$imageUrl',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      final response = await http.get(
        Uri.parse('http://142.93.221.34:7078$fileUrl'),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getDownloadsDirectory();
        final filePath = '${directory?.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to $filePath')),
        );
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiver}'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {
              if (!_isConnected) {
                _connectToWebSocket();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(
                  _messages[_messages.length - 1 - index],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _sendFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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

class ChatMessage {
  final String? content;
  final String sender;
  final String receiver;
  final String chatRoomId;
  final String type; // TEXT, FILE
  final String? timestamp;
  final String? fileName;
  final int? fileSize;
  final String? fileType;

  ChatMessage({
    this.content,
    required this.sender,
    required this.receiver,
    required this.chatRoomId,
    required this.type,
    this.timestamp,
    this.fileName,
    this.fileSize,
    this.fileType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'],
      sender: json['sender'],
      receiver: json['receiver'],
      chatRoomId: json['chatRoomId'],
      type: json['type'],
      timestamp: json['timestamp'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      fileType: json['fileType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'receiver': receiver,
      'chatRoomId': chatRoomId,
      'type': type,
      'timestamp': timestamp,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
    };
  }
}
