/// Schedule BLoC — manages timetable state using Cubit.
/// Handles loading schedule, Friday detection, smart next class finder, and section filtering.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/schedule_entry.dart';
import '../../domain/repositories/schedule_repository.dart';

// ── State ──

enum ScheduleViewMode { today, week }

class ScheduleState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final ScheduleViewMode viewMode;
  final String group;
  final int section;
  final String currentDay; // e.g. "friday", "saturday"
  final List<ScheduleEntry> todayEntries;
  final Map<String, List<ScheduleEntry>> weekEntries;
  final ScheduleEntry? nextClass;
  final String? nextClassDay; // e.g. "saturday"
  final int selectedWeekDayIndex;

  const ScheduleState({
    this.isLoading = true,
    this.errorMessage,
    this.viewMode = ScheduleViewMode.today,
    this.group = 'A',
    this.section = 1,
    this.currentDay = 'saturday',
    this.todayEntries = const [],
    this.weekEntries = const {},
    this.nextClass,
    this.nextClassDay,
    this.selectedWeekDayIndex = 0,
  });

  bool get isFriday => currentDay == 'friday';

  ScheduleState copyWith({
    bool? isLoading,
    String? errorMessage,
    ScheduleViewMode? viewMode,
    String? group,
    int? section,
    String? currentDay,
    List<ScheduleEntry>? todayEntries,
    Map<String, List<ScheduleEntry>>? weekEntries,
    ScheduleEntry? nextClass,
    String? nextClassDay,
    int? selectedWeekDayIndex,
    bool clearError = false,
    bool clearNextClass = false,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      viewMode: viewMode ?? this.viewMode,
      group: group ?? this.group,
      section: section ?? this.section,
      currentDay: currentDay ?? this.currentDay,
      todayEntries: todayEntries ?? this.todayEntries,
      weekEntries: weekEntries ?? this.weekEntries,
      nextClass: clearNextClass ? null : (nextClass ?? this.nextClass),
      nextClassDay: clearNextClass ? null : (nextClassDay ?? this.nextClassDay),
      selectedWeekDayIndex: selectedWeekDayIndex ?? this.selectedWeekDayIndex,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        viewMode,
        group,
        section,
        currentDay,
        todayEntries,
        weekEntries,
        nextClass,
        nextClassDay,
        selectedWeekDayIndex,
      ];
}

// ── Cubit ──

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleCubit(this._repository) : super(const ScheduleState());

  /// Load schedule for [group] / [section].
  Future<void> loadSchedule(String group, int section) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final today = _todayKey();
      final weekEntries = await _repository.getWeeklySchedule(group, section);
      final todayEntries = today == 'friday'
          ? <ScheduleEntry>[]
          : (weekEntries[today] ?? []);

      final (nextClass, nextClassDay) = _findNextUpcomingClass(today, weekEntries);

      final todayIdx = AppConstants.daysEn.indexOf(today);
      final initialWeekIdx = todayIdx >= 0 ? todayIdx : 0;

      emit(state.copyWith(
        isLoading: false,
        group: group,
        section: section,
        currentDay: today,
        todayEntries: todayEntries,
        weekEntries: weekEntries,
        nextClass: nextClass,
        nextClassDay: nextClassDay,
        selectedWeekDayIndex: initialWeekIdx,
        clearNextClass: nextClass == null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Toggle between Today and Week views.
  void toggleView() {
    final newMode = state.viewMode == ScheduleViewMode.today
        ? ScheduleViewMode.week
        : ScheduleViewMode.today;
    emit(state.copyWith(viewMode: newMode));
  }

  /// Set view mode explicitly.
  void setViewMode(ScheduleViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  /// Switch to Week view and select a specific day.
  void selectWeekDay(int index) {
    emit(state.copyWith(
      viewMode: ScheduleViewMode.week,
      selectedWeekDayIndex: index,
    ));
  }

  /// Refresh the next class indicator periodically.
  void refreshNextClass() {
    final (nextClass, nextClassDay) =
        _findNextUpcomingClass(state.currentDay, state.weekEntries);
    emit(state.copyWith(
      nextClass: nextClass,
      nextClassDay: nextClassDay,
      clearNextClass: nextClass == null,
    ));
  }

  /// Maps actual DateTime weekday to schedule key.
  String _todayKey() {
    final now = DateTime.now();
    const map = {
      DateTime.saturday: 'saturday',
      DateTime.sunday: 'sunday',
      DateTime.monday: 'monday',
      DateTime.tuesday: 'tuesday',
      DateTime.wednesday: 'wednesday',
      DateTime.thursday: 'thursday',
      DateTime.friday: 'friday',
    };
    return map[now.weekday] ?? 'saturday';
  }

  /// Smart finder for the next upcoming class across days.
  (ScheduleEntry?, String?) _findNextUpcomingClass(
    String currentDay,
    Map<String, List<ScheduleEntry>> weekEntries,
  ) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // 1. Check if there is an upcoming class today
    if (currentDay != 'friday') {
      final todayList = weekEntries[currentDay] ?? [];
      for (final entry in todayList) {
        if (entry.type == 'rest' || entry.type == 'project') continue;
        final (h, m) = entry.startTimeParts;
        if (h * 60 + m > nowMinutes) {
          return (entry, currentDay);
        }
      }
    }

    // 2. If no remaining classes today (or it's Friday), find the next day with classes
    const orderedDays = [
      'saturday',
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
    ];

    int startIdx = 0;
    if (currentDay != 'friday') {
      final curIdx = orderedDays.indexOf(currentDay);
      startIdx = (curIdx + 1) % orderedDays.length;
    }

    for (var i = 0; i < orderedDays.length; i++) {
      final dayKey = orderedDays[(startIdx + i) % orderedDays.length];
      final dayEntries = (weekEntries[dayKey] ?? [])
          .where((e) => e.type != 'rest' && e.type != 'project')
          .toList();
      if (dayEntries.isNotEmpty) {
        return (dayEntries.first, dayKey);
      }
    }

    return (null, null);
  }

  /// Update an existing entry
  Future<void> updateScheduleEntry(ScheduleEntry original, ScheduleEntry updated) async {
    await _repository.updateEntry(original, updated);
    await loadSchedule(state.group, state.section);
  }

  /// Add a brand new schedule entry
  Future<void> addScheduleEntry(ScheduleEntry newEntry) async {
    await _repository.addEntry(newEntry);
    await loadSchedule(state.group, state.section);
  }

  /// Delete an entry
  Future<void> deleteScheduleEntry(ScheduleEntry entry) async {
    await _repository.deleteEntry(entry);
    await loadSchedule(state.group, state.section);
  }

  /// Reset to original default schedule
  Future<void> resetScheduleToDefault() async {
    await _repository.resetScheduleToDefault();
    await loadSchedule(state.group, state.section);
  }

  /// Check if schedule has custom edits
  Future<bool> hasCustomEdits() => _repository.hasCustomSchedule();
}
