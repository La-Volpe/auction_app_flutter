import 'package:car_auction_app/authentication/bloc/auth_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_event.dart'; // Import AuthEvent
import 'package:car_auction_app/authentication/data/auth_service.dart';
import 'package:car_auction_app/navigation/view/main_screen.dart';
import 'package:car_auction_app/profile/bloc/profile_bloc.dart';
import 'package:car_auction_app/search/bloc/search_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auction/view/auction_screen.dart';
import 'authentication/view/auth_screen.dart';
import 'search/view/search_screen.dart'; // Added import for SearchScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            secureStorage: const FlutterSecureStorage(),
            mockAuthService: MockAuthService(),
          )..add(AuthStatusChecked()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(authBloc: BlocProvider.of<AuthBloc>(context)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Car Auction App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthScreen(),
          '/auth': (context) => const AuthScreen(),
          '/search': (context) => const SearchScreen(),
          '/main': (context) => const MainScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/auction') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AuctionScreen(
                uuid: args['uuid'] ?? '',
                model: args['model'] ?? '',
                initialPrice: num.tryParse(args['price'] ?? '0'),
              ),
            );
          }
          // fallback
          return MaterialPageRoute(builder: (_) => const AuthScreen());
        },
      ),
    );
  }
}
