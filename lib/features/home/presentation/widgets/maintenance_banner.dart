import 'package:flutter/material.dart';
import 'package:easy_app/features/home/domain/entities/maintenance_status.dart';

/// Maintenance banner dialog
class MaintenanceBanner extends StatelessWidget {
  final MaintenanceStatus maintenanceStatus;

  const MaintenanceBanner({
    super.key,
    required this.maintenanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.build, color: Colors.orange),
          SizedBox(width: 8),
          Text('Maintenance in Progress'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (maintenanceStatus.message != null)
            Text(maintenanceStatus.message!),
          if (maintenanceStatus.startTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Start: ${_formatDateTime(maintenanceStatus.startTime!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (maintenanceStatus.endTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'End: ${_formatDateTime(maintenanceStatus.endTime!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

