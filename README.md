# MET Schedule (جدول MET)

[![CI](https://github.com/mohamed-wagdy-elmasry/MET-Schedule/actions/workflows/ci.yml/badge.svg)](https://github.com/mohamed-wagdy-elmasry/MET-Schedule/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.44.3-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An offline-first, bilingual (Arabic & English) smart timetable, graduation project workspace, and campus directory built for **MET Mansoura BIS (Business Information Systems) 4th Year Students** (Academic Year 2026/2027).

---

## 🌟 Key Features

- **100% Offline-First:** Bundled schedule with zero network dependencies; runs anywhere without servers.
- **Bilingual & RTL-Ready:** Full Arabic (default) and English support with native right-to-left layout.
- **Smart Dynamic Timetable:** Real-time indicator for ongoing and next upcoming classes, full week view, and cohort filtering (Groups A & B, Sections 1–28).
- **Personalized Class Reminders:** Weekly local notifications scheduled 10 minutes prior to lectures and practical labs (with exact alarm fallback and iOS limit compliance).
- **Graduation Project Hub:** Milestones checklist, weekly notes, and project team tracking.
- **Campus Directory:** Hall, lab, and code directory with optional on-device photo attachments.
- **Friday Spiritual Hub:** Daily Sunan reminders and offline Surah Al-Kahf text.
- **Theming:** Tailored dark and light palettes with customizable primary colors.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `3.44.3` (Dart `3.12.2`)
- Android Studio / Xcode (for mobile builds)

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/mohamed-wagdy-elmasry/MET-Schedule.git
cd MET-Schedule

# Fetch dependencies
flutter pub get

# Run on connected device or simulator
flutter run
```

---

## 🧪 Testing & Code Quality

```bash
# Run static code analysis
flutter analyze

# Run unit and widget test suite
flutter test
```

---

## 📦 Building a Release

### Android Release APK / App Bundle

To sign an official release build, configure `android/key.properties` (never commit this file to version control):

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore-file>
```

> **Note:** If `key.properties` is omitted, the Gradle build falls back to debug signing automatically for convenient local testing.

```bash
# Build Android App Bundle (AAB for Google Play)
flutter build appbundle --release

# Build Android APK
flutter build apk --release
```

### iOS Release Build

```bash
flutter build ipa --release
```

---

## 📅 Updating the Schedule JSON

The bundled timetable is defined in [`assets/data/schedule.json`](assets/data/schedule.json).

To update or replace schedule data:
1. Edit or replace `assets/data/schedule.json` following the schema:
   ```json
   {
     "group": "A",
     "day": "saturday",
     "type": "lecture",
     "subject": "نظم دعم القرار",
     "room": "مدرج د",
     "instructor": "د. محمد وجدي",
     "start": "8:45 ص",
     "end": "10:15 ص",
     "sections": []
   }
   ```
2. For lectures and whole-group sessions, set `"sections": []` (applies to all sections). For specific lab or section sessions, list section numbers (e.g., `"sections": [1, 2]`).
3. Run `flutter test` to verify schedule integrity.
