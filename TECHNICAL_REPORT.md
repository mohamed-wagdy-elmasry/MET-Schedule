# Technical Due Diligence & Engineering Audit Report
**Project:** MET Schedule (`met1`)  
**Package / Application ID:** `com.met.bisschedule`  
**Flutter Version:** 3.44.3 (Channel stable) | **Dart Version:** 3.12.2  
**Target Platform:** iOS (13.0+) & Android (minSdk 21, targetSdk 35)  
**Report Date:** October 2026  
**Auditor:** Senior Mobile Systems Engineer  

---

## 1. Project Overview

### App Name, Purpose, and Target Users
- **Application Name:** **MET Schedule** (internal project identifier: `met1`, display label: *"MET Schedule"*).
- **Purpose:** A dedicated, 100% offline-first academic timetable, campus directory, and student productivity hub designed specifically for undergraduate university students. It addresses everyday campus challenges: locating dispersed lecture halls/labs, staying notified ahead of academic sessions without cellular internet, tracking lecture attendance, coordinating graduation project milestones, and navigating campus resources.
- **Target Audience:** Fourth-year students (**"Senior 2027"** class) enrolled in the Business Information Systems (**BIS**) department at the Mansoura College of Technology (MET Mansoura / الأكاديمية بالمنصورة). The cohort is divided into two primary groups:
  - **Group A:** Subdivided into academic sections 1 through 14.
  - **Group B:** Subdivided into academic sections 15 through 28.

### Platforms & Frameworks
| Platform | Target Version / SDK | Framework & Core Runtime | Notes |
| :--- | :--- | :--- | :--- |
| **Android** | minSdk 21 (Android 5.0), compileSdk 35, targetSdk 35 | Flutter 3.44.3 / Dart 3.12.2 | Kotlin Gradle DSL (`build.gradle.kts`), Java 17, Core Library Desugaring enabled |
| **iOS** | iOS 13.0+ (deployment target) | Flutter 3.44.3 / Dart 3.12.2 | CocoaPods, Swift Runner, standard Darwin notification integration |

### Current Stage of Development
**Production-Ready / Pre-Launch (Release Candidate)**  
The application is currently deployed on Apple TestFlight (**Version 1.0.0, Build 4**), passes all automated unit and widget test suites (27/27 tests passing), passes static analysis with zero lint warnings (`flutter analyze --fatal-infos`), and contains store compliance assets (including bilingual Privacy Policy and store checklists).

---

## 2. Tech Stack & Dependencies

### Runtime & SDK Constraints
- **Language:** Dart 3.12.2
- **UI Framework:** Flutter 3.44.3 (Material 3 with custom design tokens)
- **Android Target:** minSdk 21 (`Android 5.0 Lollipop`), targetSdk 35 (`Android 15`)
- **iOS Target:** iOS 13.0+ minimum deployment target defined in `ios/Podfile` and Xcode project settings.

### Production Dependencies Breakdown
From `pubspec.yaml`:

| Package | Version | Purpose in Codebase | Assessment / Risk Level |
| :--- | :--- | :--- | :--- |
| `flutter_bloc` | `^9.1.0` | Global state management for user preferences and timetable data. | **Low Risk.** Industry standard; modern BLoC 9.x implementation. |
| `equatable` | `^2.0.7` | Value equality for states, events, and domain entities (`ScheduleState`, `PreferencesState`, `ScheduleEntry`). | **Low Risk.** Solid, negligible overhead. |
| `shared_preferences` | `^2.3.4` | Persistent local storage for user preferences, attendance tallies, project notes, and custom schedule edits. | **Medium Risk.** Reliable for primitive settings, but heavily overloaded here as a pseudo-database for serializing large JSON strings. |
| `flutter_local_notifications` | `^18.0.1` | Scheduling recurring weekly lecture alarms and Friday morning reminders. | **Medium Risk.** Powerful, but platform behaviors on Android 14+ (exact alarms) and iOS (64-alarm queue ceiling) require strict handling. |
| `timezone` | `^0.10.0` | Precise Cairo timezone (`Africa/Cairo`) calculations for local notification scheduling. | **Low Risk.** Clean, required companion for local notifications. |
| `url_launcher` | `^6.3.2` | Launching external URLs (academic portals, direct WhatsApp links, phone dialer). | **Low Risk.** Standard; all schemes are declared in `Info.plist` and `AndroidManifest.xml`. |
| `image_picker` | `^1.1.2` | Capturing or importing custom campus hall and schedule board photos into the local directory. | **Low Risk.** Safe; sandboxed properly into the app documents directory. |
| `path_provider` | `^2.1.5` | Resolving platform-specific local directories (`getApplicationDocumentsDirectory`) to persist user photos. | **Low Risk.** Standard Flutter ecosystem package. |
| `path` | `^1.9.0` | Cross-platform filesystem path joins and sanitization. | **Low Risk.** Core Dart team utility. |
| `package_info_plus` | `^8.1.2` | Dynamically querying version (`1.0.0`) and build number (`4`) to render in Settings screen. | **Low Risk.** Well-maintained Plus plugin. |

