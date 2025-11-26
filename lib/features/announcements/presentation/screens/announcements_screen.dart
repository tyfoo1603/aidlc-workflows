import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_app/features/announcements/presentation/cubit/announcement_cubit.dart';
import 'package:easy_app/features/announcements/presentation/cubit/announcement_state.dart';
import 'package:easy_app/features/announcements/presentation/widgets/announcement_item.dart';
import 'package:easy_app/core/navigation/navigation_service.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Announcements list screen
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final NavigationService _navigationService = getIt<NavigationService>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AnnouncementCubit>().loadAnnouncements();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final cubit = context.read<AnnouncementCubit>();
      final state = cubit.state;
      
      if (state.hasMore && !state.isLoading) {
        if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
          cubit.searchAnnouncements(state.searchQuery!, loadMore: true);
        } else {
          cubit.loadAnnouncementsByPage(loadMore: true);
        }
      }
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<AnnouncementCubit>().clearSearch();
      context.read<AnnouncementCubit>().loadAnnouncements();
    } else {
      context.read<AnnouncementCubit>().searchAnnouncements(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _onSearch,
            ),
          ),
        ),
      ),
      body: BlocConsumer<AnnouncementCubit, AnnouncementState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<AnnouncementCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.announcements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.announcement_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery != null && state.searchQuery!.isNotEmpty
                        ? 'No announcements found'
                        : 'No announcements available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AnnouncementCubit>().clearSearch();
              await context.read<AnnouncementCubit>().loadAnnouncements();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.announcements.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.announcements.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final announcement = state.announcements[index];
                return AnnouncementItem(
                  announcement: announcement,
                  onTap: () {
                    _navigationService.navigateToAnnouncementDetail(
                      announcement.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

