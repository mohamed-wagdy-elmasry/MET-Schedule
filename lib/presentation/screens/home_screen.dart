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
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        centerTitle: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // 1. THEME TOGGLE BUTTON (START SIDE)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () =>
                      context.read<PreferencesCubit>().toggleThemeMode(),
                  child: Container(
                    width: 36,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(
                            alpha: isDark ? 0.22 : 0.12,
                          ),
                          AppTheme.accent.withValues(
                            alpha: isDark ? 0.12 : 0.08,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppTheme.primary.withValues(
                          alpha: isDark ? 0.35 : 0.25,
                        ),
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(isDark),
                          color: isDark
                              ? const Color(0xFFFFD166)
                              : AppTheme.primary,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. BRAND LOGO & TITLE: CENTERED & RESILIENT WITH FITTEDBOX
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. SCHEDULE VIEW TOGGLE (END SIDE - Only on Timetable tab)
              if (_currentIndex == 0)
                BlocBuilder<ScheduleCubit, ScheduleState>(
                  builder: (context, state) {
                    final isToday = state.viewMode == ScheduleViewMode.today;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () =>
                            context.read<ScheduleCubit>().toggleView(),
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withValues(
                                  alpha: isDark ? 0.22 : 0.12,
                                ),
                                AppTheme.accent.withValues(
                                  alpha: isDark ? 0.12 : 0.08,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: AppTheme.primary.withValues(
                                alpha: isDark ? 0.35 : 0.25,
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
                                size: 14.5,
                                color: isDark
                                    ? AppTheme.accent
                                    : AppTheme.primary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isToday
                                    ? loc.weeklySchedule
                                    : loc.todaySchedule,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                const SizedBox(width: 36),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 72 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.bgSurface.withValues(alpha: 0.98)
              : AppTheme.bgSurfaceLight.withValues(alpha: 0.98),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFF64748B).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.calendar_today_rounded,
                    label: loc.schedule,
                    isActive: _currentIndex == 0,
                    onTap: () {
                      if (_currentIndex != 0) setState(() => _currentIndex = 0);
                    },
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.school_rounded,
                    label: loc.gradProject,
                    isActive: _currentIndex == 1,
                    onTap: () {
                      if (_currentIndex != 1) setState(() => _currentIndex = 1);
                    },
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.build_circle_rounded,
                    label: loc.tools,
                    isActive: _currentIndex == 2,
                    onTap: () {
                      if (_currentIndex != 2) setState(() => _currentIndex = 2);
                    },
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_rounded,
                    label: loc.more,
                    isActive: _currentIndex == 3,
                    onTap: () {
                      if (_currentIndex != 3) setState(() => _currentIndex = 3);
                    },
                  ),
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
    final activeColor = AppTheme.primary;
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withValues(alpha: isDark ? 0.20 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
