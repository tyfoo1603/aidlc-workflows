import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/announcements/domain/entities/announcement.dart';
import 'package:easy_app/features/announcements/data/repositories/announcement_repository.dart';

/// Use case for getting announcement detail
class GetAnnouncementDetailUseCase {
  final AnnouncementRepository _repository;

  GetAnnouncementDetailUseCase({required AnnouncementRepository repository})
      : _repository = repository;

  /// Execute use case
  Future<Result<Announcement>> execute(String id) async {
    return await _repository.getAnnouncementDetail(id);
  }
}