### Development Dependencies
| Package | Version | Purpose | Assessment |
| :--- | :--- | :--- | :--- |
| `flutter_test` | SDK | Automated unit, widget, and repository testing. | Native SDK. |
| `flutter_lints` | `^6.0.0` | Static analysis rules conforming to recommended Dart conventions. | Enabled via `analysis_options.yaml`. |
| `flutter_launcher_icons` | `^0.14.3` | CLI code generator for adaptive Android icons and iOS asset catalogs. | Configured cleanly for `#080E24` dark background. |

### Outdated, Deprecated, or Risky Packages
- **No deprecated packages found:** All dependencies are on their latest major versions and fully support Dart 3 sound null safety.
- **Architectural Risk:** Overreliance on `shared_preferences` for structured multi-model persistence (Graduation project, campus photos metadata, attendance counts, custom session overrides). A lightweight embedded database like `drift` (SQLite) or `hive_ce` would provide type safety and transactional integrity.

---

## 3. Architecture & Code Structure

### Directory Tree Structure
```text
lib/
├── main.dart                                       # Entrypoint, orientation lock, DI, MultiBlocProvider, root app
├── core/
│   ├── constants/
│   │   └── app_constants.dart                      # Static asset paths, timing keys, shared preferences keys
│   ├── localization/
│   │   └── app_localizations.dart                  # Hand-rolled bilingual (AR/EN) string repository & lookup
│   ├── services/
│   │   └── notification_service.dart               # Local notifications, FNV-1a IDs, timezone handling
│   └── theme/
│       └── app_theme.dart                          # Design system, glassmorphism tokens, light & dark palettes
├── data/
│   ├── datasources/
│   │   ├── friday_data.dart                        # Static content for Friday Azkar, Sunan, and Surah Al-Kahf
│   │   ├── local_schedule_datasource.dart          # Asset JSON loader, custom edit parser, fallback handler
│   │   └── project_workspace_service.dart          # Graduation project data models & SharedPreferences storage
│   └── repositories/
│       └── schedule_repository_impl.dart           # Domain repository implementation with in-memory caching
├── domain/
│   ├── entities/
│   │   └── schedule_entry.dart                     # Core ScheduleEntry immutable entity, time parsers, FNV-1a
│   └── repositories/
│       └── schedule_repository.dart                # Abstract interface contract for schedule retrieval
└── presentation/
    ├── bloc/
    │   ├── preferences_cubit.dart                  # Cubit for theme mode, accent color, group/section, locale
    │   └── schedule_cubit.dart                     # Cubit for timetable entries, active day, next class countdown
    ├── screens/
    │   ├── graduation_project_screen.dart          # Monolithic project workspace (Links, Team, Tasks, Milestones)
    │   ├── home_screen.dart                        # Bottom navigation shell, app bar, view toggle
    │   ├── onboarding_screen.dart                  # Initial setup flow: Group and Section picker
    │   ├── settings_screen.dart                    # App preferences, theme toggle, notifications test, reset
    │   ├── splash_screen.dart                      # Animated brand launch screen & welcome banner
    │   ├── timetable_screen.dart                   # Today & Week schedule views, next class card, day pills
    │   └── tools_screen.dart                       # Monolithic hub: Directory, Attendance, Portals, Friday
    └── widgets/
        ├── color_customization_modal.dart          # Primary theme color palette picker modal
        ├── edit_session_modal.dart                 # Custom session editing sheet for students
        ├── friday_hub_widget.dart                  # Spiritual hub UI, Salawat counter, Surah Al-Kahf reader
        └── schedule_card.dart                      # Glassmorphism timetable session card with live badges
```

### Architecture Pattern & Conformity
The application follows a **Hybrid Clean Architecture / Feature-Driven Structure**:
- **Domain Layer:** Pure Dart entities (`schedule_entry.dart`) and repository interfaces (`schedule_repository.dart`) with zero Flutter UI dependencies.
- **Data Layer:** Concrete repository (`schedule_repository_impl.dart`) and data source (`local_schedule_datasource.dart`).
- **Presentation Layer:** Uses `flutter_bloc` (`PreferencesCubit` and `ScheduleCubit`) for timetable and preferences.

```
       ┌────────────────────────────────────────────────────────┐
       │                Presentation Layer                      │
       │  HomeScreen ── TimetableScreen ── SettingsScreen       │
       └───────────┬────────────────────────────────┬───────────┘
                   │ reads/emits                    │ reads/emits
                   ▼                                ▼
       ┌───────────────────────┐        ┌───────────────────────┐
       │     ScheduleCubit     │        │   PreferencesCubit    │
       └───────────┬───────────┘        └───────────┬───────────┘
                   │ calls                          │ calls
                   ▼                                ▼
       ┌───────────────────────┐        ┌───────────────────────┐
       │  ScheduleRepository   │        │   SharedPreferences   │
       │       (Domain)        │        │      (Storage)        │
       └───────────┬───────────┘        └───────────────────────┘
                   │ implemented by
                   ▼
       ┌───────────────────────┐
       │ScheduleRepositoryImpl │
       │        (Data)         │
       └───────────┬───────────┘
                   │ parses
                   ▼
       ┌───────────────────────┐
       │LocalScheduleDataSource│ ───► assets/data/schedule.json
       └───────────────────────┘
```

