part of 'profile_bloc.dart';

//This is overenginneerd, but in reality, it is a simple state management for user profile.
enum ProfileStatus {
  initial,
  loading,
  loaded, 
  logoutInProgress,
  logoutSuccess, 
  logoutFailure, 
  error, 
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? email;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.email,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? email,
    String? errorMessage,
    bool clearErrorMessage = false, // Helper to explicitly clear error message
  }) {
    return ProfileState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, email, errorMessage];
}