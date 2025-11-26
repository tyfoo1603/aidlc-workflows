









Easy App - Feature Documentation




















API Context Details

List of API URL that Easy App uses

- Base URLs:

- Staging base: `https://mcafe.azurewebsites.net/api`

- Production base: `https://mcafebaru.azurewebsites.net/api`

- Full URL = `<base> + <Config endpoint>`. I list both staging and production for each endpoint.

- Method (GET/POST) comes from api_provider.dart usage (I used `dio.get` / `dio.post` occurrences).

- Content-type notes: many POSTs send form data (`application/x-www-form-urlencoded`) unless the code uses `FormData` (multipart) or JSON explicitly.


1 Main Menu — User Story & Flow

User Story

•	As an employee using the Easy app, I want a clear main menu (landing/home) that presents the app's modules and quick actions so I can access features (Profile, Wallet, Announcements, Steps Challenge, Settings, Reports, etc.) quickly and return to them later.

Success Criteria

•	Landing screen displays user summary (name, avatar, wallet balance), a grid/list of app modules, and quick access tiles.

•	Tapping a module navigates to the correct feature route (or opens an in-app webview where required).

•	Modules reflect server-provided landing categories and respect permission flags (hidden/shown based on server response).

•	User's profile image and data load correctly from `userDB()` and update when profile is changed.

•	Logout and Settings links available in drawer or header.

Sequence (textual)

Landing VM calls `apiRepository.getLandingCategory()` → `ApiProvider.getLandingCategory()` POSTs to server → server returns categories → VM maps to tiles → tap behavior: internal route or push `Routes.appWebViewScreen` with `url`.

API Catalog & Postman Skeleton:

Request: Get Landing Categories

Method/URL: POST {{baseUrl}}{{landingCategory}}

Body: Body (form/x-www-form-urlencoded): userID = {{userID}}

App Response: LandingCategoryResponseModel — list of categories; fields typically include id, title, icon, type (internal|web), url, order, isActive, permission flags.


Request: Get Profile

Method/URL: POST {{baseUrl}}{{landingUserProfile}}

Body: body: userID

App Response: ProfileResponseModel (avatar, name, email)


Request: Get Notifications

Method/URL: POST {{baseUrl}}{{landingNotification}}

Body: body: userID, moduleID

App Response: LandingNotificationResponseModel


Request: Register Push Token

Method/URL: POST {{baseUrl}}{{landingGrabToken}}

Body: body: userID, firebaseToken, hms, appVersion

App Response: GrabTokenResponseModel


2 Login / Logout — User Story & Flow

User Story

•	As an employee I want to sign in via the Microsoft authorization flow and sign out to end my session, so my app access is secure and linked to my corporate identity.

Success Criteria

•	Login via in-app webview returns tokens and profile mapping to `userDB()`.

•	Access token gets attached to API requests automatically.

•	401 responses trigger refresh flow and retry; if refresh fails the app forces re-login.

•	Logout clears local session (and optionally revokes server sessions).

Sequence (textual)

In-app login webview → intercept redirect with `code` → POST to `Config.microsoftToken` → receive `TokenResponseModel` → write tokens to `userDB()` → call backend/profile mapping → Landing. On API 401: `ApiProvider` locks interceptors → `tokenRepository.refreshToken()` → update `userDB()` → retry original request → if refresh fails call `forceLogout()` → `userLogout()` → route to login.

API Catalog & Postman Skeleton (Merged):

Request: Exchange code for token

Method/URL: POST {{baseUrl}}{{microsoftToken}}

Body: form data with code, client_id, client_secret, grant_type, redirect_uri

App Response: TokenResponseModel — fields access_token, refresh_token, expires_in


Request: Refresh token

Method/URL: POST {{baseUrl}}{{microsoftToken}}

Body: grant_type=refresh_token, refresh_token, client credentials

App Response: TokenResponseModel — on success update userDB().userAccessToken and userRefreshToken


Request: Revoke Sign-In Sessions