#### Architectural Inconsistencies & Deviations
While the core schedule flow strictly adheres to Clean Architecture, **significant architectural drift occurs in secondary features**:
1. **Graduation Project Screen (`graduation_project_screen.dart`):** Completely bypasses BLoC. It calls `ProjectWorkspaceStorage.load()` and `ProjectWorkspaceStorage.save()` directly from within a 2,074-line `StatefulWidget`, managing complex state mutations (adding tasks, toggling milestones, modifying team phone numbers) via raw `setState()`.
2. **Tools Screen (`tools_screen.dart`):** Contains 2,580 lines of code. Sub-features like `_AttendanceTrackerPage` and `_CampusDirectoryPage` invoke raw `SharedPreferences.getInstance()` directly inside UI callbacks to read and write attendance integers and JSON photo lists, with zero separation between UI and data logic.

### State Management Approach
- **Core App State:** `flutter_bloc` Cubits:
  - `PreferencesCubit`: Manages theme mode (`ThemeMode.light` vs `ThemeMode.dark`), primary color seed, locale (`ar` vs `en`), academic group (`A` vs `B`), academic section (`1..28`), and onboarding completion flag.
  - `ScheduleCubit`: Manages schedule entries, active day filter, view mode (`today` vs `week`), next upcoming class calculation, and notification dispatch.
- **Transient UI State:** Handled via `StatefulWidget` and `setState` for tab switching, search filtering, and animation controllers.

### Navigation / Routing Approach
- The application uses **Navigator 1.0 (Imperative Routing)**:
  - Root routing is decided in `splash_screen.dart`:
    ```dart
    final nextScreen = prefs.hasOnboarded ? const ScheduleLoader() : const OnboardingScreen();
    Navigator.of(context).pushReplacement(PageRouteBuilder(...));
    ```
  - Inner screen transitions use standard `Navigator.push(context, MaterialPageRoute(...))`.
  - Main tab navigation uses an `IndexedStack` hosted inside `HomeScreen`, which preserves the state of all four tabs in memory.
- *Limitation:* Deep linking is not configured; no declarative router (e.g. `go_router`) is present.

### Dependency Injection Approach
- **Manual Dependency Injection:** Dependencies are constructed in `main.dart` and distributed down the widget tree using `MultiBlocProvider` and `BlocProvider.value`.
- Constructor injection is supported in `METApp` for unit and widget test mocking (`scheduleRepository`, `preferencesCubit`, `scheduleCubit`).
- No third-party service locator (such as `get_it` or `injectable`) is utilized.

---

## 4. Features & Screen Audit

### Feature Status Matrix

| Screen / Feature | Implementation File | Status | Description & User Value |
| :--- | :--- | :--- | :--- |
| **Splash Screen** | `splash_screen.dart` | **Complete** | Animated brand logo, custom glow ring, warm "Senior 2027" greeting badge, non-blocking schedule preload. |
| **Onboarding Screen** | `onboarding_screen.dart` | **Complete** | Academic Group (A or B) and Section (1..14 or 15..28) setup with instant live preview of weekly hours. |
| **Timetable (Today View)** | `timetable_screen.dart` | **Complete** | Daily schedule list, live countdown to the next upcoming lecture, 60s periodic timer ticker, lifecycle observer. |
| **Timetable (Week View)** | `timetable_screen.dart` | **Complete** | Horizontal day pill selector (Sat–Thu), daily session lists, rest day badges, and total lecture hours summary. |
| **Schedule Session Card** | `schedule_card.dart` | **Complete** | Glassmorphic card styling, subject color strip, multi-instructor wrap, hall location badges, quick edit modal. |
| **Custom Session Editor** | `edit_session_modal.dart` | **Complete** | Bottom sheet allowing students to customize subject title, hall code, time, or instructor name locally. |
| **Color Customizer** | `color_customization_modal.dart` | **Complete** | Dynamic palette selector with preset themes (MET Navy, Royal Emerald, Purple Dawn, Amber Gold, Rose Ruby). |
| **Graduation Project Hub** | `graduation_project_screen.dart` | **Complete** | 4-tab workspace: quick links (Drive, GitHub, Figma), team directory with WhatsApp actions, task tracker, and milestones. |
| **Campus Directory & Maps** | `tools_screen.dart` | **Complete** | Official campus building diagrams, hall codes decoding table, search filter, and sandboxed user photo gallery. |
| **Attendance Tracker** | `tools_screen.dart` | **Complete** | Lecture, section, and lab attendance counter with percentage progress bars and absence warnings per subject. |
| **University Portals** | `tools_screen.dart` | **Complete** | Direct launcher links to official academy platforms: Educational Portal, Ibn Al-Haytham system, Exam Platform. |
| **Friday Spiritual Hub** | `friday_hub_widget.dart` | **Complete** | Interactive Salawat counter, complete Surah Al-Kahf verses reader (offline), Friday Sunan checklist, and Saturday preview. |
| **Settings Screen** | `settings_screen.dart` | **Complete** | Group/section switcher, appearance toggle (Dark/Light), test notification trigger, data reset, live package version display. |

