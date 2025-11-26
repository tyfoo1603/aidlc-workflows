import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/announcements/domain/entities/announcement.dart';
import 'package:easy_app/features/announcements/data/repositories/announcement_repository.dart';

/// Use case for searching announcements
class SearchAnnouncementsUseCase {
  final AnnouncementRepository _repository;

  SearchAnnouncementsUseCase({required AnnouncementRepository repository})
      : _repository = repository;

  /// Execute use case
  Future<Result<List<Announcement>>> execute(String searchText, int page) async {
    return await _repository.searchAnnouncements(searchText, page);
  }
}

