import 'package:car_auction_app/authentication/bloc/auth_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_state.dart';
import 'package:car_auction_app/navigation/widgets/app_bottom_nav_bar.dart';
import 'package:car_auction_app/profile/view/profile_screen.dart';
import 'package:car_auction_app/search/view/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SearchScreen(), // Home
    const ProfileScreen(), // Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // If the user becomes unauthenticated while on this screen,
        // navigate them back to the authentication screen.
        // This handles cases like token expiry if such logic were implemented.
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/auth', (Route<dynamic> route) => false);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}