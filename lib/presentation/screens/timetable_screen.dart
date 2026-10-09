/// Timetable screen — shows Today's Schedule or Full Week view.
/// Features dedicated Friday spiritual hub, smart cross-day countdown,
/// and smooth custom pill tab weekly navigation in both Dark and Light modes.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/schedule_entry.dart';
import '../bloc/schedule_cubit.dart';
import '../bloc/preferences_cubit.dart';
import '../widgets/friday_hub_widget.dart';
import '../widgets/schedule_card.dart';
import '../widgets/edit_session_modal.dart';
import '../widgets/feature_tour_overlay.dart';
import 'home_screen.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          final loc = AppLocalizations.of(context);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(
                    loc.loadError,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getTextSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final prefs = context.read<PreferencesCubit>().state;
                      context.read<ScheduleCubit>().loadSchedule(prefs.group, prefs.section);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      loc.retry,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.viewMode == ScheduleViewMode.today) {
          return _TodayView(state: state);
        } else {
          return _WeekView(state: state);
        }
      },
    );
  }
}

// ── Today View ──

class _TodayView extends StatefulWidget {
  final ScheduleState state;
  const _TodayView({required this.state});

  @override
  State<_TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<_TodayView> with WidgetsBindingObserver {
  Timer? _timer;
  bool _showCompletedClasses = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // Live timer ticking every 60 seconds to refresh time-based state smoothly
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        context.read<ScheduleCubit>().refreshNextClass();
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<ScheduleCubit>().refreshNextClass();
        setState(() {});
      }
      _startTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  bool _isSchoolDayFinished(List<ScheduleEntry> entries) {
    if (entries.isEmpty) return false;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // Determine the latest scheduled end time across all sessions today (including project/rest)
    int maxEndMinutes = 0;
    for (final entry in entries) {
      final (h, m) = entry.endTimeParts;
      final endMinutes = h * 60 + m;
      if (endMinutes > maxEndMinutes) {
        maxEndMinutes = endMinutes;
      }
    }

    // If today's latest session has ended
    if (maxEndMinutes > 0 && nowMinutes >= maxEndMinutes) {
      return true;
    }

    // After 5:00 PM (17:00), academic college day is definitively finished
    if (nowMinutes >= 17 * 60) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final loc = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesCubit>().state;
    final isDark = AppTheme.isDark(context);

    // If guided tour is active, show an active full academic day preview (e.g. Saturday) so all elements are present
    final isTour = HomeScreen.isTourActive;
    final effectiveDay = isTour && (state.isFriday || state.todayEntries.isEmpty)
        ? 'saturday'
        : state.currentDay;
    final effectiveTodayEntries = isTour && (state.isFriday || state.todayEntries.isEmpty)
        ? (state.weekEntries['saturday'] ?? state.todayEntries)
        : state.todayEntries;
    final effectiveNextClass = isTour && (state.nextClass == null || state.isFriday) && effectiveTodayEntries.isNotEmpty
        ? effectiveTodayEntries.firstWhere(
            (e) => e.type != 'rest' && e.type != 'project',
            orElse: () => effectiveTodayEntries.first,
          )
        : state.nextClass;
    final effectiveNextClassDay = isTour && (state.nextClass == null || state.isFriday)
        ? 'saturday'
        : state.nextClassDay;
    final isDayFinished = isTour ? false : _isSchoolDayFinished(effectiveTodayEntries);

    // ── Dedicated Friday View ──
    if (state.isFriday && !isTour) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  _InfoChip(
                    icon: Icons.groups_rounded,
                    label: '${loc.groupLabel} ${prefs.group}',
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.tag_rounded,
                    label: '${loc.sectionLabel} ${prefs.section}',
                    color: isDark ? AppTheme.accent : AppTheme.labColorLight,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withValues(alpha: isDark ? 0.15 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF00B894).withValues(alpha: isDark ? 0.3 : 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.spa_rounded, size: 14, color: Color(0xFF00B894)),
                        const SizedBox(width: 4),
                        Text(
                          loc.isArabic ? 'يوم الجمعة' : 'Friday',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00B894),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: KeyedSubtree(
              key: AppTourKeys.fridayHubKey,
              child: FridayHubWidget(
                upcomingSaturdayEntries: state.weekEntries['saturday'] ?? [],
                onPreviewSaturday: () {
                  context.read<ScheduleCubit>().selectWeekDay(0);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      );
    }

    // ── Regular Academic Day View ──
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.todaySchedule,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _dayDisplayLabel(effectiveDay, loc),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    // High-tech Add Lecture Button
                    KeyedSubtree(
                      key: AppTourKeys.addLectureKey,
                      child: GestureDetector(
                        onTap: () => EditSessionModal.show(
                          context,
                          initialDay: effectiveDay,
                          initialGroup: prefs.group,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary,
                                isDark ? AppTheme.primaryLight : AppTheme.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                loc.isArabic ? 'إضافة محاضرة' : 'Add Lecture',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.bgCard.withValues(alpha: 0.6) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.groups_rounded,
                          label: '${loc.groupLabel} ${prefs.group}',
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.tag_rounded,
                          label: '${loc.sectionLabel} ${prefs.section}',
                          color: isDark ? AppTheme.accent : const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.event_note_rounded,
                          label: '${state.todayEntries.length} ${loc.isArabic ? "محاضرات" : "classes"}',
                          color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // If the school day has finished today:
        if (isDayFinished && !_showCompletedClasses)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF64748B).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                            (isDark ? AppTheme.accent : AppTheme.primary).withValues(alpha: isDark ? 0.15 : 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text('🎉', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.isArabic ? 'تم الانتهاء من اليوم الدراسي' : 'School Day Completed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.isArabic
                          ? 'انتهت جميع المحاضرات والسكاشن المقررة لهذا اليوم.\nأحسنت عملاً ونتمنى لك وقتاً ممتعاً وإنجازاً موفقاً! ✨'
                          : 'All classes and sections for today have ended.\nWell done and enjoy your time! ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    if (state.nextClass != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.bgDark.withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: isDark ? 0.20 : 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.next_plan_rounded, size: 20, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.isArabic
                                        ? 'موعدك القادم (${_dayDisplayLabel(state.nextClassDay ?? '', loc)})'
                                        : 'Next Session (${_dayDisplayLabel(state.nextClassDay ?? '', loc)})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.nextClass!.subjectName(loc.isArabic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.getTextPrimary(context),
                                    ),
                                  ),
                                  Text(
                                    '${state.nextClass!.startTime} • ${state.nextClass!.locationName(loc.isArabic)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.getTextSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.read<ScheduleCubit>().toggleView(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: const Icon(Icons.calendar_view_week_rounded, size: 16),
                          label: Text(
                            loc.isArabic ? 'جدول الأسبوع' : 'Full Week',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _showCompletedClasses = true),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          icon: const Icon(Icons.history_rounded, size: 16),
                          label: Text(
                            loc.isArabic ? 'عرض حصيلة اليوم' : 'Today Summary',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // Smart Next Class Hero (only shown if the next class is TODAY or in Tour preview)
          if (effectiveNextClass != null && (effectiveNextClassDay == effectiveDay || isTour)) ...[
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: AppTourKeys.nextClassCardKey,
                child: NextClassCard(
                  entry: effectiveNextClass,
                  currentDay: effectiveDay,
                  targetDay: effectiveNextClassDay ?? effectiveDay,
                ),
              ),
            ),
            // Distinct Separator between Next Class Hero and Daily Schedule List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.bgCard : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.format_list_bulleted_rounded,
                              size: 13,
                              color: isDark ? AppTheme.accent : AppTheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              loc.isArabic ? 'جدول محاضرات اليوم الكامل' : "Today's Full Schedule",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (_showCompletedClasses)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.isArabic ? 'محاضرات اليوم المنتهية:' : 'Completed classes for today:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _showCompletedClasses = false),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
                      label: Text(
                        loc.isArabic ? 'إخفاء' : 'Hide',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Today's Classes List
          if (state.todayEntries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(28),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.bgCard.withValues(alpha: 0.6) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64748B).withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                        ),
                        child: const Center(
                          child: Text('🎉', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.isArabic ? 'لا توجد محاضرات اليوم!' : loc.noClassesToday,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.isArabic
                            ? 'استمتع بيومك في المذاكرة أو الراحة والعمل على مشروع التخرج ☕'
                            : 'Enjoy your day resting or studying!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => EditSessionModal.show(
                          context,
                          initialDay: state.currentDay,
                          initialGroup: prefs.group,
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          loc.isArabic ? 'إضافة محاضرة جديدة' : 'Add New Lecture',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = effectiveTodayEntries[index];
                  final card = ScheduleCard(
                    entry: entry,
                    isHighlighted: !entry.isForAllSections,
                    preferences: prefs,
                  );
                  return index == 0
                      ? KeyedSubtree(
                          key: AppTourKeys.scheduleListKey,
                          child: card,
                        )
                      : card;
                },
                childCount: effectiveTodayEntries.length,
              ),
            ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  String _dayDisplayLabel(String dayKey, AppLocalizations loc) {
    if (dayKey == 'friday') return loc.friday;
    final idx = AppConstants.daysEn.indexOf(dayKey);
    if (idx < 0) return dayKey;
    return loc.isArabic
        ? AppConstants.daysArDisplay[idx]
        : AppConstants.daysEnDisplay[idx];
  }
}

// ── Week View (Custom Pill Tabs + PageView) ──

class _WeekView extends StatefulWidget {
  final ScheduleState state;
  const _WeekView({required this.state});

  @override
  State<_WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<_WeekView> {
  late PageController _pageController;
  late int _selectedDayIdx;

  @override
  void initState() {
    super.initState();
    _selectedDayIdx = widget.state.selectedWeekDayIndex;
    _pageController = PageController(initialPage: _selectedDayIdx);
  }

  @override
  void didUpdateWidget(covariant _WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedWeekDayIndex != widget.state.selectedWeekDayIndex) {
      _selectedDayIdx = widget.state.selectedWeekDayIndex;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _selectedDayIdx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return Column(
      children: [
        // Day Selector (Pills)
        KeyedSubtree(
          key: AppTourKeys.weekDaySelectorKey,
          child: Container(
            height: 52,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.daysEn.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final dayKey = AppConstants.daysEn[i];
                final entries = widget.state.weekEntries[dayKey] ?? [];
                final label = loc.isArabic
                    ? AppConstants.daysArDisplay[i]
                    : AppConstants.daysEnDisplay[i];
                final isSelected = i == _selectedDayIdx;
                final isToday = dayKey == widget.state.currentDay;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDayIdx = i);
                    _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? AppTheme.bgCard.withValues(alpha: 0.6) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? AppTheme.accent.withValues(alpha: 0.4) : AppTheme.primary)
                            : (isToday
                                ? AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.5)
                                : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0))),
                        width: isSelected || isToday ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : (isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF64748B).withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isToday
                                    ? (isDark ? AppTheme.accent : AppTheme.primary)
                                    : AppTheme.getTextSecondary(context)),
                          ),
                        ),
                        if (entries.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${entries.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppTheme.accent : AppTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Tab Content
        Expanded(
          child: KeyedSubtree(
            key: AppTourKeys.weekScheduleListKey,
            child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _selectedDayIdx = idx);
            },
            itemCount: AppConstants.daysEn.length,
            itemBuilder: (context, i) {
              final dayKey = AppConstants.daysEn[i];
              final entries = widget.state.weekEntries[dayKey] ?? [];

              if (entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: isDark ? 0.1 : 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('😴', style: TextStyle(fontSize: 48)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.isArabic ? 'لا توجد محاضرات في هذا اليوم' : loc.noClassesToday,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.isArabic
                            ? 'يوم راحة أو مذاكرة والعمل على المشاريع ☕'
                            : 'Rest or project day',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextHint(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => EditSessionModal.show(
                          context,
                          initialDay: dayKey,
                          initialGroup: widget.state.group,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          loc.isArabic ? 'إضافة محاضرة لهذا اليوم' : 'Add lecture for this day',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: entries.length + 1,
                itemBuilder: (context, index) {
                  if (index == entries.length) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () => EditSessionModal.show(
                            context,
                            initialDay: dayKey,
                            initialGroup: widget.state.group,
                          ),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: Text(
                            loc.isArabic ? 'إضافة محاضرة لهذا اليوم' : 'Add lecture to this day',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  }
                  return ScheduleCard(
                    entry: entries[index],
                    isHighlighted: !entries[index].isForAllSections,
                    preferences: context.read<PreferencesCubit>().state,
                  );
                },
              );
            },
          ),
        ),
      ),
    ],
  );
  }
}

// ── Helper Widgets ──

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
