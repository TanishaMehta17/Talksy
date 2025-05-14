import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talksy/common/global_varibale.dart';

class ChatService {
 

  Future<void> sendMessage({
    required BuildContext context,
    required String senderId,
    required String receiverId,
    required String content,
    required Function(bool success, Map<String, dynamic>? response) callback,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$uri/api/chat/messages'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        callback(true, data); // Successful response
      } else {
        print("Error sending message: ${response.body}");
        callback(false, null); // Failure response
      }
    } catch (e) {
      print("Exception sending message: $e");
      callback(false, null); // Exception occurred
    }
  }

  
  Future<List<Map<String, dynamic>>> getMessages(String senderId, String receiverId) async {
    try {
      final response = await http.get(Uri.parse(
        '$uri/messages?senderId=$senderId&receiverId=$receiverId',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((msg) => {
          'text': msg['content'],
          'sender': msg['senderId'],
          'receiver': msg['receiverId'],
          'createdAt': msg['createdAt'],
          'senderName': msg['sender']['username'],
          'receiverName': msg['receiver']['username'],
        }).toList();
      } else {
        debugPrint('Failed to load messages: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return [];
    }
  }

  Future<List<dynamic>> getChatUsers(String userId) async {
  final response = await http.get(
    Uri.parse('$uri/api/chat/chat-users?userId=$userId'),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load chat users');
  }
}

Future<void> searchUser({
  required BuildContext context,
  required String senderId,
  required String receiverId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$uri/api/chat/new-chat'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'senderId': senderId,
        'receiverId': receiverId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Chat initiated')),
      );
    } else {
      throw Exception('Failed to start new chat');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
Future<void> editMessage({
  required BuildContext context,
  required String messageId,
  required String newContent,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$uri/api/chat/edit-message'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'messageId': messageId,
        'newContent': newContent,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message edited successfully')),
      );
    } else {
      throw Exception('Failed to edit message');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
Future<void> deleteMessage({
  required BuildContext context,
  required String messageId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$uri/api/chat/delete-message'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'messageId': messageId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted successfully')),
      );
    } else {
      throw Exception('Failed to delete message');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
Future<Map<String, int>> getUnreadCount() async {
  try {
    final response = await http.get(
      Uri.parse('$uri/api/chat/unread-count'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final Map<String, int> unreadMap = {
        for (var entry in jsonData)
          entry['senderId'] as String: entry['count'] as int
      };
      return unreadMap;
    } else {
      throw Exception('Failed to fetch unread message count');
    }
  } catch (e) {
    print('Error fetching unread count: $e');
    return {};
  }
}
Future<bool> markMessagesAsRead({
  required String senderId,
  required String receiverId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$uri/api/chat/mark-messages-as-read'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['message'] == 'Messages marked as read';
    } else {
      print('Failed to mark messages as read: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error marking messages as read: $e');
    return false;
  }
}
Future<List<dynamic>> getRecentMessages(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$uri/api/chat/recent-messages?userId=$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      print('Failed to fetch recent messages: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error fetching recent messages: $e');
    return [];
  }
}


}
