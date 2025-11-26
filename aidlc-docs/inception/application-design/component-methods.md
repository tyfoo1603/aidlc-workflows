# Component Methods

This document defines method signatures for each component. Detailed business rules will be defined in Functional Design (per-unit, CONSTRUCTION phase).

## Core Components

### CoreNavigation
```dart
class NavigationService {
  Future<void> navigateToLogin();
  Future<void> navigateToHome();
  Future<void> navigateToProfile();
  Future<void> navigateToAnnouncements();
  Future<void> navigateToQRWallet();
  Future<void> navigateToEclaims();
  Future<void> navigateToAstroDesk();
  Future<void> navigateToReportPiracy();
  Future<void> navigateToSettings();
  Future<void> navigateToAstroNet();
  Future<void> navigateToStepsChallenge();
  Future<void> navigateToContentHighlights();
  Future<void> navigateToFriendsFamily();
  Future<void> navigateToSookaShare();
  Future<void> openWebView(String url);
  Future<void> openExternalBrowser(String url);
  void goBack();
  void goBackToHome();
}
```

### CoreNetwork
```dart
class ApiService {
  // Authentication endpoints
  Future<Result<TokenResponse>> exchangeAuthCode(String code);
  Future<Result<TokenResponse>> refreshToken(String refreshToken);
  Future<Result<void>> revokeSignInSessions();
  Future<Result<void>> invalidateRefreshTokens();
  
  // Landing/Home endpoints
  Future<Result<List<LandingCategory>>> getLandingCategories(String userId);
  Future<Result<UserProfile>> getUserProfile(String userId);
  Future<Result<List<NotificationData>>> getModuleNotifications(String userId, String moduleId);
  Future<Result<void>> registerPushToken(String userId, String firebaseToken, String hmsToken, String appVersion);
  Future<Result<AppVersion>> getAppVersion(String appType);
  Future<Result<MaintenanceStatus>> getMaintenanceStatus();
  Future<Result<UserCheck>> checkUser(String userId);
  
  // Profile endpoints
  Future<Result<UserProfile>> updateProfile(Map<String, dynamic> profileData);
  Future<Result<void>> uploadProfilePicture(File imageFile);
  Future<Result<void>> deleteProfilePicture(String userId);
  
  // Announcements endpoints
  Future<Result<List<Announcement>>> getAnnouncements(int page);
  Future<Result<Announcement>> getAnnouncementDetails(String announcementId);
  Future<Result<List<Announcement>>> searchAnnouncements(String searchText, int page);
  
  // QR Wallet endpoints
  Future<Result<PaymentResponse>> processPayment(String id, String userId, String comments, double price, int counter);
  Future<Result<List<Transaction>>> getPaymentHistory(String userId);
  Future<Result<Transaction>> getTransactionDetails(String transactionId);
  
  // Eclaims endpoints
  Future<Result<Claim>> submitClaim(Map<String, dynamic> claimData, List<File> attachments);
  Future<Result<Claim>> updateClaim(String claimId, Map<String, dynamic> claimData, List<File> attachments);
  Future<Result<List<Claim>>> getMyClaims(String userId);
  Future<Result<Claim>> getClaimDetails(String claimId);
  Future<Result<void>> cancelClaim(String claimId);
  
  // AstroDesk endpoints
  Future<Result<List<Ticket>>> getSupportTickets(String userId);
  Future<Result<Ticket>> createSupportTicket(Map<String, dynamic> ticketData, File? image);
  Future<Result<Ticket>> getTicketDetails(String ticketId);
  Future<Result<TownHallContent>> getTownHallContent();
  
  // Report Piracy endpoints
  Future<Result<Report>> submitPiracyReport(Map<String, dynamic> reportData, List<File> attachments);
  Future<Result<List<Report>>> getReportHistory(String userId);
  
  // Settings endpoints
  Future<Result<void>> updateNotificationPreferences(String userId, Map<String, bool> preferences);
  
  // Steps Challenge endpoints
  Future<Result<List<StepData>>> getStepData(String userId);
  Future<Result<void>> updateSteps(String userId, int steps, DateTime date);
  Future<Result<List<Ranking>>> getRankings();
  
  // Sooka Share endpoints
  Future<Result<void>> submitReferLead(Map<String, dynamic> leadData);
}
```

---

## Feature Components - Use Cases (Domain Layer)

### Authentication Feature

#### LoginUseCase
```dart
class LoginUseCase {
  Future<Result<void>> execute(String authorizationCode);
}
```

#### LogoutUseCase
```dart
class LogoutUseCase {
  Future<Result<void>> execute();
}
```

