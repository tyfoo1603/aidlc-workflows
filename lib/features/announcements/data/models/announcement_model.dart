import 'package:easy_app/features/announcements/domain/entities/announcement.dart';

/// Announcement data model for API response
class AnnouncementModel {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? publishDate;
  final String? expiryDate;
  final bool? isActive;
  final String? category;
  final int? priority;
  final String? author;

  AnnouncementModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.publishDate,
    this.expiryDate,
    this.isActive,
    this.category,
    this.priority,
    this.author,
  });

  /// Create from JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['short_desc'] as String?,
      content: json['desc'] as String?,
      imageUrl: json['image'] as String?,
      publishDate: json['created_at'] as String?,
      expiryDate: null, // Not provided in API response
      isActive: true, // Assume active if present in response
      category: json['category_id'] as String?,
      priority: null, // Not provided in API response
      author: json['created_by'] as String?,
    );
  }

  /// Convert to domain entity
  Announcement toEntity() {
    return Announcement(
      id: id,
      title: title,
      description: description,
      content: content,
      imageUrl: imageUrl,
      publishDate: _parseDateTime(publishDate),
      expiryDate: _parseDateTime(expiryDate),
      isActive: isActive ?? true,
      category: category,
      priority: priority,
      author: author,
    );
  }

  /// Parse date time string
  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'publishDate': publishDate,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'category': category,
      'priority': priority,
      'author': author,
    };
  }
}

