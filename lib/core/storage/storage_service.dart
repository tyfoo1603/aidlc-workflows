import 'package:hive_flutter/hive_flutter.dart';

/// Storage service for managing Hive boxes
class StorageService {
  static const String _userProfileBox = 'user_profile';
  static const String _landingCategoriesBox = 'landing_categories';
  static const String _announcementsBox = 'announcements';
  static const String _transactionsBox = 'transactions';
  static const String _claimsBox = 'claims';
  static const String _ticketsBox = 'tickets';
  static const String _reportsBox = 'reports';
  static const String _stepsBox = 'steps';

  /// Initialize Hive storage
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // TODO: Register type adapters for entities
    // Hive.registerAdapter(UserProfileAdapter());
    // etc.
    
    // Open boxes (non-encrypted for cached data)
    await Hive.openBox(_userProfileBox);
    await Hive.openBox(_landingCategoriesBox);
    await Hive.openBox(_announcementsBox);
    await Hive.openBox(_transactionsBox);
    await Hive.openBox(_claimsBox);
    await Hive.openBox(_ticketsBox);
    await Hive.openBox(_reportsBox);
    await Hive.openBox(_stepsBox);
  }

  /// Get user profile box
  Box get userProfileBox => Hive.box(_userProfileBox);

  /// Get landing categories box
  Box get landingCategoriesBox => Hive.box(_landingCategoriesBox);

  /// Get announcements box
  Box get announcementsBox => Hive.box(_announcementsBox);

  /// Get transactions box
  Box get transactionsBox => Hive.box(_transactionsBox);

  /// Get claims box
  Box get claimsBox => Hive.box(_claimsBox);

  /// Get tickets box
  Box get ticketsBox => Hive.box(_ticketsBox);

  /// Get reports box
  Box get reportsBox => Hive.box(_reportsBox);

  /// Get steps box
  Box get stepsBox => Hive.box(_stepsBox);

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await userProfileBox.clear();
    await landingCategoriesBox.clear();
    await announcementsBox.clear();
    await transactionsBox.clear();
    await claimsBox.clear();
    await ticketsBox.clear();
    await reportsBox.clear();
    await stepsBox.clear();
  }

  /// Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
  }
}

