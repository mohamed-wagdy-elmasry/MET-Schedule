/// Calm, minimalist in-app feature discovery & guided tour overlay.
///
/// Features a gentle backdrop dimming, sleek spotlight cutout around target widgets,
/// real directional arrow beak pointers (▲ / ▼) pointing directly to the active section,
/// and automated smooth tab switching across all 4 screens of the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../screens/home_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/schedule_cubit.dart';

class AppTourKeys {
  // ── Tab 0: Timetable (الجدول الدراسي - اليومي والأسبوعي) ──
  static final nextClassCardKey = GlobalKey(debugLabel: 'tour_next_class');
  static final addLectureKey = GlobalKey(debugLabel: 'tour_add_lecture');
  static final scheduleListKey = GlobalKey(debugLabel: 'tour_schedule_list');
  static final viewToggleKey = GlobalKey(debugLabel: 'tour_view_toggle');
  static final weekDaySelectorKey = GlobalKey(debugLabel: 'tour_week_day_selector');
  static final weekScheduleListKey = GlobalKey(debugLabel: 'tour_week_schedule_list');
  static final fridayHubKey = GlobalKey(debugLabel: 'tour_friday_hub');

  // ── Tab 1: Graduation Project (مشروع التخرج) ──
  static final gradProjectKey = GlobalKey(debugLabel: 'tour_grad_header');
  static final gradProjectTabsKey = GlobalKey(debugLabel: 'tour_grad_tabs');

  // ── Tab 2: Campus & Tools (أدوات الحرم والخدمات) ──
  static final campusToolsKey = GlobalKey(debugLabel: 'tour_campus_directory');
  static final attendanceTrackerKey = GlobalKey(debugLabel: 'tour_attendance');
  static final universityPortalsKey = GlobalKey(debugLabel: 'tour_portals');

  // ── Tab 3: Settings (الإعدادات والتخصيص) ──
  static final settingsPrefsKey = GlobalKey(debugLabel: 'tour_settings_prefs');
  static final settingsThemeColorKey = GlobalKey(debugLabel: 'tour_settings_theme');
  static final settingsNotificationsKey = GlobalKey(debugLabel: 'tour_settings_notifications');

  // ── Global: Quick Nav (شريط التنقل) ──
  static final bottomNavKey = GlobalKey(debugLabel: 'tour_bottom_nav');
}

class TourStep {
  final String id;
  final int targetTabIndex; // 0=Timetable, 1=GradProject, 2=Tools, 3=Settings
  final ScheduleViewMode targetViewMode;
  final GlobalKey? targetKey;
  final IconData icon;
  final Color iconColor;
  final String Function(AppLocalizations loc) title;
  final String Function(AppLocalizations loc) description;
  final EdgeInsets padding;
  final double borderRadius;
  final bool preferAbove;

  const TourStep({
    required this.id,
    this.targetTabIndex = 0,
    this.targetViewMode = ScheduleViewMode.today,
    this.targetKey,
    required this.icon,
    this.iconColor = AppTheme.primary,
    required this.title,
    required this.description,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = 16,
    this.preferAbove = false,
  });

