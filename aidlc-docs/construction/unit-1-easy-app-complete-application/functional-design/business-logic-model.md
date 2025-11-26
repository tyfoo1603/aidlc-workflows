# Business Logic Model - Unit 1: Easy App Complete Application

## Overview

This document defines the business logic workflows and processes for the Core Infrastructure of the Easy App Flutter mobile application. It focuses on authentication, home page, navigation, error handling, and core services initialization.

---

## Authentication Business Logic

### OAuth Flow State Machine

**State Management Approach**: Single state machine with explicit states and transitions

**States**:
1. **Initial**: App starts, no authentication state
2. **Authorizing**: OAuth webview opened, waiting for user authentication
3. **CodeReceived**: Authorization code intercepted from redirect
4. **Exchanging**: Exchanging authorization code for tokens
5. **Authenticated**: Tokens received and stored, user authenticated
6. **Error**: Authentication failed at any step

**State Transitions**:
```
Initial → Authorizing (user taps "Sign in with Astro")
Authorizing → CodeReceived (OAuth redirect intercepted with code)
Authorizing → Error (user cancels or OAuth fails)
CodeReceived → Exchanging (code exchange initiated)
Exchanging → Authenticated (tokens received and stored)
Exchanging → Error (token exchange fails)
Authenticated → Initial (logout)
Error → Initial (retry login)
```

**Business Rules**:
- State machine is managed by AuthBloc/AuthCubit
- State transitions are atomic (one state at a time)
- Error state provides error details for user feedback
- Authenticated state persists across app restarts (via token storage)

---

### Token Management Workflow

**Token Storage**:
- **Encryption**: Hive's built-in encryption with master key derived from device
- **Storage Location**: Encrypted Hive box
- **Tokens Stored**: accessToken, refreshToken, expiresAt, issuedAt, userId

**Token Refresh Strategy**: Combination of proactive and reactive refresh
- **Proactive Refresh**: Background refresh before token expires (e.g., 5 minutes before expiry)
- **Reactive Refresh**: Automatic refresh on 401 response
- **Refresh Flow**: 
  1. Intercept 401 in API interceptor
  2. Lock interceptor to prevent concurrent refresh attempts
  3. Call refreshToken API with stored refreshToken
  4. Update stored tokens on success
  5. Retry original request with new accessToken
  6. Unlock interceptor
  7. If refresh fails, force logout and navigate to login

**Token Validation on App Launch**:
- Check for stored tokens
- If tokens exist, fetch user profile to verify authentication
- If profile fetch succeeds, consider user authenticated
- If profile fetch fails (401), attempt token refresh
- If refresh fails, clear tokens and navigate to login

---

### Authentication State Persistence

**On App Launch**:
1. Initialize storage (Hive)
2. Check for stored tokens
3. If tokens exist:
   - Fetch user profile to verify authentication
   - If profile fetch succeeds → Navigate to Home
   - If profile fetch fails → Attempt token refresh → If refresh fails → Navigate to Login
4. If no tokens exist → Navigate to Login

**Business Rules**:
- Authentication state persists via stored tokens
- Token validity verified by fetching user profile
- Automatic token refresh on validation failure
- Force re-login if refresh fails

---

### Logout Workflow

**Data Clearing**: Clear tokens + user profile + cached data + app preferences

**Logout Steps**:
1. User initiates logout (from home page menu/settings)
2. Display confirmation dialog
3. On confirmation:
   - Clear authentication tokens from storage
   - Clear user profile data from storage
   - Clear all cached feature data (announcements, transactions, claims, etc.)
   - Clear app preferences (notification preferences, etc.)
   - Attempt to revoke server sessions via Azure Graph API (non-blocking)
   - Attempt to invalidate refresh tokens via Azure Graph API (non-blocking)
   - Navigate to login screen
4. If server revocation fails, logout still completes locally with notification

**Business Rules**:
- Logout clears all local session data
- Server session revocation is attempted but not blocking
- User must manually log in again after logout
- Push notification tokens are cleared/unregistered on logout

---

## Home Page Business Logic

### Module Loading Strategy

**Loading Approach**: Load all data in parallel

**Data Sources** (loaded in parallel):
1. Landing Categories (modules)
2. User Profile (for user summary)
3. Module Notifications (per module)
4. App Version
5. Maintenance Status
6. User Check

**Loading Flow**:
1. Home page loads → Show loading indicator
2. Initiate all API calls in parallel
3. Wait for all responses (or handle failures individually)
4. Update UI with received data
5. Hide loading indicator

**Business Rules**:
- All data loaded in parallel for faster page load
- Individual API failures don't block other data loading
- Failed data sources show appropriate error states
- Cached data can be displayed while fresh data loads

---

### Module Permission Filtering