### Main User Flows

#### 1. First-Time User Onboarding Flow
1. App launches into `SplashScreen`.
2. App checks `PreferencesCubit.state.hasOnboarded`.
3. If `false`, navigates via fade transition to `OnboardingScreen`.
4. Student selects Group (`A` or `B`) and Section (`1..28`). The screen dynamically updates the section grid based on the chosen group.
5. User taps "ابدأ الآن / Get Started". `PreferencesCubit.completeOnboarding(group, section)` is invoked.
6. Local notification permission prompt is triggered via `NotificationService.instance.requestPermission()`.
7. Navigates to `HomeScreen` where `ScheduleCubit.loadSchedule(group, section)` populates the timetable and automatically schedules weekly recurring notifications.

#### 2. Core Timetable Viewing & Next-Class Tracking Flow
1. Student opens app -> `SplashScreen` preloads schedule in background -> Transitions to `HomeScreen`.
2. `ScheduleLoader` provides `ScheduleCubit` with group and section.
3. `TimetableScreen` displays:
   - On Friday: The dedicated Friday Spiritual Hub.
   - On Academic Days (Sat–Thu): The **"Next Up" countdown card** (highlighting the immediate next class with minutes remaining) and the chronological session cards.
4. If a class finishes, the internal 60-second periodic timer in `_TodayViewState` triggers `refreshNextClass()`, advancing the active countdown badge without requiring user refresh.
5. Switching from "Today" to "Week" recalculates hours and displays horizontal day tabs.

### TODO / FIXME / HACK Audit
- **Codebase Scan:** A recursive regex scan across all Dart files (`lib/`, `test/`), native configuration files (`android/`, `ios/`), and documentation revealed **0 instances of `TODO`, `FIXME`, `HACK`, or `XXX`**. The codebase is completely clean of dangling placeholder markers.

---

## 5. Backend & Data Layer

### Architecture Overview
The application is **strictly offline-first with zero remote server dependency**.
- **No Remote APIs:** No REST endpoints, GraphQL schemas, Firebase SDKs, or Supabase integrations.
- **Primary Data Source:** A bundled JSON asset located at `assets/data/schedule.json` (19.2 KB).
  - Contains **70 structured academic entries** covering both Group A (Sections 1..14) and Group B (Sections 15..28).
  - Includes normalized academic times strictly adhering to 12-hour Arabic formatting (`ص` for AM, `م` for PM).
  - Handles joint cohort lectures (marked `isForAllSections: true` or `type: "lecture"`) and split lab/section sessions.

### Local Persistence & Storage Mechanism
All client state is persisted exclusively via `SharedPreferences`:

| Storage Key | Data Format | Description |
| :--- | :--- | :--- |
| `user_group` | String (`"A"` or `"B"`) | Active academic group |
| `user_section` | Integer (`1..28`) | Active academic section |
| `user_locale` | String (`"ar"` or `"en"`) | Language setting (default: `"ar"`) |
| `theme_mode` | String (`"dark"`, `"light"`) | Theme appearance mode |
| `primary_color_seed` | Integer (`0xFF...`) | Custom theme primary color value |
| `has_onboarded` | Boolean | Flag indicating completion of onboarding |
| `custom_user_schedule_json` | JSON String | Array of modified or newly created custom schedule sessions |
| `gp_workspace_user_data_v2` | JSON String | Full graduation project workspace (links, team members, tasks, milestones) |
| `campus_user_photos` | JSON String | Array of custom campus photo metadata (local file paths, captions, dates) |
| `attendance_records` | JSON String | Map of subject names to attended/absent counts |

### Offline Support, Caching & Sync
- **Offline Support:** Complete (100%). The app functions with identical feature parity regardless of device connectivity.
- **Sync Strategy:** None. Since there is no centralized database or cloud auth, data resides purely within the application's local sandbox on the physical device.
- **Cache Invalidation:** If the student resets their schedule in Settings, the key `custom_user_schedule_json` is purged from SharedPreferences and the in-memory cache in `LocalScheduleDataSource` is reset to reload pristine asset records.

### Error Handling & Resilience
In `ScheduleCubit.loadSchedule`:
```dart
try {
  final weekEntries = await _repository.getWeeklySchedule(group, section);
  emit(state.copyWith(isLoading: false, weekEntries: weekEntries, ...));
} catch (e) {
  emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
}
```
If an unhandled file reading or deserialization exception occurs, `TimetableScreen` renders an error illustration and a **"Retry / إعادة المحاولة"** action button, preventing blank screens or unhandled app terminations.

---

## 6. Authentication & Security

### Authentication & Session Management
- **Auth Method:** None. No user login, registration, password, or bearer token handling exists. The application is completely open to local device users upon completing onboarding.

### Secrets & API Keys Storage
- **Hardcoded Secrets Audit:** **Passed with 0 flags.**
  - No API keys, client secrets, Google Services credentials, or backend tokens exist in the source code or asset files.
  - Keystore signing credentials for Android production releases are kept in `key.properties` (which is properly excluded in `.gitignore`).
  - Android Gradle build script (`android/app/build.gradle.kts`) includes a safe fallback: if `key.properties` does not exist on the local development machine or CI runner, it defaults to debug signing rather than throwing a build break.

