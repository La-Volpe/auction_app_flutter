part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileDataLoadRequested extends ProfileEvent {}

class ProfileLogoutButtonPressed extends ProfileEvent {}

class _AuthLogoutConfirmed extends ProfileEvent {
  const _AuthLogoutConfirmed();
}

class _AuthLogoutFailed extends ProfileEvent {
  final String error;
  const _AuthLogoutFailed(this.error);

  @override
  List<Object> get props => [error];
}