import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:easy_app/features/auth/presentation/screens/login_screen.dart';
import 'package:easy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_app/features/home/presentation/screens/home_screen.dart';
import 'package:easy_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_app/features/announcements/presentation/screens/announcements_screen.dart';
import 'package:easy_app/features/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:easy_app/features/announcements/presentation/cubit/announcement_cubit.dart';

/// Application router configuration
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<AuthCubit>(),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<HomeCubit>()),
            ],
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/announcements',
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<AnnouncementCubit>(),
            child: const AnnouncementsScreen(),
          ),
        ),
        GoRoute(
          path: '/announcements/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (context) => getIt<AnnouncementCubit>(),
              child: AnnouncementDetailScreen(announcementId: id),
            );
          },
        ),
        // TODO: Add other routes as screens are created
      ],
    );
  }
}