Method/URL: POST me/revokeSignInSessions (Graph API)

Body: Bearer token

App Response: AzureRepository().revoke() — typically returns HTTP 204 No Content


Request: Invalidate All Refresh Tokens

Method/URL: POST me/invalidateAllRefreshTokens (Graph API)

Body: Bearer token

App Response: AzureRepository().invalidateRefreshToken() — typically returns HTTP 204 No Content

3 Forgot Password — User Story & Flow

User Story

•	As an employee who forgot my password, I want to trigger the Microsoft self-service password reset so I can regain access.

Success Criteria

•	A "Reset password" link opens the Microsoft SSPR page in external browser.

•	The app handles navigation back to login after the user completes SSPR externally.

•	No sensitive tokens are stored or leaked during the flow.

Sequence (textual)

User taps "Forgot Password" → `login_viewmodel.resetAcc()` → `launchUrlString(Config.microsoftPasswordReset)` → user completes reset in browser → return to app → user logs in again.

API Catalog & Postman Skeleton (Merged):

Request: External Microsoft flow

Method/URL: External SSPR URL

Body: Not applicable

App Response: User completes reset in browser; no app backend API involved.


4 Change Password — User Story & Flow

User Story

•	As an employee I want an in-app way to reach the corporate change-password page so I can update my password without hunting for web links.

Success Criteria

•	Tapping Change Password opens `Routes.appWebViewScreen` with `Config` URL.

•	The webview shows the Microsoft-managed change password UI.

•	App handles back navigation and session state properly after change.

Sequence (textual)

Landing tile maps to web URL → `Routes.appWebViewScreen` → webview loads URL → user changes password → upon completion user re-authenticates in-app if tokens invalidated.

API Catalog & Postman Skeleton (Merged):

Request: Open Change Password Webview

Method/URL: Webview-based (Microsoft change-password URL)

Body: Not applicable

App Response: Webview loads Microsoft change-password UI; no backend API.

5 Profile — User Story & Flow

User Story

•	As an employee I want to view and edit my profile (name, phone, avatar) so my account details are accurate in the app.

Success Criteria

•	Profile screen displays values from `ProfileResponseModel` and `userDB()`.

•	Update actions call backend endpoints and persist updates to `userDB()` on success.

•	Profile photo upload compresses and posts image; UI shows progress and updated avatar on success.

Sequence (textual)

Profile VM calls `apiRepository.getProfile()` → server returns `ProfileResponseModel` → UI binds fields → when user edits, call `apiRepository.updateProfile(body)` → on success write updated fields to `userDB()` → UI updates via reactive `userDB()` listener. Photo upload: compress image → `apiRepository.updateProfilePhoto(fileBytes, fileName)` → on success update `userDB().userImage`.

API Catalog & Postman Skeleton (Merged):

Request: Get Profile

Method/URL: POST {{baseUrl}}{{landingUserProfile}}

Body: body: userID

App Response: ProfileResponseModel

Request: Update Profile

Method/URL: POST {{baseUrl}}{{updateProfile}}

Body: body: JSON with profile fields

App Response: UpdateProfileResponseModel

Request: Upload Profile Photo

Method/URL: POST {{baseUrl}}{{landingUpdateProfilePhoto}}

Body: form-data: image file, userID

App Response: UploadProfilePhotoResponseModel

Request: Delete Profile Photo

Method/URL: POST {{baseUrl}}{{landingDeleteProfilePhoto}}

Body: body: userID

App Response: DeleteProfilePhotoResponseModel



6 QR Wallet — User Story & Flow

User Story

•	As an employee, I want to scan and pay using QR wallet features to make in-app purchases quickly.

Success Criteria

•	Scan-to-pay endpoint returns success and updates wallet/order state.

•	App passes `userID` and required payment details to backend.

Sequence (textual)

Scan QR → app parses `id` and `price` → call `apiRepository.scanToPay(id, price, counter)` → backend returns `QrCompanyPayResponseModel` → update UI/order history.

