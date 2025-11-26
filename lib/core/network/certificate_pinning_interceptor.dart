import 'package:dio/dio.dart';
import 'package:easy_app/core/config/app_config.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Certificate pinning interceptor for API security
class CertificatePinningInterceptor extends Interceptor {
  final AppConfig _config;
  final Map<String, List<String>> _pinnedCertificates;

  CertificatePinningInterceptor({
    AppConfig? config,
  })  : _config = config ?? getIt<AppConfig>(),
        _pinnedCertificates = _buildPinnedCertificates(
          config ?? getIt<AppConfig>(),
        );

  static Map<String, List<String>> _buildPinnedCertificates(AppConfig config) {
    final pins = <String, List<String>>{};
    
    // Extract host from API base URL
    final uri = Uri.parse(config.apiBaseUrl);
    final host = uri.host;
    
    // Add certificate pins for the API host
    if (config.certificatePins.isNotEmpty) {
      pins[host] = config.certificatePins;
    }
    
    // Add Microsoft OAuth host pins
    final microsoftHost = 'login.microsoftonline.com';
    if (config.certificatePins.isNotEmpty) {
      pins[microsoftHost] = config.certificatePins;
    }
    
    return pins;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badCertificate) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Certificate pinning validation failed',
          type: DioExceptionType.badCertificate,
        ),
      );
      return;
    }
    handler.next(err);
  }

  /// Validate certificate pin
  bool _validateCertificatePin(X509Certificate certificate, String host) {
    final pins = _pinnedCertificates[host];
    if (pins == null || pins.isEmpty) {
      // No pins configured for this host, allow connection
      return true;
    }

    // Calculate SHA-256 hash of the certificate
    final certBytes = certificate.der;
    final hash = sha256.convert(certBytes);
    final pin = base64.encode(hash.bytes);

    // Check if any of the configured pins match
    for (final configuredPin in pins) {
      if (pin == configuredPin) {
        return true;
      }
    }

    return false;
  }
}

/// Helper class to create HttpClient with certificate pinning
class PinnedHttpClientFactory {
  final AppConfig _config;
  final Map<String, List<String>> _pinnedCertificates;

  PinnedHttpClientFactory({
    AppConfig? config,
  })  : _config = config ?? getIt<AppConfig>(),
        _pinnedCertificates = CertificatePinningInterceptor._buildPinnedCertificates(
          config ?? getIt<AppConfig>(),
        );

  /// Create HttpClient with certificate pinning
  HttpClient createHttpClient() {
    final client = HttpClient();
    
    // Set up certificate validation callback
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return _validateCertificate(cert, host);
    };

    return client;
  }

  bool _validateCertificate(X509Certificate cert, String host) {
    final pins = _pinnedCertificates[host];
    if (pins == null || pins.isEmpty) {
      // No pins configured, allow connection (for development)
      // In production, you might want to return false here
      return true;
    }

    // Calculate SHA-256 hash of the certificate
    final certBytes = cert.der;
    final hash = sha256.convert(certBytes);
    final pin = base64.encode(hash.bytes);

    // Check if any of the configured pins match
    for (final configuredPin in pins) {
      if (pin == configuredPin) {
        return true;
      }
    }

    // Pin mismatch - reject certificate
    return false;
  }
}
