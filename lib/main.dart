import 'package:flutter/material.dart';
import 'authentication/view/auth_screen.dart';
import 'search/view/search_screen.dart'; // Added import for SearchScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Auction App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/auth': (context) => const AuthScreen(),
        '/search': (context) => const SearchScreen(), // Added search route
      },
    );
  }
}
