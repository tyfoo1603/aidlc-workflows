import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_app/features/home/domain/entities/user_summary.dart';

/// User summary card widget
class UserSummaryCard extends StatelessWidget {
  final UserSummary userSummary;

  const UserSummaryCard({
    super.key,
    required this.userSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage: userSummary.avatar != null
                  ? CachedNetworkImageProvider(userSummary.avatar!)
                  : null,
              child: userSummary.avatar == null
                  ? Text(
                      userSummary.name.isNotEmpty
                          ? userSummary.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userSummary.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userSummary.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (userSummary.walletBalance != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Wallet: RM ${userSummary.walletBalance!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

