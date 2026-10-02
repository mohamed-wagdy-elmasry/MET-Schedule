/// Color Customization Modal — allows students to customize the app theme accent
/// and choose specific colors for Lectures, Sections, Labs, and REST sessions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/preferences_cubit.dart';

class ColorCustomizationModal extends StatelessWidget {
  const ColorCustomizationModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ColorCustomizationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        final currentPrimary = prefs.primaryColorValue;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getTextHint(context).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.palette_rounded, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isArabic ? 'تخصيص ألوان التطبيق' : 'Customize Colors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Section 1: Main App Theme Accent ──
                Text(
                  isArabic ? 'اللون الأساسي للتطبيق' : 'Main Theme Accent',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'اختر مظهرك المفضل من بين ألوان عصرية مصممة للطلاب'
                      : 'Choose your favorite palette curated for students',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextHint(context),
                  ),
                ),
                const SizedBox(height: 12),

                // Palette grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: AppPalettes.list.length,
                  itemBuilder: (context, index) {
                    final pal = AppPalettes.list[index];
                    final isSelected = pal.primary.toARGB32() == currentPrimary;

                    return GestureDetector(
                      onTap: () {
                        context.read<PreferencesCubit>().setPrimaryColor(pal.primary.toARGB32());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? pal.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                              : (isDark ? AppTheme.bgCardLight : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? pal.primary : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: pal.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: pal.primary.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isArabic ? pal.nameAr : pal.nameEn,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? pal.primary : AppTheme.getTextPrimary(context),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                Divider(color: AppTheme.getBorder(context)),
                const SizedBox(height: 16),

                // ── Section 2: Session Type Colors ──
                Text(
                  isArabic ? 'ألوان المحاضرات والسكاشن والمعامل' : 'Lecture & Section Colors',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'حدد اللون المميز لكل نوع محاضرة أو سكشن في جدولك'
                      : 'Assign distinct colors for lectures, sections, labs & rest',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextHint(context),
                  ),
                ),
                const SizedBox(height: 14),

                _SessionColorPickerRow(
                  label: isArabic ? 'المحاضرات 🎓' : 'Lectures 🎓',
                  typeKey: 'lecture',
                  currentColor: AppTheme.sessionColor('lecture', isDark, prefs.customSessionColors),
                  onSelect: (c) => context.read<PreferencesCubit>().setSessionColor('lecture', c.toARGB32()),
                ),
                const SizedBox(height: 10),

                _SessionColorPickerRow(
                  label: isArabic ? 'السكاشن ✏️' : 'Sections ✏️',
                  typeKey: 'section',
                  currentColor: AppTheme.sessionColor('section', isDark, prefs.customSessionColors),
                  onSelect: (c) => context.read<PreferencesCubit>().setSessionColor('section', c.toARGB32()),
                ),
                const SizedBox(height: 10),

                _SessionColorPickerRow(
                  label: isArabic ? 'العملي والمعامل 💻' : 'Labs 💻',
                  typeKey: 'lab',
                  currentColor: AppTheme.sessionColor('lab', isDark, prefs.customSessionColors),
                  onSelect: (c) => context.read<PreferencesCubit>().setSessionColor('lab', c.toARGB32()),
                ),
                const SizedBox(height: 10),

                _SessionColorPickerRow(
                  label: isArabic ? 'الراحة ومشاريع التخرج ☕' : 'REST / Projects ☕',
                  typeKey: 'rest',
                  currentColor: AppTheme.sessionColor('rest', isDark, prefs.customSessionColors),
                  onSelect: (c) => context.read<PreferencesCubit>().setSessionColor('rest', c.toARGB32()),
                ),

                const SizedBox(height: 24),

                // Reset Colors Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<PreferencesCubit>().resetColors();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'تمت استعادة الألوان الافتراضية بنجاح' : 'Colors restored to defaults'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(isArabic ? 'استعادة الألوان الافتراضية' : 'Reset Colors to Default'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.getTextSecondary(context),
                      side: BorderSide(color: AppTheme.getBorder(context)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SessionColorPickerRow extends StatelessWidget {
  final String label;
  final String typeKey;
  final Color currentColor;
  final ValueChanged<Color> onSelect;

  const _SessionColorPickerRow({
    required this.label,
    required this.typeKey,
    required this.currentColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCardLight : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.getBorder(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          // Current color circle button
          GestureDetector(
            onTap: () => _showColorGrid(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: currentColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: currentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_drop_down, color: currentColor, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorGrid(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: AppPalettes.sessionOptions.map((c) {
              final isChosen = c.toARGB32() == currentColor.toARGB32();
              return GestureDetector(
                onTap: () {
                  onSelect(c);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isChosen ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isChosen ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
