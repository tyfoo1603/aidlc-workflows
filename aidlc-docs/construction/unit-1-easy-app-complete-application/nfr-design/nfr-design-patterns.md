# NFR Design Patterns - Unit 1: Easy App Complete Application

## Overview

This document defines NFR design patterns for Unit 1: Easy App Complete Application, focusing on Core Infrastructure. These patterns implement the NFR requirements to ensure performance, security, scalability, and availability.

---

## Performance Patterns

### PERF-PATTERN-001: App Startup Optimization

**Pattern**: Optimized App Initialization
**NFR Requirement**: PERF-001 (App startup < 2 seconds)

**Design**:
- **Lazy Initialization**: Initialize non-critical services lazily
- **Parallel Initialization**: Initialize independent services in parallel
- **Pre-initialization**: Pre-initialize critical services before app launch
- **Deferred Loading**: Defer heavy operations until after home page display

**Implementation**:
```dart
// Core services initialized first (blocking)
await initializeStorage();
await initializeNetwork();

// Repositories initialized in parallel (non-blocking)
await Future.wait([
  initializeAuthRepository(),
  initializeHomeRepository(),
]);

// Use cases and BLoCs initialized lazily (on first use)
```

**Critical Path**:
1. Storage initialization (required for token check)
2. Network initialization (required for API calls)
3. Authentication check (required for navigation)
4. Home page data loading (can be parallel)

---

### PERF-PATTERN-002: API Response Time Optimization

**Pattern**: Optimized API Calls
**NFR Requirement**: PERF-002 (Critical APIs < 1s, others < 2s)

**Design**:
- **Request Batching**: Batch multiple requests when possible
- **Parallel Requests**: Load home page data in parallel
- **Request Deduplication**: Prevent duplicate concurrent requests
- **Response Caching**: Cache API responses to avoid redundant calls

**Implementation**:
```dart
// Parallel data loading for home page
Future.wait([
  getLandingCategories(),
  getUserProfile(),
  getModuleNotifications(),
  getAppVersion(),
  getMaintenanceStatus(),
]);
```

**Caching Strategy**:
- Cache API responses with expiration
- Use cached data when available
- Refresh in background

---

### PERF-PATTERN-003: Image Loading Optimization

**Pattern**: Lazy Image Loading with Memory + Disk Cache
**NFR Requirement**: PERF-003 (Lazy load with memory + disk cache)

**Design**:
- **Lazy Loading**: Load images as they come into view
- **Memory Cache**: Cache frequently accessed images in memory
- **Disk Cache**: Persist images to disk for offline access
- **Preloading**: Preload critical images (user avatar, module icons)

**Implementation**:
```dart
// Use cached_network_image
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 200,
  memCacheHeight: 200,
  maxWidthDiskCache: 500,
  maxHeightDiskCache: 500,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**Cache Configuration**:
- Memory cache: 50 MB
- Disk cache: 100 MB
- LRU eviction policy

---

### PERF-PATTERN-004: Data Caching with Size Limits and Expiration

**Pattern**: Smart Caching with Limits
**NFR Requirement**: PERF-004 (Cache with size limits and expiration)

**Design**:
- **Size Limits**: Fixed cache size limits per data type
- **LRU Eviction**: Remove least recently used data when cache is full
- **Time-based Expiration**: Remove expired data automatically
- **Cache Invalidation**: Invalidate cache on data updates

**Implementation**:
```dart
// Cache configuration
class CacheConfig {
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration defaultExpiration = Duration(minutes: 30);
  
