# Unit of Work - Story Mapping

This document maps each user story to its corresponding unit of work for the Easy App Flutter mobile application.

## Story to Unit Mapping

### Unit 1: Easy App Complete Application

All user stories are assigned to this single unit.

#### Authentication & Authorization Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| AUTH-001 | Login via Microsoft OAuth | Authentication | 5 | High |
| AUTH-002 | Logout | Authentication | 2 | High |
| AUTH-003 | Forgot/Unlock Password | Authentication | 2 | Medium |
| **Subtotal** | | | **9** | |

#### Home/Landing Page Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| HOME-001 | View Home Page with Modules | Home | 5 | High |
| HOME-002 | Navigate to Feature from Home | Home | 2 | High |
| **Subtotal** | | | **7** | |

#### Profile Management Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| PROFILE-001 | View Profile | Profile | 3 | Medium |
| PROFILE-002 | Update Profile Details | Profile | 5 | Medium |
| PROFILE-003 | Upload Profile Picture | Profile | 5 | Medium |
| PROFILE-004 | Delete Profile Picture | Profile | 2 | Low |
| PROFILE-005 | View Home Care Information | Profile | 2 | Low |
| PROFILE-006 | View Profile Updates | Profile | 2 | Low |
| **Subtotal** | | | **19** | |

#### Announcements Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| ANN-001 | View Announcements List | Announcements | 3 | Medium |
| ANN-002 | View Announcement Details | Announcements | 3 | Medium |
| ANN-003 | Search Announcements | Announcements | 5 | Medium |
| ANN-004 | Filter Announcements | Announcements | 5 | Medium |
| **Subtotal** | | | **16** | |

#### QR Wallet Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| QR-001 | Scan QR Code for Payment | QR Wallet | 8 | Medium |
| QR-002 | Show My QR Code | QR Wallet | 3 | Medium |
| QR-003 | View Payment History | QR Wallet | 3 | Medium |
| QR-004 | View Transaction Details | QR Wallet | 3 | Medium |
| **Subtotal** | | | **17** | |

#### Eclaims Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| ECLAIM-001 | View Eclaims Guide | Eclaims | 2 | Low |
| ECLAIM-002 | View Eclaims Options | Eclaims | 2 | Medium |
| ECLAIM-003 | Submit Out of Office Claim | Eclaims | 8 | Medium |
| ECLAIM-004 | Submit Health Screening Claim | Eclaims | 8 | Medium |
| ECLAIM-005 | Submit New Entry Claim | Eclaims | 8 | Medium |
| ECLAIM-006 | View My Claims | Eclaims | 3 | Medium |
| ECLAIM-007 | View Claim Details | Eclaims | 3 | Medium |
| ECLAIM-008 | Cancel Claim | Eclaims | 5 | Medium |
| **Subtotal** | | | **39** | |

#### AstroDesk Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| ASTRODESK-001 | View My Existing Support Tickets | AstroDesk | 3 | Medium |
| ASTRODESK-002 | Filter Support Tickets | AstroDesk | 3 | Low |
| ASTRODESK-003 | Create New Support Ticket | AstroDesk | 8 | Medium |
| ASTRODESK-004 | View Detailed Ticket Information | AstroDesk | 2 | Medium |
| ASTRODESK-005 | View Town Hall Content | AstroDesk | 2 | Low |
| **Subtotal** | | | **18** | |

#### Report Piracy Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| PIRACY-001 | Choose Piracy Report Type | Report Piracy | 1 | Medium |
| PIRACY-002 | Report Piracy from a Commercial Outlet | Report Piracy | 5 | Medium |
| PIRACY-003 | Report Piracy from a Website | Report Piracy | 5 | Medium |
| **Subtotal** | | | **11** | |

#### Settings Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| SETT-001 | View Current App Version | Settings | 1 | Low |
| SETT-002 | Update Easy App to Latest Version | Settings | 5 | Medium |
| SETT-003 | Manage Notification Preferences | Settings | 5 | Medium |
| **Subtotal** | | | **11** | |

#### AstroNet Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| ASTRONET-001 | Log In and View AstroNet News | AstroNet | 5 | Medium |
| **Subtotal** | | | **5** | |

