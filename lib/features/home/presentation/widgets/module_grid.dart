import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_app/features/home/domain/entities/landing_category.dart';

/// Module grid widget displaying app modules
class ModuleGrid extends StatelessWidget {
  final List<LandingCategory> modules;
  final Function(LandingCategory) onModuleTap;

  const ModuleGrid({
    super.key,
    required this.modules,
    required this.onModuleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return _ModuleCard(
            module: module,
            onTap: () => onModuleTap(module),
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final LandingCategory module;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              if (module.icon.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: module.icon,
                  width: 48,
                  height: 48,
                  errorWidget: (context, url, error) => Icon(
                    Icons.apps,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              else
                Icon(
                  Icons.apps,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              const SizedBox(height: 8),
              // Name
              Text(
                module.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

