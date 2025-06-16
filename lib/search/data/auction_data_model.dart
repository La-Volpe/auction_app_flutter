import 'package:equatable/equatable.dart';

class AuctionData extends Equatable {
  final int id;
  final String? feedback;
  final DateTime? valuatedAt;
  final DateTime? requestedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String make;
  final String model;
  final String externalId;
  final String? fkSellerUser;
  final num? price; // Can be int or double
  final bool? positiveCustomerFeedback;
  final String? fkUuidAuction;
  final DateTime? inspectorRequestedAt;
  final String? origin;
  final String? estimationRequestId;

  const AuctionData({
    required this.id,
    this.feedback,
    this.valuatedAt,
    this.requestedAt,
    this.createdAt,
    this.updatedAt,
    required this.make,
    required this.model,
    required this.externalId,
    this.fkSellerUser,
    this.price,
    this.positiveCustomerFeedback,
    this.fkUuidAuction,
    this.inspectorRequestedAt,
    this.origin,
    this.estimationRequestId,
  });

  factory AuctionData.fromJson(Map<String, dynamic> json) {
    return AuctionData(
      id: json['id'] as int,
      feedback: json['feedback'] as String?,
      valuatedAt: json['valuatedAt'] != null ? DateTime.tryParse(json['valuatedAt'] as String) : null,
      requestedAt: json['requestedAt'] != null ? DateTime.tryParse(json['requestedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      make: json['make'] as String,
      model: json['model'] as String,
      externalId: json['externalId'] as String,
      fkSellerUser: json['_fk_sellerUser'] as String?, // Note the underscore
      price: json['price'] as num?,
      positiveCustomerFeedback: json['positiveCustomerFeedback'] as bool?,
      fkUuidAuction: json['_fk_uuid_auction'] as String?, // Note the underscore
      inspectorRequestedAt: json['inspectorRequestedAt'] != null ? DateTime.tryParse(json['inspectorRequestedAt'] as String) : null,
      origin: json['origin'] as String?,
      estimationRequestId: json['estimationRequestId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        feedback,
        valuatedAt,
        requestedAt,
        createdAt,
        updatedAt,
        make,
        model,
        externalId,
        fkSellerUser,
        price,
        positiveCustomerFeedback,
        fkUuidAuction,
        inspectorRequestedAt,
        origin,
        estimationRequestId,
      ];
}

class AuctionDataChoice extends Equatable {
  final String make;
  final String model;
  final String containerName;
  final num similarity; // Can be int or double
  final String externalId;

  const AuctionDataChoice({
    required this.make,
    required this.model,
    required this.containerName,
    required this.similarity,
    required this.externalId,
  });

  factory AuctionDataChoice.fromJson(Map<String, dynamic> json) {
    return AuctionDataChoice(
      make: json['make'] as String,
      model: json['model'] as String,
      containerName: json['containerName'] as String,
      similarity: json['similarity'] as num,
      externalId: json['externalId'] as String,
    );
  }

  @override
  List<Object?> get props => [make, model, containerName, similarity, externalId];
}

// Model for the error response structure from CosChallenge
class ServerErrorDetails extends Equatable {
  final String msgKey;
  final Map<String, dynamic>? params;
  final String message;

  const ServerErrorDetails({
    required this.msgKey,
    this.params,
    required this.message,
  });

  factory ServerErrorDetails.fromJson(Map<String, dynamic> json) {
    return ServerErrorDetails(
      msgKey: json['msgKey'] as String,
      params: json['params'] as Map<String, dynamic>?,
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [msgKey, params, message];
}