import 'package:equatable/equatable.dart';

/// Landing category entity (app module)
class LandingCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String url;
  final String type; // "internal" or "web"

  const LandingCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.url,
    required this.type,
  });

  /// Check if module is internal (app route)
  bool get isInternal => type == 'internal';

  /// Check if module is web (webview)
  bool get isWeb => type == 'web';

  @override
  List<Object?> get props => [id, name, icon, url, type];
}