API Catalog & Postman Skeleton (Merged):

Request: Scan to Pay

Method/URL: POST {{baseUrl}}{{mCafeQrCompanyPayNew}}

Body: body: id, userID, comments, price, counter

App Response: QrCompanyPayResponseModel

7 Announcements — User Story & Flow

User Story

•	As an employee I want to see app announcements and search or paginate through them.

Success Criteria

•	Announcements list loads from server and supports pagination and search.

•	Tapping an announcement loads details (announcementSearch by id).

Sequence (textual)

Landing/announcements VM calls `apiRepository.getAnnouncementsByPage(page)` → backend returns paged list → UI shows list → search calls `announcementsSearchPage` → detail uses `announcementSearch(id)`.

API Catalog & Postman Skeleton (Merged):

Request: Get Announcements (page)

Method/URL: GET {{baseUrl}}{{mCafeAnnouncementRetrievePage}}?page={{page}}

Body: N/A

App Response: AnnouncementsRetrievePageResponseModel

Request: Announcement Search

Method/URL: POST {{baseUrl}}{{mCafeAnnouncementSearchPage}}

Body: body: search_text (with page query param)

App Response: AnnouncementsRetrievePageResponseModel (supports CancelToken)

Request: Announcement Detail

Method/URL: POST {{baseUrl}}{{announcementSearch}}

Body: body: anc_id

App Response: AnnouncementSearchResponseModel (single announcement detail)


8 Steps Challenge — User Story & Flow

User Story

•	As an employee I want to sync my daily steps and view step-history/challenges.

Success Criteria

•	App posts step counts and retrieves historical steps for the user.

•	Steps sync uses `userDB().userId` and date stamps.

Sequence (textual)

App collects steps (OS APIs) → call `apiRepository.updateSteps(steps, date)` → server persists → UI uses `apiRepository.retrieveSteps()` to show history.

API Catalog & Postman Skeleton (Merged):

Request: Update Steps

Method/URL: POST {{baseUrl}}{{stepsUpdate}}

Body: body: user_id, steps, date

App Response: StepsUpdateResponseModel

Request: Retrieve Steps

Method/URL: POST {{baseUrl}}{{stepsRetrieveSteps}}

Body: body: user_id

App Response: RetrieveStepsResponseModel


9 Report Piracy — User Story & Flow

User Story

•	As an employee I want to report piracy incidents (content misuse) so the content team can take action.

Success Criteria

•	Form submission posts the complaint to backend and receives a confirmation.

•	Optionally show user's report history.

Sequence (textual)

User fills report → `apiRepository.reportPiracySubmit(body)` → backend returns acknowledgment → optionally fetch report history.

API Catalog & Postman Skeleton (Merged):

Request: Submit piracy report

Method/URL: POST {{baseUrl}}{{reportPiracySubmit}}

Body: body: userID, details, attachments (multipart if file)

App Response: EagleEyesSubmitResponseModel or ReportHistoryResponseModel (success structure)

10 Settings — User Story & Flow

User Story

•	As an employee I want to manage app-level settings (notifications, privacy, preferences) so the app behaves as I expect.

Success Criteria

•	Settings screen shows persisted preferences from backend or local storage.

•	Toggling notification preferences calls `updateNotifications` or similar endpoints.

Sequence (textual)

Settings VM calls `apiRepository.getNotification(moduleID)` → display → toggles call `updateNotifications(markAll/id)`.

API Catalog & Postman Skeleton (Merged):

Request: Get Notifications

Method/URL: POST {{baseUrl}}{{landingNotification}}

Body: body: userID, moduleID

App Response: LandingNotificationResponseModel

Request: Update Notifications

Method/URL: POST {{baseUrl}}{{mCafeUpdateNotifications}}

Body: body: user_id, id OR user_id, mark_all

App Response: UpdateNotificationsResponseModel



11 Share With Friends (Refer Friend) — User Story & Flow

User Story

•	As an employee I want to refer friends and share app invites so that they can join or use features.

Success Criteria