### Platform Permissions Requested

#### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```
*Note on Android Permissions:*
1. `USE_EXACT_ALARM` was intentionally removed to comply with Google Play's strict policy against non-alarm-clock applications using privileged exact alarms. The app uses `SCHEDULE_EXACT_ALARM` with runtime permission checks and graceful fallback to `inexactAllowWhileIdle`.
2. `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` are **not requested**. Campus photos are stored securely inside the app's internal documents directory.

#### iOS (`Info.plist`)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>يحتاج تطبيق MET Schedule للوصول إلى مكتبة الصور لاختيار الخرائط والمستندات الدراسية. / Requires photo library access to select campus maps and study documents.</string>
<key>NSCameraUsageDescription</key>
<string>يحتاج تطبيق MET Schedule لاستخدام الكاميرا لتصوير الجداول والمستندات الدراسية. / Requires camera access to capture schedule and study documents.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>يحتاج تطبيق MET Schedule لحفظ الجداول والخرائط في مكتبة الصور. / Requires permission to save schedules and campus maps to your photo library.</string>
```

### Security Findings & Vulnerability Assessment
1. **Plaintext Storage of Personal Team Contact Data:**
   In `ProjectWorkspaceStorage`, team members' full names and personal Egyptian mobile phone numbers are stored as unencrypted JSON in SharedPreferences (`NSUserDefaults` on iOS, XML on Android). While typical for offline productivity apps, on a rooted device or via unencrypted device backups, these numbers could be inspected.
   *Recommendation:* Use `flutter_secure_storage` or AES-GCM database encryption if student contact privacy is a primary concern.
2. **Clipboard Data Placement:**
   When students tap a team member's phone number or project URL in `GraduationProjectScreen`, the raw string is copied directly to `Clipboard.setData(ClipboardData(text: ...))`. On Android 13+ and iOS 16+, system clipboard paste notifications will appear.
3. **No Network Attack Surface:**
   Because the app makes zero HTTP requests, it is immune to Man-in-the-Middle (MITM), DNS spoofing, session hijacking, SQL injection, or server-side data leaks.

---

## 7. UI / UX Design & Accessibility

### Design System & Theming
- **Design Language:** Modern Material 3 hybrid with curated glassmorphism (`AppTheme.glassDecoration`).
- **Theme Modes:** Fully implemented **Dual Theming** (Dark Mode & Light Mode):
  - **Dark Mode:** Deep midnight navy background (`#080E24`), card surface (`#111936`), vibrant cyan/accent borders (`#00D2D3`).
  - **Light Mode:** Crisp slate background (`#F8FAFC`), card surface (`#FFFFFF`), slate borders (`#E2E8F0`).
- **Dynamic Accent Customization:** The user can change the primary brand color seed dynamically via `ColorCustomizationModal`, which updates the global `ThemeData` across all screens instantly.

### Responsiveness & Layout Adaptability
- **Orientation:** Strictly locked to **Portrait Mode** across both platforms (`main.dart` and native manifests).
- **Tablet & Large Screen Support:** Fully functional on iPad and Android tablets in portrait orientation. Uses flexible layouts, `FittedBox` on header titles, and scrollable slivers to prevent overflows.
- **Accessibility & Font Scaling:** In `main.dart`, the application explicitly clamps system text scaling factors:
  ```dart
  textScaler: MediaQuery.of(context).textScaler.clamp(
    minScaleFactor: 0.8,
    maxScaleFactor: 1.4,
  )
  ```
  This prevents UI layout breakages on devices with extreme accessibility font enlargement while keeping text readable.

### Localization & RTL Support
- **Primary Locale:** Arabic (`ar`).
- **Secondary Locale:** English (`en`).
- **RTL Support:** Full Arabic Right-To-Left (RTL) mirroring is supported automatically via Flutter's layout engine. Timetable cards, icon placements, and text directions align natively.
- **String Architecture:** Implemented via a centralized hand-rolled class in `app_localizations.dart`.

### State Feedback (Loading, Empty, Error)
- **Loading:** Subtle branded `CircularProgressIndicator` during splash and timetable reload.
- **Empty States:** Clean illustration icons (e.g. 📷 for empty campus gallery, 📋 for empty tasks, 🌸 for Friday hub) with helpful Arabic and English action prompts.
- **Error States:** Dedicated error column with descriptive text and an explicit Retry button in `TimetableScreen`.

---

## 8. Performance & Resource Utilization

### Potential Bottlenecks & Audit Observations

#### 1. Monolithic Screen Widgets & Build Methods
- **Finding:** `tools_screen.dart` is **2,580 lines** and `graduation_project_screen.dart` is **2,074 lines**.
- **Impact:** In `_GraduationProjectScreenState`, modifying a single checkbox on a milestone calls `setState()`, triggering a build of the entire nested widget hierarchy (Links tab, Team tab, Tasks tab, Milestones tab) rather than rebuilding only the affected card.
- **Mitigation Present:** The app employs `RepaintBoundary` on individual navigation items and schedule cards to prevent paint invalidation cascades onto the Flutter engine.

