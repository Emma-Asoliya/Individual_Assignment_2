import 'package:bookswapapp/screens/post_a_book.dart';
import 'package:flutter/material.dart';
import 'package:bookswapapp/screens/mylistings.dart';
import 'package:bookswapapp/screens/chats.dart';
import 'package:bookswapapp/screens/settings.dart';

class Listings extends StatefulWidget {
  const Listings({super.key});

  @override
  State<Listings> createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listings',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.red,
      ),
     
      body: _getCurrentPage(),

      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostABook()));
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ) : null,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red, 
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        iconSize: 30,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Listings',
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
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return MyListings();
      case 2:
        return ChatsPage();
      case 3:
        return Settings();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search books by title, author, or subject...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        
      
        
        SizedBox(height: 16),
        
        // Book Listings Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: 6, // Example books
            itemBuilder: (context, index) {
              return _buildBookCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool value) {
          // Handle filter selection
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.red[100],
        labelStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildBookCard(int index) {
    // Example book data
    List<Map<String, String>> books = [
      {'title': 'Data Structures & Algorithms', 'subject': 'Computer Science', 'condition': 'Like New', 'price': 'Free'},
      {'title': 'Introduction to Psychology', 'subject': 'Psychology', 'condition': 'Good', 'price': 'Swap'},
      {'title': 'Calculus Early Transcendentals', 'subject': 'Mathematics', 'condition': 'Fair', 'price': '\$10'},
      {'title': 'The Great Gatsby', 'subject': 'Literature', 'condition': 'Excellent', 'price': 'Free'},
      {'title': 'Organic Chemistry', 'subject': 'Chemistry', 'condition': 'Good', 'price': 'Swap'},
      {'title': 'Physics for Scientists', 'subject': 'Physics', 'condition': 'Like New', 'price': '\$15'},
    ];

    final book = books[index];

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Image
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[200],
            child: Icon(Icons.menu_book, size: 50, color: Colors.grey[500]),
          ),
          
          // Book Details
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title']!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  book['subject']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Text(
                  book['condition']!,
                  style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      book['price']!,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                    ),
                    Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}