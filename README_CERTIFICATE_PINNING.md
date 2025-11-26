# Certificate Pinning Setup Guide

This guide explains how to set up certificate pinning for the Easy App.

## Overview

Certificate pinning enhances API security by ensuring the app only connects to servers with specific certificates. This prevents man-in-the-middle attacks.

## How It Works

1. The app calculates SHA-256 hash of the server's certificate
2. The hash is compared against configured certificate pins
3. If the pin matches, the connection is allowed
4. If the pin doesn't match, the connection is rejected

## Setting Up Certificate Pins

### Step 1: Extract Certificate Pin

You can extract the certificate pin using the `CertificatePinHelper` utility:

```dart
import 'package:easy_app/core/utils/certificate_pin_helper.dart';

// From PEM file
final pin = await CertificatePinHelper.extractPinFromFile('path/to/certificate.pem');

// From PEM content
final pemContent = '''-----BEGIN CERTIFICATE-----
...certificate content...
-----END CERTIFICATE-----''';
final pin = CertificatePinHelper.extractPinFromPem(pemContent);
```

### Step 2: Configure Pins in AppConfig

Update `lib/core/config/app_config.dart` with your certificate pins:

```dart
case Environment.staging:
  return AppConfig(
    // ... other config ...
    certificatePins: [
      'YOUR_CERTIFICATE_PIN_HERE', // SHA-256 hash in base64
      // You can add multiple pins for certificate rotation
    ],
  );
```

### Step 3: Get Certificate Pin from Server

#### Option A: Using OpenSSL (Command Line)

```bash
# Get certificate from server
openssl s_client -servername mcafe.azurewebsites.net -connect mcafe.azurewebsites.net:443 < /dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```

#### Option B: Using Browser

1. Open the API URL in a browser (e.g., `https://mcafe.azurewebsites.net/api`)
2. Click the lock icon in the address bar
3. View certificate details
4. Export certificate to PEM format
5. Use `CertificatePinHelper.extractPinFromFile()` to get the pin

#### Option C: Using Online Tools

Use online tools like:
- https://www.ssllabs.com/ssltest/analyze.html
- https://report-uri.com/home/pkp_hash

## Certificate Rotation

When certificates are rotated, you should:

1. Add the new certificate pin to the `certificatePins` array
2. Keep the old pin for a transition period
3. Remove the old pin after all users have updated

Example:
```dart
certificatePins: [
  'NEW_CERTIFICATE_PIN',  // New certificate
  'OLD_CERTIFICATE_PIN',  // Old certificate (for backward compatibility)
],
```

## Testing

### Development

In development, you can temporarily disable certificate pinning by:
- Setting `certificatePins: []` in `AppConfig.getConfig(Environment.dev)`
- Or commenting out the certificate pinning interceptor setup

### Staging/Production

Always enable certificate pinning in staging and production environments.

## Troubleshooting

### Connection Fails with "Certificate pinning validation failed"

1. Verify the certificate pin is correct
2. Check if the certificate has been rotated
3. Ensure the pin format is correct (base64-encoded SHA-256, 44 characters)
4. Check if you're connecting to the correct server

### Pin Format Validation

Use `CertificatePinHelper.isValidPinFormat()` to validate pin format:

```dart
if (CertificatePinHelper.isValidPinFormat(pin)) {
  // Pin format is valid
} else {
  // Pin format is invalid
}
```

## Security Notes

- Never commit certificate pins to version control if they're sensitive
- Use environment variables or secure configuration management
- Rotate certificates regularly
- Monitor certificate expiration dates
- Keep backup pins for certificate rotation

## References

- [OWASP Certificate Pinning Guide](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/data-and-backend/security)

