# Sumadhura Visitor Management Mobile Application

> An enterprise-grade Flutter mobile application built for front-desk reception and security personnel at **Sumadhura Properties** to register visitors, manage visitor directories, generate/scan QR codes, and record visitor check-in and check-out activities. Implemented following strict **Model-View-ViewModel (MVVM)** architectural separation, Riverpod state management, Dio REST client, camera QR scanning, and persistent MockAPI synchronization.

---

## 📱 Environment & SDK Versions

- **Flutter SDK**: `3.38.5` (Channel stable)
- **Dart SDK**: `3.10.4`
- **Target Platform**: Android (SDK 21+ / Android 5.0 through Android 16)
- **Tested Device**: Physical Android Phone (`I2219 • Android 16 API 36`) & Android Emulators
- **State Management**: Flutter Riverpod (`v2.5.1`)
- **HTTP Client**: Dio (`v5.4.3+1`)

---

## 🚀 Setup & Run Instructions

### 1. Prerequisites
Ensure you have the following installed on your machine:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.27.0`)
- Android Studio / VS Code with Flutter extensions
- Android SDK Platform-Tools (`adb`)

### 2. Clone the Repository
```bash
git clone git@github.com:shreeju-s-code/sumadhura-assignment.git
cd sumadhura-assignment
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run Static Code Analysis
Ensure zero lint or compilation errors:
```bash
flutter analyze
```
*(Result: `No issues found!`)*

### 5. Run the Automated Test Suite
Execute the unit and widget test suite:
```bash
flutter test
```
*(Result: `All 18 tests passed!`)*

### 6. Run the Application
Connect an Android device or launch an emulator, then execute:
```bash
flutter run
```

To configure a custom MockAPI base URL via environment variable:
```bash
flutter run --dart-define=API_BASE_URL=https://<your-mockapi-id>.mockapi.io/api/v1/
```

### 7. Build Installable Android APK
To compile the standalone release APK for device installation:
```bash
flutter build apk --release
```
The output APK file will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Test Login Credentials

> **Notice**: As per the assignment scenario and specifications, this application is designed for front-desk and security desk personnel on dedicated premise devices. **No login credentials or authentication gates are required.** 
>
> Staff immediately access the **Dashboard**, **Visitor Registration**, **Live Directory**, and **QR Camera Scanner** upon launching the app for frictionless operational throughput.

---

## 🌐 REST API Details

The application integrates with **MockAPI** for persistent cloud CRUD operations. It also includes an in-memory repository fallback store to ensure zero UI interruption in case of network latency or third-party mock server rate-limiting.

- **Base URL**: `https://6ae0f627be3bc8fead981e6d.mockapi.io/api/v1/`
- **Configurable**: Configured in [`lib/core/constants/api_endpoints.dart`](lib/core/constants/api_endpoints.dart) or via `--dart-define=API_BASE_URL=...`

### REST Endpoints Implemented

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| **`GET`** | `/visitors` | Retrieve all registered visitors |
| **`GET`** | `/visitors/:id` | Retrieve single visitor details by unique ID |
| **`POST`** | `/visitors` | Register a new visitor record |
| **`PUT`** | `/visitors/:id` | Update / edit an existing visitor record |
| **`DELETE`**| `/visitors/:id` | Delete visitor record after user confirmation |
| **`PUT`** | `/visitors/:id` | Check-in / check-out status update with timestamps |

### Sample Visitor JSON Payloads

#### 1. Complete Visitor Record (`GET /visitors/:id`)
```json
{
  "id": "101",
  "name": "Rahul Sharma",
  "mobile": "9876543210",
  "email": "rahul.sharma@example.com",
  "visitor_type": "Customer",
  "project": "Project A",
  "purpose": "Site visit & flat handover",
  "status": "Registered",
  "created_at": "2026-10-30T10:00:00+05:30",
  "check_in_time": null,
  "check_out_time": null
}
```

