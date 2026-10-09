/// Edit/Add Session Modal — allows students to modify any class details
/// (subject, room, instructor, start/end time, type) directly from the schedule card.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final ScrollController? scrollController;

  const EditSessionModal({
    super.key,
    this.entry,
    this.initialDay,
    this.initialGroup,
    this.scrollController,
  });

  static void show(
    BuildContext context, {
    ScheduleEntry? entry,
    String? initialDay,
    String? initialGroup,
  }) {
    final scheduleCubit = context.read<ScheduleCubit>();
    final prefsCubit = context.read<PreferencesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ScheduleCubit>.value(value: scheduleCubit),
          BlocProvider<PreferencesCubit>.value(value: prefsCubit),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.35,
          maxChildSize: 0.96,
          expand: false,
          builder: (sheetContext, scrollController) => EditSessionModal(
            entry: entry,
            initialDay: initialDay,
            initialGroup: initialGroup,
            scrollController: scrollController,
          ),
        ),
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

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _subjectError;
  String? _roomError;
  String? _instructorError;
  String? _timeError;

  bool get _isEditing => widget.entry != null;

  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final periodStr = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minuteStr $periodStr';
  }

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
    _noteCtrl = TextEditingController(text: e?.noteAr ?? '');

    if (e != null) {
      final (sh, sm) = ScheduleEntry.parseTime(e.startTime);
      _startTime = TimeOfDay(hour: sh, minute: sm);
      final (eh, em) = ScheduleEntry.parseTime(e.endTime);
      _endTime = TimeOfDay(hour: eh, minute: em);
    } else {
      _startTime = const TimeOfDay(hour: 8, minute: 45);
      _endTime = const TimeOfDay(hour: 10, minute: 15);
    }

    _startTimeCtrl = TextEditingController(text: _formatTimeOfDay(_startTime!));
    _endTimeCtrl = TextEditingController(text: _formatTimeOfDay(_endTime!));

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

  Future<void> _pickTime({required bool isStart}) async {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 8, minute: 45))
        : (_endTime ?? const TimeOfDay(hour: 10, minute: 15));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart
          ? (isArabic ? 'اختر وقت البدء' : 'Select Start Time')
          : (isArabic ? 'اختر وقت الانتهاء' : 'Select End Time'),
      cancelText: loc.cancel,
      confirmText: isArabic ? 'تأكيد' : 'OK',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          _startTimeCtrl.text = _formatTimeOfDay(picked);
        } else {
          _endTime = picked;
          _endTimeCtrl.text = _formatTimeOfDay(picked);
        }
        _timeError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);

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
                  Navigator.of(context).pop();
                }
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
                  Navigator.of(context).pop();
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

            // Header Row with Title, Delete (if editing), and Always-Visible Close Button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 10) {
                  Navigator.of(context).pop();
                }
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
                  Navigator.of(context).pop();
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
                      child: Icon(
                        _isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          _isEditing
                              ? (isArabic ? 'تعديل بيانات المحاضرة' : 'Edit Lecture Details')
                              : (isArabic ? 'إضافة محاضرة جديدة' : 'Add New Lecture'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ),
                    ),
                    if (_isEditing)
                      IconButton(
                        tooltip: isArabic ? 'حذف المحاضرة' : 'Delete',
                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 22),
                        onPressed: () => _confirmDelete(context, loc),
                      ),
                    IconButton(
                      tooltip: isArabic ? 'إغلاق' : 'Close',
                      icon: Icon(Icons.close_rounded, color: AppTheme.getTextSecondary(context), size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.getBorder(context)),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Subject Name ──
                    _buildFieldLabel(isArabic ? 'اسم المادة' : 'Subject Name'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _subjectCtrl,
                      onChanged: (_) {
                        if (_subjectError != null) setState(() => _subjectError = null);
                      },
                      decoration: InputDecoration(
                        hintText: isArabic ? 'مثال: نظم دعم القرار' : 'e.g. Decision Support Systems',
                        prefixIcon: const Icon(Icons.menu_book_rounded, size: 20),
                        errorText: _subjectError,
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
                                onChanged: (_) {
                                  if (_roomError != null) setState(() => _roomError = null);
                                },
                                decoration: InputDecoration(
                                  hintText: isArabic ? 'مثال: مدرج A أو معمل 1' : 'Hall A or Lab 1',
                                  prefixIcon: const Icon(Icons.location_on_rounded, size: 18),
                                  errorText: _roomError,
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]')),
                                ],
                                onChanged: (_) {
                                  if (_instructorError != null) setState(() => _instructorError = null);
                                },
                                decoration: InputDecoration(
                                  hintText: isArabic ? 'اسم الدكتور أو المعيد' : 'Instructor name',
                                  prefixIcon: const Icon(Icons.person_rounded, size: 18),
                                  errorText: _instructorError,
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
                              _buildFieldLabel(isArabic ? 'وقت البدء (ص / م)' : 'Start Time'),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _pickTime(isStart: true),
                                borderRadius: BorderRadius.circular(12),
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: _startTimeCtrl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: isArabic ? '08:45 ص' : '08:45 AM',
                                      prefixIcon: const Icon(Icons.access_time_rounded, size: 18),
                                    ),
                                  ),
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
                              _buildFieldLabel(isArabic ? 'وقت الانتهاء (ص / م)' : 'End Time'),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _pickTime(isStart: false),
                                borderRadius: BorderRadius.circular(12),
                                child: IgnorePointer(
                                  child: TextField(
                                    controller: _endTimeCtrl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: isArabic ? '10:15 ص' : '10:15 AM',
                                      prefixIcon: const Icon(Icons.access_time_filled_rounded, size: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_timeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 16, color: AppTheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _timeError!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
      onTap: () {
        setState(() {
          _selectedType = type;
          if (type == 'rest') {
            _roomError = null;
            _instructorError = null;
          }
        });
      },
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
    final room = _roomCtrl.text.trim();
    final instructor = _instructorCtrl.text.trim();

    String? subjectErr;
    String? roomErr;
    String? instructorErr;
    String? timeErr;

    if (subject.isEmpty) {
      subjectErr = isArabic ? 'يرجى إدخال اسم المادة' : 'Please enter subject name';
    } else if (subject.length < 2) {
      subjectErr = isArabic ? 'اسم المادة قصير جداً (حرفين على الأقل)' : 'Subject name is too short (at least 2 letters)';
    }

    final isAcademic = _selectedType != 'rest';

    if (isAcademic) {
      if (room.isEmpty) {
        roomErr = isArabic ? 'يرجى تحديد القاعة أو المعمل' : 'Please specify room or lab';
      } else if (room.length < 2) {
        roomErr = isArabic ? 'اسم القاعة أو المعمل غير صالح' : 'Invalid room or lab';
      }

      if (instructor.isEmpty) {
        instructorErr = isArabic ? 'يرجى إدخال اسم الدكتور أو المعيد' : 'Please enter instructor name';
      } else if (RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]').hasMatch(instructor)) {
        instructorErr = isArabic ? 'اسم الدكتور أو المعيد لا يمكن أن يحتوي على أرقام' : 'Instructor name cannot contain numbers';
      } else if (instructor.replaceAll(RegExp(r'[^a-zA-Z\u0621-\u064A]'), '').length < 2) {
        instructorErr = isArabic ? 'اسم المحاضر غير صالح' : 'Invalid instructor name';
      }
    }

    if (_startTime == null || _endTime == null) {
      timeErr = isArabic ? 'يرجى تحديد وقت البدء ووقت الانتهاء' : 'Please set start and end time';
    } else {
      final startMin = _startTime!.hour * 60 + _startTime!.minute;
      final endMin = _endTime!.hour * 60 + _endTime!.minute;
      if (endMin <= startMin) {
        timeErr = isArabic ? 'وقت الانتهاء يجب أن يكون بعد وقت البدء' : 'End time must be after start time';
      }
    }

    if (subjectErr != null || roomErr != null || instructorErr != null || timeErr != null) {
      setState(() {
        _subjectError = subjectErr;
        _roomError = roomErr;
        _instructorError = instructorErr;
        _timeError = timeErr;
      });

      final firstError = subjectErr ?? roomErr ?? instructorErr ?? timeErr;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firstError!),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final startTime = _formatTimeOfDay(_startTime!);
    final endTime = _formatTimeOfDay(_endTime!);
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: loc.isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(loc.isArabic ? 'حذف المحاضرة' : 'Delete Lecture'),
        ),
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
