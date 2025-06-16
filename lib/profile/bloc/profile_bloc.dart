import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:car_auction_app/authentication/bloc/auth_bloc.dart';
import 'package:car_auction_app/authentication/bloc/auth_event.dart' show AuthLogoutRequested;
import 'package:car_auction_app/authentication/bloc/auth_state.dart' as auth_state_lib;
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthBloc _authBloc;
  StreamSubscription? _authSubscription;

  ProfileBloc({required AuthBloc authBloc})
      : _authBloc = authBloc,
        super(const ProfileState()) {
    on<ProfileDataLoadRequested>(_onProfileDataLoadRequested);
    on<ProfileLogoutButtonPressed>(_onProfileLogoutButtonPressed);
    on<_AuthLogoutConfirmed>(_onAuthLogoutConfirmed);
    on<_AuthLogoutFailed>(_onAuthLogoutFailed);
    
    
    add(ProfileDataLoadRequested());
  }

  void _onProfileDataLoadRequested(
    ProfileDataLoadRequested event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(status: ProfileStatus.loading, clearErrorMessage: true));
    final currentUserEmail = _authBloc.state.email; 

    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      emit(state.copyWith(status: ProfileStatus.loaded, email: currentUserEmail));
    } else {
      // This could happen if AuthBloc hasn't emitted an authenticated state with an email yet,
      // or if the user is not authenticated.
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: 'User email not available.'));
    }
  }

  Future<void> _onProfileLogoutButtonPressed(
    ProfileLogoutButtonPressed event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.logoutInProgress, clearErrorMessage: true));

    await _authSubscription?.cancel(); 
    _authSubscription = null;

    _authSubscription = _authBloc.stream.listen((authState) {
      if (authState.status == auth_state_lib.AuthStatus.unauthenticated) {
        if (state.status == ProfileStatus.logoutInProgress) { // Ensure we only react if logout is in progress
            if (authState.errorMessage == null) {
                add(const _AuthLogoutConfirmed()); 
            } else {
                add(_AuthLogoutFailed(authState.errorMessage!)); 
            }
        }
        _authSubscription?.cancel(); 
        _authSubscription = null;
      }
    });

    _authBloc.add(AuthLogoutRequested()); // Actually telling AuthBloc to log out
  }

  void _onAuthLogoutConfirmed(
    _AuthLogoutConfirmed event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(status: ProfileStatus.logoutSuccess, email: null, clearErrorMessage: true));
  }

  void _onAuthLogoutFailed(
    _AuthLogoutFailed event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(status: ProfileStatus.logoutFailure, errorMessage: event.error));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}