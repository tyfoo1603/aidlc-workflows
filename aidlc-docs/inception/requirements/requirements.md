# Easy App - Flutter Mobile Application Requirements

## Intent Analysis Summary

### User Request
Build a mobile Flutter application for Easy App based on requirements in `docs/V1EasyApp_HighLevelFeatures.md` and API contract in `docs/V2EasyApp_APIContract.md`. The backend is out of scope and already available.

### Request Type
**New Project** - Greenfield Flutter mobile application development

### Scope Estimate
**System-wide** - Complete mobile application with 13+ features/modules

### Complexity Estimate
**Complex** - Multi-feature enterprise mobile application with authentication, payments, claims management, and various integrations

---

## Functional Requirements

### FR1: Authentication & Authorization

#### FR1.1: Microsoft OAuth Login
- **Description**: Users must authenticate using Microsoft OAuth flow via in-app webview
- **User Story**: As an Astro employee, I want to log in to Easy App using my Astro email credentials so that I can securely access my personalized home page and available apps
- **Steps**:
  1. User starts with sign-in page with "Sign in with Astro" button
  2. User enters Astro email account and clicks Next
  3. User enters password and clicks Sign in
  4. After successful authentication, user lands on home page showing profile details and available apps
- **Technical Details**:
  - In-app webview for Microsoft OAuth authorization
  - Intercept redirect with `code` parameter
  - POST to Microsoft token endpoint to exchange code for tokens
  - Store access_token and refresh_token securely using Hive with encryption
  - Implement automatic token refresh on 401 responses
  - Force re-login if refresh fails
- **API Endpoints**:
  - Microsoft OAuth authorize: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize`
  - Microsoft OAuth token: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token`
  - Token refresh: Same token endpoint with `grant_type=refresh_token`

#### FR1.2: Logout
- **Description**: Users can log out from the home page
- **Technical Details**:
  - Clear local session data (tokens, user data)
  - Optionally revoke server sessions via Azure Graph API
  - Route to login screen
- **API Endpoints**:
  - Revoke Sign-In Sessions: `POST https://graph.microsoft.com/v1.0/me/revokeSignInSessions`
  - Invalidate Refresh Tokens: `POST https://graph.microsoft.com/v1.0/me/invalidateAllRefreshTokens`

#### FR1.3: Forgot/Unlock Password
- **Description**: Users can reset or unlock their account password
- **User Story**: As an Astro employee, I want to reset or unlock my account password so that I can regain access to Easy App when I am locked out
- **Steps**:
  1. User clicks on Forgot/Unlock Password icon from home page
  2. App redirects to Microsoft password reset page in external browser
  3. User completes reset in browser
  4. User returns to app and logs in again
- **Technical Details**: External browser redirect to Microsoft SSPR page

### FR2: Home/Landing Page

#### FR2.1: Main Menu Display
- **Description**: Landing screen displays user summary, app modules, and quick actions
- **User Story**: As an employee using the Easy app, I want a clear main menu (landing/home) that presents the app's modules and quick actions so I can access features quickly
- **Success Criteria**:
  - Display user summary (name, avatar, wallet balance)
  - Display grid/list of app modules
  - Modules reflect server-provided landing categories
  - Respect permission flags (hidden/shown based on server response)
  - Tapping a module navigates to correct feature route or opens in-app webview
- **API Endpoints**:
  - Get Landing Categories: `POST {{baseUrl}}/landing/newcategory` (body: userID)
  - Get Profile: `POST {{baseUrl}}/landing/newuserprofile` (body: userID)
  - Get Notifications: `POST {{baseUrl}}/landing/newmodulesnotification` (body: userID, moduleID)
  - Register Push Token: `POST {{baseUrl}}/landing/newgrab token` (body: userID, firebaseToken, hms, appVersion)

#### FR2.2: App Version Check
- **Description**: Check app version and maintenance status on app launch
- **API Endpoints**:
  - Get Version: `POST {{baseUrl}}/landing/version` (body: appType)
  - Get Maintenance: `GET {{baseUrl}}/landing/newmaintenance`
  - User Check: `POST {{baseUrl}}/landing/newusercheck` (body: userID)

### FR3: Profile Management

#### FR3.1: View Profile
- **Description**: Display user profile information
- **User Story**: As an Astro employee, I want to access and update my profile so that I can keep my personal information accurate and up to date
- **API Endpoint**: `POST {{baseUrl}}/landing/newuserprofile` (body: userID)

