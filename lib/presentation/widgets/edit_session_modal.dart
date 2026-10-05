/// Edit/Add Session Modal — allows students to modify any class details
/// (subject, room, instructor, start/end time, type) directly from the schedule card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/schedule_entry.dart';
import '../bloc/preferences_cubit.dart';
import '../bloc/schedule_cubit.dart';

class EditSessionModal extends StatefulWidget {
  final ScheduleEntry? entry;
  final String? initialDay;
  final String? initialGroup;

  const EditSessionModal({
    super.key,
    this.entry,
    this.initialDay,
    this.initialGroup,
  });

  static void show(
    BuildContext context, {
    ScheduleEntry? entry,
    String? initialDay,
    String? initialGroup,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditSessionModal(
        entry: entry,
        initialDay: initialDay,
        initialGroup: initialGroup,
      ),
    );
  }

  @override
  State<EditSessionModal> createState() => _EditSessionModalState();
}

class _EditSessionModalState extends State<EditSessionModal> {
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _roomCtrl;
  late final TextEditingController _instructorCtrl;
  late final TextEditingController _startTimeCtrl;
  late final TextEditingController _endTimeCtrl;
  late final TextEditingController _noteCtrl;

  late String _selectedType;
  late String _selectedDay;
  late String _group;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _subjectCtrl = TextEditingController(text: e?.subjectNameAr ?? '');
    _roomCtrl = TextEditingController(text: e?.locationNameAr ?? '');
    _instructorCtrl = TextEditingController(
      text: e != null && e.instructors.isNotEmpty
          ? e.instructors.join(' / ')
          : (e?.instructorNameAr ?? ''),
    );
    _startTimeCtrl = TextEditingController(text: e?.startTime ?? '');
    _endTimeCtrl = TextEditingController(text: e?.endTime ?? '');
    _noteCtrl = TextEditingController(text: e?.noteAr ?? '');

