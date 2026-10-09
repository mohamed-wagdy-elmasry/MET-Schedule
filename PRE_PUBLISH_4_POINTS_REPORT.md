# تقرير فحص النقاط الأربع قبل النشر — MET Schedule
**تاريخ الفحص:** 7 أكتوبر 2026  
**حالة الفحص:** فحص وقراءة حقائق صارمة (Facts Only) بدون أي تعديل برمجي على ملفات المشروع أو افتراضات تخمينية.

---

## 1) Target SDK الفعلي (Android)

### أ. قيم compileSdk و targetSdk و minSdk الفعلية في الـ Release Build
تم التحقق عبر تشغيل `flutter build appbundle --release` وفحص الـ Manifest المدمج النهائي في `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml` بالإضافة إلى فحص badging عبر أداة `aapt`:

- **compileSdkVersion:** `36` (Android 16 DP / Platform Build Version Code `36` من Android SDK 36.1.0)
- **targetSdkVersion:** `36` (المطابق لمتطلبات Google Play للعام 2024+ والبالغة 34 فأعلى)
- **minSdkVersion:** `24` (محدد من خلال متطلبات مكتبة desugar ومكتبات الإشعارات)

#### مخرجات أمر `aapt dump badging` على نسخة الـ Release:
```text
package: name='com.met.bisschedule' versionCode='4' versionName='1.0.0' platformBuildVersionName='16' platformBuildVersionCode='36' compileSdkVersion='36' compileSdkVersionCodename='16'
sdkVersion:'24'
targetSdkVersion:'36'
uses-permission: name='android.permission.POST_NOTIFICATIONS'
uses-permission: name='android.permission.RECEIVE_BOOT_COMPLETED'
uses-permission: name='android.permission.SCHEDULE_EXACT_ALARM'
uses-permission: name='android.permission.VIBRATE'
uses-permission: name='com.met.bisschedule.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
application-label:'MET Schedule'
```

#### مخرجات الـ Manifest المدمج النهائي (`build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`):
```xml
    <uses-sdk
        android:minSdkVersion="24"
        android:targetSdkVersion="36" />
```

#### توثيق الأوامر المنفذة ورسائل الخطأ:
- **الأمر:**
  `& "C:\Users\DELL 3561 G11\AppData\Local\Android\Sdk\build-tools\36.1.0\aapt2.exe" dump badging "d:\M\met1\build\app\outputs\bundle\release\app-release.aab"`
- **رسالة الخطأ:**
  `d:\M\met1\build\app\outputs\bundle\release\app-release.aab: error: could not identify format of APK.`  
  *(السبب: أداة aapt2 dump badging مصممة لحزم APK وليس ملفات AAB بصيغة zip الخاصة بـ AppBundle، ولذلك تم فحص الـ Manifest المدمج المباشر الناتج عن بناء الـ AAB وكذلك فحص APK النهائي بنجاح).*

---

### ب. محتوى `android/app/build.gradle.kts` كامل
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.met.bisschedule"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.met.bisschedule"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    val hasReleaseKey = keystorePropertiesFile.exists() && keystoreProperties.containsKey("keyAlias")

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
```

- **فحص compileOptions:** مفعل بها `isCoreLibraryDesugaringEnabled = true` و Java 17 compatibility.
- **فحص kotlin:** محدد بها `jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17`.
- **فحص dependencies:** تحتوي على `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.
- **هل يوجد coreLibraryDesugaring و desugar_jdk_libs؟** نعم، موجودة ومفعلة.

---

