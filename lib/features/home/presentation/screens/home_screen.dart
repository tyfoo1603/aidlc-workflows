import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_app/core/navigation/navigation_service.dart';
import 'package:easy_app/core/error/result.dart';
import 'package:easy_app/core/di/dependency_injection.dart';
import 'package:easy_app/features/auth/data/repositories/auth_repository.dart';
import 'package:easy_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_app/features/home/domain/entities/app_version.dart';
import 'package:easy_app/features/home/domain/entities/maintenance_status.dart';
import 'package:easy_app/features/home/presentation/widgets/maintenance_banner.dart';
import 'package:easy_app/features/home/presentation/widgets/update_dialog.dart';
import 'package:easy_app/features/home/presentation/widgets/user_summary_card.dart';
import 'package:easy_app/features/home/presentation/widgets/module_grid.dart';

/// Home screen displaying modules and user summary
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NavigationService _navigationService = getIt<NavigationService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final tokensResult = await _authRepository.getStoredTokens();
    if (tokensResult.isSuccess && tokensResult.valueOrNull != null && mounted) {
      context.read<HomeCubit>().loadHomeData(tokensResult.valueOrNull!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => context.read<HomeCubit>().navigateToLogin(),
            tooltip: 'Login',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigationService.navigateToSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          // Show maintenance banner if maintenance is active
          if (state.maintenanceStatus?.isMaintenanceActive == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMaintenanceBanner(context, state.maintenanceStatus!);
            });
          }

          // Show update dialog if update is available
          if (state.appVersion?.isUpdateAvailable == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showUpdateDialog(context, state.appVersion!);
            });
          }

          // Show success message popup or snackbar
          if (state.successType != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final successType = state.successType!;
              // Show snackbar for token copy, dialog for other success types
              if (successType == SuccessType.tokenCopied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(successType.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                _showSuccessDialog(context, successType.message);
              }
              // Clear the message after showing
              context.read<HomeCubit>().clearMessages();
            });
          }

          // Show error if any
          if (state.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              // Clear the message after showing
              context.read<HomeCubit>().clearMessages();
            });
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadHomeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Summary Card
                  if (state.userSummary != null)
                    UserSummaryCard(userSummary: state.userSummary!),

                  const SizedBox(height: 16),

                  // Token Copy Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Authentication Token',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            context.read<HomeCubit>().copyTokenToClipboard();
                          },
                          tooltip: 'Copy token to clipboard',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Modules Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Announcements Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () =>
                                _navigationService.navigateToAnnouncements(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.announcement,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Announcements',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Modules Grid
                        if (state.modules != null && state.modules!.isNotEmpty)
                          ModuleGrid(
                            modules: state.modules!,
                            onModuleTap: (category) {
                              context
                                  .read<HomeCubit>()
                                  .navigateToModule(category);
                            },
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('No modules available'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMaintenanceBanner(
    BuildContext context,
    MaintenanceStatus maintenanceStatus,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MaintenanceBanner(
        maintenanceStatus: maintenanceStatus,
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, AppVersion appVersion) {
    showDialog(
      context: context,
      barrierDismissible: !appVersion.isCriticalUpdate,
      builder: (context) => UpdateDialog(
        appVersion: appVersion,
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
