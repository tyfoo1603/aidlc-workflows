import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/announcements/domain/entities/announcement.dart';
import 'package:easy_app/features/announcements/data/repositories/announcement_repository.dart';

/// Use case for getting all announcements
class GetAnnouncementsUseCase {
  final AnnouncementRepository _repository;

  GetAnnouncementsUseCase({required AnnouncementRepository repository})
      : _repository = repository;

  /// Execute use case
  Future<Result<List<Announcement>>> execute() async {
    return await _repository.getAnnouncements();
  }
}