•	Refer flow submits required info to backend and returns success.

•	UI shows share dialog or deep-link generation.

Sequence (textual)

User fills refer form → `apiRepository.referSubmitLead(model)` → backend returns response → show confirmation.

API Catalog & Postman Skeleton (Merged):

Request: Submit Refer Lead

Method/URL: POST {{baseUrl}}{{mCafeSubmitLead}}

Body: body: JSON payload of refer friend fields

App Response: ReferFriendSubmitLeadResponseModel


12 Highlight Content (Product Highlight) — User Story & Flow

User Story

•	As an employee I want to view highlighted content/product details curated by the company.

Success Criteria

•	Categories and highlighted content load from backend.

•	Detail pages open with content retrieved via API.

Sequence (textual)

Categories fetched → user selects category → `getProductHighlight(id)` → details via `getProductHighlightDetails(id)`.

API Catalog & Postman Skeleton (Merged):

Request: Get Product Categories

Method/URL: GET {{baseUrl}}{{productCategory}}

Body: N/A

App Response: ProductHighlightCategoryResponseModel

Request: Get Product Detail

Method/URL: POST {{baseUrl}}{{productRetrieve}}

Body: body: id

App Response: ProductHighlightRetrieveResponseModel

Request: Get Product Highlight Details

Method/URL: POST {{baseUrl}}{{productSearch}}

Body: body: id

App Response: ProductHighlightSearchResponseModel


13 Astro Friends & Family (F&F) — User Story & Flow

User Story

•	As an employee I want to manage friends & family listings (e.g., beneficiaries, family contacts) in the app.

Success Criteria

•	F&F list loads and supports add/edit/delete operations.

•	Backend endpoints for F&F are called and return appropriate models.

Sequence (textual)

User opens F&F → `apiRepository` fetches list → user manages entries → backend persists changes.

API Catalog & Postman Skeleton (Merged):

Request: Get F&F List

Method/URL: POST {{baseUrl}}{{fnfEndpoint}}

Body: body: userID

App Response: FnfResponseModel


14 E-Claims — User Story & Flow

User Story

•	As an employee I want to submit claims, check approval status, and view history so I can manage expenses and reimbursements.

Success Criteria

•	Claims module supports create/edit/submit, shows approval history and counts.

•	Endpoints for new claim, edit claim, my claims, pending approvals, etc., are implemented and returning correctly shaped models.

Sequence (textual)

User starts claim → fill forms (with file attachments) → call `apiRepository.newClaim(formData)` → backend returns created claim → view via `claimDetails(eclaim_id)` and status via `claimMyClaims()`.

API Catalog & Postman Skeleton (Merged):

Request: Get Claim User

Method/URL: POST {{baseUrl}}{{claimUser}}

Body: body: emp_id

App Response: ClaimUserResponseModel

Request: Get My Claims

Method/URL: POST {{baseUrl}}{{claimMyClaims}}

Body: body: emp_id

App Response: ClaimMyClaimsResponseModel

Request: Get Claim Details

Method/URL: POST {{baseUrl}}{{claimDetails}}

Body: body: eclaim_id

App Response: claim details (raw response)

Request: Cancel Claim

Method/URL: POST {{baseUrl}}{{claimCancelClaim}}

Body: body: eclaim_id

App Response: cancellation response

Request: Create/Edit Claim

Method/URL: POST {{baseUrl}}{{claimNew}} / {{baseUrl}}{{claimEdit}}

Body: form-data: fields + files

App Response: create/edit responses (ClaimNewEditClaimResponseModel)




15 AstroDesk (ASAP / Town Hall / Service Desk) — User Story & Flow

User Story

•	As an employee I want to submit ASAP/service desk tickets or view town-hall items so I can request help or see timely announcements.

Success Criteria

•	Ticket submission supports optional image attachment and returns confirmation.

•	Town Hall content loads via endpoint.

Sequence (textual)

Fill ticket form → call `apiRepository.asap(model, file)` → backend returns `AsapResponseModel` → UI shows confirmation.