#### FR3.2: Update Profile
- **Description**: Users can edit personal details (preferred language, contact number, office phone extension)
- **Steps**:
  1. User clicks Profile icon from home page
  2. User clicks edit icon to update details
  3. User saves changes
- **API Endpoint**: `POST {{baseUrl}}/landing/updateprofile` (body: JSON with profile fields)

#### FR3.3: Profile Picture Management
- **Description**: Users can upload or delete profile picture
- **Steps**:
  1. User clicks photo icon
  2. User selects upload new picture or delete current one
  3. Image is compressed before upload
- **API Endpoints**:
  - Upload Photo: `POST {{baseUrl}}/landing/newupdateprofilephoto` (multipart form-data: image file, userID)
  - Delete Photo: `POST {{baseUrl}}/landing/newdestroy` (body: userID)

#### FR3.4: View Home Care Information
- **Description**: Display user's home care details
- **Steps**: User clicks Home Care section to view details

#### FR3.5: View Updates
- **Description**: Display recent changes or notifications related to profile
- **Steps**: User clicks Updates section

### FR4: Announcements

#### FR4.1: View Announcements List
- **Description**: Display list of announcements in chronological order
- **User Story**: As an Astro employee, I want to view announcements in Easy App so that I can stay updated with important company information
- **Steps**:
  1. User taps bell icon at top right or scrolls to announcement section
  2. User sees list of announcements
- **API Endpoints**:
  - Get Announcements (paginated): `GET {{baseUrl}}/announcement/retrievepage?page={{page}}`
  - Search Announcements: `POST {{baseUrl}}/announcement/searchpage` (body: search_text, query: page)

#### FR4.2: View Announcement Details
- **Description**: Display full details of selected announcement
- **Steps**: User taps on an announcement
- **API Endpoint**: `POST {{baseUrl}}/announcement/search` (body: anc_id)

#### FR4.3: Search Announcements
- **Description**: Search for specific announcements using keywords
- **Steps**: User enters search keywords

#### FR4.4: Filter Announcements
- **Description**: Filter announcements by category or date
- **Steps**: User applies filters

### FR5: QR Wallet

#### FR5.1: Scan QR Code
- **Description**: Scan QR code for payment
- **User Story**: As an Astro employee, I want to use the QR Wallet feature so that I can make payments, scan QR codes, and track my transactions easily
- **Steps**:
  1. User clicks QR Wallet icon from home page
  2. User clicks Scan QR button
  3. App scans QR code and parses id and price
  4. User confirms payment
- **API Endpoint**: `POST {{baseUrl}}/mcafe/qrcompanypaynew` (body: id, userID, comments, price, counter)

#### FR5.2: Show QR Code
- **Description**: Display user's QR code for others to scan
- **Steps**: User clicks Show QR button

#### FR5.3: View Payment History
- **Description**: Display all past transactions
- **Steps**: User clicks Payment History

#### FR5.4: View Transaction Details
- **Description**: Display detailed information for a specific transaction
- **Steps**: User clicks on a specific transaction

### FR6: Eclaims

#### FR6.1: View Eclaims Guide
- **Description**: Display Eclaims user guide in web viewer
- **User Story**: As an Astro employee, I want to access and manage my claims so that I can submit new entries and view claim-related information easily
- **Steps**: User clicks top right sidebar to view guide

#### FR6.2: Access Eclaims Options
- **Description**: Display three claim options
- **Steps**: User clicks plus sign to reveal: Out of Office, Health Screening Claim, New Entry

#### FR6.3: Submit Out of Office Claim
- **Description**: Submit out of office claim
- **Steps**: User selects Out of Office and fills in details

#### FR6.4: Submit Health Screening Claim
- **Description**: Submit health screening claim
- **Steps**: User selects Health Screening Claim and enters details

#### FR6.5: Submit New Entry
- **Description**: Create a new claim entry
- **Steps**: User selects New Entry and creates claim
- **API Endpoints**:
  - Get Claim User: `POST {{baseUrl}}/claim/user` (body: emp_id)
  - Get My Claims: `POST {{baseUrl}}/claim/myclaims` (body: emp_id)
  - Get Claim Details: `POST {{baseUrl}}/claim/claimdetails` (body: eclaim_id)
  - Create Claim: `POST {{baseUrl}}/claim/newclaim` (multipart form-data: fields + files)
  - Edit Claim: `POST {{baseUrl}}/claim/editclaim` (multipart form-data: fields + files)
  - Cancel Claim: `POST {{baseUrl}}/claim/cancelclaim` (body: eclaim_id)