#### Steps Challenge Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| STEPS-001 | View My Step Data and Rankings | Steps Challenge | 5 | Medium |
| STEPS-002 | View My Steps Progress Graph | Steps Challenge | 3 | Medium |
| STEPS-003 | Navigate Historical Step Data | Steps Challenge | 3 | Low |
| STEPS-004 | Automatically Sync Steps from Health App | Steps Challenge | 8 | High |
| **Subtotal** | | | **19** | |

#### Content Highlights Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| CONTENT-001 | View Latest Content Highlights | Content Highlights | 3 | Low |
| **Subtotal** | | | **3** | |

#### Friends & Family Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| FNF-001 | View Astro Friends and Family Referral Program | Friends & Family | 3 | Low |
| **Subtotal** | | | **3** | |

#### Sooka Share Stories

| Story ID | Title | Feature | Story Points | Priority |
|----------|-------|---------|--------------|----------|
| SOOKA-001 | View Sooka Share with Friends Campaign | Sooka Share | 3 | Low |
| SOOKA-002 | Submit a Refer Lead for Sooka Share | Sooka Share | 5 | Medium |
| **Subtotal** | | | **8** | |

| **Unit 1 Total** | | | **185** | |

---

## Story Coverage Summary

| Unit | Stories Count | Story Points | Status |
|------|---------------|--------------|--------|
| Unit 1: Easy App Complete Application | 46 | 185 | All stories assigned |

---

## Story Dependencies Within Unit

### Authentication Stories
- AUTH-001 → HOME-001 (login navigates to home)
- AUTH-002 → HOME-001 (logout accessible from home)

### Home Stories
- HOME-001 → All feature stories (home enables navigation to features)
- HOME-001 → PROFILE-001 (home displays user summary from profile)

### Profile Stories
- PROFILE-001 → PROFILE-002, PROFILE-003, PROFILE-004 (view enables edit/upload/delete)
- PROFILE-003 → PROFILE-004 (upload enables delete)

### Announcements Stories
- ANN-001 → ANN-002, ANN-003, ANN-004 (list enables details/search/filter)
- ANN-003, ANN-004 → ANN-001 (search/filter results displayed in list)

### QR Wallet Stories
- QR-001 → QR-003 (payment adds to history)
- QR-003 → QR-004 (history enables details view)
- QR-001 → HOME-001 (payment updates home wallet balance)

### Eclaims Stories
- ECLAIM-002 → ECLAIM-003, ECLAIM-004, ECLAIM-005 (options enable submission)
- ECLAIM-003, ECLAIM-004, ECLAIM-005 → ECLAIM-006 (submission adds to my claims)
- ECLAIM-006 → ECLAIM-007, ECLAIM-008 (list enables details/cancel)

---

## Cross-Feature Story Dependencies

### Home → Profile
- **HOME-001** depends on **PROFILE-001** (Home displays user summary from Profile)
- **Management**: Direct dependency within unit

### QR Wallet → Home
- **QR-001** updates Home wallet balance (HOME-001)
- **Management**: Direct dependency within unit

### Profile → Home
- **PROFILE-002, PROFILE-003** should refresh Home user summary (HOME-001)
- **Management**: Direct dependency within unit

---

## Story Priority Distribution

### High Priority Stories (Must Have)
- AUTH-001, AUTH-002 (Authentication)
- HOME-001, HOME-002 (Home/Landing)
- STEPS-004 (Sync Steps - High priority)

### Medium Priority Stories (Should Have)
- Most stories across all features

### Low Priority Stories (Nice to Have)
- PROFILE-004, PROFILE-005, PROFILE-006
- ANN-004 (Filter)
- ECLAIM-001 (Guide)
- ASTRODESK-002, ASTRODESK-005
- SETT-001
- Most webview features

---

## Notes

- **Single Unit**: All 46 stories are part of Unit 1
- **Story Coverage**: Complete coverage of all features
- **Dependencies**: All dependencies are internal to the unit
- **Development**: Features can be developed in any order, with Core Infrastructure recommended first
- **Integration**: Continuous integration as features are developed