#### RefreshTokenUseCase
```dart
class RefreshTokenUseCase {
  Future<Result<TokenResponse>> execute();
}
```

---

### Home Feature

#### LoadHomeModulesUseCase
```dart
class LoadHomeModulesUseCase {
  Future<Result<List<LandingCategory>>> execute();
}
```

#### LoadUserProfileUseCase
```dart
class LoadUserProfileUseCase {
  Future<Result<UserProfile>> execute();
}
```

#### RegisterPushTokenUseCase
```dart
class RegisterPushTokenUseCase {
  Future<Result<void>> execute(String firebaseToken, String hmsToken);
}
```

#### CheckAppVersionUseCase
```dart
class CheckAppVersionUseCase {
  Future<Result<AppVersion>> execute();
}
```

#### CheckMaintenanceStatusUseCase
```dart
class CheckMaintenanceStatusUseCase {
  Future<Result<MaintenanceStatus>> execute();
}
```

---

### Profile Feature

#### GetProfileUseCase
```dart
class GetProfileUseCase {
  Future<Result<UserProfile>> execute();
}
```

#### UpdateProfileUseCase
```dart
class UpdateProfileUseCase {
  Future<Result<UserProfile>> execute(Map<String, dynamic> profileData);
}
```

#### UploadProfilePictureUseCase
```dart
class UploadProfilePictureUseCase {
  Future<Result<String>> execute(File imageFile);
}
```

#### DeleteProfilePictureUseCase
```dart
class DeleteProfilePictureUseCase {
  Future<Result<void>> execute();
}
```

---

### Announcements Feature

#### GetAnnouncementsUseCase
```dart
class GetAnnouncementsUseCase {
  Future<Result<List<Announcement>>> execute(int page);
}
```

#### GetAnnouncementDetailsUseCase
```dart
class GetAnnouncementDetailsUseCase {
  Future<Result<Announcement>> execute(String announcementId);
}
```

#### SearchAnnouncementsUseCase
```dart
class SearchAnnouncementsUseCase {
  Future<Result<List<Announcement>>> execute(String searchText, int page);
}
```

#### FilterAnnouncementsUseCase
```dart
class FilterAnnouncementsUseCase {
  Future<Result<List<Announcement>>> execute(String? category, DateTime? fromDate, DateTime? toDate, int page);
}
```

---

### QR Wallet Feature

#### ScanQRCodeUseCase
```dart
class ScanQRCodeUseCase {
  Future<Result<QRCodeData>> execute(String qrCodeString);
}
```

#### ShowQRCodeUseCase
```dart
class ShowQRCodeUseCase {
  Future<Result<String>> execute(); // Returns QR code image/data
}
```

#### ProcessPaymentUseCase
```dart
class ProcessPaymentUseCase {
  Future<Result<PaymentResponse>> execute(String id, String comments, double price, int counter);
}
```

#### GetPaymentHistoryUseCase
```dart
class GetPaymentHistoryUseCase {
  Future<Result<List<Transaction>>> execute();
}
```

#### GetTransactionDetailsUseCase
```dart
class GetTransactionDetailsUseCase {
  Future<Result<Transaction>> execute(String transactionId);
}
```

---

### Eclaims Feature

#### SubmitOutOfOfficeClaimUseCase
```dart
class SubmitOutOfOfficeClaimUseCase {
  Future<Result<Claim>> execute(Map<String, dynamic> claimData, List<File> attachments);
}
```

#### SubmitHealthScreeningClaimUseCase
```dart
class SubmitHealthScreeningClaimUseCase {
  Future<Result<Claim>> execute(Map<String, dynamic> claimData, List<File> attachments);
}
```

#### SubmitNewEntryClaimUseCase
```dart
class SubmitNewEntryClaimUseCase {
  Future<Result<Claim>> execute(Map<String, dynamic> claimData, List<File> attachments);
}
```

#### GetMyClaimsUseCase
```dart
class GetMyClaimsUseCase {
  Future<Result<List<Claim>>> execute();
}
```

#### GetClaimDetailsUseCase
```dart
class GetClaimDetailsUseCase {
  Future<Result<Claim>> execute(String claimId);
}
```

#### CancelClaimUseCase
```dart
class CancelClaimUseCase {
  Future<Result<void>> execute(String claimId);
}
```

---

### AstroDesk Feature

#### GetSupportTicketsUseCase
```dart
class GetSupportTicketsUseCase {
  Future<Result<List<Ticket>>> execute();
}
```

#### CreateSupportTicketUseCase
```dart
class CreateSupportTicketUseCase {
  Future<Result<Ticket>> execute(Map<String, dynamic> ticketData, File? image);
}
```