  static const Map<Type, Duration> expirationTimes = {
    UserProfile: Duration(hours: 1),
    LandingCategory: Duration(minutes: 30),
    Announcement: Duration(minutes: 15),
    Transaction: Duration(hours: 1),
  };
}
```

**Cache Management**:
- Monitor cache size
- Evict LRU items when limit reached
- Remove expired items periodically
- Invalidate on updates

---

## Security Patterns

### SEC-PATTERN-001: Secure Token Storage

**Pattern**: Platform-Native Secure Storage
**NFR Requirement**: SEC-001 (flutter_secure_storage for tokens)

**Design**:
- **Platform Keychain/Keystore**: Use platform-native secure storage
- **Automatic Encryption**: Leverage platform encryption
- **Token Separation**: Store tokens separately from other data
- **Secure Access**: Access tokens only through secure storage API

**Implementation**:
```dart
// Token storage service
class SecureTokenStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  Future<void> saveTokens(Token token) async {
    await _storage.write(key: 'access_token', value: token.accessToken);
    await _storage.write(key: 'refresh_token', value: token.refreshToken);
    await _storage.write(key: 'expires_at', value: token.expiresAt.toIso8601String());
  }
  
  Future<Token?> getTokens() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final expiresAtStr = await _storage.read(key: 'expires_at');
    
    if (accessToken == null || refreshToken == null || expiresAtStr == null) {
      return null;
    }
    
    return Token(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtStr),
    );
  }
}
```

**Security Benefits**:
- Platform-native encryption
- Hardware-backed security (when available)
- Automatic key management
- Secure deletion

---

### SEC-PATTERN-002: Certificate Pinning

**Pattern**: SSL Certificate Pinning for All Environments
**NFR Requirement**: SEC-002 (Pin certificates for all environments)

**Design**:
- **Certificate Pinning**: Pin SSL certificates for API endpoints
- **Environment-Specific**: Different certificates per environment
- **Strict Enforcement**: Block requests on pin failure
- **Certificate Rotation**: Support certificate updates

**Implementation**:
```dart
// Certificate pinning configuration
class CertificatePinningConfig {
  static Map<String, List<String>> get certificates => {
    'dev': [
      'sha256/DEV_CERTIFICATE_HASH_1',
      'sha256/DEV_CERTIFICATE_HASH_2',
    ],
    'staging': [
      'sha256/STAGING_CERTIFICATE_HASH_1',
      'sha256/STAGING_CERTIFICATE_HASH_2',
    ],
    'prod': [
      'sha256/PROD_CERTIFICATE_HASH_1',
      'sha256/PROD_CERTIFICATE_HASH_2',
    ],
  };
}

// Dio interceptor for certificate pinning
class CertificatePinningInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Certificate pinning handled by Dio's certificate pinning plugin
    handler.next(options);
  }
}
```

**Pinning Strategy**:
- Pin leaf certificate + intermediate certificates
- Support multiple pins for certificate rotation
- Strict enforcement (no fallback)
- Environment-specific pins

---

### SEC-PATTERN-003: API Request Security

**Pattern**: Certificate Pinning + Bearer Token Authentication
**NFR Requirement**: SEC-004 (Certificate pinning + Bearer token)

**Design**:
- **Certificate Pinning**: All API requests use pinned certificates
- **Bearer Token**: Access token in Authorization header
- **Token Refresh**: Automatic token refresh on 401
- **HTTPS Only**: All API calls over HTTPS

**Implementation**:
```dart
// API interceptor for authentication
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getTokens();
    if (token != null && !token.isExpired) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token refresh logic
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        return handler.resolve(await _retry(err.requestOptions));
      }
    }
    handler.next(err);
  }
}
```

**Security Measures**:
- All requests over HTTPS
- Certificate pinning enforced
- Bearer token authentication
- Automatic token refresh

---

## Scalability Patterns

### SCAL-PATTERN-001: Hybrid Offline Synchronization

**Pattern**: Auto-Sync Critical Data, Manual Sync Others
**NFR Requirement**: SCAL-001 (Hybrid synchronization)

**Design**:
- **Auto-Sync Critical**: Automatically sync critical data when connection restored
- **Manual Sync Others**: User triggers sync for other data
- **Background Sync**: Sync in background without blocking UI
- **Sync Notification**: Notify user when sync completes

**Implementation**:
```dart
// Sync service
class DataSyncService {
  // Auto-sync critical data
  Future<void> autoSyncCritical() async {
    await Future.wait([
      syncUserProfile(),
      syncHomeModules(),
      syncAppVersion(),
      syncMaintenanceStatus(),
    ]);
  }
  