### FR7: AstroDesk

#### FR7.1: View Existing Tickets
- **Description**: Display previous tickets created by user
- **User Story**: As an Astro employee, I want to access AstroDesk so that I can view existing tickets and create new support requests easily
- **Steps**: User clicks AstroDesk icon from home page

#### FR7.2: Filter Tickets
- **Description**: Filter tickets by type
- **Steps**: User clicks top right filter icon

#### FR7.3: Create New Ticket
- **Description**: Create a new support ticket
- **Steps**: User clicks plus sign and fills in details
- **API Endpoint**: `POST {{baseUrl}}/mcafe/newasap` (multipart: fields + image)

#### FR7.4: View Ticket Details
- **Description**: Display ticket details and status updates
- **Steps**: User clicks on any ticket

#### FR7.5: View Town Hall
- **Description**: Display town hall content
- **API Endpoint**: `GET {{baseUrl}}/mcafe/townhall`

### FR8: Report Piracy

#### FR8.1: Choose Report Type
- **Description**: Select type of piracy report
- **User Story**: As an Astro employee, I want to report piracy so that I can help protect Astro's content and prevent unauthorized distribution
- **Steps**: User sees two options: Report from commercial outlet or Report a website

#### FR8.2: Report Commercial Outlet
- **Description**: Submit report about commercial outlet
- **Steps**: User enters outlet details and can view previous reports under History

#### FR8.3: Report Website
- **Description**: Submit report about pirating website
- **Steps**: User enters URL and details
- **API Endpoint**: `POST {{baseUrl}}/reportpiracy/submit` (body: userID, details, attachments - multipart if file)

### FR9: Settings

#### FR9.1: View App Version
- **Description**: Display current app version
- **User Story**: As an Astro employee, I want to access the Settings page so that I can check my app version and update Easy App without using the app store
- **Steps**: User clicks Settings icon from home page

#### FR9.2: Update Easy App
- **Description**: Upgrade app to latest version
- **Steps**: User clicks Update button
- **Technical Details**: Optional force update with notification and custom update mechanism

#### FR9.3: Notification Preferences
- **Description**: Manage notification preferences
- **API Endpoints**:
  - Get Notifications: `POST {{baseUrl}}/landing/newmodulesnotification` (body: userID, moduleID)
  - Update Notifications: `POST {{baseUrl}}/mcafe/updatenotifications` (body: user_id, id OR user_id, mark_all)

### FR10: AstroNet

#### FR10.1: Login to AstroNet
- **Description**: Authenticate with AstroNet credentials
- **User Story**: As an Astro employee, I want to log in to AstroNet so that I can view the latest company news and updates
- **Steps**:
  1. User clicks AstroNet icon from home page
  2. User enters credentials (username and password)
  3. After successful login, app redirects to in-app browser displaying AstroNet's latest news tab

### FR11: Steps Challenge

#### FR11.1: View Step Data
- **Description**: Display user's step data and rankings
- **User Story**: As an Astro employee, I want to participate in the Steps Challenge so that I can monitor my daily steps and compare my progress with others
- **Steps**:
  1. User clicks Steps Challenge icon from home page
  2. App retrieves step data from Google Fit (Android) / Apple Health (iOS)
  3. App displays rankings and values for all users
  4. User can see graph showing step count over time
  5. User can scroll or click dots to view previous days' data
- **API Endpoints**:
  - Update Steps: `POST {{baseUrl}}/steps/update` (body: user_id, steps, date)
  - Retrieve Steps: `POST {{baseUrl}}/steps/retrievesteps` (body: user_id)
- **Technical Details**: Integrate with Google Fit (Android) and Apple Health (iOS) to automatically fetch step data

### FR12: Content Highlights

#### FR12.1: View Content Highlights
- **Description**: Display content highlights in web viewer
- **User Story**: As an Astro employee, I want to view content highlights so that I can stay informed about the latest shows and releases
- **Steps**: User clicks Content Highlights icon, app redirects to web viewer displaying content from astro.com.my
- **API Endpoints**:
  - Get Product Categories: `GET {{baseUrl}}/product/category`
  - Get Product Detail: `POST {{baseUrl}}/product/retrieve` (body: id)
  - Get Product Highlight Details: `POST {{baseUrl}}/product/search` (body: id)

### FR13: Astro Friends and Family

