import 'package:bookswapapp/listings.dart';
import 'package:bookswapapp/signin.dart';
import 'package:flutter/material.dart';
import 'landing_page.dart';

void main (){
  runApp(BookSwap());
}

class BookSwap extends StatefulWidget {
  BookSwap({super.key});

  @override
  State<BookSwap> createState() => _BookSwapState();
}

class _BookSwapState extends State<BookSwap> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSwap App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => Listings(),
        '/signup': (context) => LoginPage(),
      },
    );
  }
}
