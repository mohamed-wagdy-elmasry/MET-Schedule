/// Settings screen — theme mode switcher, language toggle, group/section change, notifications, about.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/preferences_cubit.dart';
import '../bloc/schedule_cubit.dart';
import '../widgets/color_customization_modal.dart';
import '../widgets/feature_tour_overlay.dart';
import 'home_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  loc.settings,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ),
            ),

            // ── Current Preferences ──
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: AppTourKeys.settingsPrefsKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassDecorationWithColor(
                    AppTheme.primary,
                    context,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _SettingInfo(
                            icon: Icons.groups_rounded,
                            label: loc.currentGroup,
                            value: '${loc.groupLabel} ${prefs.group}',
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 24),
                          _SettingInfo(
                            icon: Icons.tag_rounded,
                            label: loc.currentSection,
                            value: '${loc.sectionLabel} ${prefs.section}',
                            color: isDark
                                ? AppTheme.accent
                                : AppTheme.labColorLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showChangePrefsDialog(context, loc, prefs),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: Text(loc.isArabic ? 'تغيير' : 'Change'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Appearance / Theme (Dark & Light) ──
            SliverToBoxAdapter(
              child: _AppearanceSettingCard(
                isDark: isDark,
                loc: loc,
              ),
            ),

            // ── Palette / Theme Colors ──
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: AppTourKeys.settingsThemeColorKey,
                child: _SettingTile(
                  icon: Icons.palette_rounded,
                  title: loc.isArabic
                      ? 'تخصيص الألوان والثيم'
                      : 'App Theme & Colors',
                  subtitle: loc.isArabic
                      ? 'تغيير اللون الأساسي وألوان المحاضرات والسكاشن'
                      : 'Change primary & session colors',
                  onTap: () => ColorCustomizationModal.show(context),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(prefs.primaryColorValue),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                prefs.primaryColorValue,
                              ).withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppTheme.getTextHint(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Language ──
            SliverToBoxAdapter(
              child: _SettingTile(
                icon: Icons.language_rounded,
                title: loc.language,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prefs.isArabic ? loc.arabic : loc.english,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.accent : AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch.adaptive(
                      value: prefs.isArabic,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (_) =>
                          context.read<PreferencesCubit>().toggleLocale(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Reset Schedule to Default ──
            SliverToBoxAdapter(
              child: _SettingTile(
                icon: Icons.restart_alt_rounded,
                title: loc.isArabic
                    ? 'استعادة الجدول الأصلي'
                    : 'Reset Default Schedule',
                subtitle: loc.isArabic
                    ? 'إلغاء التعديلات والعودة لجدول الكلية الرسمي'
                    : 'Revert all edits to official timetable',
                onTap: () => _confirmResetSchedule(context, loc),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(
                      color: AppTheme.error.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => _confirmResetSchedule(context, loc),
                  child: Text(
                    loc.isArabic ? 'استعادة' : 'Reset',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            // ── Notifications ──
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: AppTourKeys.settingsNotificationsKey,
                child: _SettingTile(
                  icon: Icons.notifications_rounded,
                  title: loc.notificationsEnabled,
                  subtitle: loc.notificationsDesc,
                  trailing: Switch.adaptive(
                    value: prefs.notificationsEnabled,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (_) async {
                      final prefsCubit = context.read<PreferencesCubit>();
                      final scheduleCubit = context.read<ScheduleCubit>();
                      await prefsCubit.toggleNotifications();
                      if (!prefs.notificationsEnabled) {
                        // Turning ON — request permission and schedule
                        await NotificationService.instance.requestPermission();
                        final allEntries = scheduleCubit.state.weekEntries.values
                            .expand((list) => list)
                            .toList();
                        await NotificationService.instance
                            .scheduleAllNotifications(allEntries);
                      } else {
                        // Turning OFF — cancel all
                        await NotificationService.instance.cancelAll();
                      }
                    },
                  ),
                ),
              ),
            ),


            // ── In-App Guided Tour ──
            SliverToBoxAdapter(
              child: _SettingTile(
                icon: Icons.tips_and_updates_rounded,
                title: loc.appGuide,
                subtitle: loc.appGuideSubtitle,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
                onTap: () {
                  HomeScreen.startTour(context);
                },
              ),
            ),

            // ── About & Developer Card ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.glass(context),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.appName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.department,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.semester,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextHint(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final versionStr = snapshot.hasData
                            ? snapshot.data!.version
                            : AppConstants.appVersion;
                        return Text(
                          '${loc.version} $versionStr',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextHint(context),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Developer Recognition Badge (El-Forma -> LinkedIn Profile)
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _launchLinkedIn(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withValues(
                                  alpha: isDark ? 0.22 : 0.12,
                                ),
                                (isDark ? AppTheme.accent : const Color(0xFF6C5CE7))
                                    .withValues(alpha: isDark ? 0.18 : 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.code_rounded,
                                      size: 18,
                                      color: isDark ? AppTheme.accent : AppTheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      loc.isArabic ? 'تم التطوير بواسطة ' : 'Crafted by ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.getTextPrimary(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'El-Forma',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppTheme.accent
                                            : AppTheme.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('🎭', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.link_rounded,
                                      size: 14,
                                      color: isDark ? AppTheme.accent : AppTheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      loc.isArabic ? 'تواصل عبر LinkedIn' : 'Connect on LinkedIn',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppTheme.accent : AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      size: 11,
                                      color: isDark ? AppTheme.accent : AppTheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Privacy Policy Tile
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _launchPrivacyPolicy(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.privacy_tip_outlined,
                                  size: 15,
                                  color: isDark ? AppTheme.accent : AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  loc.privacyPolicy,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getTextPrimary(context),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 11,
                                  color: AppTheme.getTextHint(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  static void _launchPrivacyPolicy(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.bgCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.privacyPolicy,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.getTextPrimary(sheetContext),
                          ),
                        ),
                        Text(
                          isAr ? 'تطبيق MET Schedule • حماية وأمان كامل' : 'MET Schedule • 100% Privacy',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextSecondary(sheetContext),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildPolicyCard(
                    context: sheetContext,
                    icon: Icons.wifi_off_rounded,
                    color: const Color(0xFF10B981),
                    title: isAr ? 'تطبيق أوفلاين بالكامل (100% Offline)' : '100% Offline-First',
                    desc: isAr
                        ? 'يعمل التطبيق بالكامل بدون إنترنت ولا يقوم برفع أو إرسال أي بيانات إلى أي خوادم أو جهات خارجية إطلاقاً.'
                        : 'The app functions entirely offline and never uploads any data to external servers.',
                  ),
                  _buildPolicyCard(
                    context: sheetContext,
                    icon: Icons.sd_storage_rounded,
                    color: const Color(0xFF3B82F6),
                    title: isAr ? 'البيانات والتخزين المحلي' : 'Local Data Storage',
                    desc: isAr
                        ? 'جميع بياناتك (المجموعة، السكشن، سجلات الحضور والغياب، مهام التخرج، الملاحظات) محفوظة محلياً على ذاكرة هاتفك فقط.'
                        : 'All your data (group, section, attendance logs, graduation tasks, notes) is stored strictly on your device.',
                  ),
                  _buildPolicyCard(
                    context: sheetContext,
                    icon: Icons.notifications_active_rounded,
                    color: const Color(0xFFF59E0B),
                    title: isAr ? 'صلاحيات الإشعارات' : 'Notification Permissions',
                    desc: isAr
                        ? 'تُستخدم الصلاحية محلياً فقط لجدولة تذكيرات المحاضرات قبل موعدها بـ 10 دقائق وتنبيه يوم الجمعة.'
                        : 'Used strictly on-device to schedule class reminders 10 min prior and Friday reminder.',
                  ),
                  _buildPolicyCard(
                    context: sheetContext,
                    icon: Icons.delete_sweep_rounded,
                    color: const Color(0xFFEF4444),
                    title: isAr ? 'مسح وحذف البيانات' : 'Data Deletion & Reset',
                    desc: isAr
                        ? 'يمكنك مسح وتصفير كافة بياناتك بنقرة زر واحدة من خيارات "إعادة الضبط" في الإعدادات أو بحذف التطبيق.'
                        : 'You can erase all stored data anytime using the Reset options in Settings or by uninstalling.',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPolicyCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    final isDark = AppTheme.isDark(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppTheme.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchLinkedIn(BuildContext context) async {
    final uri = Uri.parse('https://www.linkedin.com/in/mohamed-wagdy-el-masry');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.isArabic ? 'تعذر فتح الرابط' : 'Could not open link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmResetSchedule(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restart_alt_rounded, color: AppTheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(loc.isArabic ? 'استعادة الجدول الأصلي' : 'Reset Schedule'),
              ),
            ),
          ],
        ),
        content: Text(
          loc.isArabic
              ? 'هل أنت متأكد من استعادة الجدول الدراسي المعتمد من الكلية؟\nسيتم إلغاء أي تعديلات أو إضافات يدوية أجريتها على المحاضرات والسكاشن.'
              : 'Are you sure you want to revert to the official timetable? All manual edits and additions will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(loc.isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await context.read<ScheduleCubit>().resetScheduleToDefault();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      loc.isArabic
                          ? '✅ تم استعادة الجدول المعتمد بنجاح'
                          : 'Official schedule restored successfully',
                    ),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(loc.isArabic ? 'استعادة الآن' : 'Reset Now'),
          ),
        ],
      ),
    );
  }

  void _showChangePrefsDialog(
    BuildContext context,
    AppLocalizations loc,
    PreferencesState prefs,
  ) {
    String group = prefs.group;
    int section = prefs.section;
    final isDark = AppTheme.isDark(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (sheetContext, scrollController) {
            return StatefulBuilder(
              builder: (modalCtx, setModalState) {
                final sections = AppConstants.groupSections[group] ?? [1];

                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getCardBg(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar (interactive drag-to-dismiss)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (details.primaryDelta != null && details.primaryDelta! > 10) {
                              Navigator.of(ctx).pop();
                            }
                          },
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Center(
                              child: Container(
                                width: 44,
                                height: 4.5,
                                decoration: BoxDecoration(
                                  color: AppTheme.getTextHint(context).withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Header Row with Title and Close Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (details.primaryDelta != null && details.primaryDelta! > 10) {
                              Navigator.of(ctx).pop();
                            }
                          },
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    loc.changePreferences,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.getTextPrimary(context),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: loc.isArabic ? 'إغلاق' : 'Close',
                                  icon: Icon(Icons.close_rounded, color: AppTheme.getTextSecondary(context), size: 24),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 1, color: AppTheme.getBorder(context)),

                        // Scrollable Body
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.only(
                              left: 24,
                              right: 24,
                              top: 16,
                              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                            ),
                            child: Column(
                              children: [
                                // Group selector
                                Row(
                                  children: AppConstants.groups.map((g) {
                                    final selected = g == group;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            group = g;
                                            section = AppConstants.groupSections[g]!.first;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 6),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? AppTheme.primary
                                                : AppTheme.getCardSub(context),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected
                                                  ? AppTheme.primary
                                                  : (isDark
                                                      ? Colors.white.withValues(alpha: 0.06)
                                                      : const Color(0xFFE2E8F0)),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${loc.groupLabel} $g',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: selected
                                                    ? Colors.white
                                                    : AppTheme.getTextSecondary(context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),

                                // Section grid
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: sections.map((s) {
                                    final selected = s == section;
                                    return GestureDetector(
                                      onTap: () => setModalState(() => section = s),
                                      child: Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? (isDark ? AppTheme.accent : AppTheme.primary)
                                              : AppTheme.getCardSub(context),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: selected
                                                ? (isDark ? AppTheme.accent : AppTheme.primary)
                                                : (isDark
                                                    ? Colors.white.withValues(alpha: 0.06)
                                                    : const Color(0xFFE2E8F0)),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$s',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? Colors.white
                                                  : AppTheme.getTextSecondary(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.read<PreferencesCubit>().setGroupAndSection(
                                        group,
                                        section,
                                      );
                                      context.read<ScheduleCubit>().loadSchedule(
                                        group,
                                        section,
                                      );
                                      Navigator.pop(ctx);
                                    },
                                    child: Text(loc.save),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SettingInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SettingInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextHint(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    Widget content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDark ? AppTheme.textSecondary : AppTheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getTextHint(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

class _AppearanceSettingCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations loc;

  const _AppearanceSettingCard({
    required this.isDark,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 22,
                color: isDark ? AppTheme.textSecondary : AppTheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.themeMode,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark ? loc.darkMode : loc.lightMode,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextHint(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.bgCardLight : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _ThemeButton(
                    icon: Icons.dark_mode_rounded,
                    label: loc.darkMode,
                    isSelected: isDark,
                    onTap: () => context
                        .read<PreferencesCubit>()
                        .setThemeMode(ThemeMode.dark),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ThemeButton(
                    icon: Icons.light_mode_rounded,
                    label: loc.lightMode,
                    isSelected: !isDark,
                    onTap: () => context
                        .read<PreferencesCubit>()
                        .setThemeMode(ThemeMode.light),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppTheme.getTextHint(context),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
