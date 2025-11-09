// lib/models/chat.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSender;
  final DateTime createdAt;
  final String? bookId;
  final String? bookTitle;

  Chat({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSender,
    required this.createdAt,
    this.bookId,
    this.bookTitle,
  });

  // Convert Firestore document to Chat object
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSender: data['lastMessageSender'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      bookId: data['bookId'],
      bookTitle: data['bookTitle'],
    );
  }

  // Convert Chat object to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSender': lastMessageSender,
      'createdAt': Timestamp.fromDate(createdAt),
      if (bookId != null) 'bookId': bookId,
      if (bookTitle != null) 'bookTitle': bookTitle,
    };
  }
}