import 'package:go_router/go_router.dart';
import 'package:easy_app/core/di/dependency_injection.dart';

/// Navigation service for centralized navigation
class NavigationService {
  final GoRouter _router;

  NavigationService({
    GoRouter? router,
  }) : _router = router ?? getIt<GoRouter>();

  // Expose router for internal use (e.g., in HomeCubit)
  GoRouter get router => _router;

  /// Navigate to login screen
  Future<void> navigateToLogin() async {
    _router.go('/login');
  }

  /// Navigate to home screen
  Future<void> navigateToHome() async {
    _router.go('/home');
  }

  /// Navigate to profile screen
  Future<void> navigateToProfile() async {
    _router.push('/profile');
  }

  /// Navigate to announcements screen
  Future<void> navigateToAnnouncements() async {
    _router.push('/announcements');
  }

  /// Navigate to announcement detail screen
  Future<void> navigateToAnnouncementDetail(String id) async {
    _router.push('/announcements/$id');
  }

  /// Navigate to QR wallet screen
  Future<void> navigateToQRWallet() async {
    _router.push('/qr-wallet');
  }

  /// Navigate to eclaims screen
  Future<void> navigateToEclaims() async {
    _router.push('/eclaims');
  }

  /// Navigate to AstroDesk screen
  Future<void> navigateToAstroDesk() async {
    _router.push('/astrodesk');
  }

  /// Navigate to report piracy screen
  Future<void> navigateToReportPiracy() async {
    _router.push('/report-piracy');
  }

  /// Navigate to settings screen
  Future<void> navigateToSettings() async {
    _router.push('/settings');
  }

  /// Navigate to AstroNet screen
  Future<void> navigateToAstroNet() async {
    _router.push('/astronet');
  }

  /// Navigate to steps challenge screen
  Future<void> navigateToStepsChallenge() async {
    _router.push('/steps-challenge');
  }

  /// Navigate to content highlights screen
  Future<void> navigateToContentHighlights() async {
    _router.push('/content-highlights');
  }

  /// Navigate to friends & family screen
  Future<void> navigateToFriendsFamily() async {
    _router.push('/friends-family');
  }

  /// Navigate to Sooka Share screen
  Future<void> navigateToSookaShare() async {
    _router.push('/sooka-share');
  }

  /// Open webview with URL
  Future<void> openWebView(String url) async {
    _router.push('/webview?url=${Uri.encodeComponent(url)}');
  }

  /// Open external browser with URL
  Future<void> openExternalBrowser(String url) async {
    // TODO: Implement external browser opening
    // Use url_launcher package
  }

  /// Go back
  void goBack() {
    _router.pop();
  }

  /// Go back to home
  void goBackToHome() {
    _router.go('/home');
  }
}
