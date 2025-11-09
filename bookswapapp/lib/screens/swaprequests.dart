import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswapapp/screens/listings.dart';

class SwapRequests extends StatefulWidget {
  const SwapRequests({super.key});

  @override
  State<SwapRequests> createState() => _SwapRequestsState();
}

class _SwapRequestsState extends State<SwapRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentTab = 0; // 0 = Received, 1 = Sent

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugSwapFlow();
    });
  }

  // Add this method to debug the swap flow
  void _debugSwapFlow() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('DEBUG: No user signed in');
        return;
      }

      print('=== SWAP FLOW DEBUG ===');
      
      // Check current user
      print('Current User: ${user.uid}');
      print('Current Email: ${user.email}');
      
      // Check received requests
      QuerySnapshot received = await _firestore
          .collection('swap_requests')
          .where('ownerId', isEqualTo: user.uid)
          .get();
      print('📥 Received requests: ${received.docs.length}');
      
      for (var doc in received.docs) {
        final request = doc.data() as Map<String, dynamic>;
        print('   - ${request['bookTitle']} (Status: ${request['status']})');
      }
      
      // Check sent requests
      QuerySnapshot sent = await _firestore
          .collection('swap_requests')
          .where('requestorId', isEqualTo: user.uid)
          .get();
      print('📤 Sent requests: ${sent.docs.length}');
      
      for (var doc in sent.docs) {
        final request = doc.data() as Map<String, dynamic>;
        print('   - ${request['bookTitle']} (Status: ${request['status']})');
      }
      
      print('=== END DEBUG ===');
    } catch (e) {
      print('DEBUG ERROR: $e');
    }
  }

  // Add this test method
  void _testSwapFlow() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      print('🧪 TESTING SWAP FLOW...');
      
      // Get any book from the database
      QuerySnapshot books = await _firestore.collection('books').limit(1).get();
      
      if (books.docs.isNotEmpty) {
        final book = books.docs.first;
        final bookData = book.data() as Map<String, dynamic>;
        
        // Create a test swap request
        await _firestore.collection('swap_requests').add({
          'bookId': book.id,
          'bookTitle': bookData['title'] ?? 'Test Book',
          'bookAuthor': bookData['author'] ?? 'Test Author',
          'bookCondition': bookData['condition'] ?? 'Good',
          'bookImageUrl': bookData['imageUrl'],
          'requestorId': user.uid,
          'requestorName': user.displayName ?? 'Test User',
          'requestorEmail': user.email,
          'ownerId': bookData['userId'],
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print('TEST: Created swap request');
        _debugSwapFlow(); // Show updated state
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test swap request created!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        print('No books found to test with');
      }
    } catch (e) {
      print('TEST ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Swap Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: user == null 
          ? Center(child: Text('Please log in to view swap requests'))
          : Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 0),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _currentTab == 0 ? Colors.red : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Received',
                                style: TextStyle(
                                  color: _currentTab == 0 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentTab = 1),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _currentTab == 1 ? Colors.red : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Sent',
                                style: TextStyle(
                                  color: _currentTab == 1 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Requests List
                Expanded(
                  child: _currentTab == 0
                      ? _buildReceivedRequests(user.uid)
                      : _buildSentRequests(user.uid),
                ),
              ],
            ),
      // Add floating action button for testing
      floatingActionButton: FloatingActionButton(
        onPressed: _testSwapFlow,
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildReceivedRequests(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('swap_requests')
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No swap requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'When someone requests to swap your book,\nit will appear here.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _testSwapFlow,
                  child: Text('Create Test Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            return _buildRequestItem(request, requests[index].id, true);
          },
        );
      },
    );
  }

  Widget _buildSentRequests(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('swap_requests')
          .where('requestorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No sent swap requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Your swap requests will appear here.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            return _buildRequestItem(request, requests[index].id, false);
          },
        );
      },
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request, String requestId, bool isReceived) {
    Color statusColor = Colors.orange; // pending
    String statusText = 'Pending';
    String statusMessage = '';
    
    if (request['status'] == 'accepted') {
      statusColor = Colors.green;
      statusText = 'Accepted';
      statusMessage = 'Swap approved! You can arrange the book exchange.';
    } else if (request['status'] == 'declined') {
      statusColor = Colors.red;
      statusText = 'Declined';
      statusMessage = 'Swap request was declined.';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: request['bookImageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(request['bookImageUrl']!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Icon(Icons.menu_book, color: Colors.grey[500]),
                        ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['bookTitle'] ?? 'Unknown Book',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'by ${request['bookAuthor'] ?? 'Unknown Author'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Condition: ${request['bookCondition'] ?? 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Request info
            Text(
              isReceived
                  ? 'Request from: ${request['requestorName']}'
                  : 'Request to: Book Owner',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            
            // Status-specific UI
            if (request['status'] == 'pending' && isReceived) ...[
              // Pending request - show action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateRequestStatus(requestId, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Accept Swap'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateRequestStatus(requestId, 'declined'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                      ),
                      child: Text(
                        'Decline',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (request['status'] == 'pending' && !isReceived) ...[
              // Sent request waiting for response
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waiting for owner to respond...',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (request['status'] == 'accepted') ...[
              // Accepted swap
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (request['status'] == 'declined') ...[
              // Declined swap
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      print('Updating swap request $requestId to: $status');
      
      // First get the current request data
      DocumentSnapshot requestDoc = await _firestore.collection('swap_requests').doc(requestId).get();
      Map<String, dynamic> request = requestDoc.data() as Map<String, dynamic>;
      
      print('Updating book: ${request['bookTitle']}');
      print('Requestor: ${request['requestorId']}');
      print('Owner: ${request['ownerId']}');
      
      // Update the request status
      await _firestore.collection('swap_requests').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully updated swap request status to: $status');
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swap request ${status == 'accepted' ? 'accepted' : 'declined'}!'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Force a refresh of the stream
      setState(() {});
      
    } catch (e) {
      print('FAILED to update swap request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}