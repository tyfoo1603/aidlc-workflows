import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Helper class for certificate pinning operations
class CertificatePinHelper {
  /// Extract certificate pin from a certificate file
  /// 
  /// Usage:
  /// ```dart
  /// final pin = await CertificatePinHelper.extractPinFromFile('path/to/certificate.pem');
  /// ```
  static Future<String> extractPinFromFile(String filePath) async {
    final file = File(filePath);
    final certContent = await file.readAsString();
    return extractPinFromPem(certContent);
  }

  /// Extract certificate pin from PEM certificate content
  /// 
  /// Usage:
  /// ```dart
  /// final pemContent = '''-----BEGIN CERTIFICATE-----
  /// ...certificate content...
  /// -----END CERTIFICATE-----''';
  /// final pin = CertificatePinHelper.extractPinFromPem(pemContent);
  /// ```
  static String extractPinFromPem(String pemContent) {
    // Remove PEM headers and whitespace
    final cleanContent = pemContent
        .replaceAll('-----BEGIN CERTIFICATE-----', '')
        .replaceAll('-----END CERTIFICATE-----', '')
        .replaceAll('\n', '')
        .replaceAll(' ', '');

    // Decode base64
    final certBytes = base64Decode(cleanContent);

    // Calculate SHA-256 hash
    final hash = sha256.convert(certBytes);

    // Return base64-encoded pin
    return base64.encode(hash.bytes);
  }

  /// Extract certificate pin from X509Certificate
  static String extractPinFromCertificate(X509Certificate certificate) {
    final certBytes = certificate.der;
    final hash = sha256.convert(certBytes);
    return base64.encode(hash.bytes);
  }

  /// Validate pin format (should be base64-encoded SHA-256 hash)
  static bool isValidPinFormat(String pin) {
    try {
      // Decode to check if it's valid base64
      base64Decode(pin);
      // SHA-256 hash in base64 should be 44 characters (32 bytes * 4/3)
      return pin.length == 44;
    } catch (e) {
      return false;
    }
  }
}

