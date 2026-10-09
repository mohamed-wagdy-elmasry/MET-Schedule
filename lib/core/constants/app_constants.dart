/// Application-wide constants for MET BIS 4th Year app.
///
/// Central place for all magic values — edit here, not scattered through code.
library;

class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appNameEn = 'MET Schedule';
  static const String appNameAr = 'جدول MET';
  static const String appVersion = '1.0.0'; // Fallback if runtime package info is unavailable
  static const String privacyPolicyUrl =
      'https://mohamed-wagdy-elmasry.github.io/MET-Schedule/privacy/';

  // ── SharedPreferences Keys ──
  static const String prefGroup = 'student_group';
  static const String prefSection = 'student_section';
  static const String prefLocale = 'app_locale';
  static const String prefOnboarded = 'has_onboarded';
  static const String prefAttendance = 'attendance_data';
  static const String prefAbsences = 'absences_data';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefThemeMode = 'app_theme_mode';
  static const String prefPrimaryColor = 'custom_primary_color';
  static const String prefSessionColors = 'custom_session_colors';

  // ── Schedule Asset Path ──
  static const String scheduleAssetPath = 'assets/data/schedule.json';

  // ── Days of Week (ordered Saturday-first as per Egyptian academic week) ──
  static const List<String> daysEn = [
    'saturday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday',
  ];
  static const List<String> daysArDisplay = [
    'السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
  ];
  static const List<String> daysEnDisplay = [
    'Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
  ];

  // ── Notification ──
  static const int notificationLeadMinutes = 10;
  static const String notificationChannelId = 'met_schedule_channel';
  static const String notificationChannelName = 'Class Reminders';
  static const String notificationChannelDesc =
      'Notifications 10 min before each class/lab session';

  // ── Groups ──
  static const List<String> groups = ['A', 'B'];
  static const Map<String, List<int>> groupSections = {
    'A': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
    'B': [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28],
  };

  // ── Session Type Labels ──
  static const Map<String, String> sessionTypeEn = {
    'lecture': 'Lecture',
    'lab': 'Lab',
    'section': 'Section',
    'project': 'Project',
  };
  static const Map<String, String> sessionTypeAr = {
    'lecture': 'محاضرة',
    'lab': 'عملي',
    'section': 'سكشن',
    'project': 'مشروع',
  };
}
