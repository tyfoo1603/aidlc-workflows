# Domain Entities - Unit 1: Easy App Complete Application

## Overview

This document defines domain entities, data structures, and relationships for the Core Infrastructure of the Easy App Flutter mobile application.

---

## Core Infrastructure Entities

### Token Entity

**Purpose**: Represents authentication tokens (access token and refresh token)

**Structure**:
```dart
class Token {
  final String accessToken;      // OAuth access token
  final String refreshToken;     // OAuth refresh token
  final DateTime expiresAt;      // Access token expiration time
  final DateTime issuedAt;       // Token issuance time
  final String userId;           // User ID associated with tokens
}
```

**Fields**:
- `accessToken` (String, required): OAuth access token for API authentication
- `refreshToken` (String, required): OAuth refresh token for token renewal
- `expiresAt` (DateTime, required): Access token expiration timestamp
- `issuedAt` (DateTime, required): Token issuance timestamp
- `userId` (String, required): User ID associated with tokens

**Business Rules**:
- Tokens are stored encrypted in Hive
- expiresAt is calculated from expires_in (seconds) from API response
- issuedAt is set to current time when tokens are received
- userId is extracted from token or user profile after authentication

**API Mapping**:
- API Response: `TokenResponseModel` with `access_token`, `refresh_token`, `expires_in`
- Entity Mapping: `access_token` → `accessToken`, `refresh_token` → `refreshToken`, `expires_in` → `expiresAt` (calculated)

---

### LandingCategory Entity

**Purpose**: Represents app modules/categories displayed on home page

**Structure**:
```dart
class LandingCategory {
  final String id;               // Category/module ID
  final String name;             // Category name (mapped from title)
  final String icon;             // Icon URL or asset path
  final String url;              // Module URL (for webview modules)
  final String type;             // Module type: "internal" or "web"
}
```

**Fields**:
- `id` (String, required): Unique identifier for the category/module
- `name` (String, required): Display name for the category (mapped from API `title`)
- `icon` (String, required): Icon URL or asset path for the category
- `url` (String, required): URL for webview modules, route for internal modules
- `type` (String, required): Module type - "internal" for app routes, "web" for webview

**Business Rules**:
- Categories are filtered by server (only accessible modules are returned)
- Categories are displayed in order specified by server
- Internal type modules navigate to app routes
- Web type modules open in-app webview

**API Mapping**:
- API Response: `LandingCategoryResponseModel` with `id`, `title`, `icon`, `type`, `url`, `order`, `isActive`, `permission flags`
- Entity Mapping: `title` → `name`, other fields mapped directly

---

### UserSummary Entity

**Purpose**: Represents user summary information displayed on home page

**Structure**:
```dart
class UserSummary {
  final String name;             // User's display name
  final String? avatar;          // Avatar URL (nullable)
  final double? walletBalance;   // Wallet balance (nullable, from QR Wallet)
  final String email;            // User's email
  final String userId;          // User ID
}
```

**Fields**:
- `name` (String, required): User's display name
- `avatar` (String?, optional): URL to user's profile picture
- `walletBalance` (double?, optional): User's wallet balance (from QR Wallet feature)
- `email` (String, required): User's email address
- `userId` (String, required): User's unique identifier

**Business Rules**:
- UserSummary is composed from Profile data (name, avatar, email, userId)
- Wallet balance is fetched from QR Wallet feature
- Avatar is nullable (user may not have profile picture)
- Wallet balance is nullable (may not be available)

**Data Sources**:
- Profile data from `getUserProfile` API
- Wallet balance from QR Wallet feature (if available)

---

### AppVersion Entity

**Purpose**: Represents app version information for update checking

**Structure**:
```dart
class AppVersion {
  final String currentVersion;   // Current app version
  final String latestVersion;    // Latest available version
  final bool isCriticalUpdate;   // Whether update is critical (force update)
  final bool isUpdateAvailable; // Whether update is available
  final String? updateMessage;  // Update message (optional)
}
```

**Fields**:
- `currentVersion` (String, required): Current app version installed
- `latestVersion` (String, required): Latest version available on server
- `isCriticalUpdate` (bool, required): Whether update is critical (forces update)
- `isUpdateAvailable` (bool, required): Whether update is available
- `updateMessage` (String?, optional): Message about the update

**Business Rules**:
- Version comparison determines if update is available
- Critical updates force app update (blocking)
- Non-critical updates are optional
- Update message provides information about the update

---

### MaintenanceStatus Entity