#### FR13.1: View Friends and Family
- **Description**: Display Friends and Family referral program
- **User Story**: As an Astro employee, I want to view and access the Astro Friends and Family referral program so that I can share benefits with my friends and family
- **Steps**: User clicks icon, app redirects to web viewer displaying campaign details
- **API Endpoint**: `POST {{baseUrl}}/fnf` (body: userID)

### FR14: Sooka Share with Friends

#### FR14.1: View Sooka Share Campaign
- **Description**: Display Sooka Share with Friends campaign
- **User Story**: As an Astro employee, I want to view and access the Sooka Share with Friends campaign so that I can share exclusive offers with my friends and family
- **Steps**: User clicks icon, app redirects to in-app browser displaying campaign details
- **API Endpoints**:
  - Get Refer Category: `GET {{baseUrl}}/mcafe/refercategory`
  - Get Refer Content: `POST {{baseUrl}}/mcafe/refercontent`
  - Submit Refer Lead: `POST {{baseUrl}}/mcafe/submitlead` (body: JSON payload)

### FR15: Web View Features

#### FR15.1: In-App Web Viewer
- **Description**: Display web content within app for various features
- **Use Cases**:
  - Astro Friends and Family
  - Sooka Share with Friends
  - Content Highlights
  - Eclaims Guide
  - AstroNet
  - Change Password (Microsoft page)
- **Technical Details**: Implement webview widget with proper navigation handling

---

## Non-Functional Requirements

### NFR1: Platform Support
- **Requirement**: Application must support Android, iOS, and Web platforms
- **Details**:
  - Android: Minimum API 28 (Android 9.0)
  - iOS: Minimum iOS 15.0
  - Web: Modern browsers (Chrome, Safari, Firefox, Edge)

### NFR2: Flutter SDK Version
- **Requirement**: Use Flutter SDK version 3.38.2
- **Details**: Ensure compatibility with all required packages and plugins

### NFR3: UI/Design System
- **Requirement**: Use Material Design 3 as the primary design system
- **Details**: 
  - Consistent Material Design 3 components across all platforms
  - Responsive layouts for different screen sizes
  - Support for light and dark themes

### NFR4: Offline Capabilities
- **Requirement**: Hybrid offline support - offline for viewing cached data, online for actions
- **Details**:
  - Cache user profile, announcements, and other viewable content locally
  - Allow viewing cached data when offline
  - Require online connection for actions (payments, submissions, updates)
  - Implement data synchronization when connection is restored

### NFR5: Push Notifications
- **Requirement**: Support both Firebase Cloud Messaging (FCM) and Huawei Mobile Services (HMS)
- **Details**:
  - Register device tokens with backend on login/token refresh
  - Handle notifications from both services
  - Route notifications to appropriate app sections
  - Support notification preferences per module

### NFR6: State Management
- **Requirement**: Use Bloc/Cubit pattern for state management
- **Details**:
  - Implement BLoC architecture with Cubit for simpler state management
  - Separate business logic from UI
  - Implement proper state handling for all features

### NFR7: Security
- **Requirement**: Implement certificate pinning for API calls
- **Details**:
  - Pin SSL certificates for API endpoints
  - Secure token storage using Hive with encryption
  - Implement secure token refresh mechanism
  - Protect sensitive data in transit and at rest

### NFR8: Performance
- **Requirement**: High performance - 60fps animations, instant navigation
- **Details**:
  - Optimize app startup time
  - Ensure smooth 60fps animations throughout
  - Implement efficient image loading and caching
  - Optimize API calls and reduce unnecessary network requests
  - Implement lazy loading for lists and images

### NFR9: Error Handling
- **Requirement**: Comprehensive error handling with analytics and crash reporting
- **Details**:
  - Implement user-friendly error messages
  - Show error message with option to retry or go back on API failures
  - Integrate analytics (Firebase Analytics or similar)
  - Integrate crash reporting (Firebase Crashlytics or Sentry)
  - Log errors appropriately for debugging

### NFR10: Environment Configuration
- **Requirement**: Support Development, Staging, and Production environments with build flavors
- **Details**:
  - Implement Flutter build flavors for each environment
  - Configure different API base URLs per environment:
    - Development: TBD
    - Staging: `https://mcafe.azurewebsites.net/api`
    - Production: `https://mcafebaru.azurewebsites.net/api`
  - Environment-specific configuration files

### NFR11: Maintenance Mode
- **Requirement**: Show maintenance banner but allow limited functionality when maintenance mode is detected
- **Details**:
  - Check maintenance status on app launch
  - Display maintenance banner if active
  - Allow viewing cached content
  - Block actions requiring backend connectivity

