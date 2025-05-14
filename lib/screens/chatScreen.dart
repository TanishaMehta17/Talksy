import 'package:flutter/material.dart';
import 'package:talksy/service/chatService.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();
  List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  void loadMessages() async {
    final msgs = await chatService.getMessages(widget.currentUserId, widget.receiverId);
    setState(() => messages = msgs);
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    chatService.sendMessage(
      context: context,
      senderId: widget.currentUserId,
      receiverId: widget.receiverId,
      content: text,
      callback: (success, _) {
        if (success) {
          messageController.clear();
          loadMessages();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMine = msg['sender'] == widget.currentUserId;
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(color: isMine ? Colors.white : Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat.Hm().format(DateTime.parse(msg['createdAt'])),
                          style: TextStyle(fontSize: 10, color: isMine ? Colors.white70 : Colors.black54),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
