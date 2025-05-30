
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talksy/service/chatService.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  void loadMessages() async {
    final msgs = await chatService.getMessages(widget.currentUserId, widget.receiverId);
    print("Loaded messages: $msgs");
     if (!mounted) return;
  setState(() {
    messages = List<Map<String, dynamic>>.from(msgs); // Ensure a new list reference
  });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> msg) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(msg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(msg);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editMessage(Map<String, dynamic> msg) {
    final TextEditingController editController = TextEditingController(text: msg['text']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Enter new message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              print("Editing message: $newText");
              print("Message ID: ${msg['id']}");
              if (newText.isEmpty) return;
              Navigator.pop(context);
              await chatService.editMessage(
                context: context,
                messageId: msg['id'],
                newContent: newText,
              );
              loadMessages();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(Map<String, dynamic> msg) async {
    print("Deleting message with ID: ${msg['id']}");
    await chatService.deleteMessage(
      context: context,
      messageId: msg['id'],
    );
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMine = msg['sender'] == widget.currentUserId;
                return GestureDetector(
                  onLongPress: isMine ? () => _showMessageOptions(context, msg) : null,
                  child: Align(
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
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.Hm().format(DateTime.parse(msg['createdAt'])),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMine ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
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
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
