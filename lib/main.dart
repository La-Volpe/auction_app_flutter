import 'package:car_auction_app/authentication/bloc/auth_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_event.dart'; // Import AuthEvent
import 'package:car_auction_app/authentication/data/auth_service.dart';
import 'package:car_auction_app/navigation/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'authentication/view/auth_screen.dart';
import 'search/view/search_screen.dart'; // Added import for SearchScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        secureStorage: const FlutterSecureStorage(),
        mockAuthService: MockAuthService(),
      )..add(AuthStatusChecked()), // Check auth status when the app starts
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Car Auction App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/', // AuthScreen will handle redirection based on auth state
        routes: {
          '/': (context) => const AuthScreen(), // Default route
          '/auth': (context) => const AuthScreen(),
          '/search': (context) => const SearchScreen(), // Kept for direct access if needed, though /main is primary
          '/main': (context) => const MainScreen(), // New main screen with bottom nav
        },
      ),
    );
  }
}
