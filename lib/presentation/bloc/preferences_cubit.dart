/// Preferences Cubit — manages student group/section selection, locale,
/// notifications, theme mode, and custom color palettes.
///
/// Persists all values to SharedPreferences.
library;

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// ── State ──

class PreferencesState extends Equatable {
  final String group;
  final int section;
  final Locale locale;
  final bool hasOnboarded;
  final bool notificationsEnabled;
  final Map<String, int> attendance; // subjectId → count attended
  final Map<String, int> absences; // subjectId → count absent
  final ThemeMode themeMode;
  final int primaryColorValue; // e.g. 0xFF6C63FF
  final Map<String, int> customSessionColors; // type → color int

  const PreferencesState({
    this.group = 'A',
    this.section = 1,
    this.locale = const Locale('ar'),
    this.hasOnboarded = false,
    this.notificationsEnabled = true,
    this.attendance = const {},
    this.absences = const {},
    this.themeMode = ThemeMode.dark,
    this.primaryColorValue = 0xFF6C63FF,
    this.customSessionColors = const {},
  });

  PreferencesState copyWith({
    String? group,
    int? section,
    Locale? locale,
    bool? hasOnboarded,
    bool? notificationsEnabled,
    Map<String, int>? attendance,
    Map<String, int>? absences,
    ThemeMode? themeMode,
    int? primaryColorValue,
    Map<String, int>? customSessionColors,
  }) {
    return PreferencesState(
      group: group ?? this.group,
      section: section ?? this.section,
      locale: locale ?? this.locale,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      attendance: attendance ?? this.attendance,
      absences: absences ?? this.absences,
      themeMode: themeMode ?? this.themeMode,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      customSessionColors: customSessionColors ?? this.customSessionColors,
    );
  }

  bool get isArabic => locale.languageCode == 'ar';
  bool get isDarkMode => themeMode == ThemeMode.dark;
  Color get primaryColor => Color(primaryColorValue);

  Color? getCustomSessionColor(String type) {
    final val = customSessionColors[type];
    return val != null ? Color(val) : null;
  }

  @override
  List<Object?> get props => [
        group,
        section,
        locale,
        hasOnboarded,
        notificationsEnabled,
        attendance,
        absences,
        themeMode,
        primaryColorValue,
        customSessionColors,
      ];
}

// ── Cubit ──

class PreferencesCubit extends Cubit<PreferencesState> {
  final SharedPreferences _prefs;

