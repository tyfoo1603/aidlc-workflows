import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/announcements/domain/entities/announcement.dart';
import 'package:easy_app/features/announcements/data/repositories/announcement_repository.dart';

/// Use case for getting announcements by page
class GetAnnouncementsByPageUseCase {
  final AnnouncementRepository _repository;

  GetAnnouncementsByPageUseCase({required AnnouncementRepository repository})
      : _repository = repository;

  /// Execute use case
  Future<Result<List<Announcement>>> execute(int page) async {
    return await _repository.getAnnouncementsByPage(page);
  }
}

