# Sumadhura Visitor Management Mobile Application (MVVM Architecture)

> An enterprise-grade Flutter mobile application built for front-desk reception and security staff at **Sumadhura Properties**. Implemented following strict **Model-View-ViewModel (MVVM)** architectural separation, Riverpod state management, Dio REST client, camera QR scanning, and dynamic QR generation.

---

## 🏛️ MVVM Architecture Overview

The application follows the **Model-View-ViewModel (MVVM)** pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                            VIEWS                            │
│  - DashboardView (Today's metrics & recent visitors)        │
│  - VisitorListView (Search, project/status filters, CRUD)   │
│  - VisitorFormView (Registration & edit with validation)    │
│  - VisitorDetailsView (Pass profile & dynamic QR pass)      │
│  - QrScannerView (Camera scanning & debounce guard)         │
│  - MainNavigationView (BottomNavigationBar: Home/List/Scan) │
└──────────────┬──────────────────────────────▲───────────────┘
               │ User Events                  │ State Streams
               ▼                              │
┌─────────────────────────────────────────────┴───────────────┐
│                          VIEWMODELS                         │
│  - DashboardViewModel (Metric aggregation & refresh)        │
│  - VisitorListViewModel (Filtering, search, & deletion)     │
│  - VisitorFormViewModel (Form validation & submission)      │
│  - VisitorDetailsViewModel (Status check-in/out & pass)     │
│  - QrScannerViewModel (Debounced QR decode & API lookup)    │
└──────────────┬──────────────────────────────▲───────────────┘
               │ Business Logic & Repos       │ Cached Data
               ▼                              │
┌─────────────────────────────────────────────┴───────────────┐
│                            MODELS                           │
│  - Visitor Domain Model & Lifecycle Status State Machine    │
│  - Enums (VisitorType, ProjectName, VisitorStatus)          │
│  - IVisitorRepository & VisitorRepository (Data Sync)       │
│  - IVisitorApiService & Dio ApiClient (REST Operations)     │
└─────────────────────────────────────────────────────────────┘
```

### Key Responsibilities
1. **Model Layer (`lib/features/visitor/data/`)**:
   - `Visitor`: Immutable domain entity with business rules (`canCheckIn`, `canCheckOut`, `isCompleted`).
   - `VisitorRepository`: Exposes visitor CRUD operations, enforces lifecycle transitions, and maintains a persistent cache with offline fallback.
   - `VisitorApiService`: Dio HTTP service executing REST operations against MockAPI.
2. **ViewModel Layer (`lib/viewmodels/`)**:
   - `DashboardViewModel`: Computes today's metrics from API-backed records using local date.
   - `VisitorListViewModel`: Manages search queries, status filter chips, project dropdown filter, and deletion.
   - `VisitorFormViewModel`: Manages form validation, registration, and editing.
   - `VisitorDetailsViewModel`: Manages visitor pass display, check-in, check-out, and deletion.
   - `QrScannerViewModel`: Handles camera scanner debouncing (`_isProcessingScan`), API lookup, and action sheet execution.
3. **View Layer (`lib/views/`)**:
   - Declarative widgets that observe ViewModels and render UI without containing business or HTTP logic.
   - Host `MainNavigationView` with Bottom Navigation: **Dashboard**, **Visitors**, and **Scan**.

---

## 🧩 Reusable UI Components (`lib/shared/widgets/`)

| Component Name | File | Purpose |
| :--- | :--- | :--- |
| **`CustomTextField`** | `custom_text_field.dart` | Form inputs with icons, validation, and theme styling |
| **`CustomButton`** | `custom_button.dart` | Action buttons (Primary, Secondary, Teal, Destructive) with loading spinners |
| **`DashboardStatCard`** | `dashboard_stat_card.dart` | Metric card displaying title, count, and subtitle with icon badges |
| **`VisitorCard`** | `features/visitor/presentation/widgets/visitor_card.dart` | Directory card with name, 10-digit mobile, status, project, and actions |
| **`StatusChip`** | `status_chip.dart` | Color-coded status chip with approved palette (`#64748B`, `#15803D`, `#475569`) |
| **`LoadingView`** | `loading_view.dart` | Centered branded loading spinner with customizable progress text |
| **`EmptyStateWidget`** | `empty_state_widget.dart` | Clean zero-state illustration with optional action callback |
| **`ErrorView`** | `error_view.dart` | Network and API error banner with retry button |

---

## 🎨 Approved Color Palette & Human-Touch Design

| Token | Hex Code | Role in Application |
| :--- | :--- | :--- |
| **Primary Navy** | `#142B4A` | App bars, strong headings, primary buttons, bottom navigation |
| **Teal Accent** | `#18A999` | Key actions, FABs, selected chips, QR scanner target reticle |
| **Background** | `#F4F7FB` | Soft, comfortable off-white neutral canvas |
| **Borders** | `#DCE4ED` | Input field borders, card borders, dividers |
| **Text Primary** | `#142B4A` | Deep slate navy replacing harsh pure black |
| **Status: Registered** | `#64748B` | Neutral slate badge |
| **Status: Checked In** | `#15803D` | Forest green badge |
| **Status: Checked Out** | `#475569` | Completed visit slate badge |
| **Destructive / Error** | `#B91C1C` | Deletion dialogs, failure alerts |
| **Attention / Warning** | `#B45309` | Warning prompts |

---

## 📋 Business Rules & Validation

1. **Visitor Registration**:
   - `Visitor Name`: Required (minimum 2 characters).
   - `Mobile Number`: Required, **strictly 10 digits**.
   - `Email Address`: Optional; validated with RFC regex when entered.
   - `Visitor Type`: Dropdown (`Customer`, `Vendor`, `Other`).
   - `Project Location`: Dropdown (`Project A`, `Project B`, `Project C`).
   - `Purpose of Visit`: Required.
2. **Visit Lifecycle Workflow**:
   - `Registered` ➔ `Checked In` ➔ `Checked Out`
   - New visitors start in **`Registered`** status.
   - **Check-in is permitted only for Registered visitors.**
   - **Check-out is permitted only for Checked In visitors.**
   - **Visitors cannot check out before checking in.**
   - **Completed visits cannot be checked in again.**
3. **QR Generation & Camera Scanning**:
   - QR code is generated on the Visitor Details screen using the **server-assigned visitor ID**.
   - QR scanner uses the camera to decode the visitor ID and fetches visitor profile via REST API.
   - Debounce guard prevents repeated scanner callbacks from triggering duplicate actions.
4. **Dashboard Statistics**:
   - Total Visitors Today (registered on current device local date).
   - Currently Checked In (status is `Checked In`).
   - Checked Out Today (checked out on current device local date).

---

## ⚙️ REST API & MockAPI Integration

### Configurable Base URL
Configure the base URL in [api_endpoints.dart](file:///c:/SumadhuraAssignment/lib/core/constants/api_endpoints.dart#L9) or pass it via CLI:
```bash
flutter run --dart-define=API_BASE_URL=https://<your-mockapi-id>.mockapi.io/api/v1
```

### Endpoints
- `GET /visitors`: Retrieve all visitors
- `GET /visitors/:id`: Retrieve single visitor
- `POST /visitors`: Register visitor
- `PUT /visitors/:id`: Update visitor profile
- `DELETE /visitors/:id`: Delete visitor
- `PUT /visitors/:id`: Check-in / check-out with timestamps

---

## 🧪 Automated Test Suite

```bash
flutter test
```
All **13 automated tests pass with 100% success**:
- `test/visitor_model_test.dart`: Serialization and lifecycle status rules
- `test/validators_test.dart`: Name, purpose, 10-digit mobile, and email validation
- `test/dashboard_metrics_test.dart`: Device local date metric calculations
- `test/visitor_repository_test.dart`: Repository business rule enforcement
- `test/widget_test.dart`: Widget tree rendering and dashboard verification

```bash
flutter analyze
```
**No issues found! (0 errors, 0 warnings, 0 lints)**
