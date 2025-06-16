import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_event.dart';
import 'package:car_auction_app/authentication/bloc/auth_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:car_auction_app/authentication/data/auth_service.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(
        secureStorage: const FlutterSecureStorage(),
        mockAuthService: MockAuthService(),
      ), // TODO: ..add(AuthStatusChecked()) for initial status check
      child: const _AuthScreenView(), // Child is now the new StatefulWidget
    );
  }
}

class _AuthScreenView extends StatefulWidget {
  const _AuthScreenView(); 

  @override
  State<_AuthScreenView> createState() => _AuthScreenViewState();
}

class _AuthScreenViewState extends State<_AuthScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    if (mounted) {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  void _login() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated || (state.status == AuthStatus.unauthenticated && state.errorMessage != null)) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }

          if (state.status == AuthStatus.unauthenticated && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
          } else if (state.status == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Login Successful!'),
                  backgroundColor: Colors.green,
                ),
              );
            print('Login successful (from BLoC state): ${state.email}');
            // TODO: Navigate to vin_entry screen
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: _isLoading ? null : _togglePasswordVisibility,
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24.0),
                  if (state.status == AuthStatus.unauthenticated && state.errorMessage != null && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Login', style: TextStyle(fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
