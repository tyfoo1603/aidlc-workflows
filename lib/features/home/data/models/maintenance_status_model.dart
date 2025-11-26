import 'package:easy_app/features/home/domain/entities/maintenance_status.dart';

/// Maintenance status model (data layer)
class MaintenanceStatusModel {
  final bool isMaintenanceActive;
  final String? message;
  final DateTime? startTime;
  final DateTime? endTime;

  MaintenanceStatusModel({
    required this.isMaintenanceActive,
    this.message,
    this.startTime,
    this.endTime,
  });

  /// Create from JSON
  factory MaintenanceStatusModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceStatusModel(
      isMaintenanceActive: json['isMaintenanceActive'] as bool? ?? false,
      message: json['message']?.toString(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'].toString())
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'].toString())
          : null,
    );
  }

  /// Convert to domain entity
  MaintenanceStatus toEntity() {
    return MaintenanceStatus(
      isMaintenanceActive: isMaintenanceActive,
      message: message,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