#### GetTicketDetailsUseCase
```dart
class GetTicketDetailsUseCase {
  Future<Result<Ticket>> execute(String ticketId);
}
```

#### GetTownHallContentUseCase
```dart
class GetTownHallContentUseCase {
  Future<Result<TownHallContent>> execute();
}
```

---

### Report Piracy Feature

#### SubmitCommercialOutletReportUseCase
```dart
class SubmitCommercialOutletReportUseCase {
  Future<Result<Report>> execute(Map<String, dynamic> reportData, List<File> attachments);
}
```

#### SubmitWebsiteReportUseCase
```dart
class SubmitWebsiteReportUseCase {
  Future<Result<Report>> execute(Map<String, dynamic> reportData, List<File> attachments);
}
```

#### GetReportHistoryUseCase
```dart
class GetReportHistoryUseCase {
  Future<Result<List<Report>>> execute();
}
```

---

### Settings Feature

#### GetAppVersionUseCase
```dart
class GetAppVersionUseCase {
  Future<Result<String>> execute();
}
```

#### CheckForUpdatesUseCase
```dart
class CheckForUpdatesUseCase {
  Future<Result<UpdateInfo>> execute();
}
```

#### UpdateNotificationPreferencesUseCase
```dart
class UpdateNotificationPreferencesUseCase {
  Future<Result<void>> execute(Map<String, bool> preferences);
}
```

---

### AstroNet Feature

#### LoginToAstroNetUseCase
```dart
class LoginToAstroNetUseCase {
  Future<Result<void>> execute(String username, String password);
}
```

#### GetAstroNetContentUseCase
```dart
class GetAstroNetContentUseCase {
  Future<Result<String>> execute(); // Returns URL or content
}
```

---

### Steps Challenge Feature

#### GetStepDataUseCase
```dart
class GetStepDataUseCase {
  Future<Result<List<StepData>>> execute();
}
```

#### SyncStepsFromHealthAppUseCase
```dart
class SyncStepsFromHealthAppUseCase {
  Future<Result<void>> execute();
}
```

#### GetRankingsUseCase
```dart
class GetRankingsUseCase {
  Future<Result<List<Ranking>>> execute();
}
```

#### GetProgressGraphUseCase
```dart
class GetProgressGraphUseCase {
  Future<Result<List<StepDataPoint>>> execute(DateTime fromDate, DateTime toDate);
}
```

---

### Content Highlights Feature

#### GetContentHighlightsUseCase
```dart
class GetContentHighlightsUseCase {
  Future<Result<String>> execute(); // Returns URL or content
}
```

---

### Friends & Family Feature

#### GetFriendsFamilyContentUseCase
```dart
class GetFriendsFamilyContentUseCase {
  Future<Result<String>> execute(); // Returns URL or content
}
```

---

### Sooka Share Feature

#### GetSookaShareContentUseCase
```dart
class GetSookaShareContentUseCase {
  Future<Result<String>> execute(); // Returns URL or content
}
```

#### SubmitReferLeadUseCase
```dart
class SubmitReferLeadUseCase {
  Future<Result<void>> execute(Map<String, dynamic> leadData);
}
```

---

## Feature Components - Repositories (Data Layer)

### AuthRepository
```dart
class AuthRepository {
  Future<Result<TokenResponse>> exchangeAuthCode(String code);
  Future<Result<TokenResponse>> refreshToken(String refreshToken);
  Future<Result<void>> revokeSignInSessions();
  Future<Result<void>> invalidateRefreshTokens();
  Future<Result<void>> saveTokens(TokenResponse tokens);
  Future<Result<TokenResponse?>> getStoredTokens();
  Future<Result<void>> clearTokens();
}
```

### HomeRepository
```dart
class HomeRepository {
  Future<Result<List<LandingCategory>>> getLandingCategories();
  Future<Result<UserProfile>> getUserProfile();
  Future<Result<List<NotificationData>>> getModuleNotifications(String moduleId);
  Future<Result<void>> registerPushToken(String firebaseToken, String hmsToken, String appVersion);
  Future<Result<AppVersion>> getAppVersion();
  Future<Result<MaintenanceStatus>> getMaintenanceStatus();
  Future<Result<UserCheck>> checkUser();
}
```

### ProfileRepository
```dart
class ProfileRepository {
  Future<Result<UserProfile>> getProfile();
  Future<Result<UserProfile>> updateProfile(Map<String, dynamic> profileData);
  Future<Result<String>> uploadProfilePicture(File imageFile);
  Future<Result<void>> deleteProfilePicture();
  Future<Result<UserProfile?>> getCachedProfile();
  Future<Result<void>> cacheProfile(UserProfile profile);
}
```