### NFR12: Version Management
- **Requirement**: Optional force update with notification and custom update mechanism
- **Details**:
  - Check app version on launch
  - Compare with server version
  - Show update notification if new version available
  - Implement force update mechanism when required
  - Support custom update flow (not just app store)

### NFR13: Testing
- **Requirement**: Comprehensive test coverage including unit, widget, integration, and e2e tests
- **Details**:
  - Unit tests for business logic and utilities
  - Widget tests for UI components
  - Integration tests for feature flows
  - End-to-end tests for critical user journeys
  - Target minimum 70% code coverage

### NFR14: Health Data Integration
- **Requirement**: Integrate with Google Fit (Android) and Apple Health (iOS) for Steps Challenge
- **Details**:
  - Request appropriate permissions
  - Fetch step data from platform health services
  - Sync step data with backend
  - Handle permission denials gracefully

### NFR15: Accessibility
- **Requirement**: No specific accessibility requirements beyond standard Flutter accessibility
- **Details**: Rely on Flutter's built-in accessibility features

---

## Technical Architecture Requirements

### TAR1: API Integration
- **Base URLs**:
  - Staging: `https://mcafe.azurewebsites.net/api`
  - Production: `https://mcafebaru.azurewebsites.net/api`
- **Authentication**: Microsoft OAuth 2.0 with token refresh
- **Request Format**: 
  - Most POST requests use `application/x-www-form-urlencoded`
  - File uploads use `multipart/form-data`
  - Some endpoints use JSON
- **Error Handling**: Certificate pinning, automatic retry with exponential backoff for transient failures

### TAR2: Data Storage
- **Token Storage**: Hive with encryption for secure token storage
- **Local Caching**: Implement local caching for offline viewing
- **User Preferences**: Store user preferences and settings locally

### TAR3: Dependency Management
- **State Management**: flutter_bloc package
- **HTTP Client**: dio package for API calls
- **Local Storage**: hive package with encryption
- **Push Notifications**: firebase_messaging and hms_push packages
- **Health Data**: health package for cross-platform health data access
- **Web View**: webview_flutter package
- **Image Handling**: cached_network_image for efficient image loading

### TAR4: Code Organization
- **Architecture**: Clean Architecture with BLoC pattern
- **Structure**: Feature-based folder structure
- **Separation**: Clear separation between UI, business logic, and data layers

---

## Integration Requirements

### IR1: Microsoft OAuth Integration
- Integrate Microsoft OAuth 2.0 flow
- Handle token exchange and refresh
- Implement secure token storage
- Handle session revocation

### IR2: Push Notification Services
- Integrate Firebase Cloud Messaging (FCM)
- Integrate Huawei Mobile Services (HMS) Push
- Register device tokens with backend
- Handle notification routing

### IR3: Health Data Services
- Integrate Google Fit API (Android)
- Integrate Apple HealthKit (iOS)
- Request and handle permissions
- Sync step data with backend

### IR4: Analytics and Crash Reporting
- Integrate analytics service (Firebase Analytics or similar)
- Integrate crash reporting (Firebase Crashlytics or Sentry)
- Track user events and errors
- Monitor app performance

---

## Constraints and Assumptions

### Constraints
1. Backend API is already available and out of scope
2. Must use Flutter SDK 3.38.2
3. Must support Android (API 28+), iOS (15+), and Web
4. Must implement certificate pinning for security
5. Must support both FCM and HMS push notifications

### Assumptions
1. Backend API endpoints are stable and documented
2. Microsoft OAuth tenant and client credentials are available
3. Firebase and HMS project configurations are available
4. App will be distributed through app stores (Google Play, App Store) and potentially web
5. Users have Astro corporate email accounts for authentication

---

## Success Criteria

1. All 13+ features are fully implemented and functional
2. App successfully authenticates users via Microsoft OAuth
3. All API endpoints are properly integrated
4. App works offline for viewing cached content
5. Push notifications work on both Android (FCM/HMS) and iOS (FCM)
6. Steps Challenge successfully integrates with Google Fit and Apple Health
7. App meets high performance requirements (60fps, instant navigation)
8. Comprehensive test coverage is achieved
9. App supports all three platforms (Android, iOS, Web)
10. Security requirements (certificate pinning, encrypted storage) are implemented

---

## Out of Scope

1. Backend API development (already available)
2. Server-side authentication logic (handled by Microsoft and backend)
3. Backend database design
4. Backend business logic implementation

