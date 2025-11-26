import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:easy_app/features/announcements/domain/usecases/get_announcements_by_page_usecase.dart';
import 'package:easy_app/features/announcements/domain/usecases/search_announcements_usecase.dart';
import 'package:easy_app/features/announcements/domain/usecases/get_announcement_detail_usecase.dart';
import 'package:easy_app/features/announcements/presentation/cubit/announcement_state.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Announcement Cubit
class AnnouncementCubit extends Cubit<AnnouncementState> {
  final GetAnnouncementsUseCase _getAnnouncementsUseCase;
  final GetAnnouncementsByPageUseCase _getAnnouncementsByPageUseCase;
  final SearchAnnouncementsUseCase _searchAnnouncementsUseCase;
  final GetAnnouncementDetailUseCase _getAnnouncementDetailUseCase;

  AnnouncementCubit({
    GetAnnouncementsUseCase? getAnnouncementsUseCase,
    GetAnnouncementsByPageUseCase? getAnnouncementsByPageUseCase,
    SearchAnnouncementsUseCase? searchAnnouncementsUseCase,
    GetAnnouncementDetailUseCase? getAnnouncementDetailUseCase,
  })  : _getAnnouncementsUseCase =
            getAnnouncementsUseCase ?? getIt<GetAnnouncementsUseCase>(),
        _getAnnouncementsByPageUseCase = getAnnouncementsByPageUseCase ??
            getIt<GetAnnouncementsByPageUseCase>(),
        _searchAnnouncementsUseCase = searchAnnouncementsUseCase ??
            getIt<SearchAnnouncementsUseCase>(),
        _getAnnouncementDetailUseCase = getAnnouncementDetailUseCase ??
            getIt<GetAnnouncementDetailUseCase>(),
        super(const AnnouncementState());

  /// Load all announcements (newretrieve endpoint)
  Future<void> loadAnnouncements() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    
    final result = await _getAnnouncementsUseCase.execute();
    
    result.fold(
      onSuccess: (announcements) {
        emit(state.copyWith(
          isLoading: false,
          announcements: announcements,
          currentPage: 1,
          hasMore: false, // newretrieve returns all, no pagination
        ));
      },
      onFailure: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }

  /// Load announcements by page
  Future<void> loadAnnouncementsByPage({bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    final page = loadMore ? state.currentPage + 1 : 1;
    
    emit(state.copyWith(
      isLoading: true,
      currentPage: page,
      clearError: true,
    ));

    final result = await _getAnnouncementsByPageUseCase.execute(page);

    result.fold(
      onSuccess: (announcements) {
        final updatedList = loadMore
            ? [...state.announcements, ...announcements]
            : announcements;
        
        emit(state.copyWith(
          isLoading: false,
          announcements: updatedList,
          hasMore: announcements.length >= 10, // Assuming 10 items per page
        ));
      },
      onFailure: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }

  /// Search announcements
  Future<void> searchAnnouncements(String query, {bool loadMore = false}) async {
    if (state.isLoading || (!state.hasMore && loadMore)) return;

    final page = loadMore ? state.currentPage + 1 : 1;
    
    emit(state.copyWith(
      isLoading: true,
      searchQuery: query,
      currentPage: page,
      clearError: true,
    ));

    final result = await _searchAnnouncementsUseCase.execute(query, page);

    result.fold(
      onSuccess: (announcements) {
        final updatedList = loadMore
            ? [...state.announcements, ...announcements]
            : announcements;
        
        emit(state.copyWith(
          isLoading: false,
          announcements: updatedList,
          hasMore: announcements.length >= 10,
        ));
      },
      onFailure: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }

  /// Load announcement detail
  Future<void> loadAnnouncementDetail(String id) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _getAnnouncementDetailUseCase.execute(id);

    result.fold(
      onSuccess: (announcement) {
        emit(state.copyWith(
          isLoading: false,
          selectedAnnouncement: announcement,
        ));
      },
      onFailure: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }

  /// Clear search
  void clearSearch() {
    emit(state.copyWith(
      searchQuery: null,
      currentPage: 1,
      clearAnnouncements: true,
    ));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}

