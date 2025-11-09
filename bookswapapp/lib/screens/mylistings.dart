import 'package:flutter/material.dart';

class MyListings extends StatefulWidget {
  const MyListings({super.key});

  @override
  State<MyListings> createState() => _MyListingsState();
}

class _MyListingsState extends State<MyListings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Listings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildListingCard('Data Structures & Algorithms', 'Computer Science', 'Active', Colors.green),
          _buildListingCard('Introduction to Psychology', 'Psychology', 'Pending Swap', Colors.orange),
          _buildListingCard('Calculus Made Easy', 'Mathematics', 'Swapped', Colors.blue),
          _buildListingCard('The Great Gatsby', 'Literature', 'Active', Colors.green),
        ],
      ),
    );
  }

  Widget _buildListingCard(String title, String category, String status, Color statusColor) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: Colors.grey[200],
          child: Icon(Icons.menu_book, color: Colors.grey[600]),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category),
            SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to book details/edit
        },
      ),
    );
  }
}