import 'package:bookswapapp/providers/user_provider.dart';
import 'package:bookswapapp/screens/swaprequests.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswapapp/screens/post_a_book.dart';
import 'package:bookswapapp/screens/settings.dart';
import 'package:bookswapapp/screens/chats.dart';
import 'package:provider/provider.dart';

class Listings extends StatefulWidget {
  const Listings({super.key});

  @override
  State<Listings> createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0; // Current tab index

  // Add this method to your _ListingsState class
  Future<void> _requestSwap(Map<String, dynamic> book, String bookId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      print('REQUESTING SWAP for book: ${book['title']}');
      
      // Create swap request document
      await _firestore.collection('swap_requests').add({
        'bookId': bookId,
        'bookTitle': book['title'],
        'bookAuthor': book['author'],
        'bookCondition': book['condition'],
        'bookImageUrl': book['imageUrl'],
        'requestorId': currentUser.uid,
        'requestorName': currentUser.displayName ?? 'Unknown User',
        'requestorEmail': currentUser.email,
        'ownerId': book['userId'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('SWAP REQUEST SENT!');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swap request sent for "${book['title']}"!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      print('SWAP REQUEST FAILED: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send swap request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context);
  final user = userProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
        actions: _currentIndex == 0 || _currentIndex == 1 ? [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostABook()),
              );
            },
          ),
        ] : null,
      ),
      body: user == null
        ? Center(child: Text('Please log in to view books'))
      : _buildCurrentScreen(user),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'My Books',
          ),
           BottomNavigationBarItem(
      icon: Icon(Icons.swap_horiz),  
      label: 'Swaps',                
    ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.red,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Browse Books';
      case 1:
        return 'My Books';
      case 2:
        return 'Chats';
      case 3:
        return 'Settings';
      default:
        return 'BookSwap';
    }
  }

  Widget _buildCurrentScreen(User? user) {
    switch (_currentIndex) {
      case 0: // Browse - All Books
        return _buildBrowseScreen(user);
      case 1: // My Books - User's Books Only
        return _buildMyBooksScreen(user);
        case 2: return SwapRequests(); 
      case 3: // Chats
        return ChatsPage();
      case 4: // Settings
        return Settings();
      default:
        return _buildBrowseScreen(user);
    }
  }

  Widget _buildBrowseScreen(User? user) {
    if (user == null) {
      return Center(
        child: Text(
          'Please log in to browse books',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('books')
          .snapshots(), // All books for browsing
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading books',
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No books available for swapping', true);
        }

        final books = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index].data() as Map<String, dynamic>;
            final bookId = books[index].id;
            final isMyBook = book['userId'] == user.uid;
            return _buildBookItem(book, bookId, isMyBook);
          },
        );
      },
    );
  }

  Widget _buildMyBooksScreen(User? user) {
    if (user == null) {
      return Center(
        child: Text(
          'Please log in to view your books',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('books')
          .where('userId', isEqualTo: user.uid)
          .snapshots(), // Only user's books
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading your books',
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No books listed yet', false);
        }

        final books = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index].data() as Map<String, dynamic>;
            return _buildBookItem(book, books[index].id, true);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, bool isBrowse) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            isBrowse 
                ? 'Be the first to add a book!'
                : 'Tap the + button to add your first book!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostABook()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Add a Book'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(Map<String, dynamic> book, String bookId, bool isMyBook) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('swap_requests')
          .where('bookId', isEqualTo: bookId)
          .where('requestorId', isEqualTo: _auth.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool hasPendingSwap = false;
        bool isApprovedSwap = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final swapRequest = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          hasPendingSwap = swapRequest['status'] == 'pending';
          isApprovedSwap = swapRequest['status'] == 'accepted';
        }
      
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[200],
              ),
              child: book['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(book['imageUrl']!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Icon(Icons.menu_book, color: Colors.grey[500]),
                    ),
            ),
            title: Text(
              book['title'] ?? 'No Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('by ${book['author'] ?? 'Unknown'}'),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getConditionColor(book['condition']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        book['condition'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _getPriceText(book),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!isMyBook) ...[
                  SizedBox(height: 4),
                  if (hasPendingSwap)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        'Swap Pending',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isApprovedSwap)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Swap Approved!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Posted by another user',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ],
            ),
            trailing: isMyBook ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editBook(book, bookId);
                } else if (value == 'delete') {
                  _deleteBook(book, bookId);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ) : null,
            onTap: () {
              _showBookDetails(book, bookId, isMyBook, hasPendingSwap, isApprovedSwap);
            },
          ),
        );
      },
    );
  }

  Color _getConditionColor(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'like new':
        return Colors.lightGreen;
      case 'good':
        return Colors.orange;
      case 'fair':
        return Colors.orangeAccent;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriceText(Map<String, dynamic> book) {
    if (book['priceType'] == 'free') {
      return 'Free';
    } else if (book['priceType'] == 'swap') {
      return 'Swap';
    } else {
      return '\$${book['price']?.toStringAsFixed(2) ?? '0'}';
    }
  }

  void _editBook(Map<String, dynamic> book, String bookId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostABook(
          bookId: bookId,
          initialBook: book,
        ),
      ),
    );
  }

  void _deleteBook(Map<String, dynamic> book, String bookId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book'),
          content: Text('Are you sure you want to delete "${book['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performDelete(bookId);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting book: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookDetails(Map<String, dynamic> book, String bookId, bool isMyBook, bool hasPendingSwap, bool isApprovedSwap) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Image and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Cover
                  Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: book['imageUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(book['imageUrl']!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Icon(Icons.menu_book, size: 40, color: Colors.grey[500]),
                          ),
                  ),
                  SizedBox(width: 16),
                  // Book Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'by ${book['author'] ?? 'Unknown Author'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getConditionColor(book['condition']),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book['condition'] ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _getPriceText(book),
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // SWAP STATUS BADGE
                        if (!isMyBook && hasPendingSwap) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              'Swap Request Pending',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else if (!isMyBook && isApprovedSwap) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              'Swap Approved! Start Chatting',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Additional Details
              if (book['subject'] != null) ...[
                _buildDetailRow('Subject', book['subject']!),
              ],
              if (book['description'] != null && book['description'].toString().isNotEmpty) ...[
                _buildDetailRow('Description', book['description']!),
              ],
              _buildDetailRow('Posted by', isMyBook ? 'You' : 'Another User'),
              
              SizedBox(height: 20),
              
              // Action Buttons
              if (isMyBook) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _editBook(book, bookId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Edit Book'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteBook(book, bookId);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (hasPendingSwap) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Swap request is pending approval'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Swap Pending',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
              ] else if (isApprovedSwap) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // _startChat(book, bookId); // We'll implement this later
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chat feature coming soon!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Start Chat'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _requestSwap(book, bookId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Request Swap'),
                  ),
                ),
              ],
              
              SizedBox(height: 8),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}