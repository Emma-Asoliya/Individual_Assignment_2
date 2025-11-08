import 'package:bookswapapp/screens/post_a_book.dart';
import 'package:flutter/material.dart';

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
          'Browse Listings',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(child: Center(
            child: Text(
              'Book Listings will Appear Here',
              style: TextStyle(fontSize: 16),
            ),
          )
          )
        ],
        
      ),

      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostABook()),
        );
      },
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      child: Icon(Icons.add),
      ),
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

        items: 
       const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: 
        Icon(Icons.home_max_rounded),
        label: 'Home'),

        BottomNavigationBarItem(icon: 
        Icon(Icons.book),
        label: 'My Listings'),

        BottomNavigationBarItem(icon: 
        Icon(Icons.chat),
        label: 'Chats'),

        BottomNavigationBarItem(icon: 
        Icon(Icons.settings),
        label: 'Settings'),
        
      
       ]),
    );
    
  }
}