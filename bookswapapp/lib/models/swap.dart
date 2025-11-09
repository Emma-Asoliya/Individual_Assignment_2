import 'package:cloud_firestore/cloud_firestore.dart';

class Swap {
  final String id;
  final String bookId;
  final String bookTitle;
  final String? bookImageUrl;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String status; // pending, accepted, rejected, completed
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? chatId;

  Swap({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    this.bookImageUrl,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.chatId,
  });

  factory Swap.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Swap(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookImageUrl: data['bookImageUrl'],
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      chatId: data['chatId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      if (bookImageUrl != null) 'bookImageUrl': bookImageUrl,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (chatId != null) 'chatId': chatId,
    };
  }
}