**Purpose**: Represents maintenance mode status

**Structure**:
```dart
class MaintenanceStatus {
  final bool isMaintenanceActive; // Whether maintenance mode is active
  final String? message;          // Maintenance message (optional)
  final DateTime? startTime;       // Maintenance start time (optional)
  final DateTime? endTime;        // Maintenance end time (optional)
}
```

**Fields**:
- `isMaintenanceActive` (bool, required): Whether maintenance mode is currently active
- `message` (String?, optional): Maintenance message to display
- `startTime` (DateTime?, optional): When maintenance started
- `endTime` (DateTime?, optional): When maintenance is expected to end

**Business Rules**:
- Maintenance mode affects API availability
- Maintenance banner is displayed when active
- Maintenance message is shown to users
- App functionality continues but API calls may fail

---

### Error Entity

**Purpose**: Represents application errors with classification

**Structure**:
```dart
class AppError {
  final ErrorType type;          // Error classification
  final String message;          // User-friendly error message
  final String? technicalMessage; // Technical error details (for logging)
  final int? statusCode;         // HTTP status code (if applicable)
  final bool isRetryable;        // Whether error is retryable
}
```

**Error Types**:
```dart
enum ErrorType {
  network,        // Network errors (no internet, timeout)
  authentication, // Authentication errors (401, token expired)
  server,         // Server errors (500, 503)
  validation,    // Validation errors (400, invalid input)
  unknown        // Unknown/unexpected errors
}
```

**Fields**:
- `type` (ErrorType, required): Error classification
- `message` (String, required): User-friendly error message
- `technicalMessage` (String?, optional): Technical details for logging
- `statusCode` (int?, optional): HTTP status code if applicable
- `isRetryable` (bool, required): Whether error can be retried

**Business Rules**:
- Errors are classified into one of the error types
- User-friendly messages are shown to users
- Technical details are logged for debugging
- Retryable errors trigger automatic retry

---

## Entity Relationships

### Token → UserSummary
- **Relationship**: One-to-One
- **Description**: Token contains userId, which links to UserSummary
- **Usage**: Token authentication enables fetching UserSummary

### UserSummary → LandingCategory
- **Relationship**: One-to-Many (indirect)
- **Description**: UserSummary determines which LandingCategories are accessible
- **Usage**: User permissions determine which modules are displayed

### AppVersion → App Behavior
- **Relationship**: One-to-One
- **Description**: AppVersion determines app update behavior
- **Usage**: Critical updates force app update, optional updates show notification

### MaintenanceStatus → App Behavior
- **Relationship**: One-to-One
- **Description**: MaintenanceStatus affects app functionality
- **Usage**: Maintenance mode shows banner and may affect API calls

---

## Data Flow

### Authentication Flow
```
Token (from API) → Stored in Encrypted Hive → Used for API Authentication
```

### Home Page Data Flow
```
LandingCategory[] (from API) → Displayed on Home
UserSummary (from Profile API) → Displayed on Home
AppVersion (from API) → Checked for Updates
MaintenanceStatus (from API) → Displayed as Banner
```

### Error Flow
```
API Error → Classified as AppError → Handled Based on Type → User Sees Message
```

---

## Entity Validation

### Token Validation
- accessToken must not be empty
- refreshToken must not be empty
- expiresAt must be in the future when token is issued
- userId must not be empty

### LandingCategory Validation
- id must not be empty
- name must not be empty
- type must be "internal" or "web"
- url must not be empty

### UserSummary Validation
- name must not be empty
- email must be valid email format
- userId must not be empty
- walletBalance must be non-negative if provided

### AppVersion Validation
- currentVersion must not be empty
- latestVersion must not be empty
- Version format must be valid (semantic versioning)

### MaintenanceStatus Validation
- isMaintenanceActive must be boolean
- If maintenance is active, message should be provided

---

## Entity Serialization

### JSON Serialization
All entities support JSON serialization/deserialization for:
- API request/response mapping
- Local storage (caching)
- State persistence

### Hive Serialization
Entities stored in Hive (Token, cached data) support Hive serialization:
- Type adapters for Hive boxes
- Encrypted storage for sensitive entities (Token)

---

## Notes

- **Entity Immutability**: Entities are immutable (final fields, no setters)
- **Null Safety**: Entities use nullable types where appropriate
- **API Mapping**: Entities map from API response models
- **Validation**: Entity validation occurs at repository layer
- **Caching**: Some entities (UserSummary, LandingCategory) are cached locally

