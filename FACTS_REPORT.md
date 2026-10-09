# تقرير حقائق المشروع (Facts Report) — MET Schedule
**تاريخ الفحص:** 7 أكتوبر 2026  
**حالة الفحص:** قراءة وفحص حقائق صارم بدون أي تعديل برمجي أو افتراضات تخمينية.

---

## 0) عام

### 1. مخرجات `flutter --version`
```text
Flutter 3.44.3 • channel stable • https://github.com/flutter/flutter.git
Framework • revision e1fd963c6f (4 months ago) • 2026-06-18 14:59:18 -0700
Engine • hash 97bcd50733ba183d436566477a85414db19fdb97 (revision a4ce257c68) (3 months ago) • 2026-06-18 17:14:12.000Z
Tools • Dart 3.12.2 • DevTools 2.57.0
```

### 2. مخرجات `flutter doctor -v`
```text
[√] Flutter (Channel stable, 3.44.3, on Microsoft Windows [Version 10.0.22631.6199], locale en-US) [949ms]
    • Flutter version 3.44.3 on channel stable at C:\flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision e1fd963c6f (4 months ago), 2026-06-18 14:59:18 -0700
    • Engine revision a4ce257c68
    • Dart version 3.12.2
    • DevTools version 2.57.0
    • Feature flags: enable-web, enable-linux-desktop, enable-macos-desktop, enable-windows-desktop, enable-android, enable-ios, cli-animations, enable-native-assets, enable-swift-package-manager, omit-legacy-version-file, enable-lldb-debugging, enable-uiscene-migration

[√] Windows Version (11 Pro 64-bit, 23H2, 2009) [3.2s]

[!] Android toolchain - develop for Android devices (Android SDK version 36.1.0) [1,690ms]
    • Android SDK at C:\Users\DELL35~1\AppData\Local\Android\Sdk
    • Emulator version 37.1.11.0 (build_id 15917651) (CL:N/A)
    • Platform android-36, build-tools 36.1.0
    • Java binary at: C:\Program Files\Java\jdk-17\bin\java
      This JDK is specified in your Flutter configuration.
      To change the current JDK, run: `flutter config --jdk-dir="path/to/jdk"`.
    • Java version Java(TM) SE Runtime Environment (build 17.0.12+8-LTS-286)
    X Android license status unknown.
      Run `flutter doctor --android-licenses` to accept the SDK licenses.
      See https://flutter.dev/to/windows-android-setup for more details.

[√] Chrome - develop for the web [473ms]
    • Chrome at C:\Program Files\Google\Chrome\Application\chrome.exe

[!] Visual Studio - develop Windows apps (Visual Studio Build Tools 2026 18.3.2) [470ms]
    • Visual Studio at C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools
    • Visual Studio Build Tools 2026 version 18.3.11520.95
    X The current Visual Studio installation is incomplete.
      Please use Visual Studio Installer to complete the installation or reinstall Visual Studio.

[√] Connected device (3 available) [412ms]
    • Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.22631.6199]
    • Chrome (web)      • chrome  • web-javascript • Google Chrome 154.0.8037.98
    • Edge (web)        • edge    • web-javascript • Microsoft Edge 154.0.4258.53

[√] Network resources [602ms]
    • All expected network resources are available.

! Doctor found issues in 2 categories.
```

### 3. محتوى `pubspec.yaml` كامل
```yaml
name: met1
description: "MET - Smart Timetable & Student Hub"
publish_to: 'none'

version: 1.0.0+4

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7

  # Local Storage
  shared_preferences: ^2.3.4

  # Notifications
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0

  # System & Utilities
  url_launcher: ^6.3.2
  path_provider: ^2.1.5
  path: ^1.9.0
  package_info_plus: ^8.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/app_logo.png"
  min_sdk_android: 21
  adaptive_icon_background: "#080E24"
  adaptive_icon_foreground: "assets/images/app_logo.png"

flutter:
  uses-material-design: true

  assets:
    - assets/data/
    - assets/images/
```

