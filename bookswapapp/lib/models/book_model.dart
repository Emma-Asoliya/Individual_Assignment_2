import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String? id;
  final String title;
  final String author;
  final String subject;
  final String condition;
  final String priceType; // 'free', 'swap', or 'price'
  final double? price;
  final String? imageUrl;
  final String userId;
  final String userEmail;
  final DateTime createdAt;
  final List<String> searchKeywords;
  bool isFavorited;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.subject,
    required this.condition,
    required this.priceType,
    this.price,
    this.imageUrl,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    required this.searchKeywords,
    this.isFavorited = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'subject': subject,
      'condition': condition,
      'priceType': priceType,
      'price': price,
      'imageUrl': imageUrl,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': createdAt,
      'searchKeywords': searchKeywords,
      'isFavorited': isFavorited,
    };
  }

  // Create Book from Firestore document
  factory Book.fromMap(String id, Map<String, dynamic> map) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      subject: map['subject'] ?? '',
      condition: map['condition'] ?? '',
      priceType: map['priceType'] ?? 'free',
      price: map['price']?.toDouble(),
      imageUrl: map['imageUrl'],
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
      isFavorited: map['isFavorited'] ?? false,
    );
  }

  String get priceDisplay {
    switch (priceType) {
      case 'free':
        return 'Free';
      case 'swap':
        return 'Swap';
      case 'price':
        return '\$${price?.toStringAsFixed(2) ?? '0'}';
      default:
        return 'Free';
    }
  }
}