  // Manual sync for other data
  Future<void> manualSyncAll() async {
    await Future.wait([
      syncAnnouncements(),
      syncTransactions(),
      syncClaims(),
      syncTickets(),
    ]);
  }
  
  // Monitor connection and auto-sync
  void monitorConnection() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        autoSyncCritical();
      }
    });
  }
}
```

**Sync Strategy**:
- Critical data: Auto-sync on connection restore
- Other data: Manual sync on user request
- Background sync: Non-blocking
- User notification: Show sync status

---

### SCAL-PATTERN-002: Cache Size Management with LRU Eviction

**Pattern**: Fixed Size Cache with LRU Eviction
**NFR Requirement**: SCAL-002 (Fixed size limit with LRU eviction)

**Design**:
- **Fixed Size Limits**: Set maximum cache size per data type
- **LRU Eviction**: Remove least recently used items when limit reached
- **Cache Monitoring**: Monitor cache size and eviction
- **Automatic Cleanup**: Automatic eviction when limits reached

**Implementation**:
```dart
// LRU cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();
  
  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      final value = _cache.remove(key);
      _cache[key] = value!;
      return value;
    }
    return null;
  }
  
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used (first item)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
}
```

**Cache Limits**:
- Image cache: 50 MB
- Data cache: 100 MB
- Total cache: 150 MB
- LRU eviction when limits reached

---

### SCAL-PATTERN-003: Infinite Scroll with Lazy Loading

**Pattern**: Infinite Scroll for Large Datasets
**NFR Requirement**: SCAL-003 (Infinite scroll with lazy loading)

**Design**:
- **Infinite Scroll**: Load more items as user scrolls
- **Lazy Loading**: Load items only when needed
- **Pagination**: Server-side pagination
- **Loading Indicators**: Show loading state during fetch

**Implementation**:
```dart
// Infinite scroll list
class InfiniteScrollList extends StatefulWidget {
  @override
  _InfiniteScrollListState createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }
  
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    final items = await _fetchPage(_currentPage);
    setState(() {
      _items.addAll(items);
      _currentPage++;
      _isLoading = false;
      _hasMore = items.length >= pageSize;
    });
  }
}
```

**Loading Strategy**:
- Load initial page on screen load
- Load next page when user scrolls near end
- Show loading indicator during fetch
- Handle end of list gracefully

---

### SCAL-PATTERN-004: Memory Management with Monitoring

**Pattern**: Explicit Cache Limits + Memory Monitoring
**NFR Requirement**: SCAL-004 (Explicit cache limits + memory monitoring)

**Design**:
- **Explicit Limits**: Set explicit cache size limits
- **Memory Monitoring**: Monitor memory usage
- **Logging**: Log memory warnings for debugging
- **Cleanup**: Cleanup unused resources

**Implementation**:
```dart
// Memory monitoring service
class MemoryMonitor {
  static void monitorMemory() {
    Timer.periodic(Duration(minutes: 5), (timer) {
      final memoryUsage = _getMemoryUsage();
      if (memoryUsage > 100 * 1024 * 1024) { // 100 MB
        _logMemoryWarning(memoryUsage);
        _cleanupUnusedResources();
      }
    });
  }
  
