# Business Rules - Unit 1: Easy App Complete Application

## Overview

This document defines validation rules, constraints, and business policies for the Core Infrastructure of the Easy App Flutter mobile application.

---

## Authentication Business Rules

### Token Storage Rules

**BR-AUTH-001**: Token Encryption
- **Rule**: All authentication tokens must be stored using Hive's built-in encryption with a master key derived from the device
- **Constraint**: Tokens cannot be stored in plain text
- **Validation**: Encryption key must be securely derived and stored

**BR-AUTH-002**: Token Structure
- **Rule**: Token entity must contain: accessToken, refreshToken, expiresAt, issuedAt, userId
- **Constraint**: All fields are required
- **Validation**: Token structure must match API response structure

**BR-AUTH-003**: Token Expiration
- **Rule**: Access tokens expire based on expires_in value from API response
- **Constraint**: expiresAt is calculated as: current time + expires_in (in seconds)
- **Validation**: Token expiration must be checked before use

---

### Token Refresh Rules

**BR-AUTH-004**: Proactive Token Refresh
- **Rule**: Tokens must be refreshed proactively 5 minutes before expiration
- **Constraint**: Background refresh must not interrupt user experience
- **Validation**: Refresh must complete before token expires

**BR-AUTH-005**: Reactive Token Refresh
- **Rule**: On 401 response, token must be refreshed automatically
- **Constraint**: Only one refresh attempt per 401 response
- **Validation**: Refresh must succeed before retrying original request

**BR-AUTH-006**: Refresh Failure Handling
- **Rule**: If token refresh fails, user must be forced to re-login
- **Constraint**: All stored tokens must be cleared on refresh failure
- **Validation**: User must be navigated to login screen

**BR-AUTH-007**: Concurrent Refresh Prevention
- **Rule**: Only one token refresh can occur at a time
- **Constraint**: Interceptor must be locked during refresh
- **Validation**: Concurrent refresh attempts must be queued

---

### Authentication State Rules

**BR-AUTH-008**: Authentication Persistence
- **Rule**: Authentication state persists across app restarts via stored tokens
- **Constraint**: Tokens must be validated on app launch
- **Validation**: User profile must be fetched to verify authentication

**BR-AUTH-009**: Authentication Verification
- **Rule**: On app launch, stored tokens must be validated by fetching user profile
- **Constraint**: If profile fetch fails (401), token refresh must be attempted
- **Validation**: User is authenticated only if profile fetch succeeds

**BR-AUTH-010**: Authentication State Machine
- **Rule**: Authentication state must follow state machine: Initial → Authorizing → CodeReceived → Exchanging → Authenticated → Error
- **Constraint**: State transitions must be atomic
- **Validation**: Only valid state transitions are allowed

---

### Logout Rules

**BR-AUTH-011**: Logout Data Clearing
- **Rule**: Logout must clear: tokens + user profile + cached data + app preferences
- **Constraint**: All local session data must be cleared
- **Validation**: No authenticated data remains after logout

**BR-AUTH-012**: Server Session Revocation
- **Rule**: Logout must attempt to revoke server sessions via Azure Graph API
- **Constraint**: Server revocation is non-blocking (logout completes even if revocation fails)
- **Validation**: User is logged out locally regardless of server revocation success

**BR-AUTH-013**: Post-Logout Behavior
- **Rule**: After logout, user must be navigated to login screen
- **Constraint**: User cannot access authenticated features without re-authentication
- **Validation**: App does not auto-login after logout

---

## Home Page Business Rules

### Module Loading Rules

**BR-HOME-001**: Parallel Data Loading
- **Rule**: All home page data must be loaded in parallel (modules, profile, notifications, version, maintenance)
- **Constraint**: Individual API failures must not block other data loading
- **Validation**: All data sources are initiated simultaneously

**BR-HOME-002**: Module Permission Filtering
- **Rule**: Server returns only modules user has permission to access
- **Constraint**: Client displays all modules received from server (no client-side filtering)
- **Validation**: No unauthorized modules are displayed

**BR-HOME-003**: Module Display Order
- **Rule**: Modules must be displayed in the order specified by server (order field)
- **Constraint**: Order field from server response determines display order
- **Validation**: Modules are sorted by order field before display

---

### Push Token Registration Rules

