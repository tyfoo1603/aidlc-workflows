import 'package:equatable/equatable.dart';

/// Maintenance status entity
class MaintenanceStatus extends Equatable {
  final bool isMaintenanceActive;
  final String? message;
  final DateTime? startTime;
  final DateTime? endTime;

  const MaintenanceStatus({
    required this.isMaintenanceActive,
    this.message,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [
        isMaintenanceActive,
        message,
        startTime,
        endTime,
      ];
}