#### 2. Static Asset Memory Footprint
The bundled asset images represent the largest proportion of disk and runtime memory:
- `assets/images/app_logo.png`: **534 KB** (1024x1024 high resolution)
- `assets/images/campus_buildings_map.jpg`: **167 KB**
- `assets/images/campus_halls_guide.jpg`: **205 KB**
When `_FullScreenImageViewer` opens these high-resolution campus maps, Flutter loads them directly into an `InteractiveViewer`. While smooth on modern devices, adding `cacheWidth` or `cacheHeight` constraints would reduce memory consumption on low-end 2GB RAM Android devices.

#### 3. Startup Time & App Size
- **Cold Startup:** Near instantaneous (~350–500ms on typical devices). Data loading occurs from the local APK/IPA bundle using rootBundle, requiring zero network socket handshakes.
- **Release APK / AAB Size:** Approximately 16–22 MB uncompressed, which is optimal for a Flutter application with Material components and bundled assets. Code shrinking (`isMinifyEnabled = true`, `isShrinkResources = true`) is active in `build.gradle.kts`.

---

## 9. Code Quality & Maintainability

### Metrics & Distribution
- **Total Lines of Dart Code in `lib/`:** **13,705 lines** across 24 files.
- **Average File Size:** ~571 lines.
- **Largest Files in Codebase:**

| File Path | Line Count | File Size | Primary Functionality | Refactoring Urgency |
| :--- | :--- | :--- | :--- | :--- |
| `lib/presentation/screens/tools_screen.dart` | 2,580 | 105.1 KB | Campus Directory, Maps, Attendance Tracker, Portals | **HIGH** |
| `lib/presentation/screens/graduation_project_screen.dart` | 2,074 | 82.3 KB | Project Workspace (Links, Team, Tasks, Milestones) | **HIGH** |
| `lib/presentation/screens/timetable_screen.dart` | 1,099 | 45.8 KB | Today & Week Views, Day Pills, Next Class logic | **MEDIUM** |
| `lib/presentation/screens/settings_screen.dart` | 1,058 | 40.9 KB | App Settings, Theme picker, Notification test | **MEDIUM** |
| `lib/presentation/widgets/friday_hub_widget.dart` | 1,051 | 49.2 KB | Surah Al-Kahf reader, Azkar, Salawat counter | **MEDIUM** |
| `lib/presentation/widgets/schedule_card.dart` | 869 | 37.1 KB | Schedule Entry Card, badges, status colors | **LOW** |

### Linting & Static Analysis
- **Setup:** Configured via `package:flutter_lints/flutter.yaml` in `analysis_options.yaml`.
- **Static Analysis Result:** `flutter analyze --fatal-infos` executed cleanly with **0 issues found** (0 errors, 0 warnings, 0 lints).
- **Code Style & Conventions:**
  - Follows standard Dart naming conventions (`UpperCamelCase` for classes, `lowerCamelCase` for members and variables, `snake_case` for filenames).
  - Proper use of `const` constructors throughout widget trees.
  - Good documentation comments with `///` docstrings across all public classes.

### Maintainability Challenges
1. **Monolithic Files Violating Single Responsibility:**
   `tools_screen.dart` contains three distinct production features inside private classes: `_CampusDirectoryPage`, `_AttendanceTrackerPage`, and `_UniversityPortalsPage`. These should be split into dedicated feature directories under `presentation/screens/tools/`.
2. **Hand-Rolled Localization Repository:**
   `app_localizations.dart` uses string getters with ternary logic (`isArabic ? ar : en`). While lightweight and functional for two languages, it lacks compile-time pluralization, parameter formatting, and standard translation tooling (ARB files).

---

## 10. Testing & DevOps

### Automated Test Suite
- **Location:** `test/`
- **Test File Count:** 9 test files
- **Total Test Cases:** **27 automated tests** (Unit & Widget)
- **Execution Speed:** ~8 seconds total execution time.
- **Pass Rate:** **100% (27 passed, 0 failed)**.

```text
00:08 +27: All tests passed!
```

#### Test Coverage Summary
1. `test/schedule_repository_test.dart`: Verifies loading all 70 entries from `schedule.json`, chronological time sorting (11:55 ص before 12:30 م), and section filtering across Groups A (1..14) and B (15..28).
2. `test/verify_schedule_test.dart`: Verifies JSON schema integrity, valid days, time ranges, and location codes.
3. `test/notification_id_test.dart`: Validates deterministic 32-bit FNV-1a hash algorithm; tests zero collision across all 70 bundled sessions and verifies IDs are isolated above reserved system IDs (`2027`, `7777`, `9999`).
4. `test/cubit_stability_and_error_test.dart`: Tests `PreferencesCubit` stability, error state emission in `ScheduleCubit`, and error UI with retry button callbacks.
5. `test/theme_mode_test.dart`: Tests theme switching between light and dark modes and ensures `ScheduleCard` renders cleanly in both.
6. `test/widget_test.dart`: Full app smoke test validating transition from `SplashScreen` to `HomeScreen`.
7. `test/project_workspace_test.dart`: Verifies serialization and deserialization of graduation project tasks, links, and milestones.

