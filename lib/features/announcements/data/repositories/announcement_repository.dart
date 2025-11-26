import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/error/app_error.dart';
import 'package:easy_app/core/network/api_service.dart';
import 'package:easy_app/features/announcements/domain/entities/announcement.dart';
import 'package:easy_app/features/announcements/data/models/announcement_model.dart';

/// Announcement repository for announcement-related data operations
class AnnouncementRepository {
  final ApiService _apiService;

  AnnouncementRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Get all announcements (newretrieve endpoint)
  Future<Result<List<Announcement>>> getAnnouncements() async {
    try {
      final result = await _apiService.getAnnouncements();

      return result.fold(
        onSuccess: (data) {
          // Handle nested response structure: {status, message, data: {announcements: [...]}}
          if (data is Map<String, dynamic>) {
            // Extract announcements from data.announcements
            final dataObj = data['data'] as Map<String, dynamic>?;
            if (dataObj != null) {
              final announcementsList = dataObj['announcements'] as List?;
              if (announcementsList != null) {
                final announcements = announcementsList
                    .map((item) => AnnouncementModel.fromJson(
                        item as Map<String, dynamic>))
                    .map((model) => model.toEntity())
                    .toList();
                return Success(announcements);
              }
            }
            // Fallback: try direct list or single item
            if (data.containsKey('announcements')) {
              final announcementsList = data['announcements'] as List?;
              if (announcementsList != null) {
                final announcements = announcementsList
                    .map((item) => AnnouncementModel.fromJson(
                        item as Map<String, dynamic>))
                    .map((model) => model.toEntity())
                    .toList();
                return Success(announcements);
              }
            }
            // Try as single announcement object
            if (data.containsKey('id')) {
              return Success([AnnouncementModel.fromJson(data).toEntity()]);
            }
          } else if (data is List) {
            // Handle direct list response
            final announcements = data
                .map((item) =>
                    AnnouncementModel.fromJson(item as Map<String, dynamic>))
                .map((model) => model.toEntity())
                .toList();
            return Success(announcements);
          }
          return const Success([]);
        },
        onFailure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to load announcements',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Get announcements by page
  Future<Result<List<Announcement>>> getAnnouncementsByPage(int page) async {
    try {
      final result = await _apiService.getAnnouncementsByPage(page);

      return result.fold(
        onSuccess: (data) {
          // Handle nested response structure: {status, message, data: {announcements: [...]}}
          if (data is Map<String, dynamic>) {
            final dataObj = data['data'] as Map<String, dynamic>?;
            if (dataObj != null) {
              final announcementsList = dataObj['announcements'] as List?;
              if (announcementsList != null) {
                final announcements = announcementsList
                    .map((item) => AnnouncementModel.fromJson(
                        item as Map<String, dynamic>))
                    .map((model) => model.toEntity())
                    .toList();
                return Success(announcements);
              }
            }
            // Fallback: try direct list access
            final items = data['announcements'] as List? ??
                data['data'] as List? ??
                data['items'] as List? ??
                [];
            final announcements = items
                .map((item) =>
                    AnnouncementModel.fromJson(item as Map<String, dynamic>))
                .map((model) => model.toEntity())
                .toList();
            return Success(announcements);
          } else if (data is List) {
            final announcements = data
                .map((item) =>
                    AnnouncementModel.fromJson(item as Map<String, dynamic>))
                .map((model) => model.toEntity())
                .toList();
            return Success(announcements);
          }
          return const Success([]);
        },
        onFailure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to load announcements',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Search announcements
  Future<Result<List<Announcement>>> searchAnnouncements(
    String searchText,
    int page,
  ) async {
    try {
      final result = await _apiService.searchAnnouncements(searchText, page);

      return result.fold(
        onSuccess: (data) {
          // Handle nested response structure: {status, message, data: {announcements: [...]}}
          if (data is Map<String, dynamic>) {
            final dataObj = data['data'] as Map<String, dynamic>?;
            if (dataObj != null) {
              final announcementsList = dataObj['announcements'] as List?;
              if (announcementsList != null) {
                final announcements = announcementsList
                    .map((item) => AnnouncementModel.fromJson(
                        item as Map<String, dynamic>))
                    .map((model) => model.toEntity())
                    .toList();
                return Success(announcements);
              }
            }
            // Fallback: try direct list access
            final items = data['announcements'] as List? ??
                data['data'] as List? ??
                data['items'] as List? ??
                [];
            final announcements = items
                .map((item) =>
                    AnnouncementModel.fromJson(item as Map<String, dynamic>))
                .map((model) => model.toEntity())
                .toList();
            return Success(announcements);
          } else if (data is List) {
            final announcements = data
                .map((item) =>
                    AnnouncementModel.fromJson(item as Map<String, dynamic>))
                .map((model) => model.toEntity())
                .toList();
            return Success(announcements);
          }
          return const Success([]);
        },
        onFailure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to search announcements',
        technicalMessage: e.toString(),
      ));
    }
  }

  /// Get announcement detail by ID
  Future<Result<Announcement>> getAnnouncementDetail(String id) async {
    try {
      final result = await _apiService.getAnnouncementDetail(id);

      return result.fold(
        onSuccess: (data) {
          // Handle nested response structure: {status, message, data: {...}}
          if (data is Map<String, dynamic>) {
            // Try to extract from data.data or data directly
            final announcementData =
                data['data'] as Map<String, dynamic>? ?? data;
            final model = AnnouncementModel.fromJson(announcementData);
            return Success(model.toEntity());
          }
          return Failure(AppError.unknown(
            message: 'Invalid announcement detail response format',
            technicalMessage: 'Expected Map but got ${data.runtimeType}',
          ));
        },
        onFailure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(AppError.unknown(
        message: 'Failed to load announcement detail',
        technicalMessage: e.toString(),
      ));
    }
  }
}
