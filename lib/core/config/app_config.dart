import 'package:easy_app/core/config/environment.dart';

/// Application configuration
class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final List<String> certificatePins;

  // Microsoft OAuth Configuration
  final String microsoftTenantId;
  final String microsoftClientId;
  final String microsoftClientSecret;
  final String microsoftRedirectUri;
  final String microsoftScope;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.certificatePins,
    required this.microsoftTenantId,
    required this.microsoftClientId,
    required this.microsoftClientSecret,
    required this.microsoftRedirectUri,
    required this.microsoftScope,
  });

  static AppConfig getConfig(Environment env) {
    switch (env) {
      case Environment.dev:
        return AppConfig(
          environment: env,
          apiBaseUrl: 'TBD', // TODO: Set development API URL
          appName: 'Easy App Dev',
          enableLogging: true,
          certificatePins: [
            // TODO: Add development certificate pins
          ],
          microsoftTenantId: '84934ccb-279a-44ec-ac04-af10fec22a71',
          microsoftClientId: 'f3e01f56-4436-44ff-9eec-ec21e40d83c8',
          microsoftClientSecret: 'TBD', // TODO: Set development client secret
          microsoftRedirectUri: 'easyapp://auth/callback', // Custom URL scheme
          microsoftScope: 'openid profile email',
        );
      case Environment.staging:
        return AppConfig(
          environment: env,
          apiBaseUrl: 'https://mcafe.azurewebsites.net/api',
          appName: 'Easy App Staging',
          enableLogging: true,
          certificatePins: [
            // TODO: Add staging certificate pins
          ],
          microsoftTenantId: '84934ccb-279a-44ec-ac04-af10fec22a71',
          microsoftClientId: 'f3e01f56-4436-44ff-9eec-ec21e40d83c8',
          microsoftClientSecret: 'TBD', // TODO: Set staging client secret
          microsoftRedirectUri: 'easyapp://auth/callback/',
          microsoftScope: 'openid profile email',
        );
      case Environment.prod:
        return AppConfig(
          environment: env,
          apiBaseUrl: 'https://mcafebaru.azurewebsites.net/api',
          appName: 'Easy App',
          enableLogging: false,
          certificatePins: [
            // TODO: Add production certificate pins
          ],
          microsoftTenantId: 'TBD', // TODO: Set production tenant ID
          microsoftClientId: 'TBD', // TODO: Set production client ID
          microsoftClientSecret: 'TBD', // TODO: Set production client secret
          microsoftRedirectUri: 'easyapp://auth/callback/',
          microsoftScope: 'openid profile email',
        );
    }
  }

  /// Get Microsoft OAuth authorize URL
  String get microsoftAuthorizeUrl {
    return 'https://login.microsoftonline.com/$microsoftTenantId/oauth2/v2.0/authorize?'
        'client_id=$microsoftClientId&'
        'response_type=code&'
        'redirect_uri=${Uri.encodeComponent(microsoftRedirectUri)}&'
        'response_mode=query&'
        'scope=${Uri.encodeComponent(microsoftScope)}';
  }

  /// Get Microsoft OAuth token URL
  String get microsoftTokenUrl {
    return 'https://login.microsoftonline.com/$microsoftTenantId/oauth2/v2.0/token';
  }
}
