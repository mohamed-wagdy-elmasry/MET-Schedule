/// Onboarding screen — premium glassmorphism design with group & section picker.
///
/// Shows only once; preferences are persisted via [PreferencesCubit].
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart' show ScheduleLoader;
import '../bloc/preferences_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  String _selectedGroup = 'A';
  int _selectedSection = 1;
  int _currentPage = 0; // 0 = welcome, 1 = group, 2 = section

  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<int> get _availableSections =>
      AppConstants.groupSections[_selectedGroup] ?? [1];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: Stack(
        children: [
          // ── Animated gradient background ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ]
                    : const [
                        Color(0xFFF8FAFC),
                        Color(0xFFEFF6FF),
                        Color(0xFFF1F5F9),
                      ],
              ),
            ),
          ),

          // ── Decorative circles ──
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.2,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: isDark ? 0.1 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    // Language toggle in top-right
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _LanguageChip(loc: loc),
                        ],
                      ),
                    ),

                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        children: [
                          _buildWelcomePage(loc),
                          _buildGroupPage(loc),
                          _buildSectionPage(loc),
                        ],
                      ),
                    ),

                    // Navigation dots + button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        children: [
                          // Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) => _buildDot(i)),
                          ),
                          const SizedBox(height: 24),
                          // Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _currentPage == 2 ? loc.letsGo : loc.next,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    final isDark = AppTheme.isDark(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary
            : (isDark ? AppTheme.textHint.withValues(alpha: 0.3) : const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ── Page 0: Welcome ──
  Widget _buildWelcomePage(AppLocalizations loc) {
    final isDark = AppTheme.isDark(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Official MET App Logo
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: isDark ? 0.45 : 0.25),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            loc.welcomeTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.getTextPrimary(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondary(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withValues(alpha: isDark ? 0.3 : 0.25)),
            ),
            child: Text(
              loc.semester,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.accent : AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 1: Group Selection ──
  Widget _buildGroupPage(AppLocalizations loc) {
    final isDark = AppTheme.isDark(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups_rounded, size: 64, color: AppTheme.primary),
          const SizedBox(height: 24),
          Text(
            loc.selectGroup,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: AppConstants.groups.map((g) {
              final isSelected = _selectedGroup == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGroup = g;
                      _selectedSection = AppConstants.groupSections[g]!.first;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : (isDark ? AppTheme.bgCard : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [
                              if (!isDark)
                                BoxShadow(
                                  color: const Color(0xFF64748B).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${loc.groupLabel} $g',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.isArabic ? 'مجموعة $g' : 'Group $g',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppTheme.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Page 2: Section Selection ──
  Widget _buildSectionPage(AppLocalizations loc) {
    final isDark = AppTheme.isDark(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.format_list_numbered_rounded, size: 64, color: AppTheme.accent),
              const SizedBox(height: 24),
              Text(
                loc.selectSection,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${loc.groupLabel} $_selectedGroup',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _availableSections.map((s) {
                  final isSelected = s == _selectedSection;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSection = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [AppTheme.accent, AppTheme.accentAlt],
                              )
                            : null,
                        color: isSelected ? null : (isDark ? AppTheme.bgCard : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.accent : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                if (!isDark)
                                  BoxShadow(
                                    color: const Color(0xFF64748B).withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          '$s',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Save and navigate
      final prefsCubit = context.read<PreferencesCubit>();
      await prefsCubit.setGroupAndSection(_selectedGroup, _selectedSection);
      await prefsCubit.completeOnboarding();
      NotificationService.instance.checkAndShowSeniorWelcomeOnFirstLaunch().ignore();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: const ScheduleLoader(),
          ),
        ),
      );
    }
  }
}

// ── Language Toggle Chip ──
class _LanguageChip extends StatelessWidget {
  final AppLocalizations loc;
  const _LanguageChip({required this.loc});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return GestureDetector(
      onTap: () => context.read<PreferencesCubit>().toggleLocale(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.bgCard.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1)),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: AppTheme.accent),
            const SizedBox(width: 6),
            Text(
              loc.isArabic ? 'EN' : 'عربي',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
