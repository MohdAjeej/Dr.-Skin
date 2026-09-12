import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:O2ISkinSense/Api/ApiService.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatRoomPage extends StatefulWidget {
  final String sender;
  final String chatroomid;
  final String receiver;

  const ChatRoomPage({
    Key? key,
    required this.sender,
    required this.receiver,
    required this.chatroomid,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late StompClient _stompClient;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  PlatformFile? _selectedFile;
  String? _fileName;
  String? _fileType;
  int? _fileSize;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _fetchChatHistory();
  }

  void _fetchChatHistory() async {
    String roomId = widget.chatroomid;
    String apiUrl = "${ApiService.baseUrl}/api/chat/history?chatRoomId=$roomId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> messages = data["messages"];
        print("Edfvgfdhgfhgf $messages ");
        setState(() {
          _messages.addAll(messages.map((msg) => {
                "sender": msg["sender"],
                "content": msg["content"],
                "type": msg["type"] ??
                    (msg["content"].toString().startsWith('/download/')
                        ? "FILE"
                        : "TEXT"),
                "fileName": msg["fileName"],
                "timestamp": msg["timestamp"],
              }));
        });
        _scrollToBottom();
      }
    } catch (e) {
      print("Error fetching chat history: $e");
    }
  }

  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: "${ApiService.baseUrl}/websocket",
        onConnect: _onWebSocketConnected,
        onDisconnect: (frame) => print("Disconnected"),
        onWebSocketError: (dynamic error) => print("Error: $error"),
      ),
    );
    _stompClient.activate();
  }

  void _onWebSocketConnected(StompFrame frame) {
    _stompClient.subscribe(
      destination: "/topic/private/${widget.chatroomid}",
      callback: (StompFrame frame) {
        if (frame.body != null) {
          Map<String, dynamic> receivedMessage = jsonDecode(frame.body!);

          // Check if this message is from ourselves (already in UI)
          bool isDuplicate = _messages.any((msg) =>
              msg["sender"] == receivedMessage["sender"] &&
              msg["content"] == receivedMessage["content"] &&
              msg["timestamp"] == receivedMessage["timestamp"]);

          if (!isDuplicate) {
            setState(() {
              _messages.add({
                "sender": receivedMessage["sender"],
                "content": receivedMessage["content"],
                "type": receivedMessage["type"],
                "fileName": receivedMessage["fileName"],
                "timestamp": receivedMessage["timestamp"],
              });
            });
            _scrollToBottom();
          }
        }
      },
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _fileName = _selectedFile!.name;
        _fileType = _selectedFile!.extension;
        _fileSize = _selectedFile!.size;
      });
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null || _selectedFile!.path == null) return null;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path!,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        return responseBody.trim(); // Returns the download URL
      } else {
        print('File upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty && _selectedFile == null) return;

    String? fileUrl;
    if (_selectedFile != null) {
      fileUrl = await _uploadFile();
      if (fileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file')),
        );
        return;
      }
    }

    final chatMessage = {
      "sender": widget.sender,
      "receiver": widget.receiver,
      "chatRoomId": widget.chatroomid,
      "content": fileUrl ?? _messageController.text,
      "type": fileUrl != null ? "FILE" : "TEXT",
      "timestamp": DateTime.now().toIso8601String(),
    };

    if (fileUrl != null) {
      chatMessage.addAll({
        "fileData": fileUrl,
        "fileName": _fileName!,
        "fileType": _getMimeTypeFromExtension(_fileType ?? ''),
        "fileSize": _fileSize!.toString(),
      });
    }

    // Send the message
    _stompClient.send(
      destination: "/app/chat.send",
      body: jsonEncode(chatMessage),
    );

    // Clear inputs
    _messageController.clear();
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _fileType = null;
      _fileSize = null;
    });
  }

  String _getMimeTypeFromExtension(String ext) {
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'txt': 'text/plain',
      'zip': 'application/zip'
    };

    return mimeTypes[ext.toLowerCase()] ?? 'application/octet-stream';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse("${ApiService.baseUrl}$url"));
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);
      OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
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
        backgroundColor: Colors.grey[200],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: Icon(Typicons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(backgroundImage: AssetImage("assets/414.jpg")),
            const SizedBox(width: 10),
            Text(widget.receiver),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isMe = message["sender"] == widget.sender;
                String? messageType = message["type"];

                Widget contentWidget;
                if (messageType == "FILE") {
                  String fileUrl = message["content"];
                  String? fileName = message["fileName"];

                  if (fileUrl.toLowerCase().endsWith('.png') ||
                      fileUrl.toLowerCase().endsWith('.jpg') ||
                      fileUrl.toLowerCase().endsWith('.jpeg')) {
                    contentWidget = GestureDetector(
                      onTap: () => _downloadFile(fileUrl, fileName ?? "image"),
                      child: CachedNetworkImage(
                        imageUrl: "${ApiService.baseUrl}$fileUrl",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  } else {
                    contentWidget = InkWell(
                      onTap: () => _downloadFile(fileUrl, fileName ?? "file"),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                fileName ?? "File",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                } else {
                  contentWidget = Text(
                    message["content"],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  );
                }

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin:
                        EdgeInsets.fromLTRB(isMe ? 60 : 8, 5, isMe ? 8 : 60, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: isMe ? const Radius.circular(15) : Radius.zero,
                        topRight:
                            isMe ? Radius.zero : const Radius.circular(15),
                        bottomLeft: const Radius.circular(15),
                        bottomRight: const Radius.circular(15),
                      ),
                      color: isMe
                          ? Colors.blue[300]
                          : const Color.fromARGB(255, 141, 209, 150),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        contentWidget,
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message["timestamp"]),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80)
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
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, -2),
              blurRadius: 5,
            ),
          ],
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickFile,
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
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.chat),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type a message...',
                          ),
                        ),
                      ),
                      if (_selectedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            _fileName ?? 'File',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
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

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
