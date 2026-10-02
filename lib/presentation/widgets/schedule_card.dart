/// Reusable schedule card widget — displays a single class/lab/section entry
/// with glassmorphism styling, session-type color coding, quick edit button,
/// and smart time indicators. Fully adapts to both Dark and Light modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/schedule_entry.dart';
import '../bloc/preferences_cubit.dart';
import 'edit_session_modal.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleEntry entry;
  final bool isHighlighted;
  final bool showSectionBadge;

  const ScheduleCard({
    super.key,
    required this.entry,
    this.isHighlighted = false,
    this.showSectionBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);
    final isRest = entry.type == 'rest' || entry.type == 'project';

    PreferencesState? prefs;
    try {
      prefs = context.watch<PreferencesCubit>().state;
    } catch (_) {
      prefs = null;
    }
    final customColor = prefs?.getCustomSessionColor(entry.type);
    final color = isRest
        ? AppTheme.getRestColor(isDark, prefs?.getCustomSessionColor('rest'))
        : (customColor ?? AppTheme.sessionColor(entry.type, isDark, prefs?.customSessionColors));

    // Build single unified, elegant badge label and icon
    String badgeText;
    IconData badgeIcon;

    if (isRest) {
      badgeText = isArabic ? 'مشروع / راحة' : 'Project / Rest';
      badgeIcon = Icons.coffee_rounded;
    } else if (entry.type == 'lecture') {
      badgeText = isArabic ? 'محاضرة' : 'Lecture';
      badgeIcon = Icons.school_rounded;
    } else if (entry.type == 'lab') {
      if (showSectionBadge && !entry.isForAllSections && entry.forSections.isNotEmpty) {
        badgeText = isArabic
            ? 'عملي ${entry.forSections.join("، ")}'
            : 'Lab ${entry.forSections.join(", ")}';
      } else {
        badgeText = isArabic ? 'عملي' : 'Lab';
      }
      badgeIcon = Icons.computer_rounded;
    } else {
      // section
      if (showSectionBadge && !entry.isForAllSections && entry.forSections.isNotEmpty) {
        badgeText = isArabic
            ? 'سكشن ${entry.forSections.join("، ")}'
            : 'Sec ${entry.forSections.join(", ")}';
      } else {
        badgeText = isArabic ? 'سكشن' : 'Section';
      }
      badgeIcon = Icons.edit_note_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
          colors: isDark
              ? [
                  color.withValues(alpha: isRest ? 0.16 : (isHighlighted ? 0.22 : 0.12)),
                  AppTheme.bgCard.withValues(alpha: 0.90),
                ]
              : [
                  color.withValues(alpha: isRest ? 0.12 : (isHighlighted ? 0.15 : 0.07)),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark
              ? (isHighlighted || isRest ? 0.45 : 0.20)
              : (isHighlighted || isRest ? 0.50 : 0.25)),
          width: isHighlighted || isRest ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withValues(alpha: isHighlighted || isRest ? 0.18 : 0.06)
                : const Color(0xFF64748B).withValues(alpha: isHighlighted || isRest ? 0.10 : 0.05),
            blurRadius: isDark ? 20 : 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sleek vertical accent indicator strip on leading edge
          Positioned(
            top: 14,
            bottom: 14,
            right: isArabic ? 0 : null,
            left: isArabic ? null : 0,
            child: Container(
              width: 3.5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(isArabic ? 3 : 0),
                  right: Radius.circular(isArabic ? 0 : 3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row: Unified Badge + Time + Fixed-Corner Quick Edit ──
                Row(
                  children: [
                    // Single Unified Type & Section Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withValues(alpha: isDark ? 0.35 : 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 13, color: color),
                          const SizedBox(width: 5),
                          Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Time badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppTheme.getTextSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.timeRange(isArabic),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Quick Edit Button ALWAYS anchored at the far trailing corner
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => EditSessionModal.show(context, entry: entry),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.16 : 0.09),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: isDark ? 0.35 : 0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Subject Name ──
                Text(
                  entry.subjectName(isArabic),
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppTheme.getTextPrimary(context),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Details (Location & Instructor in Modern Capsule Chips) ──
                if (isRest) ...[
                  Row(
                    children: [
                      Icon(Icons.coffee_rounded, size: 16, color: color.withValues(alpha: 0.9)),
                      const SizedBox(width: 6),
                      Text(
                        isArabic
                            ? 'مخصص للعمل على مشروع التخرج والمذاكرة والراحة'
                            : 'Dedicated for Graduation Project & Rest',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Location Capsule Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? color.withValues(alpha: 0.12)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withValues(alpha: isDark ? 0.25 : 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.locationType == 'lab'
                                  ? Icons.computer_rounded
                                  : (entry.locationName(isArabic).contains('مدرج')
                                      ? Icons.domain_rounded
                                      : Icons.meeting_room_rounded),
                              size: 13,
                              color: color,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              entry.locationName(isArabic),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? color : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Instructor Capsule Tag
                      if (entry.instructors.length <= 1 &&
                          (entry.instructors.isNotEmpty || entry.instructorName(isArabic).isNotEmpty))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 13,
                                color: AppTheme.getTextHint(context),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                entry.instructors.isNotEmpty
                                    ? entry.instructors.first
                                    : entry.instructorName(isArabic),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (entry.instructors.length > 1) ...[
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entry.instructors.map((instructor) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_rounded, size: 12, color: AppTheme.getTextHint(context)),
                                const SizedBox(width: 4),
                                Text(
                                  instructor,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getTextSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],

                // ── Note (if any) ──
                if (entry.note(isArabic) != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warning),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            entry.note(isArabic)!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero card for the upcoming/current class on the Today view.
class NextClassCard extends StatelessWidget {
  final ScheduleEntry entry;
  final String currentDay;
  final String? targetDay;

  const NextClassCard({
    super.key,
    required this.entry,
    required this.currentDay,
    this.targetDay,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);

    PreferencesState? prefs;
    try {
      prefs = context.watch<PreferencesCubit>().state;
    } catch (_) {
      prefs = null;
    }
    final customColor = prefs?.getCustomSessionColor(entry.type);
    final color = customColor ?? AppTheme.sessionColor(entry.type, isDark, prefs?.customSessionColors);

    // Calculate time until class
    final now = DateTime.now();
    final parts = entry.startTime.split(':');
    final classHour = int.parse(parts[0]);
    final classMinute = int.parse(parts[1]);

    final isSameDay = targetDay == null || targetDay == currentDay;
    int diffMinutes = 0;

    if (isSameDay) {
      final classTime = DateTime(now.year, now.month, now.day, classHour, classMinute);
      diffMinutes = classTime.difference(now).inMinutes;
    } else {
      final curIdx = _dayIndex(currentDay);
      final tgtIdx = _dayIndex(targetDay!);
      int dayDiff = (tgtIdx - curIdx) % 7;
      if (dayDiff <= 0) dayDiff += 7;

      final targetDate = now.add(Duration(days: dayDiff));
      final classTime = DateTime(targetDate.year, targetDate.month, targetDate.day, classHour, classMinute);
      diffMinutes = classTime.difference(now).inMinutes;
    }

    String timeLabel;
    if (diffMinutes < 0) {
      timeLabel = loc.now;
    } else if (diffMinutes < 60) {
      timeLabel = '$diffMinutes ${loc.minutes}';
    } else {
      final hours = diffMinutes ~/ 60;
      final mins = diffMinutes % 60;
      timeLabel = isArabic ? '$hours س $mins د' : '${hours}h ${mins}m';
    }

    final dayPrefix = !isSameDay && targetDay != null
        ? '${_dayName(targetDay!, isArabic)}: '
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  color.withValues(alpha: 0.25),
                  AppTheme.bgCard.withValues(alpha: 0.9),
                ]
              : [
                  color.withValues(alpha: 0.16),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withValues(alpha: 0.2)
                : const Color(0xFF64748B).withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Live status indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withValues(alpha: isDark ? 0.45 : 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: diffMinutes <= 0 ? const Color(0xFF00E5A0) : color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (diffMinutes <= 0 ? const Color(0xFF00E5A0) : color).withValues(alpha: 0.8),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      diffMinutes <= 0
                          ? (isArabic ? 'المحاضرة جارية الآن' : 'Class In Progress')
                          : (isArabic ? 'المحاضرة القادمة' : loc.nextClass),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Glowing Countdown Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: diffMinutes <= 10 && isSameDay
                        ? [
                            AppTheme.error.withValues(alpha: isDark ? 0.25 : 0.18),
                            AppTheme.error.withValues(alpha: isDark ? 0.12 : 0.08),
                          ]
                        : [
                            AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                            (isDark ? AppTheme.accent : AppTheme.primary).withValues(alpha: isDark ? 0.15 : 0.10),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (diffMinutes <= 10 && isSameDay
                            ? AppTheme.error
                            : (isDark ? AppTheme.accent : AppTheme.primary))
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: diffMinutes <= 10 && isSameDay
                          ? AppTheme.error
                          : (isDark ? AppTheme.accent : AppTheme.primary),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      diffMinutes <= 0
                          ? (isArabic ? 'الآن' : 'Now')
                          : '$dayPrefix${loc.startsIn} $timeLabel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: diffMinutes <= 10 && isSameDay
                            ? AppTheme.error
                            : (isDark ? AppTheme.accent : AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Quick edit button (pen icon only) — anchored at the far trailing corner
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => EditSessionModal.show(context, entry: entry),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.16 : 0.09),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            entry.subjectName(isArabic),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Time capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(
                      entry.timeRange(isArabic),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Location capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.locationType == 'lab'
                          ? Icons.computer_rounded
                          : (entry.locationName(isArabic).contains('مدرج')
                              ? Icons.domain_rounded
                              : Icons.meeting_room_rounded),
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entry.locationName(isArabic),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? color : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Instructor capsule
              if (entry.instructors.length <= 1 &&
                  (entry.instructors.isNotEmpty || entry.instructorName(isArabic).isNotEmpty))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_rounded, size: 14, color: AppTheme.getTextHint(context)),
                      const SizedBox(width: 5),
                      Text(
                        entry.instructors.isNotEmpty
                            ? entry.instructors.first
                            : entry.instructorName(isArabic),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (entry.instructors.length > 1) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.instructors.map((inst) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_rounded, size: 12, color: AppTheme.getTextHint(context)),
                      const SizedBox(width: 4),
                      Text(
                        inst,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  int _dayIndex(String dayKey) {
    const order = ['saturday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    final idx = order.indexOf(dayKey);
    return idx >= 0 ? idx : 0;
  }

  String _dayName(String dayKey, bool isArabic) {
    final idx = AppConstants.daysEn.indexOf(dayKey);
    if (idx < 0) return dayKey;
    return isArabic ? AppConstants.daysArDisplay[idx] : AppConstants.daysEnDisplay[idx];
  }
}
