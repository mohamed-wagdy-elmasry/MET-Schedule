# MET Schedule — App Store & Google Play Store Submission Checklist

This document contains pre-filled questionnaire answers, policy compliance statements, permission justifications, and required asset specifications for publishing **MET Schedule** (`met1`) to the Apple App Store and Google Play Store.

---

## 1. Google Play Console — Data Safety Section

When completing the **Data safety** form in Google Play Console:

| Question | Answer | Details / Justification |
| :--- | :--- | :--- |
| **Does your app collect or share any user data?** | **No** | The application is fully offline and does not collect, transmit, share, or upload any user data. |
| **Is all user data collected by your app encrypted in transit?** | **N/A** | No data is collected or transmitted over any network. |
| **Do you provide a way for users to request that their data is deleted?** | **Yes** (or N/A) | Users can reset all data directly inside Settings > Reset, or by uninstalling the app / clearing app storage. |

### Permissions Declared & Justifications

1. **`POST_NOTIFICATIONS`**
   - **Purpose:** Schedules local reminders 10 minutes prior to university lectures/sections and the Friday reminder.
   - **Type:** Local push notification. No remote push servers (FCM/APNs) are involved.
2. **`SCHEDULE_EXACT_ALARM`**
   - **Purpose:** Used strictly to trigger precise 10-minute pre-lecture alert reminders so students arrive on time to lectures/labs across the campus.
   - **Fallback:** If exact alarm permission is revoked or denied on Android 13+, the app automatically falls back to `inexactAllowWhileIdle` without crashing.
   - **Note:** `USE_EXACT_ALARM` was removed from the manifest in accordance with Google Play's exact alarm policy for non-alarm clock apps.
3. **`RECEIVE_BOOT_COMPLETED`**
   - **Purpose:** Reschedules the student's recurring weekly class alarms automatically when the device restarts.
4. **`VIBRATE`**
   - **Purpose:** Haptic vibration feedback for timely notification alerts.
5. **`CAMERA`**
   - **Purpose:** Optional feature allowing students to snap and save quick photos of campus hall entrances, lab codes, or schedule notice boards into their local Campus Directory. Handled via standard system camera picker and kept strictly on the local device.

---

## 2. Apple App Store Connect — App Privacy Details

When completing **App Privacy** in App Store Connect:

- **Data Collection:** Select **"Data Not Collected"**.
- Confirm that:
  - No user identifiers, device IDs, or tracking data are captured.
  - No third-party analytics (Firebase, Flurry, Adjust, etc.) or ad networks are integrated.
  - Diagnostics and crash logs are handled strictly via Apple's opt-in system diagnostics (no third-party SDKs).

### iOS Permission Strings in `Info.plist`
- `NSCameraUsageDescription`: *"We need access to the camera so you can take and save photos of campus halls, labs, and schedule boards to your personal directory."*
- `NSPhotoLibraryUsageDescription`: *"We need access to your photo library to let you pick and attach campus images to your directory."*

---

## 3. Required Store Listing Assets

### Google Play Store
- **App Icon:** 512 x 512 px, 32-bit PNG with alpha.
- **Feature Graphic:** 1024 x 500 px, JPG or 24-bit PNG (no alpha).
- **Phone Screenshots:** Minimum 2, maximum 8 screenshots:
  - 16:9 or 9:16 aspect ratio (e.g., 1080 x 2400 px or 1080 x 1920 px).
- **Short Description (max 80 chars):**
  - AR: `الجدول الدراسي الذكي ودليل الحرم الجامعي لطلاب نظم معلومات MET الفرقة الرابعة.`
  - EN: `Smart timetable, campus directory & hub for MET BIS 4th year students.`
- **Full Description (max 4000 chars):**
  - Highlight: 100% offline-first, bilingual AR/EN, Dark/Light mode, graduation project tracker, campus directory, weekly reminders.

### Apple App Store
- **App Icon:** 1024 x 1024 px, 72 dpi, RGB, flat, no transparency, JPG or PNG.
- **Screenshots:**
  - **6.9" / 6.7" Display (iPhone 16 Pro Max / 15 Pro Max):** 1290 x 2796 px or 1320 x 2868 px.
  - **6.5" Display (iPhone 11 Pro Max / XS Max):** 1242 x 2688 px.
  - **13" iPad Pro (Optional if universal):** 2048 x 2732 px.

---

## 4. Privacy Policy URL

- **URL:** Host `docs/privacy/index.html` on GitHub Pages:
  - `https://<YOUR_GITHUB_USERNAME>.github.io/met1/privacy/`
- Set this URL in:
  1. Google Play Console > App Content > Privacy Policy.
  2. App Store Connect > App Information > Privacy Policy URL.
  3. `lib/core/constants/app_constants.dart` (`privacyPolicyUrl`).
