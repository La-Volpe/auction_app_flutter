part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

abstract class SearchSuccess extends SearchState {
  const SearchSuccess();
}

class SearchSuccessSingleItem extends SearchSuccess {
  final AuctionData auctionData;

  const SearchSuccessSingleItem(this.auctionData);

  @override
  List<Object?> get props => [auctionData];
}

class SearchSuccessMultipleItems extends SearchSuccess {
  final List<AuctionDataChoice> auctionDataChoices;

  const SearchSuccessMultipleItems(this.auctionDataChoices);

  @override
  List<Object?> get props => [auctionDataChoices];
}

class SearchFailure extends SearchState {
  final String error;
  final String? resolutionSuggestion;
  final ServerErrorDetails? serverErrorDetails;

  const SearchFailure(this.error, {this.resolutionSuggestion, this.serverErrorDetails});

  @override
  List<Object?> get props => [error, resolutionSuggestion, serverErrorDetails];
}

// Specific error states for more granular feedback

class VinValidationFailure extends SearchFailure {
  const VinValidationFailure(String error) : super(
    error,
    resolutionSuggestion: "Please ensure the VIN is 17 characters long and contains only alphanumeric characters (excluding I, O, Q)."
  );
}

class NetworkError extends SearchFailure {
  const NetworkError(String error) : super(
    error,
    resolutionSuggestion: "Please check your internet connection and try again."
  );
}

class AuthError extends SearchFailure {
  const AuthError(String error) : super(
    error,
    resolutionSuggestion: "Please ensure you are logged in and have permission to access this feature."
  );
}

class HttpError extends SearchFailure {
  final int statusCode;

  const HttpError(String error, this.statusCode, {ServerErrorDetails? serverErrorDetails}) : super(
    error,
    resolutionSuggestion: "We're having trouble retrieving vehicle information. Please try again later.",
    serverErrorDetails: serverErrorDetails
  );

  @override
  List<Object?> get props => [error, resolutionSuggestion, statusCode, serverErrorDetails];
}

class JsonDeserializationError extends SearchFailure {
  const JsonDeserializationError(String error) : super(
    error,
    resolutionSuggestion: "We encountered a problem processing vehicle information. Please try your search again."
  );
}

class ServerSideError extends SearchFailure {
  const ServerSideError(String error) : super(
    error,
    resolutionSuggestion: "Sorry, something went wrong on our end. Our team has been notified and is working on it."
  );
}