/// Timetable screen — shows Today's Schedule or Full Week view.
/// Features dedicated Friday spiritual hub, smart cross-day countdown,
/// and smooth custom pill tab weekly navigation in both Dark and Light modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/schedule_cubit.dart';
import '../bloc/preferences_cubit.dart';
import '../widgets/friday_hub_widget.dart';
import '../widgets/schedule_card.dart';
import '../widgets/edit_session_modal.dart';

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

class _TodayView extends StatelessWidget {
  final ScheduleState state;
  const _TodayView({required this.state});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesCubit>().state;
    final isDark = AppTheme.isDark(context);

    // ── Dedicated Friday View ──
    if (state.isFriday) {
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.spa_rounded, size: 14, color: Color(0xFF00B894)),
                        SizedBox(width: 4),
                        Text(
                          'يوم الجمعة',
                          style: TextStyle(
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
            child: FridayHubWidget(
              upcomingSaturdayEntries: state.weekEntries['saturday'] ?? [],
              onPreviewSaturday: () {
                context.read<ScheduleCubit>().selectWeekDay(0);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      );
    }

    // ── Regular Academic Day View ──
    return CustomScrollView(
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
                          _dayDisplayLabel(state.currentDay, loc),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    // High-tech Add Lecture Button
                    GestureDetector(
                      onTap: () => EditSessionModal.show(
                        context,
                        initialDay: state.currentDay,
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
                  ],
                ),
                const SizedBox(height: 10),
                Row(
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        '${state.todayEntries.length} ${loc.isArabic ? "محاضرات اليوم" : "classes"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Smart Next Class Hero
        if (state.nextClass != null)
          SliverToBoxAdapter(
            child: NextClassCard(
              entry: state.nextClass!,
              currentDay: state.currentDay,
              targetDay: state.nextClassDay,
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
                final entry = state.todayEntries[index];
                return ScheduleCard(
                  entry: entry,
                  isHighlighted: !entry.isForAllSections,
                );
              },
              childCount: state.todayEntries.length,
            ),
          ),

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
        Container(
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

        // Tab Content
        Expanded(
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
                  );
                },
              );
            },
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
