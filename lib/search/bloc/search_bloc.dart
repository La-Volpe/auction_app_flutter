import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For SocketException

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Actual CosChallenge and models
import '../data/auction_data_model.dart';
import '../data/vin_search_service.dart'; // Assuming CosChallenge is here

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  // Using a static user ID for demo purposes as per CosChallenge structure
  static const String _userId = 'demoUser123';

  SearchBloc() : super(SearchInitial()) {
    on<VinSubmitted>(_onVinSubmitted);
  }

  Future<void> _onVinSubmitted(
    VinSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    final vin = event.vin.toUpperCase();

    // VIN Validation using CosChallenge.vinLength
    if (vin.length != CosChallenge.vinLength) {
      emit(VinValidationFailure("VIN must be ${CosChallenge.vinLength} characters long."));
      return;
    }
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin)) {
      emit(const VinValidationFailure(
          "VIN contains invalid characters. Only alphanumeric characters (excluding I, O, Q) are allowed."));
      return;
    }

    try {
      // Using a placeholder URL as CosChallenge.httpClient mocks responses regardless of URL
      final uri = Uri.https(
        'any.url.com', // MockClient in CosChallenge ignores this
        '/search', // MockClient in CosChallenge ignores this
        {'vin': vin},
      );

      final response = await CosChallenge.httpClient.get(
        uri,
        headers: {CosChallenge.user: _userId}, // Using CosChallenge.user
      ).timeout(const Duration(seconds: 10));

      // Status codes based on CosChallenge MockClient logic:
      // 100: success (single item)
      // 200: multipleChoices
      // 300: error
      // Other status codes might not be directly produced by this specific mock.

      if (response.statusCode == 100) { // Success - single item
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          emit(SearchSuccessSingleItem(AuctionData.fromJson(data)));
        } catch (e) {
          emit(JsonDeserializationError(
              "Failed to parse successful server response: ${e.toString()}"));
        }
      } else if (response.statusCode == 200) { // Multiple choices
        try {
          final List<dynamic> dataList = jsonDecode(response.body) as List<dynamic>;
          final choices = dataList
              .map((item) => AuctionDataChoice.fromJson(item as Map<String, dynamic>))
              .toList();
          emit(SearchSuccessMultipleItems(choices));
        } catch (e) {
          emit(JsonDeserializationError(
              "Failed to parse multiple choice server response: ${e.toString()}"));
        }
      } else if (response.statusCode == 300) { // Error response from server
        ServerErrorDetails? details;
        String errorMessage = "Server returned an error.";
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          details = ServerErrorDetails.fromJson(errorData);
          errorMessage = details.message; // Use message from parsed error
        } catch (e) {
          // If parsing error details fails, use a generic message
           errorMessage = "Server returned an error, and error details could not be parsed. Raw: ${response.body}";
        }
        emit(HttpError("HTTP Error: ${response.statusCode}. $errorMessage", response.statusCode, serverErrorDetails: details));
      }
      else { // Other unexpected HTTP status codes
         emit(HttpError("Unexpected HTTP Error: ${response.statusCode}. Body: ${response.body}", response.statusCode));
      }

    } on TimeoutException catch (_) {
      emit(const NetworkError(
          "The request timed out. Please check your connection and try again."));
    } on SocketException catch (_) {
      emit(const NetworkError(
          "Network error: Could not connect to the server. Please check your internet connection."));
    } on http.ClientException catch (e) {
      if (e.message.toLowerCase().contains('auth')) {
        emit(AuthError("Authentication failed: ${e.message}. Please ensure you are authorized."));
      } else {
        emit(NetworkError(
            "Network client error: ${e.message}. Please check your connection or configuration."));
      }
    } catch (e) {
      emit(ServerSideError(
          "An unexpected error occurred: ${e.toString()}"));
    }
  }

  // No need to close CosChallenge.httpClient here as it's a static instance
  // and might be used by other parts of the app.
  // If it were specific to this BLoC and created here, then closing would be appropriate.
}