## 2) جدولة الإشعارات على Android 14+
فحص ملف [lib/core/services/notification_service.dart](file:///d:/M/met1/lib/core/services/notification_service.dart):

### أ. zonedSchedule و scheduleMode
1. **السطور 267–277 (إشعار الجمعة `scheduleFridayReminder`):**
```dart
      await _plugin.zonedSchedule(
        fridayReminderId,
        title,
        body,
        scheduled,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
```

2. **السطور 428–442 (إشعارات المحاضرات الأسبوعية `_scheduleWeekly`):**
```dart
    try {
      final canExact = await canScheduleExactNotifications();
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
```

3. **السطور 444–456 (Fallback إشعارات المحاضرات في حال فشل الجدولة الدقيقة):**
```dart
    } catch (e) {
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          NotificationDetails(android: androidDetails, iOS: iosDetails),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (inner) {
        debugPrint('[NotificationService] Failed to schedule #$id: $inner');
      }
    }
```

---

### ب. requestExactAlarmsPermission و canScheduleExactNotifications
1. **السطور 136–147 (`canScheduleExactNotifications`):**
```dart
  /// Checks whether exact alarms are permitted (Android 12+).
  /// On Android 11 or lower, returns true.
  Future<bool> canScheduleExactNotifications() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    try {
      final canExact = await androidPlugin.canScheduleExactNotifications();
      return canExact ?? false;
    } catch (_) {
      return false;
    }
  }
```

2. **السطور 150–156 (`requestExactAlarmsPermission`):**
```dart
  /// Requests exact alarms permission on Android 13/14+.
  Future<bool> requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    return await androidPlugin.requestExactAlarmsPermission() ?? false;
  }
```

---

### ج. فحص try/catch والـ Fallback وآلية التعامل مع رفض الإذن
- في السطر 429: يتم فحص إذن التنبيهات الدقيقة عبر `canScheduleExactNotifications()`.
- إذا كانت النتيجة `true`: يُستخدم `AndroidScheduleMode.exactAllowWhileIdle`.
- إذا كانت النتيجة `false`: يتم التحويل التلقائي المباشر (Fallback مسبق) إلى `AndroidScheduleMode.inexactAllowWhileIdle`.
- إذا رمت الجدولة الأولى أي `Exception` (مثلاً قيود نظام أندرويد 14 المفاجئة): يلتقطها البلوك `catch (e)` ويقوم بمحاولة fallback ثانية فورية بوضع `AndroidScheduleMode.inexactAllowWhileIdle`.
- إذا رمت المحاولة الثانية استثناءً أيضاً: يلتقطه البلوك الداخلي `catch (inner)` ويطبع الخطأ فقط `debugPrint('[NotificationService] Failed to schedule #$id: $inner');` لمنع انهيار التطبيق (No Crash).
- دالة `scheduleAllNotifications` مغلفة بالكامل بـ `try { ... } catch (e, stack) { debugPrint(...); }` (السطور 312 و 372).
- دالة `scheduleFridayReminder` مغلفة بالكامل بـ `try { ... } catch (e) { debugPrint(...); }` (السطور 231 و 278).

---

### د. uiLocalNotificationDateInterpretation و matchDateTimeComponents
- في `scheduleFridayReminder`:
  - السطور 273–274: `uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,`
  - السطر 276: `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,`
- في `_scheduleWeekly`:
  - السطور 436–437: `uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,`
  - السطر 441: `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,`
  - السطور 451–452 (في الـ fallback): `uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,`
  - السطر 454 (في الـ fallback): `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,`

---

### هـ. هل يوجد أي مكان يطلب إذن SCHEDULE_EXACT_ALARM من المستخدم أو يوجهه لإعدادات "Alarms & reminders"؟
- **النتيجة:** **NOT FOUND**.
- دالة `requestExactAlarmsPermission()` معرّفة فقط في السطور 150–156 في [notification_service.dart](file:///d:/M/met1/lib/core/services/notification_service.dart) ولا يوجد أي استدعاء لها في واجهات التطبيق بالكامل (`lib/presentation/screens/` أو غيرها).
- لا يوجد أي كود أو Intent لتوجيه المستخدم إلى إعدادات النظام `android.settings.REQUEST_SCHEDULE_EXACT_ALARM` أو صفحة "Alarms & reminders".
- الإذن معلن عنه في [AndroidManifest.xml](file:///d:/M/met1/android/app/src/main/AndroidManifest.xml) بالسطر 13 فقط.

---

## 3) عدد الإشعارات على iOS (حد الـ 64)

### أ. كيفية جدولة إشعارات المحاضرات بالكود
تُجدول المحاضرات كـ **إشعار متكرر أسبوعياً** (Weekly recurring alarm) باستخدام:
`matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`
كما هو موضح في الكود بالسطور 430–442 و 445–455 من [lib/core/services/notification_service.dart](file:///d:/M/met1/lib/core/services/notification_service.dart):
```dart
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
```
*(لا يتم إنشاء إشعار منفصل لكل تاريخ محدد في التقويم).*

---

### ب. حساب عدد الإشعارات المعلقة (pending) في أسوأ حالة
بفحص جدول [assets/data/schedule.json](file:///d:/M/met1/assets/data/schedule.json):
- إجمالي عدد السجلات في الملف: 70 عنصر (10 محاضرات، 56 سكشن وعملي، 4 ريست/مشروع).
- لكل طالب (بعد اختيار الفرقة والشعبة):
  - الفرقة A: الشعب من 1 إلى 8 تمتلك كل منها بالضبط **5 حصص أسبوعياً**.
  - الفرقة B: الشعب من 1 إلى 8 تمتلك كل منها بالضبط **5 حصص أسبوعياً**.
- إشعار الجمعة الأسبوعي (`fridayReminderId = 7777`): **1** إشعار معلق متكرر.
- الإشعار الترحيبي (`welcomeNotificationId = 2027`): يُعرض فورياً عند الفتح عبر `_plugin.show()` ولا يُسجل كإشعار مستقبلي معلق (`zonedSchedule`)، وحتى في حال حسابه كإشعار معلق:
  - **الحساب الفعلي للطالب العادي:**
    $$5 \text{ (محاضرات وسكاشن)} + 1 \text{ (جمعة)} = 6 \text{ إشعارات معلقة}$$
    (أو 7 مع الإشعار الترحيبي).
- **الحساب في أسوأ سيناريو نظري (عدم اختيار شعبة أو فرقة):**
  - في حال اختيار فرقة A فقط دون شعبة: 33 جلسة + 1 جمعة = **34 إشعاراً**.
  - في حال عدم اختيار فرقة ولا شعبة نهائياً: يحتوي الكود على حماية صريحة للحد في السطور 353–363:
    ```dart
      if (filtered.length > 60) {
        filtered = filtered.take(60).toList();
      }
    ```
    فتكون الحسبة: 60 جلسة + 1 جمعة = **61 إشعاراً معلقاً كأقصى حد نظري**.
- **مقارنة بحد الـ 64 في iOS:**
  - الحالة الفعلية: 6 من 64 إشعاراً (يمثل 9.38% فقط من الحد الأقصى).
  - أسوأ حالة نظرية: 61 من 64 إشعاراً (يمثل 95.31% من الحد الأقصى ومحمي برمجياً من التجاوز).

---

### ج. استخدام pendingNotificationRequests() أو cancelAll() قبل إعادة الجدولة
في [lib/core/services/notification_service.dart](file:///d:/M/met1/lib/core/services/notification_service.dart):
1. **السطور 328–335 (داخل `scheduleAllNotifications`):**
```dart
      // Cancel previous scheduled notifications to avoid duplicates without dismissing active welcome notification
      try {
        final pending = await _plugin.pendingNotificationRequests();
        for (final req in pending) {
          if (req.id != welcomeNotificationId) {
            await _plugin.cancel(req.id);
          }
        }
      } catch (_) {
        // Fallback only if pending query fails
      }
```
2. **السطور 315–318 (إلغاء الكل إذا أوقف المستخدم الإشعارات):**
```dart
      final enabled = prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
      if (!enabled) {
        await cancelAll();
        return;
      }
```
3. **السطور 284–291 (دالة `cancelAll` العامة):**
```dart
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      debugPrint('[NotificationService] All notifications cancelled');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling notifications: $e');
    }
  }
```

---

### د. هل توجد إشعارات أخرى بتتجدول لأيام/أسابيع قادمة (غير متكررة)؟
- **النتيجة:** **NOT FOUND** (لا يوجد).
- جميع الإشعارات المجدولة في التطبيق بالكامل تستخدم `DateTimeComponents.dayOfWeekAndTime` وتتكرر أسبوعياً فقط.

---

## 4) أجهزة iOS و orientation

### أ. قيمة TARGETED_DEVICE_FAMILY من `ios/Runner.xcodeproj/project.pbxproj`
- **Configuration: Debug** (السطر 493):
  `TARGETED_DEVICE_FAMILY = "1,2";`
- **Configuration: Release** (السطر 546):
  `TARGETED_DEVICE_FAMILY = "1,2";`
- **Configuration: Profile** (السطر 367):
  `TARGETED_DEVICE_FAMILY = "1,2";`

*(القيمة `"1,2"` تعني دعم iPhone و iPad معاً كـ Universal App).*

---

### ب. قيم `ios/Runner/Info.plist`
1. **UISupportedInterfaceOrientations** (السطور 56–59):
```xml
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
```

2. **UISupportedInterfaceOrientations~ipad** (السطور 60–63):
```xml
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
```

3. **UIRequiresFullScreen:**
- **النتيجة:** **NOT FOUND** (غير موجود في ملف Info.plist).

---

### ج. كود قفل الاتجاه في `lib/` (`SystemChrome.setPreferredOrientations`)
في [lib/main.dart](file:///d:/M/met1/lib/main.dart) (السطور 27–31):
```dart
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
```
*(لا توجد أي استدعاءات أخرى للدالة في كامل المشروع).*

---

## ملخص الأوضاع الحالية
- **الوضع الحالي (1):** minSdk=24، targetSdk=36، compileSdk=36، مع تفعيل desugar_jdk_libs:2.1.4 و Java 17.
- **الوضع الحالي (2):** دعم Android 14+ مبني بـ fallback تلقائي إلى inexactAllowWhileIdle في حال رفض أو غياب Exact Alarms، ولا يوجد طلب للإذن في الـ UI أو توجيه للمستخدم لإعدادات النظام.
- **الوضع الحالي (3):** جدولة أسبوعية متكررة بـ 6 إشعارات فعلية للطالب (وحد أقصى نظري 61 مقيد برمجياً)، وجميعها أقل من حد الـ 64 في iOS، وتُدار عبر pendingNotificationRequests دون إلغاء الإشعار الترحيبي.
- **الوضع الحالي (4):** التطبيق مضبوط Universal بـ TARGETED_DEVICE_FAMILY="1,2"، ومقفل على Portrait فقط في Info.plist و main.dart، بينما مفتاح UIRequiresFullScreen غير موجود.
