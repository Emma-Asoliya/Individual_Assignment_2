import 'package:flutter/material.dart';

class PostABook extends StatefulWidget {
  const PostABook({super.key});

  @override
  State<PostABook> createState() => _PostABookState();
}

class _PostABookState extends State<PostABook> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
        child: Text
        ('Post a Book'),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(icon: const Icon(Icons.arrow_back),
        tooltip: 'Navigation',
        onPressed: () {
          Navigator.pop(context);
        },
        )
        ),

        body: Padding(padding: 
        const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Book Title',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 14),
            TextField(
              decoration: InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 14),
            TextField(
              decoration: InputDecoration(
                labelText: 'Swap For?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 22),
            ElevatedButton(onPressed: (){
              
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 40),
            ),
            child: Text('Post Book'),
            ),

          ],
        ),
        ),

        


       //bottom Nav Bar
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
//defining the items for the bottom nav bar
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