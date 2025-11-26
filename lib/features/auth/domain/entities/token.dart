import 'package:equatable/equatable.dart';

/// Authentication token entity
class Token extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final DateTime issuedAt;
  final String userId;

  const Token({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.issuedAt,
    required this.userId,
  });

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token is about to expire (within 5 minutes)
  bool get isAboutToExpire {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        expiresAt,
        issuedAt,
        userId,
      ];
}

