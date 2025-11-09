import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; 
import 'package:bookswapapp/screens/landing_page.dart';
import 'package:bookswapapp/screens/listings.dart';
import 'package:bookswapapp/screens/post_a_book.dart';
import 'package:bookswapapp/screens/settings.dart';
import 'package:bookswapapp/screens/signin.dart';
import 'package:bookswapapp/screens/signup.dart';
import 'package:bookswapapp/providers/user_provider.dart';
import 'package:bookswapapp/providers/settings_provider.dart'; 
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BookSwap());
}

class BookSwap extends StatefulWidget {
  const BookSwap({super.key});

  @override
  State<BookSwap> createState() => _BookSwapState();
}

class _BookSwapState extends State<BookSwap> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'BookSwap App',
        theme: ThemeData(
          primarySwatch: Colors.red, // Changed to red to match your app
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingPage(),
          '/login': (context) =>  LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/listings': (context) => const Listings(),
          '/postabook': (context) => const PostABook(),
          '/settings': (context) => const Settings(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}