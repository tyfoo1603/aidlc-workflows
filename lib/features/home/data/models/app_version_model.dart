import 'package:easy_app/features/home/domain/entities/app_version.dart';

/// App version model (data layer)
class AppVersionModel {
  final String currentVersion;
  final String latestVersion;
  final bool isCriticalUpdate;
  final bool isUpdateAvailable;
  final String? updateMessage;

  AppVersionModel({
    required this.currentVersion,
    required this.latestVersion,
    required this.isCriticalUpdate,
    required this.isUpdateAvailable,
    this.updateMessage,
  });

  /// Create from JSON
  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      currentVersion: json['currentVersion']?.toString() ?? '',
      latestVersion: json['latestVersion']?.toString() ?? '',
      isCriticalUpdate: json['isCriticalUpdate'] as bool? ?? false,
      isUpdateAvailable: json['isUpdateAvailable'] as bool? ?? false,
      updateMessage: json['updateMessage']?.toString(),
    );
  }

  /// Convert to domain entity
  AppVersion toEntity() {
    return AppVersion(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      isCriticalUpdate: isCriticalUpdate,
      isUpdateAvailable: isUpdateAvailable,
      updateMessage: updateMessage,
    );
  }
}