#### Test Execution Observation
During headless `flutter test` execution, `NotificationService` calls `FlutterLocalNotificationsPlugin.cancelAll()` which catches a platform channel `LateInitializationError` inside internal `try-catch` blocks because native plugins are not mocked in pure unit tests. The test runner passes cleanly.
*Recommendation:* Introduce a mockable `NotificationServiceInterface` to avoid log spam during testing.

### CI/CD Pipeline
- **Continuous Integration:** Fully configured via GitHub Actions in `.github/workflows/ci.yml`.
- **Runner OS:** `ubuntu-latest`.
- **Flutter Action:** `subosito/flutter-action@v2` running Flutter `3.44.3` on channel `stable`.
- **Steps:**
  1. `flutter pub get`
  2. `flutter analyze --fatal-infos`
  3. `flutter test`
- **Missing CI/CD Elements:** Automated Fastlane deployments, automatic App Store Connect / TestFlight uploading, and signed Google Play AAB artifact generation.

### Crash Reporting & Telemetry
- **Crash Reporting:** **None integrated** (No Sentry, Crashlytics, or Bugsnag). Crash reports rely solely on native Apple TestFlight and Google Play Console vitals.
- **Analytics:** **None** (Strict offline privacy stance; zero analytics SDKs).

---

## 11. Release Readiness

### Store Asset & Policy Compliance Audit

| Requirement | iOS (App Store) | Android (Google Play) | Status & Verification |
| :--- | :--- | :--- | :--- |
| **App Icons** | 1024x1024 PNG generated in asset catalog | Adaptive icons (`launcher_icon`) with `#080E24` background | **Ready.** Generated via `flutter_launcher_icons`. |
| **Splash Screen** | Native `LaunchScreen.storyboard` + animated `SplashScreen` | Native `LaunchTheme` in XML + animated `SplashScreen` | **Ready.** No blank white flashes on launch. |
| **Privacy Policy** | Required for all submissions | Required for all submissions | **Ready.** Bilingual AR/EN HTML hosted in `docs/privacy/index.html`. |
| **Store Checklist** | App Store Connect review guidelines | Data Safety form answers | **Ready.** Pre-filled questionnaire in `docs/store/STORE_CHECKLIST.md`. |
| **Data Safety** | "Data Not Collected" | "No user data collected or shared" | **Compliant.** Pure offline app. |
| **Version & Build** | `1.0.0 (4)` in `pubspec.yaml` | `versionName 1.0.0`, `versionCode 4` | **Ready.** Currently deployed on TestFlight. |
| **Signing Setup** | Distribution Certificate & Provisioning Profile | Keystore defined in `key.properties` with debug fallback | **Ready.** Safe build execution. |

