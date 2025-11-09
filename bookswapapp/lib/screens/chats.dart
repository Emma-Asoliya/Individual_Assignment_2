import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswapapp/models/chat.dart'; 
import 'conversation.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: _currentUser == null
          ? Center(
              child: Text(
                'Please log in to view chats',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('participants', arrayContains: _currentUser!.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.red));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading chats',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final chats = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data() as Map<String, dynamic>;
                    return _buildChatItem(chat, chats[index].id);
                  },
                );
              },
            ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat, String chatId) {
    final currentUserId = _currentUser!.uid;
    final otherParticipantId = _getOtherParticipant(chat['participants'], currentUserId);
    
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(otherParticipantId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: CircularProgressIndicator(color: Colors.red),
            ),
            title: Text('Loading...'),
          );
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return _buildChatListItem(
            name: 'Unknown User',
            lastMessage: chat['lastMessage'] ?? '',
            time: _formatTimestamp(chat['lastMessageTime']),
            onTap: () {},
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? userData['email']?.split('@').first ?? 'Unknown User';

        return _buildChatListItem(
          name: userName,
          lastMessage: chat['lastMessage'] ?? 'No messages yet',
          time: _formatTimestamp(chat['lastMessageTime']),
          onTap: () {
            _navigateToChat(chatId, otherParticipantId, userName);
          },
        );
      },
    );
  }

  Widget _buildChatListItem({
    required String name,
    required String lastMessage,
    required String time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.grey[600]),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, overflow: TextOverflow.ellipsis),
      trailing: Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: onTap,
    );
  }

  String _getOtherParticipant(List<dynamic> participants, String currentUserId) {
    for (var participant in participants) {
      if (participant != currentUserId) {
        return participant;
      }
    }
    return '';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      final DateTime time = timestamp is Timestamp 
          ? timestamp.toDate() 
          : DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 1) return 'Now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      
      return '${time.month}/${time.day}/${time.year}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation by requesting a book swap!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToChat(String chatId, String otherUserId, String otherUserName) {

    print('Navigate to chat: $chatId with $otherUserName');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversation(
          chatId: chatId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        ),
      ),
    );
  }
}