#### 2. Check-In Payload (`PUT /visitors/:id`)
```json
{
  "status": "Checked In",
  "check_in_time": "2026-10-30T10:30:00+05:30"
}
```

#### 3. Check-Out Payload (`PUT /visitors/:id`)
```json
{
  "status": "Checked Out",
  "check_out_time": "2026-10-30T11:45:00+05:30"
}
```

---

## 📦 Third-Party Packages Used

| Package | Version | Purpose & Technical Justification |
| :--- | :--- | :--- |
| **`flutter_riverpod`** | `^2.5.1` | **State Management**: Provides declarative, testable state management with `StateNotifierProvider`, real-time UI synchronization across views, and automated dependency lifecycle disposal without context coupling. |
| **`dio`** | `^5.4.3+1` | **REST Networking**: Robust HTTP client configured with 10s connection/receive timeouts, network interceptors, request logging, and typed exception mapping (`NetworkException`, `NotFoundException`, `ValidationApiException`). |
| **`qr_flutter`** | `^4.1.0` | **QR Code Generation**: Generates clean, high-resolution vector QR code images on the Visitor Details screen encoding the server-assigned unique visitor ID. |
| **`mobile_scanner`** | `^5.2.3` | **QR Camera Scanner**: Hardware-accelerated camera preview with fast barcode detection, flashlight toggling, camera flipping, and debounce logic. |
| **`image_picker`** | `^1.2.3` | **Gallery Scanner**: Fallback capability allowing front-desk personnel to select a QR pass image from the device photo gallery. |
| **`intl`** | `^0.19.0` | **Date Formatting**: Enforces consistent local device date comparisons and human-friendly time representations (`hh:mm a, dd MMM yyyy`). |
| **`mocktail`** | `^1.0.4` | **Unit Testing**: Type-safe mocking for Dio and repository services in automated unit tests. |

---

## 🏛️ Architecture & Project Structure (MVVM)

The application follows the **Model-View-ViewModel (MVVM)** pattern:

```
lib/
├── core/
│   ├── constants/         # AppColors, ApiEndpoints
│   ├── network/           # ApiClient (Dio), ApiExceptions
│   ├── theme/             # AppTheme (Light & Dark Mode), ThemeProvider
│   └── utils/             # Responsive utility, DateFormatter, Validators, HapticHelper, AppSnackBar
├── features/
│   └── visitor/
│       ├── data/
│       │   ├── datasources/   # VisitorApiService (REST client interface & implementation)
│       │   ├── models/        # Visitor model, VisitorStatus, VisitorType, ProjectName
│       │   └── repositories/  # VisitorRepository (Lifecycle validation & offline fallback)
│       └── presentation/
│           └── controllers/   # visitorListNotifierProvider, DashboardMetrics
├── shared/
│   └── widgets/           # CustomButton, DashboardStatCard, StatusChip, LoadingView, EmptyStateWidget
├── viewmodels/            # DashboardViewModel, VisitorListViewModel, VisitorFormViewModel, etc.
├── views/
│   ├── main_navigation_view.dart          # Curved capsule bottom navigation dock
│   ├── dashboard/dashboard_view.dart      # Real-time metrics, shortcuts, confirmation popups
│   ├── visitor_list/visitor_list_view.dart# Search by name/mobile, project & status filters, CRUD
│   ├── visitor_form/visitor_form_view.dart# Registration & edit pop-up modal with 10-digit validation
│   ├── visitor_details/visitor_details_view.dart # Pass details, QR code display, edit modal trigger
│   └── qr_scanner/qr_scanner_view.dart    # Live camera preview, target reticle, debounce guard
└── main.dart              # Application entry point with ProviderScope & ThemeMode listener
```

---

## 📋 Business Rules & Validation

