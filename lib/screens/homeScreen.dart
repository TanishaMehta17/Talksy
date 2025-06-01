
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentUserId = Provider.of<UserProvider>(context, listen: false).user.id;
      fetchChats();
    });
  }

  Future<void> fetchChats() async {
    final chats = await chatService.getRecentMessages(currentUserId);
   final unread = await chatService.getUnreadCount(currentUserId);
    setState(() {
      recentChats = chats;
      unreadMap = unread;
    });
  }

  void onChatTap(String name, String id) async {
    print("Tapping on chat with $name and id $id");
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

  
void onSearchByEmail(String email) async {
  final response = await chatService.searchUserByEmail(
    context: context,
    senderId: currentUserId,
    receiverEmail: email,
  );

  if (response != null && response['chat'] != null) {
    final chat = response['chat'];
    final name = chat['receiverName'];
    final id = chat['receiverId'];

    await fetchChats(); // FIX: Refresh full chat list from backend
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
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user found with this email')),
    );
  }

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
                hintText: 'Search by email...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => onSearchByEmail(searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recentChats.length,
              itemBuilder: (context, index) {
                final chat = recentChats[index];
                final isCurrentUserSender =
                    chat['sender']['id'] == currentUserId;
                final otherUser =
                    isCurrentUserSender ? chat['receiver'] : chat['sender'];
                final name = otherUser['username'];
                final id = otherUser['id'];
                final unreadCount = unreadMap[id] ?? 0;

                return ListTile(
                  title: Text(name),
                  subtitle: Text(chat['content'] ?? ""),
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