### 4. مخرجات `flutter pub outdated`
```text
Showing outdated packages.
[*] indicates versions that are not the latest available.

Package Name                                    Current   Upgradable  Resolvable  Latest   

direct dependencies:                           
equatable                                       *2.1.0    *2.1.0      3.0.0       3.0.0    
flutter_local_notifications                     *18.0.1   *18.0.1     22.3.1      22.3.1   
package_info_plus                               *8.3.1    *8.3.1      10.2.2      10.2.2   
shared_preferences                              *2.5.5    2.5.6       2.5.6       2.5.6    
timezone                                        *0.10.1   *0.10.1     0.11.1      0.11.1   
url_launcher                                    *6.3.2    6.3.3       6.3.3       6.3.3    

dev_dependencies: all up-to-date.              

transitive dependencies:                       
clock                                           *1.1.2    *1.1.2      *1.1.2      1.1.3    
code_assets                                     *1.2.1    *1.2.1      *1.2.1      2.1.0    
dbus                                            *0.7.15   *0.7.15     *0.7.15     0.8.0    
ffi_leak_tracker                                -         -           0.1.2       0.1.2    
flutter_local_notifications_linux               *5.0.0    *5.0.0      8.0.1       8.0.1    
flutter_local_notifications_platform_interface  *8.0.0    *8.0.0      12.2.0      12.2.0   
flutter_local_notifications_web                 -         -           1.0.0       1.0.0    
flutter_local_notifications_windows             -         -           3.1.1       3.1.1    
hooks                                           *2.0.2    *2.0.2      *2.0.2      2.2.0    
intl                                            *0.20.2   *0.20.2     *0.20.2     0.20.3   
material_color_utilities                        *0.13.0   *0.13.0     *0.13.0     0.13.1   
meta                                            *1.18.0   *1.18.0     *1.18.0     1.19.0   
objective_c                                     *9.5.0    *9.5.0      *9.5.0      9.6.2    
package_info_plus_platform_interface            *3.2.1    *3.2.1      4.1.0       4.1.0    
petitparser                                     *7.0.2    *7.0.2      *7.0.2      7.1.0    
record_use                                      *0.6.0    *0.6.0      *0.6.0      1.1.1    
vector_math                                     *2.2.0    *2.2.0      *2.2.0      2.4.3    
win32                                           *5.15.0   *5.15.0     6.4.0       6.4.0    
xml                                             *7.0.1    *7.0.1      *7.0.1      7.1.0    

transitive dev_dependencies:                   
cli_util                                        *0.4.2    *0.4.2      *0.4.2      0.6.0    
matcher                                         *0.12.19  *0.12.19    *0.12.19    0.12.20  
stack_trace                                     *1.12.1   *1.12.1     *1.12.1     1.12.2   
test_api                                        *0.7.11   *0.7.11     *0.7.11     0.7.14   

2 upgradable dependencies are locked (in pubspec.lock) to older versions.
To update these dependencies, use `flutter pub upgrade`.

8  dependencies are constrained to versions that are older than a resolvable version.
To update these dependencies, edit pubspec.yaml, or run `flutter pub upgrade --major-versions`.
```

### 5. هل المشروع يستخدم Firebase؟
- **النتيجة:** **لا** (NOT FOUND).
- لا توجد أي حزم Firebase في `pubspec.yaml` أو `pubspec.lock` (لا `firebase_core` ولا `firebase_messaging` ولا `firebase_crashlytics`).

---

## 1) Android

### 1. قيم `android/app/build.gradle.kts`
- **الملف المعتمد:** `android/app/build.gradle.kts` (بصيغة Kotlin DSL)
- **applicationId:** `"com.met.bisschedule"` (سطر 28)
- **namespace:** `"com.met.bisschedule"` (سطر 17)
- **versionCode:** `flutter.versionCode` (سطر 31) [القيمة من `local.properties`: `4`، ومن `pubspec.yaml`: `4`]
- **versionName:** `flutter.versionName` (سطر 32) [القيمة من `local.properties`: `1.0.0`، ومن `pubspec.yaml`: `1.0.0`]
- **minSdk:** `flutter.minSdkVersion` (سطر 29) [الافتراضي في Flutter: 21]
- **targetSdk:** `flutter.targetSdkVersion` (سطر 30) [الافتراضي في Flutter: 34 أو 35]
- **compileSdk:** `flutter.compileSdkVersion` (سطر 18) [الافتراضي في Flutter: 34 أو 35]
- **ndkVersion:** `flutter.ndkVersion` (سطر 19)
- **minifyEnabled (isMinifyEnabled):** `true` (سطر 56)
- **shrinkResources (isShrinkResources):** `true` (سطر 57)
- **signingConfigs كاملة:**
```kotlin
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
```
- **buildTypes.release كامل:**
```kotlin
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
```