API Catalog & Postman Skeleton (Merged):

Request: Submit ASAP ticket

Method/URL: POST {{baseUrl}}{{mCafeAsap}} (multipart)

Body: fields + image

App Response: AsapResponseModel

Request: Get Online Orders

Method/URL: POST {{baseUrl}}{{mCafeOrder}}

Body: body: userID

App Response: AsapResponseModel for orders

Request: Town Hall

Method/URL: GET {{baseUrl}}{{mCafeTownHall}}

Body: N/A

App Response: TownHallResponseModel


16 Notifications (Landing Notifications / Grab Token) — User Story & Flow

User Story

•	As an employee I want to receive notifications and ensure the app registers the device push token.

Success Criteria

•	Device push token is registered with backend.

•	Landing notifications per module can be retrieved and updated/read status set.

Sequence (textual)

On login or token refresh: call `apiRepository.grabToken(pushToken, hms, appVersion)` → backend associates token → notifications delivered via FCM/HMS → tapping notification routes to feature.

API Catalog & Postman Skeleton (Merged):

Request: Register Push Token

Method/URL: POST {{baseUrl}}{{landingGrabToken}}

Body: body: userID, firebaseToken, hms, appVersion

App Response: GrabTokenResponseModel

Request: Get Notifications

Method/URL: POST {{baseUrl}}{{landingNotification}}

Body: body: userID, moduleID

App Response: LandingNotificationResponseModel

Request: Update Notifications

Method/URL: POST {{baseUrl}}{{mCafeUpdateNotifications}}

Body: body: user_id, id OR user_id, mark_all

App Response: UpdateNotificationsResponseModel







Appendix A:

Below are 16 high-level features mapped to their API endpoints and full URLs.






**Authentication (Microsoft OAuth, token exchange)**

- **Endpoints**

- `Config.microsoftOnline + Config.authorize` (authorize URL)

- Example authorize URL (uses tenant/client IDs): `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/authorize?...`

- `Config.microsoftToken` (token endpoint path: `'/token'`)

- Staging: `https://mcafe.azurewebsites.net/api/token` —


NOTE: this `microsoftToken` is used relative to Microsoft base in code; the actual MS token URL is built from `microsoftOnline` for OAuth (`microsoftOnline` already points to `https://login.microsoftonline.com/<tenant>/oauth2/v2.0`). Use `microsoftOnline + '/token'` for the real Microsoft token endpoint:

- Microsoft OAuth token: `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token`

- **Method/Notes**: browser redirect to `authorize`, then token POST to Microsoft token endpoint (content-type: `application/x-www-form-urlencoded` per OAuth spec).
















**Landing / Home (landing category, version, maintenance, user check, grab token)**


`Config.landingCategory = '/landing/newcategory'`


STG: `https://mcafe.azurewebsites.net/api/landing/newcategory`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newcategory`


Used via: `dio.post(Config.landingCategory, data: body)` (POST, form key/value)


`Config.landingVersion = '/landing/version'`


STG: `https://mcafe.azurewebsites.net/api/landing/version`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/version`


Used via: `dio.post(Config.landingVersion, data: {'appType': ...})` (POST, body)


`Config.landingMaintenance = '/landing/newmaintenance'`


STG: `https://mcafe.azurewebsites.net/api/landing/newmaintenance`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newmaintenance`


Used via: `dio.get(Config.landingMaintenance)` (GET)


`Config.landingUserCheck = '/landing/newusercheck'`


STG: `https://mcafe.azurewebsites.net/api/landing/newusercheck`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newusercheck`


Used via: `dio.post(Config.landingUserCheck, data: body)` (POST)


`Config.landingGrabToken = '/landing/newgrab

token'`


STG: `https://mcafe.azurewebsites.net/api/landing/newgrab

token`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newgrab

token`


Used via: `dio.post(Config.landingGrabToken, data: body)` (POST)


**Profile (get, update, photo upload, delete)**


`Config.landingUserProfile = '/landing/newuser