  PreferencesCubit(this._prefs) : super(const PreferencesState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final group = _prefs.getString(AppConstants.prefGroup) ?? 'A';
    final section = _prefs.getInt(AppConstants.prefSection) ?? 1;
    final localeCode = _prefs.getString(AppConstants.prefLocale) ?? 'ar';
    final onboarded = _prefs.getBool(AppConstants.prefOnboarded) ?? false;
    final notifs =
        _prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
    final themeStr = _prefs.getString(AppConstants.prefThemeMode);
    final themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    final primaryColor =
        _prefs.getInt(AppConstants.prefPrimaryColor) ?? 0xFF6C63FF;

    Map<String, int> sessionColors = {};
    final sessionColorsJson = _prefs.getString(AppConstants.prefSessionColors);
    if (sessionColorsJson != null) {
      try {
        final decoded =
            json.decode(sessionColorsJson) as Map<String, dynamic>;
        sessionColors = decoded.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    Map<String, int> attendance = {};
    final attendanceJson = _prefs.getString(AppConstants.prefAttendance);
    if (attendanceJson != null) {
      try {
        final decoded = json.decode(attendanceJson) as Map<String, dynamic>;
        attendance = decoded.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    Map<String, int> absences = {};
    final absencesJson = _prefs.getString(AppConstants.prefAbsences);
    if (absencesJson != null) {
      try {
        final decoded = json.decode(absencesJson) as Map<String, dynamic>;
        absences = decoded.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    emit(PreferencesState(
      group: group,
      section: section,
      locale: Locale(localeCode),
      hasOnboarded: onboarded,
      notificationsEnabled: notifs,
      attendance: attendance,
      absences: absences,
      themeMode: themeMode,
      primaryColorValue: primaryColor,
      customSessionColors: sessionColors,
    ));
  }

  /// Set group and section during onboarding or from settings.
  Future<void> setGroupAndSection(String group, int section) async {
    await _prefs.setString(AppConstants.prefGroup, group);
    await _prefs.setInt(AppConstants.prefSection, section);
    emit(state.copyWith(group: group, section: section));
  }

  /// Mark onboarding as complete.
  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.prefOnboarded, true);
    emit(state.copyWith(hasOnboarded: true));
  }

  /// Toggle locale between Arabic and English.
  Future<void> toggleLocale() async {
    final newLocale =
        state.isArabic ? const Locale('en') : const Locale('ar');
    await _prefs.setString(AppConstants.prefLocale, newLocale.languageCode);
    emit(state.copyWith(locale: newLocale));
  }

  /// Set a specific locale.
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(AppConstants.prefLocale, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  /// Toggle theme mode between dark and light.
  Future<void> toggleThemeMode() async {
    final nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  /// Set a specific theme mode (dark or light).
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  /// Set primary theme color.
  Future<void> setPrimaryColor(int colorValue) async {
    await _prefs.setInt(AppConstants.prefPrimaryColor, colorValue);
    emit(state.copyWith(primaryColorValue: colorValue));
  }

  /// Set custom color for a session type (lecture, section, lab, rest).
  Future<void> setSessionColor(String type, int colorValue) async {
    final updated = Map<String, int>.from(state.customSessionColors);
    updated[type] = colorValue;
    await _prefs.setString(
        AppConstants.prefSessionColors, json.encode(updated));
    emit(state.copyWith(customSessionColors: updated));
  }

  /// Reset all colors to defaults.
  Future<void> resetColors() async {
    await _prefs.remove(AppConstants.prefPrimaryColor);
    await _prefs.remove(AppConstants.prefSessionColors);
    emit(state.copyWith(
      primaryColorValue: 0xFF6C63FF,
      customSessionColors: const {},
    ));
  }

  /// Toggle notifications.
  Future<void> toggleNotifications() async {
    final newVal = !state.notificationsEnabled;
    await _prefs.setBool(AppConstants.prefNotificationsEnabled, newVal);
    emit(state.copyWith(notificationsEnabled: newVal));
  }

  // ── Attendance & Absences ──

  /// Increment attendance for a subject.
  Future<void> incrementAttendance(String subjectId) async {
    final updated = Map<String, int>.from(state.attendance);
    updated[subjectId] = (updated[subjectId] ?? 0) + 1;
    await _saveAttendance(updated);
    emit(state.copyWith(attendance: updated));
  }

  /// Decrement attendance for a subject (min 0).
  Future<void> decrementAttendance(String subjectId) async {
    final updated = Map<String, int>.from(state.attendance);
    final current = updated[subjectId] ?? 0;
    if (current > 0) {
      updated[subjectId] = current - 1;
      await _saveAttendance(updated);
      emit(state.copyWith(attendance: updated));
    }
  }

  /// Increment absence for a subject.
  Future<void> incrementAbsence(String subjectId) async {
    final updated = Map<String, int>.from(state.absences);
    updated[subjectId] = (updated[subjectId] ?? 0) + 1;
    await _saveAbsences(updated);
    emit(state.copyWith(absences: updated));
  }

  /// Decrement absence for a subject (min 0).
  Future<void> decrementAbsence(String subjectId) async {
    final updated = Map<String, int>.from(state.absences);
    final current = updated[subjectId] ?? 0;
    if (current > 0) {
      updated[subjectId] = current - 1;
      await _saveAbsences(updated);
      emit(state.copyWith(absences: updated));
    }
  }

  /// Reset all attendance and absence counters.
  Future<void> resetAttendance() async {
    await _prefs.remove(AppConstants.prefAttendance);
    await _prefs.remove(AppConstants.prefAbsences);
    emit(state.copyWith(attendance: {}, absences: {}));
  }

  Future<void> _saveAttendance(Map<String, int> data) async {
    await _prefs.setString(AppConstants.prefAttendance, json.encode(data));
  }

  Future<void> _saveAbsences(Map<String, int> data) async {
    await _prefs.setString(AppConstants.prefAbsences, json.encode(data));
  }
}