### 2. إصدارات AGP و Kotlin و Gradle و google-services plugin
- **AGP (Android Gradle Plugin):** `9.0.1` (`id("com.android.application") version "9.0.1"` في `android/settings.gradle.kts` سطر 22)
- **Kotlin:** `2.3.20` (`id("org.jetbrains.kotlin.android") version "2.3.20"` في `android/settings.gradle.kts` سطر 23)
- **Gradle:** `9.1.0` (من `gradle-9.1.0-all.zip` في `android/gradle/wrapper/gradle-wrapper.properties` سطر 5)
- **google-services plugin:** **NOT FOUND** (غير موجود وغير مطبق في المشروع)

### 3. محتوى `android/gradle/wrapper/gradle-wrapper.properties`
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-9.1.0-all.zip
```

### 4. محتوى ملفات `AndroidManifest.xml`

#### أ) الرئيسي: `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Notification permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <application
        android:label="MET Schedule"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:screenOrientation="portrait"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- flutter_local_notifications: scheduled notification receiver -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

#### ب) الخاص بالـ Debug: `android/app/src/debug/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

#### ج) الخاص بالـ Profile: `android/app/src/profile/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### 5. فحص `android/key.properties`
- **هل الملف موجود؟** **نعم** (موجود محلياً بحجم 97 بايت).
- **هل هو في `.gitignore`؟** **نعم** (مذكور صراحة في `.gitignore` سطر 52: `**/key.properties`).

### 6. فحص `google-services.json`
- **الحالة:** **NOT FOUND** (غير موجود).

### 7. محتوى `android/app/proguard-rules.pro`
```pro
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.google.gson.**
```

### 8. قائمة ملفات الأيقونات في `res/mipmap*` و `drawable*`
- **drawable:**
  - `launch_background.xml`
- **drawable-hdpi:**
  - `ic_launcher_foreground.png`
- **drawable-mdpi:**
  - `ic_launcher_foreground.png`
- **drawable-v21:**
  - `launch_background.xml`
- **drawable-xhdpi:**
  - `ic_launcher_foreground.png`
- **drawable-xxhdpi:**
  - `ic_launcher_foreground.png`
- **drawable-xxxhdpi:**
  - `ic_launcher_foreground.png`
- **mipmap-anydpi-v26:**
  - `launcher_icon.xml`
- **mipmap-hdpi:**
  - `ic_launcher.png`, `launcher_icon.png`
- **mipmap-mdpi:**
  - `ic_launcher.png`, `launcher_icon.png`
- **mipmap-xhdpi:**
  - `ic_launcher.png`, `launcher_icon.png`
- **mipmap-xxhdpi:**
  - `ic_launcher.png`, `launcher_icon.png`
- **mipmap-xxxhdpi:**
  - `ic_launcher.png`, `launcher_icon.png`
- **هل يوجد Adaptive Icon (`ic_launcher.xml` أو `launcher_icon.xml`)؟** **نعم** (`mipmap-anydpi-v26/launcher_icon.xml`).
- **هل توجد أيقونة إشعار مخصصة (`ic_notification` أو ما شابه)؟** **لا** (NOT FOUND).

### 9. محتوى `res/values/strings.xml` و `styles.xml`
- **`res/values/strings.xml`:** **NOT FOUND** (اسم التطبيق معرّف عبر `android:label="MET Schedule"` في الـ Manifest).
- **`res/values/styles.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is off -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```
- **`res/values-night/styles.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is on -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

---

## 2) iOS

### 1. محتوى `ios/Runner/Info.plist` كامل
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CADisableMinimumFrameDurationOnPhone</key>
	<true/>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>MET Schedule</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>MET Schedule</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<false/>
		<key>UISceneConfigurations</key>
		<dict>
			<key>UIWindowSceneSessionRoleApplication</key>
			<array>
				<dict>
					<key>UISceneClassName</key>
					<string>UIWindowScene</string>
					<key>UISceneConfigurationName</key>
					<string>flutter</string>
					<key>UISceneDelegateClassName</key>
					<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
					<key>UISceneStoryboardFile</key>
					<string>Main</string>
				</dict>
			</array>
		</dict>
	</dict>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
	<key>CFBundleLocalizations</key>
	<array>
		<string>ar</string>
		<string>en</string>
	</array>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>https</string>
		<string>http</string>
		<string>tel</string>
		<string>mailto</string>
		<string>whatsapp</string>
	</array>
</dict>
</plist>
```

