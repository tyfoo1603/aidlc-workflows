import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:easy_app/features/auth/domain/entities/token.dart';

/// Secure token storage using platform keychain/keystore
class SecureTokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Save tokens
  Future<void> saveTokens(Token token) async {
    await _storage.write(
      key: 'access_token',
      value: token.accessToken,
    );
    await _storage.write(
      key: 'refresh_token',
      value: token.refreshToken,
    );
    await _storage.write(
      key: 'expires_at',
      value: token.expiresAt.toIso8601String(),
    );
    await _storage.write(
      key: 'issued_at',
      value: token.issuedAt.toIso8601String(),
    );
    await _storage.write(
      key: 'user_id',
      value: token.userId,
    );
  }

  /// Get stored tokens
  Future<Token?> getTokens() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final expiresAtStr = await _storage.read(key: 'expires_at');
    final issuedAtStr = await _storage.read(key: 'issued_at');
    final userId = await _storage.read(key: 'user_id');

    if (accessToken == null ||
        refreshToken == null ||
        expiresAtStr == null ||
        issuedAtStr == null ||
        userId == null) {
      return null;
    }

    return Token(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtStr),
      issuedAt: DateTime.parse(issuedAtStr),
      userId: userId,
    );
  }

  /// Clear tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'expires_at');
    await _storage.delete(key: 'issued_at');
    await _storage.delete(key: 'user_id');
  }
}

