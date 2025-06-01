import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talksy/common/global_varibale.dart';
import 'package:talksy/service/chatService.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    initSocket();
    loadMessages();
  }

  void initSocket() {
    socket = IO.io(
      '$uri', // Replace with your actual backend host
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setQuery({
            'userId': widget.currentUserId,
          })
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print("Connected to socket server");
      socket!.emit("join", {'userId': widget.currentUserId});
    });

    socket!.on("receiveMessage", (data) {
      print("Received via socket: $data");
      if (data['sender'] == widget.receiverId) {
        setState(() {
          messages.add(Map<String, dynamic>.from(data));
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    socket!.onDisconnect((_) => print("Disconnected from socket"));
  }

  void loadMessages() async {
    final msgs =
        await chatService.getMessages(widget.currentUserId, widget.receiverId);
    if (!mounted) return;
    setState(() {
      messages = List<Map<String, dynamic>>.from(msgs);
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
     
      callback: (success, sentMsg) {
  if (success && sentMsg != null) {
    messageController.clear();
    // Normalize key for UI logic
    sentMsg['sender'] = sentMsg['senderId']; // This line is important!
    setState(() {
      messages.add(Map<String, dynamic>.from(sentMsg));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    socket?.emit("sendMessage", {
      'id': sentMsg['id'],
      'sender': widget.currentUserId,
      'receiver': widget.receiverId,
      'text': sentMsg['content'],
      'createdAt': sentMsg['createdAt'],
    });
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
    final TextEditingController editController =
        TextEditingController(text: msg['text']);
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
    print(msg['id']);
    await chatService.deleteMessage(
      context: context,
      messageId: msg['id'],
    );
    loadMessages();
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                print(msg['sender']);
                final isMine = msg['sender'] == widget.currentUserId;
                return GestureDetector(
                  onLongPress:
                      isMine ? () => _showMessageOptions(context, msg) : null,
                  child: Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMine ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                           msg['text'] ?? msg['content'] ,
                            style: TextStyle(
                                color: isMine ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.Hm()
                                .format(DateTime.parse(msg['createdAt'])),
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
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