### 2. محتوى `ios/Runner/Runner.entitlements`
- **الحالة:** **NOT FOUND** (لا يوجد ملف `.entitlements` في مجلد `ios`).

### 3. فحص `ios/Runner/PrivacyInfo.xcprivacy`
- **الحالة:** **NOT FOUND** (غير موجود).

### 4. محتوى `ios/Podfile` كامل
```ruby
platform :ios, '13.0'

# CocoaPods analytics sends network stats which can slow down build.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get has executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig and running flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

### 5. قيم `ios/Runner.xcodeproj/project.pbxproj` المستخرجة
- **PRODUCT_BUNDLE_IDENTIFIER:** `com.met.bisschedule` (وللهدف الاختباري `com.met.bisschedule.RunnerTests`)
- **MARKETING_VERSION:** `1.0`
- **CURRENT_PROJECT_VERSION:** `"$(FLUTTER_BUILD_NUMBER)"` (وللهدف الاختباري `1`)
- **IPHONEOS_DEPLOYMENT_TARGET:** `13.0`
- **DEVELOPMENT_TEAM:** **NOT FOUND** (غير محدد محلياً بالملف، يتم تعيينه عبر Codemagic / Xcode)
- **CODE_SIGN_STYLE:** `Automatic`
- **SWIFT_VERSION:** `5.0`

### 6. فحص `GoogleService-Info.plist`
- **الحالة:** **NOT FOUND** (غير موجود).

### 7. محتوى `ios/Runner/AppDelegate.swift` كامل
```swift
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Ensure foreground notifications (welcome, lecture alarms, test) display properly on iOS 14+
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

### 8. حالة `ios/Runner/Assets.xcassets/AppIcon.appiconset`
- **هل توجد أيقونة 1024x1024؟** **نعم** (`Icon-App-1024x1024@1x.png` بحجم 1,043,683 بايت).
- **هل فيها Alpha Channel (شفافية)؟** **لا** (فحص عبر Python PIL: النمط `RGB` فقط، بدون قناة شفافية No Alpha Channel)، وهي مطابقة تماماً لشروط Apple App Store.

### 9. ملخص `LaunchScreen.storyboard`
- يستخدم واجهة View Controller بسيطة تحتوي على `UIImageView` لعرض `LaunchImage` (168x185) في المنتصف بدقة أفقية ورأسية (`centerX`, `centerY`) وخلفية بيضاء كاملة (`RGB 1, 1, 1`).

---

## 3) Codemagic

- **محتوى `codemagic.yaml`:** **NOT FOUND - بيتم الإعداد من الـ UI**
- **تفاصيل الـ Workflows:**
  - يتم إدارة سير العمل بالكامل عبر لوحة تحكم Codemagic Web UI (Workflow Editor).
  - الـ Code Signing الخاص بـ iOS والنشر المباشر إلى **App Store Connect / TestFlight** يتم إعداده وتمرير شهاداته ومفاتيحه عبر الـ Web UI.
  - بناء وتوقيع حزمة الأندرويد (`AAB`) يتم إعداده عبر الـ Web UI باستخدام متغيرات البيئة للـ Keystore.

---

## 4) الإشعارات

### 1. `FirebaseMessaging.onBackgroundMessage` و `@pragma('vm:entry-point')`
- **الحالة:** **NOT FOUND** (لا يستخدم المشروع Firebase Cloud Messaging إطلاقاً).

### 2. `FirebaseMessaging.onMessage` و `onMessageOpenedApp` و `getInitialMessage`
- **الحالة:** **NOT FOUND**.

### 3. `requestPermission()` (iOS) و `POST_NOTIFICATIONS` (Android 13+)
- **الملف:** `lib/core/services/notification_service.dart` (سطر 96 إلى 132):
```dart
  /// Requests notification permission on iOS and Android 13+.
  /// Returns `true` if granted or if running on Android <= 12 where permission is granted by default.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted == true) return true;
        try {
          final settings = await iosPlugin.checkPermissions();
          return settings?.isAlertEnabled ?? false;
        } catch (_) {
          return granted ?? false;
        }
      }
      return false;
    }

    if (!Platform.isAndroid) return true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;

    try {
      final granted = await androidPlugin.requestNotificationsPermission();
      // On Android <= 12, this returns null because permission is granted at install time.
      if (granted == null) return true;
      return granted;
    } catch (e) {
      debugPrint('[NotificationService] requestNotificationsPermission note: $e');
      return true;
    }
  }
```

