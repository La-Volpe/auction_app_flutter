part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class VinSubmitted extends SearchEvent {
  final String vin;

  const VinSubmitted(this.vin);

  @override
  List<Object> get props => [vin];
}