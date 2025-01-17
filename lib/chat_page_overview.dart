import 'package:customer/app/models/chat_model/chat_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatPageOverview extends StatefulWidget {
  final String studentId;
  final String teacherId;
  final String studentName;
  final String teacherName;
  final bool showAppBar;

  const ChatPageOverview({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.teacherName,
    required this.showAppBar,
  });

  @override
  State<ChatPageOverview> createState() => _ChatPageOverviewState();
}

class _ChatPageOverviewState extends State<ChatPageOverview> {
  final _rtdb = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://my-taxi-customer-c4c9b-default-rtdb.firebaseio.com/',
  );
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();

  Stream<List<ChatModel>> get _chatStream => _rtdb
      .ref()
      .child('/chat/${widget.studentId}_75S_${widget.teacherId}')
      .orderByKey()
      .onValue
      .map(_transformSnapshot);

  List<ChatModel> _transformSnapshot(DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>;
    final messages = data.values
        .map((value) =>
            _fromJsonMap(Map<String, dynamic>.from(value['message'])))
        .toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  ChatModel _fromJsonMap(Map<String, dynamic> json) {
    return ChatModel(
      from: json['from'],
      to: json['to'],
      inputType: json['inputType'],
      message: json['message'],
      receiverName: json['receiverName'],
      senderName: json['senderName'],
      isDeleted: json['isDeleted'] ?? false,
      timestamp: json['timestamp'],
    );
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final message = {
      "message": {
        "from": widget.studentId,
        "inputType": "text",
        "message": _messageController.text,
        "senderName": widget.studentName,
        "receiverName": widget.teacherName,
        "to": widget.teacherId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "isDeleted": false,
      },
      "studentId": widget.studentId,
      "teacherId": widget.teacherId,
    };

    _rtdb
        .ref()
        .child('/chat/${widget.studentId}_75S_${widget.teacherId}')
        .push()
        .set(message);

    _messageController.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? _buildAppBar() : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatModel>>(
                stream: _chatStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('No Messages'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(messages[index]),
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        widget.studentName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatModel message) {
    final isMe = message.from == widget.studentId;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.grey[300] : Colors.white,
              border: isMe ? null : Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              message.message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Write message...",
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Colors.blue,
            elevation: 0,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