### 4. `flutter_local_notifications`: initialize، تعريف القنوات، وأيقونة الإشعار
- **الملف:** `lib/core/services/notification_service.dart` (سطر 36 إلى 88):
```dart
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      );

      await _plugin.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      // Explicitly register notification channels for Android 8.0+
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            description: AppConstants.notificationChannelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'met_welcome_channel',
            'Senior Welcome',
            description: 'Senior 2027 Welcome Notification',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'met_friday_channel',
            'Friday Reminders',
            description: 'Reminders for Friday Sunan and Azkar',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
```
- **أيقونة الإشعار المستخدمة:** `@mipmap/launcher_icon` (في الـ AndroidInitializationSettings).
- **القنوات المعرفة:**
  1. `met_schedule_channel` (اسمها "Class Reminders"، أهمية `Importance.max`)
  2. `met_welcome_channel` (اسمها "Senior Welcome"، أهمية `Importance.max`)
  3. `met_friday_channel` (اسمها "Friday Reminders"، أهمية `Importance.high`)

### 5. `getToken()` و `onTokenRefresh` ومكان إرسال التوكن للسيرفر
- **الحالة:** **NOT FOUND** (لا يوجد سيرفر أو توكنات FCM في التطبيق).

### 6. معالجة الـ payload وفتح الشاشة عند الضغط على الإشعار
- **الحالة:** **NOT FOUND** (دالة `initialize` لا تمرر `onDidReceiveNotificationResponse`، ولا يتم تمرير `payload` مع الإشعارات؛ الضغط على الإشعار يفتح التطبيق للواجهة الرئيسية فقط).

### 7. في `AndroidManifest.xml`: meta-data للقناة والأيقونة الافتراضية
- `com.google.firebase.messaging.default_notification_channel_id`: **NOT FOUND**
- `com.google.firebase.messaging.default_notification_icon`: **NOT FOUND**
- (القنوات معرّفة برمجياً داخل Dart عبر `createNotificationChannel`).

### 8. في iOS: Push Notifications و Background Modes (`remote-notification`)
- `Push Notifications` في Entitlements: **NOT FOUND** (لا يوجد ملف entitlements).
- `UIBackgroundModes` / `remote-notification` في `Info.plist`: **NOT FOUND** (التطبيق يعتمد حصراً على الإشعارات المحلية المجدولة أوفلاين).

### 9. هل الباك إند يرسل إشعارات من كود بالمشروع؟
- **الحالة:** **NOT FOUND** (لا يوجد كود باك إند؛ جميع الإشعارات تُجدول وتُطلق محلياً من داخل التطبيق عبر `NotificationService`).

---

## 5) الأمان

### 1. البحث عن Secrets و API Keys في المشروع كله
- **lib/:** تم الفحص — 0 مفاتيح أو أسرار (خالٍ تماماً).
- **assets/:** تم الفحص — 0 مفاتيح أو أسرار.
- **ios/:** تم الفحص — 0 مفاتيح أو أسرار.
- **android/key.properties:** (ملف إعدادات التوقيع المحلي):
  - سطر 1: `storePassword` (نوعه: Keystore Store Password) -> `[REDACTED]`
  - سطر 2: `keyPassword` (نوعه: Keystore Key Password) -> `[REDACTED]`
  - سطر 3: `keyAlias` (نوعه: Keystore Key Alias) -> `[REDACTED]`
  - سطر 4: `storeFile` (نوعه: Keystore File Path) -> `[REDACTED]`

### 2. هل توجد ملفات `.env` أو `keystore` أو `.p8` أو `google-services` مرفوعة في Git؟
- **فحص `git ls-files`:** النتيجة **فارغة (0 ملفات)**.
- **تغطية `.gitignore`:**
  - سطر 50: `*.keystore`
  - سطر 51: `*.jks`
  - سطر 52: `**/key.properties`
  - جميع المفاتيح والشهادات محمية وغير مضافة للـ Git.