**BR-HOME-004**: Push Token Registration Timing
- **Rule**: Push tokens must be registered on app launch (before home page), not on home page load
- **Constraint**: Registration must be non-blocking (doesn't delay app startup)
- **Validation**: Tokens are registered after authentication, before home page display

**BR-HOME-005**: Push Token Registration Check
- **Rule**: Push tokens must be registered only if not already registered
- **Constraint**: Check must be performed before registration
- **Validation**: Duplicate registrations are prevented

**BR-HOME-006**: Push Token Registration Retry
- **Rule**: Failed push token registrations must be retried with exponential backoff
- **Constraint**: Maximum 3 retry attempts
- **Validation**: Registration retries until success or max attempts reached

---

### Maintenance Mode Rules

**BR-HOME-007**: Maintenance Mode Display
- **Rule**: Maintenance banner must be displayed when maintenance mode is active
- **Constraint**: Banner must show maintenance message from server
- **Validation**: Banner is visible when maintenance status indicates active

**BR-HOME-008**: Maintenance Mode Functionality
- **Rule**: During maintenance mode, all functionality is allowed but warnings are shown
- **Constraint**: API calls may fail during maintenance (expected behavior)
- **Validation**: Users can still view cached content during maintenance

---

### App Version Update Rules

**BR-HOME-009**: Critical Version Update
- **Rule**: Critical app version updates must force app update (blocking)
- **Constraint**: Force update dialog cannot be dismissed
- **Validation**: App usage is blocked until update is completed

**BR-HOME-010**: Optional Version Update
- **Rule**: Minor app version updates are optional (user can defer)
- **Constraint**: Optional update notification can be dismissed
- **Validation**: User can continue using app without updating

**BR-HOME-011**: Version Check Frequency
- **Rule**: App version must be checked on app launch/home load
- **Constraint**: Version check must not delay app startup significantly
- **Validation**: Version check occurs in parallel with other home page data loading

---

## Navigation Business Rules

### Route Configuration Rules

**BR-NAV-001**: Route Definition
- **Rule**: All routes must be hardcoded in NavigationService
- **Constraint**: Routes must be type-safe (no string-based routing)
- **Validation**: All features have dedicated routes defined

**BR-NAV-002**: Route Parameters
- **Rule**: Route parameters must be handled by NavigationService
- **Constraint**: Parameters must be validated before navigation
- **Validation**: Invalid parameters prevent navigation

---

### Deep Linking Rules

**BR-NAV-003**: Deep Link Validation
- **Rule**: Deep links must be validated before navigation
- **Constraint**: User access to feature must be verified
- **Validation**: Unauthorized deep links are rejected

**BR-NAV-004**: Deep Link Processing
- **Rule**: Deep links must be handled by separate DeepLinkService
- **Constraint**: DeepLinkService converts deep links to NavigationService routes
- **Validation**: NavigationService receives validated route from DeepLinkService

**BR-NAV-005**: Deep Link Error Handling
- **Rule**: Invalid or unauthorized deep links must show appropriate error message
- **Constraint**: Error message must guide user to correct action
- **Validation**: Deep link errors do not crash the app

---

## Error Handling Business Rules

### Error Classification Rules

**BR-ERR-001**: Error Categories
- **Rule**: Errors must be classified as: Network errors, Authentication errors, Server errors, Validation errors, Unknown errors
- **Constraint**: Each error category has specific handling logic
- **Validation**: All errors are classified into one of these categories

**BR-ERR-002**: Network Error Classification
- **Rule**: Network errors include: No internet, timeout, connection refused
- **Constraint**: Network errors are retryable
- **Validation**: Network errors trigger automatic retry

**BR-ERR-003**: Authentication Error Classification
- **Rule**: Authentication errors include: 401 Unauthorized, token expired, invalid credentials
- **Constraint**: Authentication errors trigger token refresh
- **Validation**: Authentication errors are handled before user sees error

**BR-ERR-004**: Server Error Classification
- **Rule**: Server errors include: 500 Internal Server Error, 503 Service Unavailable, server maintenance
- **Constraint**: Server errors are not automatically retried
- **Validation**: Server errors show error message with manual retry option

**BR-ERR-005**: Validation Error Classification
- **Rule**: Validation errors include: 400 Bad Request, invalid input, missing required fields
- **Constraint**: Validation errors are not retried
- **Validation**: Validation errors show specific validation message

---

### Error Recovery Rules

**BR-ERR-006**: Network Error Retry
- **Rule**: Network errors must be retried automatically with exponential backoff
- **Constraint**: Maximum 3 retry attempts (1s, 2s, 4s delays)
- **Validation**: Retry stops after 3 attempts or success

**BR-ERR-007**: Error Message Display
- **Rule**: After retry failures, error message must be shown with manual retry option
- **Constraint**: Error messages must be user-friendly
- **Validation**: Users can manually retry failed operations

**BR-ERR-008**: Error Logging
- **Rule**: All errors must be logged with technical details for debugging
- **Constraint**: Technical error details are not shown to users
- **Validation**: Error logs contain sufficient information for debugging

---

## Core Infrastructure Initialization Rules

### Dependency Injection Rules

**BR-INIT-001**: Initialization Order
- **Rule**: Services must be initialized in order: Core services → Repositories → Use Cases → BLoCs
- **Constraint**: Dependencies must be registered before dependents
- **Validation**: Initialization order is enforced

**BR-INIT-002**: Service Registration
- **Rule**: All services must be registered via get_it service locator
- **Constraint**: Services must be registered before use
- **Validation**: Unregistered services cannot be accessed

**BR-INIT-003**: Initialization Failure
- **Rule**: Initialization failures must prevent app startup
- **Constraint**: App cannot start with incomplete initialization
- **Validation**: Initialization errors are fatal

---

### Storage Initialization Rules

**BR-INIT-004**: Storage Initialization Timing
- **Rule**: Hive storage must be initialized on app launch, before any feature access
- **Constraint**: Storage initialization is blocking (app waits for completion)
- **Validation**: No feature can access storage before initialization

**BR-INIT-005**: Storage Initialization Failure
- **Rule**: Storage initialization failures are fatal (app cannot start)
- **Constraint**: App must show error and prevent startup
- **Validation**: App does not start with uninitialized storage

**BR-INIT-006**: Encrypted Box Initialization
- **Rule**: Encrypted Hive boxes must be opened during initialization
- **Constraint**: Encryption keys must be available before box opening
- **Validation**: Encrypted boxes are ready before use

---

### Network Configuration Rules

**BR-INIT-007**: Environment-Specific Configuration
- **Rule**: Dio instance must be created per environment (dev/staging/prod) with environment-specific configuration
- **Constraint**: Base URL, certificate pinning, and interceptors are environment-specific
- **Validation**: Correct environment configuration is used

**BR-INIT-008**: Certificate Pinning
- **Rule**: Certificate pinning must be configured per environment
- **Constraint**: Pinning certificates are environment-specific
- **Validation**: Certificate pinning is active for production environment

**BR-INIT-009**: Interceptor Configuration
- **Rule**: Interceptors (token refresh, error handling, logging) must be configured per environment
- **Constraint**: Logging interceptor is active only in dev environment
- **Validation**: Interceptors are correctly configured for environment

---

## Validation Rules Summary

### Input Validation
- All API inputs must be validated before sending
- Required fields must be present
- Field formats must match API expectations
- File uploads must meet size and type constraints

### State Validation
- Authentication state must be valid before authenticated operations
- Token expiration must be checked before use
- Navigation state must be valid before navigation

### Data Validation
- API responses must be validated before use
- Entity structures must match expected format
- Cached data must be validated before use

---

## Constraint Summary

### Security Constraints
- Tokens must be encrypted at rest
- Certificate pinning must be enabled in production
- Sensitive data must not be logged
- API calls must include authentication tokens

### Performance Constraints
- API calls must complete within timeout limits
- Parallel data loading must not overwhelm server
- Retry attempts must use exponential backoff
- Cached data must be used when available

### User Experience Constraints
- Loading indicators must be shown for long operations
- Error messages must be user-friendly
- App must remain responsive during operations
- Offline functionality must be supported where possible

---

## Notes

- **Business Rules Enforcement**: Rules are enforced at the use case and repository layers
- **Validation Points**: Validation occurs at multiple layers (UI, domain, data)
- **Error Handling**: All business rule violations result in appropriate error handling
- **Rule Updates**: Business rules can be updated based on business requirements

