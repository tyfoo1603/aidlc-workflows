import 'package:easy_app/features/home/domain/entities/user_summary.dart';

/// User summary model (data layer)
class UserSummaryModel {
  final String name;
  final String? avatar;
  final double? walletBalance;
  final String email;
  final String userId;

  UserSummaryModel({
    required this.name,
    this.avatar,
    this.walletBalance,
    required this.email,
    required this.userId,
  });

  /// Create from JSON
  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      walletBalance: json['walletBalance'] != null
          ? (json['walletBalance'] as num).toDouble()
          : null,
      email: json['email']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['userID']?.toString() ?? '',
    );
  }

  /// Convert to domain entity
  UserSummary toEntity() {
    return UserSummary(
      name: name,
      avatar: avatar,
      walletBalance: walletBalance,
      email: email,
      userId: userId,
    );
  }
}