### 3. فحص ثغرات الاتصال الصريح
- `badCertificateCallback`: **NOT FOUND**
- `usesCleartextTraffic`: **NOT FOUND**
- `NSAllowsArbitraryLoads`: **NOT FOUND**
- `http://` (غير https): لم يُعثر على أي روابط استدعاءات API أو سيرفرات عبر `http://`. الرابط الوحيد هو فحص مدخلات روابط الطلاب لفرض `https` في [graduation_project_screen.dart](file:///d:/M/met1/lib/presentation/screens/graduation_project_screen.dart#L57)، ومخطط `http` في `LSApplicationQueriesSchemes` لفتح الروابط الخارجية بـ `url_launcher`.

### 4. تخزين التوكنات (`flutter_secure_storage` مقابل `SharedPreferences`)
- `flutter_secure_storage`: **NOT FOUND** (غير مثبت).
- تخزين التوكنات (Auth Tokens): **لا يوجد توكنات مصادقة أو تسجيل دخول**.
- `SharedPreferences`: يُستخدم فقط لتخزين تفضيلات الطالب المحلية (الفرقة، الشعبة، الوضع الليلي، تفعيل الإشعارات، الغياب والحضور، وبيانات مشروع التخرج محلياً):
  - [notification_service.dart](file:///d:/M/met1/lib/core/services/notification_service.dart)
  - [local_schedule_datasource.dart](file:///d:/M/met1/lib/data/datasources/local_schedule_datasource.dart)
  - [preferences_cubit.dart](file:///d:/M/met1/lib/presentation/bloc/preferences_cubit.dart)
  - [main.dart](file:///d:/M/met1/lib/main.dart)
  - [settings_screen.dart](file:///d:/M/met1/lib/presentation/screens/settings_screen.dart)

### 5. هل أوامر الـ build أو CI تستخدم `--obfuscate` و `--split-debug-info`؟
- **الحالة:** **NOT FOUND** (الأوامر الحالية تستخدم `flutter build apk --release` و `flutter build appbundle`). التعتيم البرمجي مطبق على مستوى كود أندرويد الأصلي من خلال R8/ProGuard في `android/app/build.gradle.kts` (`isMinifyEnabled = true`, `isShrinkResources = true`).

---

## 6) جودة الكود

### 1. مخرجات `flutter analyze` كاملة
```text
Analyzing met1...                                               
No issues found! (ran in 9.1s)
```

### 2. مخرجات `dart fix --dry-run`
```text
Computing fixes in met1 (dry run)...
Nothing to fix!
```

### 3. عدد وأماكن الكلمات المفتاحية في `lib/`
- **`print(`:** **0** (NOT FOUND).
- **`debugPrint(`:** **15** (جميعها في `lib/core/services/notification_service.dart` في أسطر: 90, 129, 167, 197, 279, 287, 289, 323, 354, 371, 373, 457, 500, 546, 549).
- **`TODO`:** **0** (NOT FOUND).
- **`FIXME`:** **0** (NOT FOUND).
- **`"test"` / `'test'`:** **0** (NOT FOUND).
- **`dummy` / `lorem` / `example.com` / `localhost` / `127.0.0.1` / `10.0.2.2`:** **0** (NOT FOUND).

### 4. فحص Controllers و Timers و Streams بدون `dispose`
- **المعالجين المنضبطين بالـ dispose:**
  - `_timer` في [timetable_screen.dart](file:///d:/M/met1/lib/presentation/screens/timetable_screen.dart#L142) -> ملغي في `dispose()`.
  - `_pageController` في [timetable_screen.dart](file:///d:/M/met1/lib/presentation/screens/timetable_screen.dart#L800) -> `dispose()`.
  - `_ticker` في [schedule_card.dart](file:///d:/M/met1/lib/presentation/widgets/schedule_card.dart#L496) -> `cancel()`.
  - المتحكمات الستة في [edit_session_modal.dart](file:///d:/M/met1/lib/presentation/widgets/edit_session_modal.dart#L110-L118) -> `dispose()`.
  - المتحكمات في [splash_screen.dart](file:///d:/M/met1/lib/presentation/screens/splash_screen.dart#L84-L86) و [onboarding_screen.dart](file:///d:/M/met1/lib/presentation/screens/onboarding_screen.dart#L50-L54) -> `dispose()`.
- **ملاحظة Controllers بدون استدعاء `.dispose()` صريح:**
  - في [graduation_project_screen.dart](file:///d:/M/met1/lib/presentation/screens/graduation_project_screen.dart)، يتم إنشاء متحكمات `TextEditingController` داخل دوال إظهار الـ Bottom Sheets المحلية بدون عمل dispose لها عند إغلاق الـ sheet:
    - الأسطر 1259-1263: `nameCtrl`, `trackCtrl`, `docCtrl`, `taCtrl`, `meetCtrl`
    - الأسطر 1413-1414: `titleCtrl`, `urlCtrl`
    - الأسطر 1551-1553: `nameCtrl`, `roleCtrl`, `phoneCtrl`
    - الأسطر 1674-1676: `nameCtrl`, `roleCtrl`, `phoneCtrl`
    - الأسطر 1787-1789: `titleCtrl`, `assignCtrl`, `dateCtrl`

### 5. فحص تفعيل Crashlytics أو Sentry
- **Crashlytics:** **NOT FOUND / غير مفعل**.
- **Sentry:** **NOT FOUND / غير مفعل**.
- **`FlutterError.onError` و `PlatformDispatcher.onError`:** **NOT FOUND / غير معرّفين** في `main.dart`.

### 6. عدد استدعاءات الشبكة (Network Calls)
- **عدد استدعاءات الـ API / HTTP المباشرة:** **0** (التطبيق أوفلاين 100% ويعتمد على JSON محلي مدمج في الـ assets).
- الاستدعاء الخارجي الوحيد هو `launchUrl` من حزمة `url_launcher` لفتح الروابط في المتصفح وتطبيق الهاتف/واتساب، وجميعها محاطة بـ `try/catch`.

### 7. نتائج `flutter test`
```text
00:05 +31: All tests passed!
```
- **إجمالي الاختبارات:** 31 اختباراً ناجحاً بنسبة 100% بدون أي إخفاق.

### 8. حجم فولدر `assets` وأكبر ملفاته وفحص الاستخدام
- **الحجم الإجمالي لفولدر `assets`:** **0.88 ميجابايت** (4 ملفات فقط):
  1. `assets/images/app_logo.png`: 521.8 كيلوبايت (مستخدم في الشاشات وأيقونات التطبيق).
  2. `assets/images/campus_halls_guide.jpg`: 200.6 كيلوبايت (مستخدم في [tools_screen.dart](file:///d:/M/met1/lib/presentation/screens/tools_screen.dart#L372)).
  3. `assets/images/campus_buildings_map.jpg`: 163.4 كيلوبايت (مستخدم في [tools_screen.dart](file:///d:/M/met1/lib/presentation/screens/tools_screen.dart#L358)).
  4. `assets/data/schedule.json`: 18.7 كيلوبايت (مستخدم في [local_schedule_datasource.dart](file:///d:/M/met1/lib/data/datasources/local_schedule_datasource.dart#L24)).
- **الملفات غير المستخدمة (Unused Assets):** **0** (جميع الملفات مستخدمة بالفعل).

---

## 7) الصلاحيات والمتاجر

### 1. الصلاحيات المطلوبة مقارنة بالحزم المستخدمة

#### أ) أندرويد (`AndroidManifest.xml`):
1. `android.permission.POST_NOTIFICATIONS`: لإظهار إشعارات المحاضرات والإشعار الترحيبي على أندرويد 13+ (مطابق لحزمة `flutter_local_notifications`).
2. `android.permission.RECEIVE_BOOT_COMPLETED`: لإعادة جدولة إشعارات المحاضرات بعد إعادة تشغيل الهاتف (مطابق لـ `flutter_local_notifications`).
3. `android.permission.SCHEDULE_EXACT_ALARM`: لإطلاق إشعار المحاضرة بدقة قبل الموعد بـ 10 دقائق (مطابق لـ `flutter_local_notifications`).
4. `android.permission.VIBRATE`: لاهتزاز الهاتف مع التنبيه (مطابق لـ `flutter_local_notifications`).
5. `INTERNET` (في `debug` و `profile` فقط): لتسهيل تصحيح الأخطاء والتطوير (Hot Reload).

#### ب) آبل (`Info.plist`):
- **Usage Descriptions (مثل الكاميرا أو الميكروفون أو الموقع):** **لا توجد أي أذونات مستخدمة أو مطلوبة** (تم حذف حزمة `image_picker` وجميع أذونات الكاميرا والصور نهائياً).
- **LSApplicationQueriesSchemes:** معرّفة لـ `https`, `http`, `tel`, `mailto`, `whatsapp` لعمل `url_launcher`.

#### ج) الصلاحيات الزائدة أو الناقصة:
- لا توجد أي صلاحية ناقصة.
- **ملاحظة متجر Google Play حول `SCHEDULE_EXACT_ALARM`:** يتطلب Google Play من التطبيقات التي تستخدم هذا الإذن توضيح سبب الحاجة إليه في استمارة "Exact Alarm Policy" (تطبيق جدول مواعيد ومنبه محاضرات للطلاب).

### 2. ميزات الخصوصية والحسابات والمتجر
- **تسجيل دخول (Authentication):** **لا يوجد** (التطبيق يفتح مباشرة للجدول بدون تسجيل).
- **تسجيل دخول عبر Google/Facebook/Apple:** **لا يوجد**.
- **حذف الحساب (Account Deletion):** **غير مطلوب** (لا توجد حسابات مستخدمين إطلاقاً وفق سياسة App Store 5.1.1).
- **مدفوعات أو اشتراكات (IAP):** **لا يوجد** (مجاني بالكامل).
- **محتوى تم إنشاؤه بواسطة المستخدمين (UGC) مع Report/Block:** **غير مطلوب** (الملاحظات والمهام تحفظ محلياً على هاتف الطالب فقط في SharedPreferences ولا يتم رفعها أو مشاركتها علناً).
- **إعلانات (AdMob):** **لا يوجد**.
- **تتبع (App Tracking Transparency / ATT):** **لا يوجد**.

### 3. روابط سياسة الخصوصية والشروط
- **رابط سياسة الخصوصية:**
  - `https://mohamed-wagdy-elmasry.github.io/MET-Schedule/privacy/` (معرف في `AppConstants.privacyPolicyUrl` في [app_constants.dart](file:///d:/M/met1/lib/core/constants/app_constants.dart#L14)).
- **رابط الشروط والأحكام (Terms of Service):** **NOT FOUND** (توجد سياسة خصوصية شاملة تشمل بنود الاستخدام، ولا يوجد رابط شروط منفصل).

### 4. اللغات المدعومة والـ Localization
- **اللغات المدعومة:** العربية (`ar`) والإنجليزية (`en`).
- **اللغة الافتراضية:** العربية (RTL).
- **دعم الاتجاهات (RTL/LTR):** مدعوم بالكامل تلقائياً مع تبديل الاتجاه والنصوص في كافة الشاشات.
- **التعريف في iOS:** مسجل في `Info.plist` عبر `CFBundleLocalizations` بالقيمتين `ar` و `en`.

---

## 8) خاتمة التقرير

### 1. أشياء لم أستطع التحقق منها (وسبب ذلك)
1. **بيانات ولوحة تحكم App Store Connect و TestFlight الحالية:** لعدم وجود ربط مباشر بواجهة السيرفر السحابية لآبل من بيئة التطوير المحلية دون متصفح مسجل به الحساب.
2. **بيانات ولوحة تحكم Google Play Console:** لعدم وجود مفاتيح ربط سحابية لـ Play Console محلياً.
3. **إعدادات Codemagic السحابية الدقيقة:** لعدم وجود ملف `codemagic.yaml` في مستودع الكود المحلي (يتم ضبط البناء والشهادات مباشرة عبر واجهة Codemagic UI).

### 2. ملاحظات أمنية وفنية هامة قبل الرفع للمتاجر
1. **Google Play Target SDK:** الكود يعتمد على `targetSdk = flutter.targetSdkVersion`. تم التأكد من أن Flutter 3.44.3 يستهدف تلقائياً SDK 34 أو 35 وهو مطابق لشروط Google Play الإلزامية.
2. **استمارة إذن المنبه الدقيق على Google Play (`SCHEDULE_EXACT_ALARM`):** عند رفع الـ AAB على Google Play Console، يجب ملء استمارة إعلان الإذن وتحديد الفئة كـ "Calendar / Alarm / Timetable application" لأن التطبيق يطلق تنبيهات قبل المحاضرة بـ 10 دقائق.
3. **أيقونة الـ App Store (1024x1024):** الأيقونة تم فحصها والتأكد رسمياً أنها بدون أي قناة شفافية (`No Alpha Channel`)، وهي مطابقة لاشتراطات آبل الصارمة.
4. **تشفير التصدير في iOS (`ITSAppUsesNonExemptEncryption`):** معرّف ومضبوط على `<false/>` في `Info.plist`، مما يعفي التطبيق من استبيان التشفير المعقد في TestFlight والـ App Store.

### 3. أوامر البناء (Build Commands) المستخدمة للمشروع
- **Android App Bundle (للنشر على Google Play):**
  ```bash
  flutter build appbundle --release
  ```
- **Android APK (للتجربة المباشرة والتثبيت على الأجهزة):**
  ```bash
  flutter build apk --release
  ```
- **iOS Archive / IPA (للنشر على App Store Connect عبر Codemagic / Xcode):**
  ```bash
  flutter build ipa --release
  ```