  static void _cleanupUnusedResources() {
    // Clear image cache if over limit
    imageCache.clear();
    imageCache.clearLiveImages();
    
    // Clear unused data cache
    dataCache.cleanup();
  }
}
```

**Memory Management**:
- Set explicit cache size limits
- Monitor memory usage periodically
- Log warnings when limits exceeded
- Cleanup unused resources automatically

---

## Availability Patterns

### AVAIL-PATTERN-001: Network Failure Handling

**Pattern**: Error Message + Manual Retry
**NFR Requirement**: AVAIL-001 (Show error, allow manual retry)

**Design**:
- **Error Detection**: Detect network failures
- **User-Friendly Messages**: Show clear error messages
- **Manual Retry**: Provide retry button
- **Cached Data**: Show cached data if available with offline indicator

**Implementation**:
```dart
// Error handling widget
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool showCachedData;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showCachedData) 
          OfflineIndicator(),
        Text(message),
        ElevatedButton(
          onPressed: onRetry,
          child: Text('Retry'),
        ),
      ],
    );
  }
}
```

**Error Handling**:
- Detect network failures
- Show user-friendly error message
- Provide manual retry button
- Show cached data with offline indicator

---

### AVAIL-PATTERN-002: Automatic Retry for Network Errors

**Pattern**: Auto-Retry with Exponential Backoff
**NFR Requirement**: AVAIL-002 (Auto-retry for network errors only)

**Design**:
- **Network Error Detection**: Identify network errors
- **Exponential Backoff**: Retry with increasing delays
- **Max Retries**: Limit retry attempts (max 3)
- **Error After Retries**: Show error message after retries fail

**Implementation**:
```dart
// Retry interceptor
class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isNetworkError(err) && _retryCount < 3) {
      await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
      _retryCount++;
      // Retry request
      return handler.resolve(await _retry(err.requestOptions));
    }
    handler.next(err);
  }
  
  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}
```

**Retry Strategy**:
- Network errors only
- Exponential backoff (1s, 2s, 4s)
- Maximum 3 retries
- Show error after retries fail

---

### AVAIL-PATTERN-003: Maintenance Mode Handling

**Pattern**: Maintenance Banner + Warnings
**NFR Requirement**: AVAIL-003 (Maintenance banner, allow all functionality with warnings)

**Design**:
- **Maintenance Detection**: Check maintenance status
- **Banner Display**: Show maintenance banner
- **Functionality**: Allow all app functionality
- **Warnings**: Show warnings on API calls

**Implementation**:
```dart
// Maintenance mode handler
class MaintenanceHandler {
  static bool _isMaintenanceActive = false;
  static String? _maintenanceMessage;
  
  static void checkMaintenance() async {
    final status = await _getMaintenanceStatus();
    _isMaintenanceActive = status.isActive;
    _maintenanceMessage = status.message;
  }
  
  static Widget buildBanner() {
    if (!_isMaintenanceActive) return SizedBox.shrink();
    
    return Banner(
      message: _maintenanceMessage ?? 'Maintenance in progress',
      location: BannerLocation.topStart,
      color: Colors.orange,
    );
  }
  
  static void showWarning() {
    if (_isMaintenanceActive) {
      // Show warning dialog or snackbar
    }
  }
}
```

**Maintenance Behavior**:
- Display maintenance banner
- Allow all functionality
- Show warnings on API calls
- Display maintenance message

---

## Integration Patterns

### INT-PATTERN-001: Push Notification Handling

**Pattern**: Consistent Notification Handling
**NFR Requirement**: INT-001 (Handle notifications same way regardless of state)

**Design**:
- **Consistent Handling**: Same handling for all app states
- **Deep Linking**: Navigate to appropriate feature
- **Notification Display**: Show notification appropriately
- **No Special Queuing**: No different handling per state

**Implementation**:
```dart
// Push notification handler
class PushNotificationHandler {
  static void handleNotification(RemoteMessage message) {
    // Same handling regardless of app state
    final data = message.data;
    final route = data['route'];
    
    // Navigate to route
    NavigationService.navigateToRoute(route);
  }
  
