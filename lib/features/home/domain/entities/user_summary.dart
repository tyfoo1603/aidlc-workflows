import 'package:equatable/equatable.dart';

/// User summary entity for home page display
class UserSummary extends Equatable {
  final String name;
  final String? avatar;
  final double? walletBalance;
  final String email;
  final String userId;

  const UserSummary({
    required this.name,
    this.avatar,
    this.walletBalance,
    required this.email,
    required this.userId,
  });

  @override
  List<Object?> get props => [name, avatar, walletBalance, email, userId];
}