1. **Visitor Registration**:
   - `Visitor Name`: Mandatory (minimum 2 characters).
   - `Mobile Number`: Mandatory, **strictly 10 digits**.
   - `Email Address`: Optional; validated with RFC regex if entered.
   - `Visitor Type`: Dropdown selection (`Customer`, `Vendor`, `Other`).
   - `Project Location`: Dropdown selection (`Project A`, `Project B`, `Project C`).
   - `Purpose of Visit`: Mandatory text.
   - Newly registered visitors receive **`Registered`** status by default.

2. **Visit Lifecycle Workflow**:
   - Status progression: **`Registered` ➔ `Checked In` ➔ `Checked Out`**
   - **Check-in** is permitted **only** when status is `Registered`.
   - **Check-out** is permitted **only** when status is `Checked In`.
   - **Visitors cannot check out before checking in.**
   - **Visitors cannot check in twice.**
   - **Completed visits cannot be checked in again.**

3. **Dashboard Real-Time Statistics**:
   - **Total Visitors Today**: Visitors whose registration timestamp matches the device's local date.
   - **Currently Checked In**: Visitors whose current status is `Checked In`.
   - **Checked Out Today**: Visitors checked out on the device's local date.
   - No separate dashboard endpoint needed; computed in-memory from API records via `DashboardMetrics.fromVisitors`.

---

## 🎨 UI/UX Features & Bonus Enhancements

- **Curved Stadium Capsule Bottom Bar**: Custom floating dock styled with Sumadhura Deep Navy (`#142B4A`), rounded capsule corners (`BorderRadius.circular(36)`), clear labels (*Dashboard*, *Visitors*, *Scanner*), and brand teal active indicators.
- **Floating Curved SnackBars**: Distinct 2-color notification system:
  - **Green** (`#15803D`) for all successful operations (registration, check-in, check-out, edits).
  - **Red** (`#DC2626`) for errors and validation failures.
- **Dark Mode Support**: Full light and dark theme implementation switchable with an animated AppBar theme toggle icon.
- **Modal Pop-Up Editing**: Register and Edit flows open in a smooth centered modal pop-up with keyboard scroll clearance.
- **Confirmation Dialogs**: Mandatory `AlertDialog` confirmation guards prior to visitor deletion, check-in, and check-out.
- **Haptic Feedback**: Heavy vibration feedback integrated on tab switches, pull-to-refresh, QR scan detection, and status updates.

---

## 🧪 Automated Test Suite (18 Tests Passing)

```bash
flutter test
```
All **18 automated tests pass with 100% success**:
- `test/visitor_model_test.dart`: Model serialization and lifecycle business rules.
- `test/validators_test.dart`: Name, purpose, 10-digit mobile, and email validation logic.
- `test/dashboard_metrics_test.dart`: Local device date metric calculation accuracy.
- `test/visitor_repository_test.dart`: Lifecycle business rules enforcement (check-in/check-out limits).
- `test/app_snackbar_test.dart`: Floating curved SnackBar color assertions (Green/Red).
- `test/theme_mode_test.dart`: Light/Dark mode state management verification.
- `test/widget_test.dart`: Widget tree rendering and dashboard overview verification.

---

## ⚠️ Known Limitations

1. **MockAPI Rate-Limiting & Bursts**: 
   Free-tier MockAPI endpoints can occasionally throttle or respond with HTTP 429/400 during rapid sequential automated test requests. The application incorporates a resilient, in-memory repository fallback cache (`_mockFallbackStore`) so that all CRUD operations, offline lookups, and state transitions continue uninterrupted even during network failures.
2. **Single Visit Session Per Registration**:
   As outlined in the assignment brief, one visit session (Registered ➔ Checked In ➔ Checked Out) is tracked per visitor registration. Multi-session visit histories for returning visitors across different days are out of scope.
3. **Camera Emulation on Simulators**:
   Real-time video QR scanning requires a physical Android camera or an emulator with configured webcam emulation. For environments without a physical camera, the app provides *Enter Pass ID* manual entry and *Upload Scanner* from gallery.
