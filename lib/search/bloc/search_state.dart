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
  const VinValidationFailure(String error) : super(error, resolutionSuggestion: "Please ensure the VIN is 17 characters long and contains only alphanumeric characters (excluding I, O, Q).");
}

class NetworkError extends SearchFailure {
  const NetworkError(String error) : super(error, resolutionSuggestion: "Please check your internet connection and try again.");
}

class AuthError extends SearchFailure {
  const AuthError(String error) : super(error, resolutionSuggestion: "Authentication failed. Please ensure you are authorized to access this service.");
}

class HttpError extends SearchFailure {
  final int statusCode;
  const HttpError(String error, this.statusCode, {ServerErrorDetails? serverErrorDetails}) : super(error, resolutionSuggestion: "The server responded with an error. Please try again later. If the problem persists, contact support with code: $statusCode.", serverErrorDetails: serverErrorDetails);
}

class JsonDeserializationError extends SearchFailure {
  const JsonDeserializationError(String error) : super(error, resolutionSuggestion: "Failed to process the data from the server. Please try again. If the issue continues, it might be a temporary server-side problem.");
}

class ServerSideError extends SearchFailure { // General server-side error if not fitting other categories
  const ServerSideError(String error) : super(error, resolutionSuggestion: "An unexpected error occurred on the server. Please try again later.");
}