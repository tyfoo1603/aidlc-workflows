import 'package:equatable/equatable.dart';
import 'package:easy_app/features/announcements/domain/entities/announcement.dart';

/// Announcement state
class AnnouncementState extends Equatable {
  final bool isLoading;
  final List<Announcement> announcements;
  final Announcement? selectedAnnouncement;
  final String? searchQuery;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const AnnouncementState({
    this.isLoading = false,
    this.announcements = const [],
    this.selectedAnnouncement,
    this.searchQuery,
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  AnnouncementState copyWith({
    bool? isLoading,
    List<Announcement>? announcements,
    Announcement? selectedAnnouncement,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool clearAnnouncements = false,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return AnnouncementState(
      isLoading: isLoading ?? this.isLoading,
      announcements: clearAnnouncements
          ? []
          : (announcements ?? this.announcements),
      selectedAnnouncement: clearSelected
          ? null
          : (selectedAnnouncement ?? this.selectedAnnouncement),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        announcements,
        selectedAnnouncement,
        searchQuery,
        currentPage,
        hasMore,
        errorMessage,
      ];
}

