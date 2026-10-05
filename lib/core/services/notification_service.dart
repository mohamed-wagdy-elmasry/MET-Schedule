/// Offline notification service — schedules weekly recurring alarms
/// 10 minutes before each class using `flutter_local_notifications`.
///
/// Handles Android 13+ permission requests, test notifications, and Friday reminders.
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../domain/entities/schedule_entry.dart';
import '../constants/app_constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialise the plugin + timezone database. Call once from `main()`.
  Future<void> init() async {
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();
      // Cairo timezone for Egypt
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      } catch (_) {
        // Fallback to local
      }

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

      _initialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

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

  /// Checks whether exact alarms are permitted (Android 12+).
  /// On Android 11 or lower, returns true.
  Future<bool> canScheduleExactNotifications() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return true;
    try {
      final canExact = await androidPlugin.canScheduleExactNotifications();
      return canExact ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Requests exact alarms permission on Android 13/14+.
  Future<bool> requestExactAlarmsPermission() async {
    if (!Platform.isAndroid) return true;
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;
    return await androidPlugin.requestExactAlarmsPermission() ?? false;
  }

  /// Sends an immediate test notification to verify notification permissions and display.
  Future<bool> showInstantTestNotification({
    String title = 'MET Schedule 🔔',
    String body = 'هذا إشعار تجريبي! نظام الإشعارات يعمل بنجاح وبدقة 100% ✨',
  }) async {
    try {
      await init();
      final granted = await requestPermission();
      if (!granted) {
        debugPrint('[NotificationService] Notification permission not granted');
      }

      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      );

      await _plugin.show(
        9999,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Error showing test notification: $e');
      return false;
    }
  }

  /// Schedules Friday morning reminder for Surah Al-Kahf and Salawat.
  Future<void> scheduleFridayReminder() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0); // 09:00 AM

      while (scheduled.weekday != DateTime.friday) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 7));
      }

      const androidDetails = AndroidNotificationDetails(
        'met_friday_channel',
        'Friday Reminders',
        channelDescription: 'Reminders for Friday Sunan and Azkar',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          '📖 قراءة سورة الكهف • 📿 الإكثار من الصلاة على النبي ﷺ • 🤲 تحري ساعة الاستجابة',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      );

      await _plugin.zonedSchedule(
        7777,
        'جمعة مباركة 🌸 | سنن يوم الجمعة',
        '📖 قراءة سورة الكهف • 📿 الصلاة على النبي ﷺ • 🤲 تحري ساعة الاستجابة',
        scheduled,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling Friday reminder: $e');
    }
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      debugPrint('[NotificationService] All notifications cancelled');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling notifications: $e');
    }
  }

  /// Schedules weekly recurring notifications for every entry in [entries].
  Future<void> scheduleAllNotifications(List<ScheduleEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
      if (!enabled) {
        await cancelAll();
        return;
      }

      await init();
      final granted = await requestPermission();
      if (!granted) {
        debugPrint('[NotificationService] Cannot schedule: Permission not granted');
        return;
      }

      // Cancel all existing before re-scheduling to avoid duplicates.
      await _plugin.cancelAll();

      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.type == 'rest' || entry.type == 'project') continue;
        await _scheduleWeekly(entry, i);
      }

      await scheduleFridayReminder();
      debugPrint('[NotificationService] Scheduled ${entries.length} weekly notifications + Friday reminder');
    } catch (e, stack) {
      debugPrint('[NotificationService] Error scheduling notifications: $e\n$stack');
    }
  }

  /// Schedules a single weekly recurring notification.
  Future<void> _scheduleWeekly(ScheduleEntry entry, int id) async {
    final (hour, minute) = entry.startTimeParts;

    // Subtract 10 minutes for the reminder
    var reminderMinute = minute - AppConstants.notificationLeadMinutes;
    var reminderHour = hour;
    if (reminderMinute < 0) {
      reminderMinute += 60;
      reminderHour -= 1;
    }
    if (reminderHour < 0) {
      reminderHour += 24;
    }

    final dartWeekday = _dayToWeekday(entry.day);
    if (dartWeekday == null) return;

    final scheduledDate = _nextInstanceOfWeekday(
      dartWeekday,
      reminderHour,
      reminderMinute,
    );

    // Build notification body — bilingual
    final title = '${entry.subjectNameAr} | ${entry.subjectNameEn}';
    final body =
        '📍 ${entry.locationNameAr} • ${entry.instructorNameAr}\n'
        '⏰ ${entry.startTime} – ${entry.endTime}';

    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );

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
  }

  /// Gets the next occurrence of [weekday] at [hour]:[minute].
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Move to the correct weekday
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // If it's already passed this week, move to next week
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }

  /// Maps our day key to Dart's DateTime.weekday (1=Mon, 7=Sun).
  int? _dayToWeekday(String day) {
    const mapping = {
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
    };
    return mapping[day.toLowerCase().trim()];
  }

  /// Sends an immediate welcome notification for Senior 2027 upon first setup/launch.
  Future<bool> showSeniorWelcomeNotification({bool? isArabic}) async {
    try {
      await init();
      final granted = await requestPermission();
      if (!granted) {
        debugPrint('[NotificationService] Welcome notification skipped: Permission not granted');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final ar = isArabic ?? (prefs.getString('selected_locale') ?? 'ar') == 'ar';

      final title = ar ? 'Senior 2027 🎓🎉 | مرحباً بك' : 'Senior 2027 🎓🎉 | Welcome!';
      final body = ar
          ? 'نتمنى لك فصلاً دراسياً موفقاً وتخرجاً بامتياز إن شاء الله! 🥳🚀'
          : 'Wishing you a successful semester and graduating with honors! 🥳🚀';
      final bigText = ar
          ? 'أهلاً بك يا بطل في سنتك الأخيرة! 🎉✨ نتمنى لك فصلاً دراسياً موفقاً ومليئاً بالإنجازات والتخرج بامتياز إن شاء الله! 🥳🎓🚀'
          : 'Welcome to your senior year! 🎉✨ Wishing you a great semester full of achievements and graduation with honors! 🥳🎓🚀';

      final androidDetails = AndroidNotificationDetails(
        'met_welcome_channel',
        'Senior Welcome',
        channelDescription: 'Senior 2027 Welcome Notification',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(bigText),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      );

      await _plugin.show(
        2027,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
      debugPrint('[NotificationService] Senior welcome notification sent successfully');
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Error showing welcome notification: $e');
      return false;
    }
  }

  /// Automatically displays the Senior 2027 welcome notification on the user's first launch.
  Future<void> checkAndShowSeniorWelcomeOnFirstLaunch([SharedPreferences? prefs]) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    const key = 'has_shown_senior_welcome_v2';
    final alreadyShown = sp.getBool(key) ?? false;
    if (alreadyShown) return;

    final isAr = (sp.getString('selected_locale') ?? 'ar') == 'ar';
    final sent = await showSeniorWelcomeNotification(isArabic: isAr);
    if (sent) {
      await sp.setBool(key, true);
    }
  }
}
