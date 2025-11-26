import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_app/features/home/domain/entities/app_version.dart';

/// Update dialog for app version updates
class UpdateDialog extends StatelessWidget {
  final AppVersion appVersion;

  const UpdateDialog({
    super.key,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !appVersion.isCriticalUpdate,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              appVersion.isCriticalUpdate ? Icons.warning : Icons.info,
              color: appVersion.isCriticalUpdate ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 8),
            const Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Version: ${appVersion.currentVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Latest Version: ${appVersion.latestVersion}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (appVersion.updateMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                appVersion.updateMessage!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (appVersion.isCriticalUpdate) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a critical update. Please update to continue using the app.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!appVersion.isCriticalUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () => _openAppStore(context),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppStore(BuildContext context) async {
    // TODO: Get app store URLs from config
    // For Android: https://play.google.com/store/apps/details?id=<package>
    // For iOS: https://apps.apple.com/app/id<app_id>
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.astro.easyapp');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open app store'),
          ),
        );
      }
    }
  }
}
