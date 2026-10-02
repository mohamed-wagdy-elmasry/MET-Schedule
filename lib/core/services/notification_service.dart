/// Offline notification service — schedules weekly recurring alarms
/// 10 minutes before each class using `flutter_local_notifications`.
///
/// Handles Android 13+ permission requests, test notifications, and Friday reminders.
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      );

      await _plugin.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      _initialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  /// Requests notification permission on Android 13+.
  /// Returns `true` if granted.
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;

    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
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
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

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
    } catch (e) {
      debugPrint('[NotificationService] Failed to schedule #$id: $e');
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
    return mapping[day];
  }

  /// Sends an immediate welcome notification for Senior 2027 upon first setup/launch.
  Future<void> showSeniorWelcomeNotification() async {
    try {
      await init();
      final granted = await requestPermission();
      if (!granted) return;

      const androidDetails = AndroidNotificationDetails(
        'met_welcome_channel',
        'Senior Welcome',
        channelDescription: 'Senior 2027 Welcome Notification',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          'أهلاً بك يا بطل في سنتك الأخيرة! 🎉✨ نتمنى لك فصلاً دراسياً موفقاً ومليئاً بالإنجازات والتخرج بامتياز إن شاء الله! 🥳🎓🚀',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _plugin.show(
        2027,
        'Senior 2027 🎓🎉 | مرحباً بك',
        'نتمنى لك فصلاً دراسياً موفقاً وتخرجاً بامتياز إن شاء الله! 🥳🚀',
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
    } catch (e) {
      debugPrint('[NotificationService] Error showing welcome notification: $e');
    }
  }
}
