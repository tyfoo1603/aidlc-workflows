import 'package:equatable/equatable.dart';

/// App version entity
class AppVersion extends Equatable {
  final String currentVersion;
  final String latestVersion;
  final bool isCriticalUpdate;
  final bool isUpdateAvailable;
  final String? updateMessage;

  const AppVersion({
    required this.currentVersion,
    required this.latestVersion,
    required this.isCriticalUpdate,
    required this.isUpdateAvailable,
    this.updateMessage,
  });

  @override
  List<Object?> get props => [
        currentVersion,
        latestVersion,
        isCriticalUpdate,
        isUpdateAvailable,
        updateMessage,
      ];
}
