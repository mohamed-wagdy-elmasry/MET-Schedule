/// Bilingual localisation (Arabic / English) — all strings in one place.
///
/// This is a minimal hand-rolled approach suitable for a single-developer
/// offline app.  For larger teams, consider `intl` code-gen or ARB files.
library;

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  // ── Getter shortcut ──
  String _t(String en, String ar) => isArabic ? ar : en;

  // ── General ──
  String get appName => 'MET';
  String get ok => _t('OK', 'موافق');
  String get cancel => _t('Cancel', 'إلغاء');
  String get save => _t('Save', 'حفظ');
  String get next => _t('Next', 'التالي');
  String get back => _t('Back', 'رجوع');
  String get done => _t('Done', 'تم');
  String get settings => _t('Settings', 'الإعدادات');
  String get language => _t('Language', 'اللغة');
  String get arabic => _t('Arabic', 'العربية');
  String get english => _t('English', 'الإنجليزية');
  String get themeMode => _t('Appearance', 'المظهر');
  String get darkMode => _t('Dark Mode', 'الوضع الليلي');
  String get lightMode => _t('Light Mode', 'الوضع العادي');
  String get themeModeSubtitle => _t(
    'Switch between dark and light appearance',
    'التبديل بين الوضع الليلي والوضع العادي',
  );

  // ── Onboarding ──
  String get welcomeTitle =>
      _t('Welcome to MET Schedule', 'مرحباً بك في جدول MET');
  String get welcomeSubtitle => _t(
    'Your smart companion for BIS 4th Year',
    'رفيقك الذكي للفرقة الرابعة نظم معلومات',
  );
  String get selectGroup => _t('Select Your Group', 'اختر مجموعتك');
  String get selectSection => _t('Select Your Section', 'اختر رقم السكشن');
  String get groupLabel => _t('Group', 'المجموعة');
  String get sectionLabel => _t('Section', 'السكشن');
  String get getStarted => _t('Get Started', 'ابدأ الآن');
  String get letsGo => _t("Let's Go!", 'هيا بنا!');

  // ── Navigation ──
  String get today => _t('Today', 'اليوم');
  String get schedule => _t('Schedule', 'الجدول');
  String get gradProject => _t('Grad Project', 'مشروع التخرج');
  String get tools => _t('Tools', 'الأدوات');
  String get more => _t('More', 'المزيد');

  // ── Timetable ──
  String get todaySchedule => _t("Today's Schedule", 'جدول اليوم');
  String get weeklySchedule => _t('Full Week', 'الأسبوع الكامل');
  String get noClassesToday =>
      _t('No classes today! 🎉', 'لا يوجد محاضرات اليوم! 🎉');
  String get nextClass => _t('Next Class', 'المحاضرة القادمة');
  String get allSections => _t('All Sections', 'جميع السكاشن');
  String get mySchedule => _t('My Schedule', 'جدولي');
  String get lecture => _t('Lecture', 'محاضرة');
  String get lab => _t('Lab', 'عملي');
  String get section => _t('Section', 'سكشن');
  String get project => _t('Project', 'مشروع');
  String get startsIn => _t('Starts in', 'يبدأ بعد');
  String get minutes => _t('min', 'دقيقة');
  String get now => _t('Now', 'الآن');
  String get ended => _t('Ended', 'انتهى');
  String get hall => _t('Hall', 'قاعة');

  // ── Days ──
  String get saturday => _t('Saturday', 'السبت');
  String get sunday => _t('Sunday', 'الأحد');
  String get monday => _t('Monday', 'الاثنين');
  String get tuesday => _t('Tuesday', 'الثلاثاء');
  String get wednesday => _t('Wednesday', 'الأربعاء');
  String get thursday => _t('Thursday', 'الخميس');
  String get friday => _t('Friday', 'الجمعة');

  String dayName(int weekday) {
    // Dart weekday: 1=Mon … 7=Sun.  Map to our Saturday-first order.
    const enDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const arDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final idx = weekday - 1;
    return isArabic ? arDays[idx] : enDays[idx];
  }

  // ── Graduation Project ──
  String get gpTitle => _t('Graduation Project / REST', 'مشاريع التخرج / REST');
  String get gpMilestones => _t('Milestones', 'المراحل');
  String get gpNotes => _t('Weekly Notes', 'الملاحظات الأسبوعية');
  String get gpScheduleDays => _t('Monday & Thursday', 'الاثنين والخميس');
  String get addNote => _t('Add Note', 'إضافة ملاحظة');

  // ── Campus Directory ──
  String get campusDirectory => _t('Campus Directory', 'دليل الحرم الجامعي');
  String get campusDirectoryDesc =>
      _t('Halls, labs & room codes explained', 'شرح أكواد القاعات والمعامل');
  String get floor => _t('Floor', 'الطابق');
  String get capacity => _t('Capacity', 'السعة');

  // ── Attendance ──
  String get attendanceTracker => _t('Attendance Tracker', 'متتبع الحضور');
  String get attended => _t('Attended', 'حضرت');
  String get resetAll => _t('Reset All', 'إعادة تعيين');
  String get resetConfirm =>
      _t('Reset all attendance counters?', 'إعادة تعيين جميع عدادات الحضور؟');

  // ── Notifications ──
  String get notifications => _t('Notifications', 'الإشعارات');
  String get notificationsEnabled => _t('Class Reminders', 'تذكيرات المحاضرات');
  String get notificationsDesc => _t(
    'Get notified 10 min before each class',
    'إشعار قبل كل محاضرة بـ 10 دقائق',
  );
  String get notificationPermission => _t(
    'Please allow notifications to receive class reminders',
    'يرجى السماح بالإشعارات لتلقي تذكيرات المحاضرات',
  );

  // ── Settings ──
  String get currentGroup => _t('Current Group', 'المجموعة الحالية');
  String get currentSection => _t('Current Section', 'السكشن الحالي');
  String get changePreferences => _t('Change', 'تغيير');
  String get about => _t('About', 'حول التطبيق');
  String get version => _t('Version', 'الإصدار');
  String get madeWith => _t(
    'Developed & Crafted by El-Forma ❤️',
    'تم التطوير والتصميم بواسطة El-Forma ❤️',
  );
  String get semester =>
      _t('Semester 1 — 2026/2027', 'الفصل الدراسي الأول — 2026/2027');
  String get department =>
      _t('BIS — 4th Year', 'نظم معلومات الأعمال — الفرقة الرابعة');
}

/// Delegate that provides [AppLocalizations] to the widget tree.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