profile'`


STG: `https://mcafe.azurewebsites.net/api/landing/newuser

profile`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newuser

profile`


Used via: `dio.post(Config.landingUserProfile, data: {'userID': ...})` (POST)


`Config.updateProfile = '/landing/updateprofile'`


STG: `https://mcafe.azurewebsites.net/api/landing/updateprofile`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/updateprofile`


Used via: `dio.post(Config.updateProfile, data: body)` (POST)


`Config.landingUpdateProfilePhoto = '/landing/newupdate

profile

photo'`


STG: `https://mcafe.azurewebsites.net/api/landing/newupdate

profile

photo`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newupdate

profile

photo`


Used via: `dio.post(Config.landingUpdateProfilePhoto, data: FormData)` (multipart/FormData for file upload)


`Config.landingDeleteProfilePhoto = '/landing/newdestroy'`


STG: `https://mcafe.azurewebsites.net/api/landing/newdestroy`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newdestroy`


Used via: `dio.post(Config.landingDeleteProfilePhoto, data: body)` (POST)





**Announcements**


`Config.mCafeRetrieve = '/announcement/newretrieve'`


STG: `https://mcafe.azurewebsites.net/api/announcement/newretrieve`


PROD: `https://mcafebaru.azurewebsites.net/api/announcement/newretrieve`


Used via: `dio.get(Config.mCafeRetrieve)` (GET)


`Config.mCafeAnnouncementRetrievePage = '/announcement/retrievepage'`


STG: `https://mcafe.azurewebsites.net/api/announcement/retrievepage`


PROD: `https://mcafebaru.azurewebsites.net/api/announcement/retrievepage`


Used via: `dio.get(Config.mCafeAnnouncementRetrievePage, queryParameters: {'page': page})` (GET with query)


`Config.mCafeAnnouncementSearchPage = '/announcement/searchpage'`


STG: `https://mcafe.azurewebsites.net/api/announcement/searchpage`


PROD: `https://mcafebaru.azurewebsites.net/api/announcement/searchpage`


Used via: `dio.post(Config.mCafeAnnouncementSearchPage, data: {'search_text': keyword}, queryParameters: {'page': page})` (POST)


`Config.announcementSearch = '/announcement/search'`


STG: `https://mcafe.azurewebsites.net/api/announcement/search`


PROD: `https://mcafebaru.azurewebsites.net/api/announcement/search`


Used via: `dio.post(Config.announcementSearch, data: {'anc_id': id})` (POST)












**Notifications**


`Config.landingNotification = '/landing/newmodules

notification'`


STG: `https://mcafe.azurewebsites.net/api/landing/newmodules

notification`


PROD: `https://mcafebaru.azurewebsites.net/api/landing/newmodules

notification`


Used via: `dio.post(Config.landingNotification, data: body)` (POST)


`Config.mCafeGetNotifications = '/mcafe/getnotifications'`


STG: `https://mcafe.azurewebsites.net/api/mcafe/getnotifications`


PROD: `https://mcafebaru.azurewebsites.net/api/mcafe/getnotifications`


Used via: `dio.post(Config.mCafeGetNotifications, data: {'user_id': ...})` (POST)


`Config.mCafeUpdateNotifications = '/mcafe/updatenotifications'`


STG: `https://mcafe.azurewebsites.net/api/mcafe/updatenotifications`


PROD: `https://mcafebaru.azurewebsites.net/api/mcafe/updatenotifications`


Used via: `dio.post(Config.mCafeUpdateNotifications, data: body)` (POST)


















**Product Highlight**


`Config.productCategory = '/product/category'` (GET)


STG: `https://mcafe.azurewebsites.net/api/product/category`


PROD: `https://mcafebaru.azurewebsites.net/api/product/category`


Used via: `dio.get(Config.productCategory)` (GET)


`Config.productRetrieve = '/product/retrieve'` (POST)


STG: `https://mcafe.azurewebsites.net/api/product/retrieve`


