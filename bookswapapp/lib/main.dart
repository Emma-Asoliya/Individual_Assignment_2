import 'package:bookswapapp/providers/user_provider.dart';
import 'package:bookswapapp/screens/listings.dart';
import 'package:bookswapapp/screens/post_a_book.dart';
import 'package:bookswapapp/screens/signin.dart';
import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'screens/signup.dart';
import 'package:provider/provider.dart'; 
import 'providers/settings_provider.dart'; 


void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    return MultiProvider( // CHANGE MaterialApp to MultiProvider
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider())
        // Add other providers here as needed
      ],

      child: MaterialApp( // KEEP MaterialApp inside MultiProvider
        title: 'BookSwap App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LandingPage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => Signup(),
          '/listings': (context) => Listings(),
          '/postabook':(context) => PostABook(),
        },
      ),
    );
  }
}