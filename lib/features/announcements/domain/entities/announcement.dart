import 'package:equatable/equatable.dart';

/// Announcement entity
class Announcement extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final DateTime? publishDate;
  final DateTime? expiryDate;
  final bool isActive;
  final String? category;
  final int? priority;
  final String? author;

  const Announcement({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.publishDate,
    this.expiryDate,
    this.isActive = true,
    this.category,
    this.priority,
    this.author,
  });

  /// Check if announcement is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if announcement is published
  bool get isPublished {
    if (publishDate == null) return true;
    return DateTime.now().isAfter(publishDate!) || 
           DateTime.now().isAtSameMomentAs(publishDate!);
  }

  /// Check if announcement should be displayed
  bool get shouldDisplay => isActive && !isExpired && isPublished;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        content,
        imageUrl,
        publishDate,
        expiryDate,
        isActive,
        category,
        priority,
        author,
      ];
}