Used via: `dio.post(Config.productRetrieve, data: {'id': id})`


`Config.productSearch = '/product/search'` (POST)


**Steps Counter**


`Config.stepsUpdate = '/steps/update'`


STG: `https://mcafe.azurewebsites.net/api/steps/update`


Used via: `dio.post(Config.stepsUpdate, data: {'user_id':..., 'steps':..., 'date':...})`


`Config.stepsRetrieveSteps = '/steps/retrievesteps'`


STG: `https://mcafe.azurewebsites.net/api/steps/retrievesteps`


Used via: `dio.post(Config.stepsRetrieveSteps, data: {'user_id':...})`















**Claims (many endpoints)**


Example core claim endpoints used by api_provider.dart:


`Config.claimUser = '/claim/user'`


STG: `https://mcafe.azurewebsites.net/api/claim/user` (POST)


`Config.claimModule = '/claim/module'` (POST)


`Config.claimDepartment = '/claim/department'` (GET)


`Config.claimReplacement = '/claim/replacement'` (POST)


`Config.claimActiveReplace = '/claim/activereplace'` (POST)


`Config.claimDeactivateReplacement = '/claim/deactivatereplacement'` (POST)


`Config.claimDeptemp = '/claim/deptemp'` (POST)


`Config.claimMyClaims = '/claim/myclaims'` (POST)


`Config.claimCancelClaim = '/claim/cancelclaim'` (POST)


`Config.claimAuditHistory = '/claim/audithistory'` (POST)


`Config.claimDetails = '/claim/claimdetails'` (POST)


`Config.claimTotalClaim = '/claim/totalclaim'` (POST)


`Config.claimDuplicateReceipt = '/claim/duplicatereceipt'` (POST)


`Config.claimMonthlyLimit = '/claim/monthlylimit'` (POST)


`Config.claimCalculateMileage = '/claim/calculatemileage'` (POST)


`Config.claimNewClaim = '/claim/newclaim'` (POST)


`Config.claimEditClaim = '/claim/editclaim'` (POST)


`Config.claimApprovalList = '/claim/approvallist'` (POST)


And more (see Config.dart for full claim list)


Full URL pattern: `https://mcafe.azurewebsites.net/api` or `https://mcafebaru.azurewebsites.net/api` + `/claim/...`


**ASAP (support)**


`Config.mCafeAsap = '/mcafe/newasap'`


STG: `https://mcafe.azurewebsites.net/api/mcafe/newasap`


Used via: `dio.post(Config.mCafeAsap, data: FormData)` (multipart when file is attached)


**Town Hall**

- `Config.mCafeTownHall = '/mcafe/townhall'`

- STG: `https://mcafe.azurewebsites.net/api/mcafe/townhall`

- Used via: `dio.get(Config.mCafeTownHall)` (GET)


**PVR (policy/records)**


`Config.mCafePvrCategory = '/mcafe/pvrcategory'` (GET)


`Config.mCafePvrContent = '/mcafe/pvrcontent'` (POST)


**Refer / Submit Lead**


`Config.mCafeReferCategory = '/mcafe/refercategory'` (GET)


`Config.mCafeReferContent = '/mcafe/refercontent'` (POST)


`Config.mCafeSubmitLead = '/mcafe/submitlead'` (POST)


**Content Highlight**


`Config.mCafeContentHighlightTitle = '/mcafe/newswimlane'` (GET)


`Config.mCafeContentHighlight = '/mcafe/newcontent'` (POST, body: `{'url': url}`)




**Other notable endpoints**


Freshservice (tickets): `Config.getFreshServiceBaseUrl()` returns `https://astrosd

fs

sandbox.freshservice.com/api/v2` or production `https://astrosd.freshservice.com/api/v2` with endpoints like `Config.tickets`, `Config.ticketFormFields`, etc.


Azure Graph endpoints: `Config.azureURL = 'https://graph.microsoft.com/v1.0/'` with `me`, `revoke`, etc. (used for Graph calls outside `api_provider`).