### Store Requirements Missing or Pending
- **App Store / Google Play Promotional Screenshots:** Physical device screenshots matching required display dimensions (e.g. 6.7" iPhone 15 Pro Max: 1290x2796 px, and 1080x1920 Android phone) must be captured and uploaded to the store consoles prior to public release.
- **Apple Developer Account & Google Play Console Account:** Needs administrative submission by the developer account holder.

---

## 12. Known Issues, Technical Debt & Risks

### Suspected Bugs & Edge Cases

#### 1. iOS 64-Pending Notification Ceiling
- **Location:** `lib/core/services/notification_service.dart` (lines 341–354)
- **Description:** iOS operating system enforces a strict hard limit of **64 total pending local notifications** per application. If an app attempts to schedule more, iOS silently discards excess notifications.
- **Status in Code:** The codebase contains a mitigation:
  ```dart
  if (filtered.length > 60) {
    filtered.sort((a, b) => _nextOccurrenceForEntry(a).compareTo(_nextOccurrenceForEntry(b)));
    filtered = filtered.take(60).toList();
  }
  ```
  While this prevents silent drops, it means for students with more than 60 weekly sessions, later sessions in the week will not trigger notification reminders until the list rolls over.

#### 2. Android Aggressive Battery Optimizations on OEM Devices
- **Location:** `lib/core/services/notification_service.dart`
- **Description:** Aggressive OEM Android skins (Xiaomi MIUI/HyperOS, Huawei EMUI, Samsung OneUI) frequently kill background alarms and prevent `RECEIVE_BOOT_COMPLETED` from rescheduling alarms unless the user manually grants "Autostart" or exempts the app from battery optimization.
- **Risk:** Students might miss notifications if the device puts the app to sleep.
- **Mitigation Needed:** Add an in-app prompt in Settings directing users to disable battery optimization for MET Schedule.

#### 3. Plaintext SharedPreferences for Contact Numbers
- **Location:** `lib/data/datasources/project_workspace_service.dart` (line 420)
- **Description:** Storing team member phone numbers and notes in unencrypted key-value storage creates a minor privacy consideration on rooted devices.

### Technical Debt Overview
1. **Monolithic UI Files:** 4,654 lines of code concentrated across just two files (`tools_screen.dart` and `graduation_project_screen.dart`).
2. **Bypassing BLoC in Secondary Features:** Direct SharedPreferences operations and local `setState()` in graduation project and tools screens deviate from the clean BLoC architecture established in the timetable feature.
3. **Absence of Declarative Routing:** No URL-based navigation (`go_router`), preventing future deep-linking into specific tabs or lecture cards.

---

## 13. Summary & Prioritized Recommendations

### Overall Assessment
| Category | Grade | Commentary |
| :--- | :---: | :--- |
| **Architecture & Structure** | **B+** | Clean Architecture followed excellently in core timetable feature; compromised by massive monolithic files in secondary tools and project workspace. |
| **Stability & Bug Resilience** | **A** | 27/27 automated tests passing, zero analyzer warnings, graceful error UI, deterministic notification IDs, clean lifecycle handling. |
| **UI / UX & Aesthetics** | **A+** | Premium glassmorphism design, flawless light and dark theming, full Arabic RTL support, text scaling clamps, and zero UI overflows. |
| **Security & Privacy** | **A** | Zero network exposure, zero telemetry, no hardcoded secrets, safe signing scripts. Minor debt in unencrypted local phone storage. |
| **Release Readiness** | **A** | TestFlight verified, clean manifest permissions, bilingual privacy policy, complete store submission checklist. |
| **OVERALL RATING** | **A-** | **Production-Ready.** Highly polished student utility with solid fundamentals, ready for App Store and Google Play publication. |

---

### Top 10 Prioritized Recommendations

```text
  ┌────────────────────────────────────────────────────────────────────────┐
  │                        RECOMMENDATION ROADMAP                          │
  ├────────────────────────────────────────────────────────────────────────┤
  │  HIGH PRIORITY    1. Decompose tools_screen.dart & project screen       │
  │  (Refactor & UX)  2. Battery optimization guidance in Settings         │
  │                   3. Encrypt sensitive contact data                     │
  │                   4. Mock NotificationService in unit tests            │
  ├────────────────────────────────────────────────────────────────────────┤
  │  MEDIUM PRIORITY  5. Migrate ProjectWorkspace to Cubit                 │
  │  (Architecture)   6. Standardize localization with ARB / intl          │
  │                   7. Optimize image assets with thumbnail cache        │
  │                   8. Add Fastlane CI/CD deployment automation          │
  ├────────────────────────────────────────────────────────────────────────┤
  │  LOW PRIORITY     9. Migrate to Declarative Routing (go_router)        │
  │  (Enhancements)  10. Replace SharedPreferences with embedded DB (Drift)│
  └────────────────────────────────────────────────────────────────────────┘
```

#### High Priority (Pre-Release / Immediate Follow-up)
1. **Decompose Monolithic Screens into Dedicated Packages:**
   - Split `tools_screen.dart` (2,580 lines) into separate files under `lib/presentation/screens/tools/`:
     - `campus_directory_view.dart`
     - `attendance_tracker_view.dart`
     - `university_portals_view.dart`
   - Split `graduation_project_screen.dart` (2,074 lines) into separate tab widgets (`links_tab.dart`, `team_tab.dart`, `tasks_tab.dart`, `milestones_tab.dart`).
2. **Add Battery Optimization Guidance Dialog in Settings:**
   - Add a "Notification Troubleshooting" tile in `SettingsScreen` that instructs Android students on OEM devices (Xiaomi, Samsung, Oppo) how to disable battery restrictions so lecture alarms never fail.
3. **Secure Team Member Contact Information:**
   - Migrate student phone numbers and graduation project notes from plaintext SharedPreferences to `flutter_secure_storage` or encrypt the payload with AES before saving.
4. **Isolate NotificationService Platform Calls for Clean Unit Tests:**
   - Extract an abstract `NotificationServiceInterface` to prevent `LateInitializationError` messages from logging during headless test runs.

#### Medium Priority (Next Minor Release)
5. **Migrate Project Workspace State to BLoC/Cubit:**
   - Create a `ProjectWorkspaceCubit` to handle task filtering, milestone updates, and contact edits cleanly rather than managing extensive state in a monolithic `StatefulWidget`.
6. **Standardize Bilingual Strings using ARB Files (`flutter_localizations`):**
   - Replace the hand-rolled `app_localizations.dart` with standard Flutter `.arb` files and `flutter gen-l10n` to enable standardized translation workflows and plural support.
7. **Optimize Campus Map Image Memory Allocation:**
   - Add `cacheWidth: 1080` to `Image.asset` calls in `_CampusDirectoryPage` to avoid decoding high-res images at full bitmap sizes on low-memory devices.
8. **Automate Store Publishing in CI Pipeline:**
   - Extend `.github/workflows/ci.yml` with Fastlane to build and deploy signed `.aab` (Google Play Internal Track) and `.ipa` (Apple TestFlight) automatically on tagged git releases.

#### Low Priority (Long-Term Architectural Evolution)
9. **Adopt Declarative Routing (`go_router`):**
   - Transition from Navigator 1.0 to `go_router` to support deep links (e.g. `met://schedule/today`, `met://tools/campus`) and cleaner navigation history management.
10. **Migrate to an Embedded Transactional Database:**
    - Replace large JSON serialization in `SharedPreferences` with an embedded database like **Drift (SQLite)** or **Hive CE** for robust ACID-compliant queries and attendance tracking.