  static void initialize() {
    FirebaseMessaging.onMessage.listen((message) {
      handleNotification(message);
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleNotification(message);
    });
  }
}
```

**Notification Handling**:
- Foreground: Show in-app notification
- Background: Show system notification
- Terminated: Show system notification
- Deep link: Navigate to feature

---

### INT-PATTERN-002: Real-Time Health Data Sync

**Pattern**: Real-Time Step Sync
**NFR Requirement**: INT-002 (Real-time sync whenever steps change)

**Design**:
- **Step Monitoring**: Monitor step changes in real-time
- **Immediate Sync**: Sync immediately when steps change
- **Background Sync**: Sync in background when app is backgrounded
- **Permission Handling**: Handle permission denials gracefully

**Implementation**:
```dart
// Health data sync service
class HealthDataSyncService {
  StreamSubscription? _stepSubscription;
  
  void startMonitoring() {
    _stepSubscription = Health().getStepsStream().listen((steps) {
      _syncSteps(steps);
    });
  }
  
  Future<void> _syncSteps(int steps) async {
    await apiService.updateSteps(
      userId: currentUserId,
      steps: steps,
      date: DateTime.now(),
    );
  }
}
```

**Sync Strategy**:
- Monitor step changes in real-time
- Sync immediately when steps change
- Background sync when app is backgrounded
- Handle permission denials

---

### INT-PATTERN-003: Deep Link Handling

**Pattern**: Consistent Deep Link Handling
**NFR Requirement**: INT-003 (Handle deep links same way regardless of state)

**Design**:
- **Consistent Handling**: Same handling for all app states
- **URL Parsing**: Parse deep link URL
- **Access Validation**: Validate user access
- **Navigation**: Navigate to appropriate feature

**Implementation**:
```dart
// Deep link handler
class DeepLinkHandler {
  static void handleDeepLink(String url) {
    // Same handling regardless of app state
    final uri = Uri.parse(url);
    final route = uri.path;
    final params = uri.queryParameters;
    
    // Validate user access
    if (_validateAccess(route)) {
      NavigationService.navigateToRoute(route, params: params);
    } else {
      _showAccessDenied();
    }
  }
  
  static bool _validateAccess(String route) {
    // Check user permissions
    return true;
  }
}
```

**Deep Link Handling**:
- Parse deep link URL
- Validate user access
- Navigate to feature
- Same handling for all states

---

## Pattern Summary

| Pattern Category | Pattern | NFR Requirement | Priority |
|-----------------|---------|-----------------|----------|
| Performance | App Startup Optimization | PERF-001 | High |
| Performance | API Response Time Optimization | PERF-002 | High |
| Performance | Image Loading Optimization | PERF-003 | Medium |
| Performance | Data Caching with Limits | PERF-004 | High |
| Security | Secure Token Storage | SEC-001 | Critical |
| Security | Certificate Pinning | SEC-002 | High |
| Security | API Request Security | SEC-004 | High |
| Scalability | Hybrid Offline Sync | SCAL-001 | Medium |
| Scalability | Cache Size Management | SCAL-002 | Medium |
| Scalability | Infinite Scroll | SCAL-003 | Medium |
| Scalability | Memory Management | SCAL-004 | Medium |
| Availability | Network Failure Handling | AVAIL-001 | High |
| Availability | Automatic Retry | AVAIL-002 | High |
| Availability | Maintenance Mode | AVAIL-003 | Medium |
| Integration | Push Notification Handling | INT-001 | High |
| Integration | Health Data Sync | INT-002 | Medium |
| Integration | Deep Link Handling | INT-003 | Medium |

---

## Notes

- **Pattern Implementation**: Patterns are implemented at appropriate layers (data, domain, presentation)
- **Pattern Testing**: All patterns should be tested thoroughly
- **Pattern Monitoring**: Monitor pattern effectiveness and adjust as needed
- **Pattern Documentation**: Document pattern usage in code