    _selectedType = e?.type ?? 'section';
    _selectedDay = e?.day ?? widget.initialDay ?? 'saturday';
    _group = e?.group ?? widget.initialGroup ?? 'A';
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _roomCtrl.dispose();
    _instructorCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);

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

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing
                      ? (isArabic ? 'تعديل بيانات المحاضرة' : 'Edit Lecture Details')
                      : (isArabic ? 'إضافة محاضرة جديدة' : 'Add New Lecture'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                if (_isEditing)
                  IconButton(
                    tooltip: isArabic ? 'حذف المحاضرة' : 'Delete',
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 22),
                    onPressed: () => _confirmDelete(context, loc),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Subject Name ──
            _buildFieldLabel(isArabic ? 'اسم المادة' : 'Subject Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _subjectCtrl,
              decoration: InputDecoration(
                hintText: isArabic ? 'مثال: نظم دعم القرار' : 'e.g. Decision Support Systems',
                prefixIcon: const Icon(Icons.menu_book_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // ── Session Type Selector ──
            _buildFieldLabel(isArabic ? 'نوع المحاضرة / السكشن' : 'Session Type'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _typeChip('lecture', isArabic ? 'محاضرة 🎓' : 'Lecture 🎓'),
                  const SizedBox(width: 8),
                  _typeChip('section', isArabic ? 'سكشن ✏️' : 'Section ✏️'),
                  const SizedBox(width: 8),
                  _typeChip('lab', isArabic ? 'عملي 💻' : 'Lab 💻'),
                  const SizedBox(width: 8),
                  _typeChip('rest', isArabic ? 'ريست / مشروع ☕' : 'REST ☕'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Location & Instructor Row ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(isArabic ? 'القاعة أو المعمل' : 'Room / Hall'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _roomCtrl,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'مثال: مدرج A أو معمل 1' : 'Hall A or Lab 1',
                          prefixIcon: const Icon(Icons.location_on_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(isArabic ? 'الدكتور / المعيد' : 'Instructor'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _instructorCtrl,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'اسم الدكتور أو المعيد' : 'Instructor name',
                          prefixIcon: const Icon(Icons.person_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Time & Day Row ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(isArabic ? 'وقت البدء' : 'Start Time'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _startTimeCtrl,
                        decoration: InputDecoration(
                          hintText: isArabic ? '08:45 ص' : '08:45 AM',
                          prefixIcon: const Icon(Icons.access_time_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(isArabic ? 'وقت الانتهاء' : 'End Time'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _endTimeCtrl,
                        decoration: InputDecoration(
                          hintText: isArabic ? '10:15 ص' : '10:15 AM',
                          prefixIcon: const Icon(Icons.access_time_filled_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Day Selector ──
            _buildFieldLabel(isArabic ? 'اليوم' : 'Day'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppConstants.daysEn.map((dayKey) {
                  final idx = AppConstants.daysEn.indexOf(dayKey);
                  final label = isArabic
                      ? AppConstants.daysArDisplay[idx]
                      : AppConstants.daysEnDisplay[idx];
                  final isSelected = dayKey == _selectedDay;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = dayKey),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : (isDark ? AppTheme.bgCardLight : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : AppTheme.getBorder(context),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Notes (Optional) ──
            _buildFieldLabel(isArabic ? 'ملاحظة (اختياري)' : 'Note (Optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: isArabic ? 'أي ملاحظة إضافية تود ظهورها على الكارت...' : 'Additional note...',
              ),
            ),
            const SizedBox(height: 24),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _save(context),
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text(
                  _isEditing
                      ? (isArabic ? 'حفظ التعديلات' : 'Save Changes')
                      : (isArabic ? 'إضافة إلى الجدول' : 'Add to Schedule'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextSecondary(context),
      ),
    );
  }

  Widget _typeChip(String type, String label) {
    final isSelected = _selectedType == type;
    final color = AppTheme.sessionColor(type, AppTheme.isDark(context));

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isSelected ? 1.0 : 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final subject = _subjectCtrl.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'يرجى إدخال اسم المادة' : 'Please enter subject name')),
      );
      return;
    }

    final room = _roomCtrl.text.trim();
    final instructor = _instructorCtrl.text.trim();
    final defaultStart = isArabic ? '08:45 ص' : '08:45 AM';
    final defaultEnd = isArabic ? '10:15 ص' : '10:15 AM';
    final startTime = _startTimeCtrl.text.trim().isNotEmpty
        ? _startTimeCtrl.text.trim()
        : defaultStart;
    final endTime = _endTimeCtrl.text.trim().isNotEmpty
        ? _endTimeCtrl.text.trim()
        : defaultEnd;
    final note = _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null;

    final instructors = ScheduleEntry.parseInstructors(instructor);

    if (_isEditing) {
      final original = widget.entry!;
      final updated = original.copyWith(
        subjectNameAr: subject,
        subjectNameEn: subject,
        locationNameAr: room,
        locationNameEn: room,
        instructorNameAr: instructor,
        instructorNameEn: instructor,
        instructors: instructors,
        startTime: startTime,
        endTime: endTime,
        type: _selectedType,
        day: _selectedDay,
        noteAr: note,
        noteEn: note,
      );

      context.read<ScheduleCubit>().updateScheduleEntry(original, updated);
    } else {
      final prefs = context.read<PreferencesCubit>().state;
      final newEntry = ScheduleEntry(
        subjectId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        subjectNameAr: subject,
        subjectNameEn: subject,
        type: _selectedType,
        day: _selectedDay,
        startTime: startTime,
        endTime: endTime,
        locationId: room.toLowerCase().replaceAll(' ', '_'),
        locationNameAr: room,
        locationNameEn: room,
        locationType: _selectedType == 'lab' ? 'lab' : 'room',
        instructorId: instructor.toLowerCase().replaceAll(' ', '_'),
        instructorNameAr: instructor,
        instructorNameEn: instructor,
        instructors: instructors,
        forSections: [prefs.section],
        isForAllSections: _selectedType == 'lecture' || _selectedType == 'rest',
        subjectColor: '#6C63FF',
        group: _group,
        noteAr: note,
        noteEn: note,
      );

      context.read<ScheduleCubit>().addScheduleEntry(newEntry);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? (isArabic ? '✅ تم تحديث بيانات المحاضرة بنجاح' : '✅ Lecture updated successfully')
              : (isArabic ? '✅ تمت إضافة المحاضرة إلى الجدول بنجاح' : '✅ Lecture added to schedule successfully'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.isArabic ? 'حذف المحاضرة' : 'Delete Lecture'),
        content: Text(loc.isArabic ? 'هل أنت متأكد من حذف هذه المحاضرة من جدولك الدراسي؟' : 'Are you sure you want to delete this lecture from your timetable?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ScheduleCubit>().deleteScheduleEntry(widget.entry!);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.isArabic ? '🗑️ تم حذف المحاضرة من الجدول' : 'Lecture deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(loc.isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
