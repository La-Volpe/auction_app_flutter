import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:car_auction_app/mock/auth_snippet.dart'; // Assuming this is the correct path
import 'auth_event.dart';
import 'auth_state.dart';

// Event and State were made standalone, so no 'part' directives needed here.

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _secureStorage;
  final MockAuthService _mockAuthService;

  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_email';

  AuthBloc({
    required FlutterSecureStorage secureStorage,
    required MockAuthService mockAuthService,
  })  : _secureStorage = secureStorage,
        _mockAuthService = mockAuthService,
        super(const AuthState()) {
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final email = await _secureStorage.read(key: _emailKey);

      if (token != null && email != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          email: email,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.unauthenticated, errorMessage: 'Failed to check auth status'));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Emit a loading/unknown state first to ensure state change detection
    emit(state.copyWith(status: AuthStatus.unknown, clearErrorMessage: true));

    try {
      final response = _mockAuthService.authenticate(event.email, event.password);
      if (response['statusCode'] == 200) {
        // The mock service returns a message like "Authentication successful. API token: abc123xyz789"
        final message = response['message'] as String;
        final token = message.split('API token: ').last;

        await _secureStorage.write(key: _tokenKey, value: token);
        await _secureStorage.write(key: _emailKey, value: event.email);
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          email: event.email,
          clearErrorMessage: true, // Ensure any previous error is cleared on success
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: response['message'] as String?, // This will carry the error
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred during login.',
      ));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _emailKey);
      emit(state.copyWith(status: AuthStatus.unauthenticated, token: null, email: null, clearErrorMessage: true));
    } catch (e) {
      // Even if deletion fails, log out the user from the app state
      emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          token: null,
          email: null,
          errorMessage: 'Failed to clear session from storage, but logged out locally.'));
    }
  }
}