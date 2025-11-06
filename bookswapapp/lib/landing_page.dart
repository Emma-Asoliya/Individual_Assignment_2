import 'package:bookswapapp/listings.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: const Color.fromARGB(255, 230, 21, 6),
    body: Center( 
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Icon(
        Icons.menu_book_rounded,
        color: Colors.black,
        size: 100.0,
      ),
      Padding(padding: EdgeInsets.symmetric(vertical: 29),),
      Text('BookSwap',
    style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
    ), 
    Text('Swap Your Books with other students',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500 ),
    ),
    SizedBox(
      height: 20,
    ),
    ElevatedButton(onPressed: () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Listings()),
      );
    }, 
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      )
    ),
    child: Text('Get Started'),
    ),
     ]
    )
    )
    
    );
  
  }
}