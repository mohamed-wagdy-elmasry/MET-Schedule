/// Home screen — bottom navigation shell that hosts the four main tabs.
///
/// Uses an animated bottom nav with glassmorphism styling and quick theme toggle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/preferences_cubit.dart';
import '../bloc/schedule_cubit.dart';
import 'timetable_screen.dart';
import 'graduation_project_screen.dart';
import 'tools_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    TimetableScreen(),
    GraduationProjectScreen(),
    ToolsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          tooltip: isDark ? loc.lightMode : loc.darkMode,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: isDark ? const Color(0xFFFFD166) : AppTheme.primary,
              size: 22,
            ),
          ),
          onPressed: () => context.read<PreferencesCubit>().toggleThemeMode(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'MET',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Schedule',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // View toggle (only on timetable tab)
          if (_currentIndex == 0)
            BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) {
                final isToday = state.viewMode == ScheduleViewMode.today;
                return GestureDetector(
                  onTap: () => context.read<ScheduleCubit>().toggleView(),
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          AppTheme.accent.withValues(
                            alpha: isDark ? 0.15 : 0.10,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withValues(
                          alpha: isDark ? 0.4 : 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isToday
                              ? Icons.calendar_view_week_rounded
                              : Icons.today_rounded,
                          size: 15,
                          color: isDark ? AppTheme.accent : AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isToday ? loc.weeklySchedule : loc.todaySchedule,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.bgSurface.withValues(alpha: 0.95)
              : AppTheme.bgSurfaceLight.withValues(alpha: 0.97),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0xFF64748B).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.calendar_today_rounded,
                  label: loc.schedule,
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.school_rounded,
                  label: loc.gradProject,
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.build_circle_rounded,
                  label: loc.tools,
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: loc.more,
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withValues(alpha: isDark ? 0.18 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(
                  color: AppTheme.primary.withValues(
                    alpha: isDark ? 0.35 : 0.25,
                  ),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: isActive
                  ? AppTheme.primary
                  : AppTheme.getTextHint(context),
            ),
            if (isActive) ...[
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