  static List<TourStep> defaultSteps() => [
        // ── 1. Next Class Card (Timetable - Today View) ──
        TourStep(
          id: 'next_class',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.nextClassCardKey,
          icon: Icons.access_time_filled_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: (loc) => loc.isArabic
              ? 'المحاضرة أو السكشن القادم'
              : 'Next Class / Section',
          description: (loc) => loc.isArabic
              ? 'بيعرضلك فوراً المحاضرة أو السكشن الحالي والقادم، مع اسم القاعة أو المدرج، المحاضر أو المعيد، والعد التنازلي المتبقي بدقة.'
              : 'Instantly view your upcoming lecture or section with hall number, instructor name, and live countdown.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 2. Add Lecture Button (Timetable - Today View) ──
        TourStep(
          id: 'add_lecture',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.addLectureKey,
          icon: Icons.add_circle_rounded,
          iconColor: const Color(0xFF0284C7),
          title: (loc) => loc.isArabic
              ? 'إضافة وتعديل المحاضرات'
              : 'Add & Edit Custom Sessions',
          description: (loc) => loc.isArabic
              ? 'تقدر من هنا تضيف محاضرة جديدة أو سكشن إضافي لجدولك الدراسي بكل سهولة مع تحديد اليوم والوقت والقاعة.'
              : 'Easily add a new custom lecture or section to your timetable and specify the day, time, and hall.',
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          borderRadius: 14,
        ),

        // ── 3. Schedule Cards List (Timetable - Today View) ──
        TourStep(
          id: 'schedule_list',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.scheduleListKey,
          icon: Icons.view_agenda_rounded,
          iconColor: const Color(0xFF10B981),
          title: (loc) => loc.isArabic
              ? 'جدول اليوم وبطاقات المواد'
              : 'Today\'s Schedule Cards',
          description: (loc) => loc.isArabic
              ? 'قائمة منظمة بكل محاضرات وسكاشن اليوم. اضغط على أي بطاقة لتعديل القاعة أو اسم المحاضر أو تغيير لونها، واسحب لأسفل للخروج.'
              : 'Organized list of today\'s sessions. Tap any card to edit hall or instructor details or change its color.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 18,
          preferAbove: true,
        ),

        // ── 4. Today / Week View Toggle (Timetable - AppBar) ──
        TourStep(
          id: 'view_toggle',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.viewToggleKey,
          icon: Icons.calendar_month_rounded,
          iconColor: const Color(0xFF6C63FF),
          title: (loc) => loc.isArabic
              ? 'التبديل إلى جدول الأسبوع الكامل'
              : 'Today & Full Week Views',
          description: (loc) => loc.isArabic
              ? 'اضغط هنا للتبديل الفوري بين جدول اليوم المعروض وجدول الأسبوع بالكامل لمعاينة كل أيام ومحاضرات الأسبوع.'
              : 'Switch seamlessly between today\'s schedule and the full week view to inspect all your academic days.',
          padding: const EdgeInsets.all(4),
          borderRadius: 12,
        ),

        // ── 5. Week View Day Selector (Timetable - Week View) ──
        TourStep(
          id: 'week_day_selector',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.week,
          targetKey: AppTourKeys.weekDaySelectorKey,
          icon: Icons.calendar_view_week_rounded,
          iconColor: const Color(0xFF0284C7),
          title: (loc) => loc.isArabic
              ? 'شريط اختيار أيام الأسبوع'
              : 'Weekly Days Selector',
          description: (loc) => loc.isArabic
              ? 'تقدر تختار وتتنقل بين أي يوم دراسي (السبت، الأحد، الاثنين، الثلاثاء، الأربعاء، الخميس) للاطلاع على محاضرات اليوم المحدد وعدد ساعاته.'
              : 'Easily select any academic day of the week to preview all its lectures, labs, and schedule details.',
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          borderRadius: 16,
        ),

        // ── 6. Week View Schedule Cards List (Timetable - Week View) ──
        TourStep(
          id: 'week_schedule_list',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.week,
          targetKey: AppTourKeys.weekScheduleListKey,
          icon: Icons.dashboard_outlined,
          iconColor: const Color(0xFF8B5CF6),
          title: (loc) => loc.isArabic
              ? 'جدول اليوم المختار في الأسبوع'
              : 'Selected Day Timetable',
          description: (loc) => loc.isArabic
              ? 'بيعرضلك جدول المحاضرات والسكاشن كاملاً لليوم الذي اخترته، مع إمكانية السحب يميناً ويساراً للتنقل السريع بين الأيام.'
              : 'Displays the complete class list for the selected day with lecture halls and swipeable day navigation.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 18,
          preferAbove: true,
        ),

        // ── 7. Graduation Project Header & Progress (Grad Project Tab) ──
        TourStep(
          id: 'grad_project_header',
          targetTabIndex: 1,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.gradProjectKey,
          icon: Icons.school_rounded,
          iconColor: const Color(0xFF8B5CF6),
          title: (loc) => loc.isArabic
              ? 'مشروع التخرج ونسبة الإنجاز'
              : 'Project Progress & Supervisors',
          description: (loc) => loc.isArabic
              ? 'بطاقة شاملة لمشروع تخرجك توضح عنوان المشروع، اسم الدكتور المشرف والمعيد، ومؤشر نسبة الإنجاز التراكمي.'
              : 'Comprehensive hub displaying your graduation project title, supervisors, and live progress bar.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 22,
        ),

        // ── 8. Graduation Project Workspace Tabs (Grad Project Tab) ──
        TourStep(
          id: 'grad_project_tabs',
          targetTabIndex: 1,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.gradProjectTabsKey,
          icon: Icons.dashboard_customize_rounded,
          iconColor: const Color(0xFFEC4899),
          title: (loc) => loc.isArabic
              ? 'أدوات مساحة عمل المشروع'
              : 'Project Workspace Tools',
          description: (loc) => loc.isArabic
              ? 'أربعة أقسام ذكية: روابط وملفات المشروع (Drive/GitHub)، بيانات فريق العمل وأرقامهم، إدارة وتوزيع المهام، والجدول الزمني للمناقشة.'
              : 'Four workspaces: Project Links & Drive, Team members & WhatsApp, Task management, and Defense timeline.',
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          borderRadius: 16,
        ),

        // ── 9. Campus Directory & Room Codes (Tools Tab) ──
        TourStep(
          id: 'campus_directory',
          targetTabIndex: 2,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.campusToolsKey,
          icon: Icons.map_rounded,
          iconColor: const Color(0xFF0284C7),
          title: (loc) => loc.isArabic
              ? 'دليل الحرم الجامعي وأكواد القاعات'
              : 'Campus Directory & Maps',
          description: (loc) => loc.isArabic
              ? 'خرائط المعهد الرسمية، شرح مباني الكلية، ونظام أكواد وترقيم القاعات والمدرجات والمعامل للوصول السريع.'
              : 'Official campus maps, building layouts, and room/hall codes for fast navigation across campus.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 10. Attendance Tracker (Tools Tab) ──
        TourStep(
          id: 'attendance_tracker',
          targetTabIndex: 2,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.attendanceTrackerKey,
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF10B981),
          title: (loc) => loc.isArabic
              ? 'متتبع الحضور والغياب'
              : 'Attendance & Absence Tracker',
          description: (loc) => loc.isArabic
              ? 'سجّل حضورك وغيابك في المحاضرات والسكاشن أولاً بأول لتتبع النسبة المئوية وتفادي الإنذارات والغياب.'
              : 'Record your attendance for every lecture and lab to monitor absence percentages and stay safe.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 11. University Portals & Friday Hub (Tools Tab) ──
        TourStep(
          id: 'university_portals',
          targetTabIndex: 2,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.universityPortalsKey,
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF3B82F6),
          title: (loc) => loc.isArabic
              ? 'منصات المعهد وسنن الجمعة'
              : 'Student Portals & Friday Hub',
          description: (loc) => loc.isArabic
              ? 'روابط مباشرة للمنصة التعليمية، منصة الامتحانات، نظام ابن الهيثم، ومركز سنن وأذكار يوم الجمعة وسورة الكهف.'
              : 'Direct links to university portal, exam platform, Ibn Al-Haytham system, and blessed Friday hub.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 12. Department & Section Preferences (Settings Tab) ──
        TourStep(
          id: 'settings_prefs',
          targetTabIndex: 3,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.settingsPrefsKey,
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF6C63FF),
          title: (loc) => loc.isArabic
              ? 'تعديل الشعبة والفرقة والسكشن'
              : 'Department & Section Settings',
          description: (loc) => loc.isArabic
              ? 'تقدر تغير شعبتك ومجموعتك ورقم السكشن في أي وقت بضغطة زر واحدة وتحديث الجدول فورياً.'
              : 'Change your department, group, or section anytime to instantly update your personalized schedule.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 13. Theme & Color Customization (Settings Tab) ──
        TourStep(
          id: 'settings_theme_color',
          targetTabIndex: 3,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.settingsThemeColorKey,
          icon: Icons.palette_rounded,
          iconColor: const Color(0xFFEC4899),
          title: (loc) => loc.isArabic
              ? 'تخصيص الألوان والمظهر'
              : 'Theme Mode & Color Palette',
          description: (loc) => loc.isArabic
              ? 'التبديل بين الوضع الليلي المريح والفاتح، واختيار ألوانك المفضلة للمحاضرات والسكاشن والمعامل.'
              : 'Switch between dark and light modes, and customize the accent colors for lectures and labs.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 14. Smart Notifications & Reminders (Settings Tab) ──
        TourStep(
          id: 'settings_notifications',
          targetTabIndex: 3,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.settingsNotificationsKey,
          icon: Icons.notifications_active_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: (loc) => loc.isArabic
              ? 'التنبيهات والإشعارات الذكية'
              : 'Smart Reminders & Notifications',
          description: (loc) => loc.isArabic
              ? 'فعّل التنبيهات التلقائية لتصلك إشعارات قبل بدء كل محاضرة وسكشن وتنبيه سنن الجمعة لتظل دائماً في الموعد.'
              : 'Enable smart notifications before each lecture starts and spiritual Friday reminders.',
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          borderRadius: 20,
        ),

        // ── 15. Bottom Navigation Bar (Global) ──
        TourStep(
          id: 'bottom_nav',
          targetTabIndex: 0,
          targetViewMode: ScheduleViewMode.today,
          targetKey: AppTourKeys.bottomNavKey,
          icon: Icons.explore_rounded,
          iconColor: const Color(0xFF3B82F6),
          title: (loc) => loc.isArabic
              ? 'شريط التنقل السريع'
              : 'Quick Navigation Bar',
          description: (loc) => loc.isArabic
              ? 'تنقل بلمسة واحدة بين جدولك الدراسي، مساحة مشروع التخرج، أدوات الحرم، والإعدادات في أي وقت.'
              : 'Effortlessly jump between your schedule, graduation project, tools, and settings from here.',
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          borderRadius: 24,
          preferAbove: true,
        ),
      ];
}

class FeatureTourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const FeatureTourOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  });