### AnnouncementRepository (Entity-based)
```dart
class AnnouncementRepository {
  Future<Result<List<Announcement>>> getAnnouncements(int page);
  Future<Result<Announcement>> getAnnouncementDetails(String announcementId);
  Future<Result<List<Announcement>>> searchAnnouncements(String searchText, int page);
  Future<Result<List<Announcement>>> filterAnnouncements(String? category, DateTime? fromDate, DateTime? toDate, int page);
  Future<Result<List<Announcement>>> getCachedAnnouncements();
  Future<Result<void>> cacheAnnouncements(List<Announcement> announcements);
}
```

### QRWalletRepository
```dart
class QRWalletRepository {
  Future<Result<PaymentResponse>> processPayment(String id, String comments, double price, int counter);
  Future<Result<List<Transaction>>> getPaymentHistory();
  Future<Result<Transaction>> getTransactionDetails(String transactionId);
  Future<Result<String>> generateQRCode();
  Future<Result<List<Transaction>>> getCachedPaymentHistory();
  Future<Result<void>> cachePaymentHistory(List<Transaction> transactions);
}
```

### EclaimsRepository
```dart
class EclaimsRepository {
  Future<Result<Claim>> submitClaim(Map<String, dynamic> claimData, List<File> attachments);
  Future<Result<Claim>> updateClaim(String claimId, Map<String, dynamic> claimData, List<File> attachments);
  Future<Result<List<Claim>>> getMyClaims();
  Future<Result<Claim>> getClaimDetails(String claimId);
  Future<Result<void>> cancelClaim(String claimId);
  Future<Result<List<Claim>>> getCachedClaims();
  Future<Result<void>> cacheClaims(List<Claim> claims);
}
```

### AstroDeskRepository
```dart
class AstroDeskRepository {
  Future<Result<List<Ticket>>> getSupportTickets();
  Future<Result<Ticket>> createSupportTicket(Map<String, dynamic> ticketData, File? image);
  Future<Result<Ticket>> getTicketDetails(String ticketId);
  Future<Result<TownHallContent>> getTownHallContent();
  Future<Result<List<Ticket>>> getCachedTickets();
  Future<Result<void>> cacheTickets(List<Ticket> tickets);
}
```

### ReportPiracyRepository
```dart
class ReportPiracyRepository {
  Future<Result<Report>> submitReport(Map<String, dynamic> reportData, List<File> attachments);
  Future<Result<List<Report>>> getReportHistory();
  Future<Result<List<Report>>> getCachedReports();
  Future<Result<void>> cacheReports(List<Report> reports);
}
```

### SettingsRepository
```dart
class SettingsRepository {
  Future<Result<String>> getAppVersion();
  Future<Result<UpdateInfo>> checkForUpdates();
  Future<Result<void>> updateNotificationPreferences(Map<String, bool> preferences);
  Future<Result<Map<String, bool>>> getNotificationPreferences();
}
```

### AstroNetRepository
```dart
class AstroNetRepository {
  Future<Result<void>> login(String username, String password);
  Future<Result<String>> getContent();
}
```

### StepsChallengeRepository
```dart
class StepsChallengeRepository {
  Future<Result<List<StepData>>> getStepData();
  Future<Result<void>> updateSteps(int steps, DateTime date);
  Future<Result<List<Ranking>>> getRankings();
  Future<Result<List<StepData>>> getStepsFromHealthApp();
  Future<Result<List<StepData>>> getCachedStepData();
  Future<Result<void>> cacheStepData(List<StepData> stepData);
}
```

### ContentHighlightsRepository
```dart
class ContentHighlightsRepository {
  Future<Result<String>> getContent();
}
```

### FriendsFamilyRepository
```dart
class FriendsFamilyRepository {
  Future<Result<String>> getContent();
}
```

### SookaShareRepository
```dart
class SookaShareRepository {
  Future<Result<String>> getContent();
  Future<Result<void>> submitReferLead(Map<String, dynamic> leadData);
}
```

---

## Notes

- **Return Types**: All repository and use case methods return `Result<T>` type for error handling
- **Input Validation**: Validation logic will be defined in Functional Design
- **Business Rules**: Detailed business rules will be defined in Functional Design
- **Error Handling**: Errors are wrapped in Result type, exceptions are caught and converted
- **Caching**: Repositories handle both API calls and local caching
- **File Uploads**: Methods accepting File parameters handle multipart form data

