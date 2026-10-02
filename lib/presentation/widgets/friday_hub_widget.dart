/// Friday Spiritual & Academic Hub — interactive Sunan, digital Tasbeeh counter,
/// Surah Al-Kahf reader, and smart countdown to the next academic day.
/// Fully adapts to both Dark and Light modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/schedule_entry.dart';
import '../bloc/preferences_cubit.dart';
import 'edit_session_modal.dart';

class FridayHubWidget extends StatefulWidget {
  final List<ScheduleEntry> upcomingSaturdayEntries;
  final VoidCallback? onPreviewSaturday;

  const FridayHubWidget({
    super.key,
    required this.upcomingSaturdayEntries,
    this.onPreviewSaturday,
  });

  @override
  State<FridayHubWidget> createState() => _FridayHubWidgetState();
}

class _FridayHubWidgetState extends State<FridayHubWidget> {
  int _salawatCount = 0;
  final Set<String> _checkedSunan = {};
  double _buttonScale = 1.0;

  void _incrementSalawat() {
    HapticFeedback.lightImpact();
    setState(() {
      _salawatCount++;
      _buttonScale = 0.92;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _buttonScale = 1.0);
    });
  }

  void _resetSalawat() {
    HapticFeedback.mediumImpact();
    setState(() => _salawatCount = 0);
  }

  void _toggleSunnah(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_checkedSunan.contains(id)) {
        _checkedSunan.remove(id);
      } else {
        _checkedSunan.add(id);
      }
    });
  }

  void _openSurahKahfReader(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => const _SurahKahfReaderModal(),
    );
  }

  Future<void> _testNotification(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final success = await NotificationService.instance.showInstantTestNotification(
      title: 'MET Schedule 🔔 | إشعار تجريبي',
      body: 'نظام الإشعارات يعمل بنجاح! جمعة مباركة وتقبل الله طاعتكم 🌸',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ تم إرسال الإشعار بنجاح! تفقد شريط الإشعارات أعلى الشاشة'
                : '⚠️ يرجى تفعيل إذن الإشعارات من إعدادات الهاتف',
          ),
          backgroundColor: success ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);
    final firstSatEntry = widget.upcomingSaturdayEntries.isNotEmpty
        ? widget.upcomingSaturdayEntries.first
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Friday Hero Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF00B894).withValues(alpha: 0.25),
                        const Color(0xFF6C5CE7).withValues(alpha: 0.25),
                        AppTheme.bgCard.withValues(alpha: 0.95),
                      ]
                    : [
                        const Color(0xFF00B894).withValues(alpha: 0.14),
                        const Color(0xFF6C5CE7).withValues(alpha: 0.10),
                        Colors.white,
                      ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFF00B894).withValues(alpha: isDark ? 0.4 : 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B894).withValues(alpha: isDark ? 0.15 : 0.08),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894).withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF00B894).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: Color(0xFF00B894)),
                          SizedBox(width: 6),
                          Text(
                            'عطلة أسبوعية مباركة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00B894),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'تجربة الإشعار الفوري',
                      onPressed: () => _testNotification(context),
                      icon: Icon(
                        Icons.notifications_active_rounded,
                        color: isDark ? AppTheme.accent : AppTheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'جمعة مباركة 🌸',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.getTextPrimary(context),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FridayData.hadithHeader,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppTheme.getTextSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── 2. Interactive Digital Tasbeeh Card (الصلاة على النبي ﷺ) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [
                        const Color(0xFFE84393).withValues(alpha: 0.2),
                        AppTheme.bgCard.withValues(alpha: 0.9),
                      ]
                    : [
                        const Color(0xFFE84393).withValues(alpha: 0.10),
                        Colors.white,
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE84393).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE84393).withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: Color(0xFFE84393), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'عِداد الصلاة على النبي ﷺ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    if (_salawatCount > 0)
                      GestureDetector(
                        onTap: _resetSalawat,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'إعادة ضبط',
                            style: TextStyle(fontSize: 11, color: AppTheme.getTextHint(context)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '«اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ»',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFFAB1A0) : const Color(0xFFD63031),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Tap Button / Counter Circle
                AnimatedScale(
                  scale: _buttonScale,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  child: GestureDetector(
                    onTap: _incrementSalawat,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE84393), Color(0xFF6C5CE7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE84393).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_salawatCount',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'انقر للصلاة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ── 3. Friday Sunan Checklist ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سنن وآداب يوم الجمعة ✨',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openSurahKahfReader(context),
                icon: Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: isDark ? AppTheme.accent : AppTheme.primary,
                ),
                label: Text(
                  'سورة الكهف 📖',
                  style: TextStyle(
                    color: isDark ? AppTheme.accent : AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...FridayData.sunan.map((sunnah) {
            final id = sunnah['id'] as String;
            final isChecked = _checkedSunan.contains(id);
            final isKahf = id == 'kahf';

            return GestureDetector(
              onTap: () {
                if (isKahf) {
                  _openSurahKahfReader(context);
                }
                _toggleSunnah(id);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isChecked
                      ? const Color(0xFF00B894).withValues(alpha: isDark ? 0.14 : 0.10)
                      : (isDark ? AppTheme.bgCard.withValues(alpha: 0.7) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isChecked
                        ? const Color(0xFF00B894).withValues(alpha: 0.4)
                        : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFF64748B).withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isChecked
                            ? const Color(0xFF00B894)
                            : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9)),
                        border: Border.all(
                          color: isChecked
                              ? const Color(0xFF00B894)
                              : AppTheme.getTextHint(context).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sunnah['title'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isChecked
                                  ? const Color(0xFF00B894)
                                  : AppTheme.getTextPrimary(context),
                              decoration:
                                  isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sunnah['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isKahf)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.accent : AppTheme.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'قراءة 📖',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.accent : AppTheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── 4. Friday Azkar & Duas ──
          Text(
            'أدعية وأذكار مستحبة 🤲',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),

          ...FridayData.azkarAndDuas.map((dua) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.bgCard.withValues(alpha: 0.75) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF64748B).withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dua['title']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.accent : AppTheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppTheme.getTextHint(context),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: dua['content']!));
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('تم نسخ الذكر بنجاح ✨'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dua['content']!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.getTextPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📌 ${dua['reward']!}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.getTextHint(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── 5. Smart Countdown & Preview to Upcoming Saturday Schedule ──
          Builder(
            builder: (context) {
              PreferencesState? prefs;
              try {
                prefs = context.watch<PreferencesCubit>().state;
              } catch (_) {
                prefs = null;
              }

              Color? satColor;
              String satBadgeText = '';
              IconData satBadgeIcon = Icons.school_rounded;

              if (firstSatEntry != null) {
                final isRest = firstSatEntry.type == 'rest' || firstSatEntry.type == 'project';
                final customColor = prefs?.getCustomSessionColor(firstSatEntry.type);
                satColor = isRest
                    ? AppTheme.getRestColor(isDark, prefs?.getCustomSessionColor('rest'))
                    : (customColor ?? AppTheme.sessionColor(firstSatEntry.type, isDark, prefs?.customSessionColors));

                if (isRest) {
                  satBadgeText = isArabic ? 'مشروع / راحة' : 'Project / Rest';
                  satBadgeIcon = Icons.coffee_rounded;
                } else if (firstSatEntry.type == 'lecture') {
                  satBadgeText = isArabic ? 'محاضرة' : 'Lecture';
                  satBadgeIcon = Icons.school_rounded;
                } else if (firstSatEntry.type == 'lab') {
                  if (!firstSatEntry.isForAllSections && firstSatEntry.forSections.isNotEmpty) {
                    satBadgeText = isArabic
                        ? 'عملي ${firstSatEntry.forSections.join("، ")}'
                        : 'Lab ${firstSatEntry.forSections.join(", ")}';
                  } else {
                    satBadgeText = isArabic ? 'عملي' : 'Lab';
                  }
                  satBadgeIcon = Icons.computer_rounded;
                } else {
                  if (!firstSatEntry.isForAllSections && firstSatEntry.forSections.isNotEmpty) {
                    satBadgeText = isArabic
                        ? 'سكشن ${firstSatEntry.forSections.join("، ")}'
                        : 'Sec ${firstSatEntry.forSections.join(", ")}';
                  } else {
                    satBadgeText = isArabic ? 'سكشن' : 'Section';
                  }
                  satBadgeIcon = Icons.edit_note_rounded;
                }
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppTheme.primary.withValues(alpha: 0.20),
                            AppTheme.bgCard.withValues(alpha: 0.95),
                          ]
                        : [
                            AppTheme.primary.withValues(alpha: 0.12),
                            Colors.white,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: isDark ? 0.35 : 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppTheme.primary.withValues(alpha: 0.16)
                          : const Color(0xFF64748B).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppTheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'اليوم الدراسي القادم' : 'Next Study Day',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getTextSecondary(context),
                                  ),
                                ),
                                Text(
                                  isArabic ? 'السبت' : 'Saturday',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.getTextPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (widget.onPreviewSaturday != null)
                          GestureDetector(
                            onTap: widget.onPreviewSaturday,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isArabic ? 'عرض الجدول' : 'View Schedule',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppTheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (firstSatEntry != null && satColor != null) ...[
                      // Seamless, integrated Saturday First Lecture Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: satColor.withValues(alpha: isDark ? 0.25 : 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Type Badge + Time + Fixed-Corner Quick Edit
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: satColor.withValues(alpha: isDark ? 0.2 : 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: satColor.withValues(alpha: isDark ? 0.35 : 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(satBadgeIcon, size: 13, color: satColor),
                                      const SizedBox(width: 5),
                                      Text(
                                        satBadgeText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: satColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : const Color(0xFFE2E8F0),
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
                                        firstSatEntry.timeRange(isArabic),
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
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => EditSessionModal.show(context, entry: firstSatEntry),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: satColor.withValues(alpha: isDark ? 0.16 : 0.09),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: satColor.withValues(alpha: isDark ? 0.35 : 0.25),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: satColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              firstSatEntry.subjectName(isArabic),
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? satColor.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: satColor.withValues(alpha: isDark ? 0.25 : 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        firstSatEntry.locationType == 'lab'
                                            ? Icons.computer_rounded
                                            : (firstSatEntry.locationName(isArabic).contains('مدرج')
                                                ? Icons.domain_rounded
                                                : Icons.meeting_room_rounded),
                                        size: 13,
                                        color: satColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        firstSatEntry.locationName(isArabic),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? satColor : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (firstSatEntry.instructors.length <= 1 &&
                                    (firstSatEntry.instructors.isNotEmpty || firstSatEntry.instructorName(isArabic).isNotEmpty))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.school_rounded, size: 13, color: AppTheme.getTextHint(context)),
                                        const SizedBox(width: 5),
                                        Text(
                                          firstSatEntry.instructors.isNotEmpty
                                              ? firstSatEntry.instructors.first
                                              : firstSatEntry.instructorName(isArabic),
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
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            isArabic
                                ? 'لا توجد محاضرات مسجلة يوم السبت لهذه المجموعة.'
                                : 'No classes scheduled for Saturday.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.getTextSecondary(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// Surah Al-Kahf Reader Modal
// ══════════════════════════════════════════════════

class _SurahKahfReaderModal extends StatelessWidget {
  const _SurahKahfReaderModal();

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سورة الكهف 📖',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.getTextHint(context),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? Colors.white10 : Colors.black12),
            // Verses List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                itemCount: FridayData.surahKahfVerses.length,
                itemBuilder: (context, index) {
                  final verse = FridayData.surahKahfVerses[index];
                  final isBasmalah = index == 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      verse,
                      textAlign: isBasmalah ? TextAlign.center : TextAlign.justify,
                      style: TextStyle(
                        fontSize: isBasmalah ? 18 : 16,
                        height: 2.0,
                        fontWeight: isBasmalah ? FontWeight.w800 : FontWeight.w500,
                        color: isBasmalah
                            ? (isDark ? AppTheme.accent : AppTheme.labColorLight)
                            : AppTheme.getTextPrimary(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════
// Friday Data Repository
// ══════════════════════════════════════════════════

class FridayData {
  FridayData._();

  static const String hadithHeader =
      'قال رسول الله ﷺ: «خَيْرُ يَوْمٍ طَلَعَتْ عَلَيْهِ الشَّمْسُ يَوْمُ الْجُمُعَةِ، فِيهِ خُلِقَ آدَمُ، وَفِيهِ أُدْخِلَ الْجَنَّةَ، وَفِيهِ أُخْرِجَ مِنْهَا»';

  static const List<Map<String, dynamic>> sunan = [
    {
      'id': 'ghusl',
      'title': 'الغُسل والتطيّب',
      'subtitle': 'التطهر ولبس أحسن الثياب قبل صلاة الجمعة',
    },
    {
      'id': 'siwak',
      'title': 'استعمال السواك',
      'subtitle': 'تطهير الفم والتطيب بالسواك سنة مؤكدة',
    },
    {
      'id': 'early',
      'title': 'التبكير إلى المسجد',
      'subtitle': 'المشي مبكراً والإنصات للخطبة لنيل الأجر العظيم',
    },
    {
      'id': 'kahf',
      'title': 'قراءة سورة الكهف',
      'subtitle': 'نورٌ ما بين الجمعتين لمن قرأها',
    },
    {
      'id': 'salawat',
      'title': 'الإكثار من الصلاة على النبي',
      'subtitle': 'تُعرض صلاتنا على رسول الله ﷺ في هذا اليوم المبارك',
    },
    {
      'id': 'dua_hour',
      'title': 'تحري ساعة الإجابة',
      'subtitle': 'ساعة لا يوافقها عبد مسلم يدعو إلا استجيب له (آخر ساعة من العصر)',
    },
  ];

  static const List<Map<String, String>> azkarAndDuas = [
    {
      'title': 'دعاء ساعة الإجابة 🤲',
      'content': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنَ الخَيْرِ كُلِّهِ عَاجِلِهِ وَآجِلِهِ مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ، وَأَعُوذُ بِكَ مِنَ الشَّرِّ كُلِّهِ عَاجِلِهِ وَآجِلِهِ مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ.',
      'reward': 'دعاء جامع لخيري الدنيا والآخرة كان يدعو به النبي ﷺ',
    },
    {
      'title': 'الصيغة الإبراهيمية للصلاة على النبي ✨',
      'content': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ.',
      'reward': 'أفضل وأكمل صيغة للصلاة على النبي ﷺ',
    },
    {
      'title': 'سيد الاستغفار 🌟',
      'content': 'اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لاَ يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ.',
      'reward': 'من قالها موقناً بها فمات من يومه أو ليلته دخل الجنة',
    },
  ];

  static const List<String> surahKahfVerses = [
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوَجًا ۜ (1)',
    'قَيِّمًا لِّيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ وَيُبَشِّرَ الْمُؤْمِنِينَ الَّذِينَ يَعْمَلُونَ الصَّالِحَاتِ أَنَّ لَهُمْ أَجْرًا حَسَنًا (2)',
    'مَّاكِثِينَ فِيهِ أَبَدًا (3)',
    'وَيُنذِرَ الَّذِينَ قَالُوا اتَّخَذَ اللَّهُ وَلَدًا (4)',
    'مَّا لَهُم بِهِ مِنْ عِلْمٍ وَلَا لِآبَائِهِمْ ۚ كَبُرَتْ كَلِمَةً تَخْرُجُ مِنْ أَفْوَاهِهِمْ ۚ إِن يَقُولُونَ إِلَّا كَذِبًا (5)',
    'فَلَعَلَّكَ بَاخِعٌ نَّفْسَكَ عَلَىٰ آثَارِهِمْ إِن لَّمْ يُؤْمِنُوا بِهَٰذَا الْحَدِيثِ أَسَفًا (6)',
    'إِنَّا جَعَلْنَا مَا عَلَى الْأَرْضِ زِينَةً لَّهَا لِنَبْلُوَهُمْ أَيُّهُمْ أَحْسَنُ عَمَلًا (7)',
    'وَإِنَّا لَجَاعِلُونَ مَا عَلَيْهَا صَعِيدًا جُرُزًا (8)',
    'أَمْ حَسِبْتَ أَنَّ أَصْحَابَ الْكَهْفِ وَالرَّقِيمِ كَانُوا مِنْ آيَاتِنَا عَجَبًا (9)',
    'إِذْ أَوَى الْفِتْيَةُ إِلَى الْكَهْفِ فَقَالُوا رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا (10)',
    'فَضَرَبْنَا عَلَىٰ آذَانِهِمْ فِي الْكَهْفِ سِنِينَ عَدَدًا (11)',
    'ثُمَّ بَعَثْنَاهُمْ لِنَعْلَمَ أَيُّ الْحِزْبَيْنِ أَحْصَىٰ لِمَا لَبِثُوا أَمَدًا (12)',
    'نَّحْنُ نَقُصُّ عَلَيْكَ نَبَأَهُم بِالْحَقِّ ۚ إِنَّهُمْ فِتْيَةٌ آمَنُوا بِرَبِّهِمْ وَزِدْنَاهُمْ هُدًى (13)',
    'وَرَبَطْنَا عَلَىٰ قُلُوبِهِمْ إِذْ قَامُوا فَقَالُوا رَبُّنَا رَبُّ السَّمَاوَاتِ وَالْأَرْضِ لَن نَّدْعُوَ مِن دُونِهِ إِلَٰهًا ۖ لَّقَدْ قُلْنَا إِذًا شَطَطًا (14)',
    'هَٰؤُلَاءِ قَوْمُنَا اتَّخَذُوا مِن دُونِهِ آلِهَةً ۖ لَّوْلَا يَأْتُونَ عَلَيْهِم بِسُلْطَانٍ بَيِّنٍ ۖ فَمَنْ أَظْلَمُ مِمَّنِ افْتَرَىٰ عَلَى اللَّهِ كَذِبًا (15)',
    'وَإِذِ اعْتَزَلْتُمُوهُمْ وَمَا يَعْبُدُونَ إِلَّا اللَّهَ فَأْوُوا إِلَى الْكَهْفِ يَنشُرْ لَكُمْ رَبُّكُم مِّن رَّحْمَتِهِ وَيُهَيِّئْ لَكُم مِّنْ أَمْرِكُم مِّرْفَقًا (16)',
    'وَتَرَى الشَّمْسَ إِذَا طَلَعَت تَّزَاوَرُ عَن كَهْفِهِمْ ذَاتَ الْيَمِينِ وَإِذَا غَرَبَت تَّقْرِضُهُمْ ذَاتَ الشِّمَالِ وَهُمْ فِي فَجْوَةٍ مِّنْهُ ۚ ذَٰلِكَ مِنْ آيَاتِ اللَّهِ ۗ مَن يَهْدِ اللَّهُ فَهُوَ الْمُهْتَدِ ۖ وَمَن يُضْلِلْ فَلَن تَجِدَ لَهُ وَلِيًّا مُّرْشِدًا (17)',
    'وَتَحْسَبُهُمْ أَيْقَاظًا وَهُمْ رُقُودٌ ۚ وَنُقَلِّبُهُمْ ذَاتَ الْيَمِينِ وَذَاتَ الشِّمَالِ ۖ وَكَلْبُهُم بَاسِطٌ ذِرَاعَيْهِ بِالْوَصِيدِ ۚ لَوِ اطَّلَعْتَ عَلَيْهِمْ لَوَلَّيْتَ مِنْهُمْ فِرَارًا وَلَمُلِئْتَ مِنْهُم رُعْبًا (18)',
    'وَكَذَٰلِكَ بَعَثْنَاهُمْ لِيَتَسَاءَلُوا بَيْنَهُمْ ۚ قَالَ قَائِلٌ مِّنْهُمْ كَمْ لَبِثْتُمْ ۖ قَالُوا لَبِثْنَا يَوْمًا أَوْ بَعْضَ يَوْمٍ ۚ قَالُوا رَبُّكُمْ أَعْلَمُ بِمَا لَبِثْتُمْ فَابْعَثُوا أَحَدَكُم بِوَرِقِكُمْ هَٰذِهِ إِلَى الْمَدِينَةِ فَلْيَنظُرْ أَيُّهَا أَزْكَىٰ طَعَامًا فَلْيَأْتِكُم بِرِزْقٍ مِّنْهُ وَلْيَتَلَطَّفْ وَلَا يُشْعِرَنَّ بِكُمْ أَحَدًا (19)',
    'إِنَّهُمْ إِن يَظْهَرُوا عَلَيْكُمْ يَرْجُمُوكُمْ أَوْ يُعِيدُوكُمْ فِي مِلَّتِهِمْ وَلَن تُفْلِحُوا إِذًا أَبَدًا (20)',
    'وَقُلِ الْحَمْدُ لِلَّهِ الَّذِي لَمْ يَتَّخِذْ وَلَدًا وَلَمْ يَكُن لَّهُ شَرِيكٌ فِي الْمُلْكِ وَلَمْ يَكُن لَّهُ وَلِيٌّ مِّنَ الذُّلِّ ۖ وَكَبِّرْهُ تَكْبِيرًا ۝ (111)',
  ];
}