  /// Check if the student has already seen the in-app guided tour
  static Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_inapp_feature_tour_v8') ?? false;
  }

  /// Mark the in-app tour as seen in SharedPreferences
  static Future<void> markTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_inapp_feature_tour_v8', true);
  }

  /// Reset the in-app tour flag so it can be replayed
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_inapp_feature_tour_v8', false);
  }

  @override
  State<FeatureTourOverlay> createState() => _FeatureTourOverlayState();
}

class _FeatureTourOverlayState extends State<FeatureTourOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );
    _animCtrl.forward();

    // Ensure we start on the correct tab and scroll to first target
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareStep(_currentStepIndex);
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _syncTabWithStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < widget.steps.length) {
      final step = widget.steps[stepIndex];
      HomeScreen.switchTab(context, step.targetTabIndex);
      try {
        context.read<ScheduleCubit>().setViewMode(step.targetViewMode);
      } catch (_) {}
    }
  }

  Future<void> _prepareStep(int stepIndex) async {
    if (stepIndex < 0 || stepIndex >= widget.steps.length) return;
    final step = widget.steps[stepIndex];
    _syncTabWithStep(stepIndex);

    // Brief frame for tab switch & layout
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (step.targetKey?.currentContext != null) {
      try {
        await Scrollable.ensureVisible(
          step.targetKey!.currentContext!,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: 0.35,
        );
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _currentStepIndex = stepIndex);
      _animCtrl.reset();
      _animCtrl.forward();
    }
  }

  Rect? _getTargetRect(GlobalKey? key, EdgeInsets padding) {
    if (key == null || key.currentContext == null) return null;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || !renderBox.attached) {
      return null;
    }
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      offset.dx - padding.left,
      offset.dy - padding.top,
      size.width + padding.horizontal,
      size.height + padding.vertical,
    );
  }

  Future<void> _nextStep() async {
    HapticFeedback.lightImpact();
    if (_currentStepIndex < widget.steps.length - 1) {
      final nextIndex = _currentStepIndex + 1;
      await _prepareStep(nextIndex);
    } else {
      FeatureTourOverlay.markTourSeen();
      try {
        context.read<ScheduleCubit>().setViewMode(ScheduleViewMode.today);
      } catch (_) {}
      widget.onComplete();
    }
  }

  Future<void> _prevStep() async {
    HapticFeedback.lightImpact();
    if (_currentStepIndex > 0) {
      final prevIndex = _currentStepIndex - 1;
      await _prepareStep(prevIndex);
    }
  }

  void _skip() {
    HapticFeedback.mediumImpact();
    FeatureTourOverlay.markTourSeen();
    try {
      context.read<ScheduleCubit>().setViewMode(ScheduleViewMode.today);
    } catch (_) {}
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);
    final screenSize = MediaQuery.of(context).size;
    final step = widget.steps[_currentStepIndex];
    final targetRect = _getTargetRect(step.targetKey, step.padding);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── 1. Soft Gentle Spotlight Dimmed Background ──
          RepaintBoundary(
            child: CustomPaint(
              size: screenSize,
              painter: _CalmSpotlightPainter(
                targetRect: targetRect,
                borderRadius: step.borderRadius,
                accentColor: step.iconColor,
                isDark: isDark,
              ),
            ),
          ),

          // ── 2. Tap Outside Area to Advance ──
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextStep,
              child: const SizedBox.expand(),
            ),
          ),

          // ── 3. Floating Pointer Bubble with Directional Arrow (▲ / ▼) ──
          _buildArrowCalloutCard(
            context: context,
            step: step,
            targetRect: targetRect,
            screenSize: screenSize,
            loc: loc,
            isArabic: isArabic,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowCalloutCard({
    required BuildContext context,
    required TourStep step,
    required Rect? targetRect,
    required Size screenSize,
    required AppLocalizations loc,
    required bool isArabic,
    required bool isDark,
  }) {
    final totalSteps = widget.steps.length;
    final isLastStep = _currentStepIndex == totalSteps - 1;

    double? top;
    double? bottom;
    bool isAboveTarget = false;

    if (targetRect == null) {
      // Safe fallback in upper center
      top = screenSize.height * 0.30;
    } else {
      final targetCenterY = targetRect.center.dy;
      if (step.preferAbove || targetCenterY > screenSize.height * 0.50) {
        // Render ABOVE the target with downward arrow (▼)
        isAboveTarget = true;
        bottom = (screenSize.height - targetRect.top) + 10;
        if (bottom > screenSize.height - 230) {
          bottom = screenSize.height * 0.40;
        }
      } else {
        // Render BELOW the target with upward arrow (▲)
        isAboveTarget = false;
        top = targetRect.bottom + 10;
        if (top > screenSize.height - 260) {
          top = screenSize.height * 0.35;
        }
      }
    }

    // Precise horizontal offset for the triangle pointer relative to the card's left edge (card left is 16)
    final targetCenterX = targetRect?.center.dx ?? screenSize.width / 2;
    final arrowRelativeX = (targetCenterX - 16.0 - 9.0).clamp(12.0, screenSize.width - 32.0 - 30.0);

    return Positioned(
      top: top,
      bottom: bottom,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {}, // Prevent taps inside card from closing
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── UPWARD ARROW (When card is below target) ──
              if (!isAboveTarget && targetRect != null)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: arrowRelativeX),
                      child: CustomPaint(
                        size: const Size(18, 10),
                        painter: _TriangleArrowPainter(
                          isPointingUp: true,
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderColor: step.iconColor.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── CARD BODY ──
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: step.iconColor.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: step.iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Step indicator + Title + Skip
                    Row(
                      children: [
                        // Icon in soft circular badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: step.iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(step.icon, color: step.iconColor, size: 17),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title(loc),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                              Text(
                                isArabic
                                    ? 'خطوة ${_currentStepIndex + 1} من $totalSteps'
                                    : 'Step ${_currentStepIndex + 1} of $totalSteps',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: step.iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Skip button
                        GestureDetector(
                          onTap: _skip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  loc.skip,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getTextSecondary(context),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.close_rounded,
                                  size: 13,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Description Body
                    Text(
                      step.description(loc),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Bottom Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Button (Arrow points to the LEFT)
                        if (_currentStepIndex > 0)
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _prevStep,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFCBD5E1),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded, // Points LEFT ←
                                    size: 13,
                                    color: AppTheme.getTextPrimary(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    loc.previous,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getTextPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Step dots
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(totalSteps, (i) {
                            final isActive = i == _currentStepIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              width: isActive ? 12 : 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? step.iconColor
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),

                        // Next / Complete Button (Arrow points to the RIGHT)
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: step.iconColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLastStep ? loc.gotIt : loc.next,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isLastStep
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded, // Points RIGHT →
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── DOWNWARD ARROW (When card is above target) ──
              if (isAboveTarget && targetRect != null)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: arrowRelativeX),
                      child: CustomPaint(
                        size: const Size(18, 10),
                        painter: _TriangleArrowPainter(
                          isPointingUp: false,
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderColor: step.iconColor.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the calm, non-intrusive spotlight dimmed backdrop.
class _CalmSpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double borderRadius;
  final Color accentColor;
  final bool isDark;

  _CalmSpotlightPainter({
    required this.targetRect,
    required this.borderRadius,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    if (targetRect == null) {
      canvas.drawRect(
        fullRect,
        Paint()..color = const Color(0x65000000),
      );
      return;
    }

    final targetRRect = RRect.fromRectAndRadius(
      targetRect!,
      Radius.circular(borderRadius),
    );

    // 1. Gentle Cutout Mask
    final maskPath = Path()
      ..addRect(fullRect)
      ..addRRect(targetRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      maskPath,
      Paint()..color = isDark ? const Color(0x75080E1A) : const Color(0x55000000),
    );

    // 2. Soft Accent Border around the spotlight
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawRRect(targetRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CalmSpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}

/// Custom painter for drawing a sharp triangle beak pointer attached to the bubble.
class _TriangleArrowPainter extends CustomPainter {
  final bool isPointingUp;
  final Color color;
  final Color borderColor;

  _TriangleArrowPainter({
    required this.isPointingUp,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (isPointingUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _TriangleArrowPainter oldDelegate) {
    return oldDelegate.isPointingUp != isPointingUp ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor;
  }
}