**Filtering Approach**: Filter on server response (only return modules user has access to)

**Business Rules**:
- Server returns only modules user has permission to access
- Client displays all modules received from server
- No client-side filtering needed (server handles permissions)
- If no modules returned, show appropriate empty state

---

### Push Token Registration

**Registration Timing**: Register on app launch (before home page), not on home page load

**Registration Flow**:
1. App launches
2. After authentication (or if already authenticated)
3. Get FCM token (Firebase Cloud Messaging)
4. Get HMS token (Huawei Mobile Services) if on Huawei device
5. Register tokens with backend via `registerPushToken` API
6. Registration happens in background (non-blocking)
7. If registration fails, retry with exponential backoff

**Business Rules**:
- Push token registration occurs on app launch, not home page load
- Registration is non-blocking (doesn't delay app startup)
- Registration retries on failure with exponential backoff
- Tokens are registered only if not already registered (check before registering)

---

### Maintenance Mode Handling

**Maintenance Mode Behavior**: Display maintenance banner, allow all functionality but show warnings

**Maintenance Mode Flow**:
1. Check maintenance status on app launch/home load
2. If maintenance mode is active:
   - Display maintenance banner at top of screen
   - Allow all app functionality
   - Show warnings on API calls that maintenance is active
   - Display maintenance message from server
3. If maintenance mode is inactive:
   - Hide maintenance banner
   - Normal app operation

**Business Rules**:
- Maintenance mode doesn't block app usage
- Users can still view cached content
- API calls may fail during maintenance (expected)
- Clear maintenance message displayed to users

---

### App Version Update Handling

**Update Strategy**: Combination - Force update for critical versions, optional for minor versions

**Version Check Flow**:
1. Check app version on app launch/home load
2. Compare current app version with server version
3. If server indicates critical update required:
   - Display force update dialog (cannot be dismissed)
   - Block app usage until updated
   - Provide link to app store for update
4. If server indicates optional update available:
   - Display optional update notification
   - Allow user to defer update
   - Show update notification again on next app launch
5. If versions match:
   - No action needed

**Business Rules**:
- Critical updates force app update (blocking)
- Minor updates are optional (user can defer)
- Update notifications are non-intrusive for optional updates
- Force update dialog cannot be dismissed

---

## Navigation Business Logic

### Navigation Route Configuration

**Route Configuration**: Hardcoded route definitions in NavigationService

**Route Structure**:
- Routes defined as constants in NavigationService
- Each feature has a dedicated route
- Routes include: Login, Home, Profile, Announcements, QR Wallet, Eclaims, AstroDesk, Report Piracy, Settings, AstroNet, Steps Challenge, Content Highlights, Friends & Family, Sooka Share, WebView

**Navigation Flow**:
1. Feature requests navigation via NavigationService
2. NavigationService resolves route from hardcoded definitions
3. NavigationService performs navigation using Flutter Navigator
4. Navigation state managed by NavigationService

**Business Rules**:
- All routes defined in NavigationService
- Routes are type-safe (no string-based routing)
- NavigationService handles route parameters
- Deep links resolve to NavigationService routes

---

### Deep Linking Strategy

**Deep Link Handling**: Deep links handled by separate deep link service, NavigationService receives route

**Deep Link Flow**:
1. App receives deep link (from notification or external source)
2. DeepLinkService parses deep link URL
3. DeepLinkService extracts feature/module ID
4. DeepLinkService validates user has access to feature
5. DeepLinkService converts deep link to NavigationService route
6. DeepLinkService calls NavigationService with route
7. NavigationService performs navigation

**Business Rules**:
- Deep links are validated before navigation
- User access is verified before navigation
- Deep links are converted to NavigationService routes
- NavigationService handles actual navigation

---

## Error Handling Business Logic

### Error Classification

**Classification Approach**: Network errors, Authentication errors, Server errors, Validation errors, Unknown errors

**Error Categories**:
1. **Network Errors**: No internet, timeout, connection refused
2. **Authentication Errors**: 401 Unauthorized, token expired, invalid credentials
3. **Server Errors**: 500 Internal Server Error, 503 Service Unavailable, server maintenance
4. **Validation Errors**: 400 Bad Request, invalid input, missing required fields
5. **Unknown Errors**: Unexpected errors, unmapped status codes

**Error Handling**:
- Each error category has specific handling logic
- Error messages are user-friendly
- Technical error details logged for debugging
- User sees appropriate error message based on category

---

### Error Recovery Strategy

**Recovery Approach**: Automatic retry with exponential backoff for network errors

**Retry Strategy**:
1. **Network Errors**: Automatic retry with exponential backoff (max 3 retries)
   - Retry after 1 second
   - Retry after 2 seconds
   - Retry after 4 seconds
   - If all retries fail, show error message with manual retry option
2. **Authentication Errors**: Trigger token refresh, retry original request
3. **Server Errors**: Show error message, allow manual retry
4. **Validation Errors**: Show validation error message, no retry
5. **Unknown Errors**: Show generic error message, allow manual retry

**Business Rules**:
- Network errors are retried automatically
- Retry uses exponential backoff to avoid overwhelming server
- Maximum 3 retries for network errors
- After retries fail, show error with manual retry option
- Authentication errors trigger token refresh automatically

---

## Core Infrastructure Initialization

### Dependency Injection Initialization

**Initialization Order**: Core services first (Storage, Network, Navigation), then Repositories, then Use Cases, then BLoCs

**Initialization Sequence**:
1. **Core Services** (registered first):
   - StorageService (Hive initialization)
   - NetworkService (Dio configuration)
   - NavigationService (route setup)
   - ErrorHandlerService
2. **Repositories** (registered second):
   - AuthRepository
   - HomeRepository
   - ProfileRepository
   - (All other feature repositories)
3. **Use Cases** (registered third):
   - LoginUseCase
   - LogoutUseCase
   - (All other feature use cases)
4. **BLoCs/Cubits** (registered last):
   - AuthBloc
   - HomeBloc
   - (All other feature BLoCs)

**Business Rules**:
- Initialization order is critical (dependencies must be registered before dependents)
- All services registered via get_it service locator
- Initialization happens on app launch
- Initialization failures prevent app startup

---

### Storage Initialization

**Initialization Timing**: Initialize on app launch, before any feature access

**Initialization Flow**:
1. App launches
2. Initialize Hive storage (before any other operations)
3. Open encrypted Hive boxes
4. Verify storage is ready
5. Proceed with app initialization
6. If storage initialization fails, show error and prevent app startup

**Business Rules**:
- Storage must be initialized before any feature access
- Storage initialization is blocking (app waits for completion)
- Storage initialization failures are fatal (app cannot start)
- Encrypted boxes are opened during initialization

---

### Network Configuration

**Configuration Approach**: Dio instance per environment (dev/staging/prod) with environment-specific configuration

**Network Setup**:
1. Determine current environment (dev/staging/prod) from build configuration
2. Create Dio instance for current environment
3. Configure base URL for environment
4. Configure certificate pinning for environment
5. Add interceptors:
   - Token refresh interceptor
   - Error handling interceptor
   - Logging interceptor (dev only)
6. Register Dio instance in dependency injection

**Business Rules**:
- Separate Dio instance per environment
- Environment-specific base URLs
- Environment-specific certificate pinning
- Interceptors configured per environment
- Network configuration happens during app initialization

---

## Business Process Flows

### Complete Authentication Flow

```
1. App Launch
   ↓
2. Check Stored Tokens
   ↓
3. If Tokens Exist:
   - Fetch User Profile
   - If Success → Navigate to Home
   - If 401 → Refresh Token → If Success → Navigate to Home, If Fail → Navigate to Login
   ↓
4. If No Tokens:
   - Navigate to Login
   ↓
5. User Taps "Sign in with Astro"
   ↓
6. Open OAuth Webview
   ↓
7. User Authenticates with Microsoft
   ↓
8. Intercept Authorization Code
   ↓
9. Exchange Code for Tokens
   ↓
10. Store Tokens (Encrypted)
    ↓
11. Fetch User Profile
    ↓
12. Navigate to Home
```

### Complete Home Page Load Flow

```
1. Navigate to Home
   ↓
2. Show Loading Indicator
   ↓
3. Load All Data in Parallel:
   - Landing Categories
   - User Profile
   - Module Notifications
   - App Version
   - Maintenance Status
   - User Check
   ↓
4. Update UI with Received Data
   ↓
5. Hide Loading Indicator
   ↓
6. Handle Individual Failures (if any)
```

### Complete Error Recovery Flow

```
1. API Call Made
   ↓
2. Error Occurs
   ↓
3. Classify Error:
   - Network Error → Retry with Exponential Backoff (max 3)
   - Authentication Error → Refresh Token → Retry Request
   - Server Error → Show Error, Allow Manual Retry
   - Validation Error → Show Validation Message
   - Unknown Error → Show Generic Error, Allow Manual Retry
   ↓
4. If Retry Succeeds → Continue Normal Flow
   ↓
5. If Retry Fails → Show Error Message to User
```

---

## Notes

- **State Management**: All business logic state managed by BLoCs/Cubits
- **Error Handling**: Comprehensive error handling with automatic recovery where possible
- **Token Management**: Secure token storage with automatic refresh
- **Performance**: Parallel data loading for optimal user experience
- **Security**: Encrypted storage, certificate pinning, secure token handling

