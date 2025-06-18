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
      emit(VinValidationFailure("Invalid VIN length"));
      return;
    }
    if (!RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin)) {
      emit(const VinValidationFailure(
          "Invalid VIN format"));
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
      // 100: 200 (single item)
      // 300: multipleChoices
      // else: error

      if (response.statusCode == 200) {
        try {
          //Well... it was requested not to modify the CosChallenge file,
          // but the server response has a bug that needs fixing. so... here it goes...
          String fixedBody = response.body.replaceFirstMapped(
            RegExp(r'("externalId":\s*".*?")\s*(")'),
                (m) => '${m[1]}, ${m[2]}',
          );

          final data = jsonDecode(fixedBody) as Map<String, dynamic>;
          emit(SearchSuccessSingleItem(AuctionData.fromJson(data)));
        } catch (e) {
          // Log the actual error for debugging
          print('JSON Deserialization Error: ${e.toString()}');
          emit(const JsonDeserializationError(
              "Unable to process vehicle data"));
        }
      } else if (response.statusCode == 300) { // Multiple choices
        try {
          final List<dynamic> dataList = jsonDecode(response.body) as List<dynamic>;
          final choices = dataList
              .map((item) => AuctionDataChoice.fromJson(item as Map<String, dynamic>))
              .toList();
          emit(SearchSuccessMultipleItems(choices));
        } catch (e) {
          // Log the actual error for debugging
          print('Multiple Choices JSON Error: ${e.toString()}');
          emit(const JsonDeserializationError(
              "Unable to process vehicle options"));
        }
      } else { // Error response from server
        ServerErrorDetails? details;
        String userFriendlyMessage = "Unable to retrieve vehicle information";

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          details = ServerErrorDetails.fromJson(errorData);

          // Store original message for logging
          String originalMessage = details.message;
          print('Server Error: $originalMessage');

          // Only pass user-friendly message to UI
        } catch (e) {
          // Log the parsing error
          print('Error parsing server error: ${e.toString()}');
          print('Raw response: ${response.body}');
        }

        emit(HttpError(userFriendlyMessage, response.statusCode,
            serverErrorDetails: details));
      }

    } on TimeoutException catch (_) {
      emit(const NetworkError(
          "Request timed out"));
    } on SocketException catch (_) {
      emit(const NetworkError(
          "Network connection issue"));
    } on http.ClientException catch (e) {
      // Log the actual error for debugging
      print('HTTP Client Exception: ${e.message}');

      if (e.message.toLowerCase().contains('auth')) {
        emit(const AuthError("Authentication failed"));
      } else {
        emit(const NetworkError("Connection problem"));
      }
    } catch (e) {
      // Log the actual error for debugging
      print('Unexpected Error: ${e.toString()}');
      emit(const ServerSideError(
          "An unexpected error occurred"));
    }
  }
}