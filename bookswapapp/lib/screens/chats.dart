import 'package:flutter/material.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: [
          _buildChatItem('John Doe', 'Hey, is this book still available?', '2 min ago'),
          _buildChatItem('Sarah Smith', 'I have the book you were looking for!', '1 hour ago'),
          _buildChatItem('Mike Johnson', 'When can we meet for the swap?', '3 hours ago'),
          _buildChatItem('BookSwap Support', 'Welcome to BookSwap!', '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildChatItem(String name, String lastMessage, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.grey[600]),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, overflow: TextOverflow.ellipsis),
      trailing: Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: () {
        // Navigate to chat conversation
      },
    );
  }
}