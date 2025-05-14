import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talksy/providers/userProvider.dart';
import 'package:talksy/screens/chatScreen.dart';
import 'package:talksy/service/chatService.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService chatService = ChatService();
  List<dynamic> recentChats = [];
  Map<String, int> unreadMap = {};
  final TextEditingController searchController = TextEditingController();
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely access context in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentUserId = Provider.of<UserProvider>(context, listen: false).user.id;
      fetchChats();
    });
  }

  Future<void> fetchChats() async {
    final chats = await chatService.getRecentMessages(currentUserId);
    final unread = await chatService.getUnreadCount();
    setState(() {
      recentChats = chats;
      unreadMap = unread;
    });
  }

  void onChatTap(String name, String id) async {
    await chatService.markMessagesAsRead(
      senderId: id,
      receiverId: currentUserId,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          currentUserId: currentUserId,
          receiverId: id,
          receiverName: name,
        ),
      ),
    ).then((_) => fetchChats());
  }

  void onSearch(String userId) async {
    await chatService.searchUser(
      context: context,
      senderId: currentUserId,
      receiverId: userId,
    );
    fetchChats();
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Talksy')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search user ID...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => onSearch(searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recentChats.length,
              itemBuilder: (context, index) {
                final chat = recentChats[index];
                final isSender = chat['sender']['_id'] == currentUserId;
                final name = isSender
                    ? chat['receiver']['username']
                    : chat['sender']['username'];
                final id = isSender
                    ? chat['receiver']['_id']
                    : chat['sender']['_id'];
                final unreadCount = unreadMap[id] ?? 0;

                return ListTile(
                  title: Text(name),
                  subtitle: Text(chat['content']),
                  trailing: unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => onChatTap(name, id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
