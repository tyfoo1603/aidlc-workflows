import 'package:easy_app/features/home/domain/entities/landing_category.dart';

/// Landing category model (data layer)
class LandingCategoryModel {
  final String id;
  final String title;
  final String icon;
  final String type;
  final String url;
  final int order;
  final bool isActive;

  LandingCategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.type,
    required this.url,
    required this.order,
    required this.isActive,
  });

  /// Create from JSON
  factory LandingCategoryModel.fromJson(Map<String, dynamic> json) {
    return LandingCategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      type: json['type']?.toString() ?? 'internal',
      url: json['url']?.toString() ?? '',
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to domain entity
  LandingCategory toEntity() {
    return LandingCategory(
      id: id,
      name: title,
      icon: icon,
      url: url,
      type: type,
    );
  }
}

