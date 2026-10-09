/// Domain entity representing a single schedule entry (lecture, lab, section, or project).
///
/// Immutable value object — no Flutter/JSON dependencies here.
library;

import 'package:equatable/equatable.dart';

class ScheduleEntry extends Equatable {
  final String subjectId;
  final String subjectNameAr;
  final String subjectNameEn;
  final String type; // lecture | lab | section | project
  final String day; // saturday, sunday, …
  final String startTime; // "08:45"
  final String endTime; // "10:15"
  final String locationId;
  final String locationNameAr;
  final String locationNameEn;
  final String locationType; // hall | lab | room
  final String instructorId;
  final String instructorNameAr;
  final String instructorNameEn;
  final List<String> instructors;
  final List<int> forSections; // empty list means ALL sections in the group
  final bool isForAllSections;
  final String? noteAr;
  final String? noteEn;
  final String subjectColor;
  final String group; // A or B
  final List<String>? periods; // Optional sub-periods (e.g. ["11:20 AM - 11:55 AM", "11:55 AM - 12:30 PM"])

  const ScheduleEntry({
    required this.subjectId,
    required this.subjectNameAr,
    required this.subjectNameEn,
    required this.type,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.locationId,
    required this.locationNameAr,
    required this.locationNameEn,
    required this.locationType,
    required this.instructorId,
    required this.instructorNameAr,
    required this.instructorNameEn,
    this.instructors = const [],
    required this.forSections,
    required this.isForAllSections,
    this.noteAr,
    this.noteEn,
    required this.subjectColor,
    required this.group,
    this.periods,
  });

  /// Returns the subject name based on locale.
  String subjectName(bool isArabic) => isArabic ? subjectNameAr : subjectNameEn;

  /// Returns the location display name based on locale.
  String locationName(bool isArabic) => isArabic ? locationNameAr : locationNameEn;

  /// Returns the instructor display name based on locale (stripped of any invalid digits).
  String instructorName(bool isArabic) {
    if (instructors.isNotEmpty) {
      final cleanedList = instructors
          .map((i) => i.replaceAll(RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]'), '').trim())
          .where((i) => i.isNotEmpty)
          .toList();
      if (cleanedList.isNotEmpty) return cleanedList.join(' / ');
    }
    final name = isArabic ? instructorNameAr : instructorNameEn;
    return name.replaceAll(RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]'), '').trim();
  }

  /// Parses instructor data (string with separators or list) into a list of names,
  /// removing any numbers in Arabic or English digits.
  static List<String> parseInstructors(dynamic raw) {
    if (raw == null) return const [];
    final List<String> rawStrings = [];
    if (raw is List) {
      for (final e in raw) {
        if (e != null) rawStrings.add(e.toString());
      }
    } else {
      rawStrings.add(raw.toString());
    }

    final List<String> result = [];
    final regex = RegExp(r'[/،,\n\r]+');
    for (final str in rawStrings) {
      final parts = str.split(regex);
      for (final part in parts) {
        final cleaned = part.replaceAll(RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]'), '').trim();
        if (cleaned.isNotEmpty && cleaned.replaceAll(RegExp(r'[^a-zA-Z\u0621-\u064A]'), '').isNotEmpty) {
          result.add(cleaned);
        }
      }
    }
    return result;
  }

  /// Returns the note based on locale.
  String? note(bool isArabic) => isArabic ? noteAr : noteEn;

  static String _normalizeDigits(String input) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var i = 0; i < 10; i++) {
      input = input.replaceAll(arabicIndic[i], '$i');
    }
    return input;
  }

  static (int hour, int minute) _parseTime(String timeStr) {
    final clean = _normalizeDigits(timeStr.trim().toUpperCase());
    final isPM = clean.contains('PM') || clean.contains('م');
    final isAM = clean.contains('AM') || clean.contains('ص');
    final digits = clean
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .replaceAll('ص', '')
        .replaceAll('م', '')
        .trim();
    final parts = digits.split(':');
    if (parts.length < 2) return (0, 0);
    var hour = int.tryParse(parts[0].trim()) ?? 0;
    final minute = int.tryParse(parts[1].trim()) ?? 0;
    if (isPM && hour < 12) hour += 12;
    if (isAM && hour == 12) hour = 0;
    return (hour, minute);
  }

  /// Parses a time string into 24-hour (hour, minute).
  static (int hour, int minute) parseTime(String timeStr) => _parseTime(timeStr);

  /// Formats a time string (e.g. "09:00 AM") for the current locale ("09:00 ص" or "09:00 AM").
  static String formatSingleTime(String timeStr, bool isArabic) {
    if (!isArabic) {
      return timeStr.replaceAll('ص', 'AM').replaceAll('م', 'PM');
    }
    return timeStr
        .replaceAll('AM', 'ص')
        .replaceAll('am', 'ص')
        .replaceAll('PM', 'م')
        .replaceAll('pm', 'م');
  }

  /// Formatted single start time: e.g. "09:00 ص" or "09:00 AM"
  String startTimeFormatted(bool isArabic) => formatSingleTime(startTime, isArabic);

  /// Formatted time range: e.g. "09:00 ص – 10:45 ص" or "09:00 AM – 10:45 AM"
  String timeRange(bool isArabic) {
    return '${formatSingleTime(startTime, isArabic)} – ${formatSingleTime(endTime, isArabic)}';
  }

  /// Formats an individual period string like "11:20 AM - 11:55 AM" to localized "11:20 ص – 11:55 ص"
  static String formatPeriodString(String periodStr, bool isArabic) {
    final parts = periodStr.split('-');
    if (parts.length == 2) {
      return '${formatSingleTime(parts[0].trim(), isArabic)} – ${formatSingleTime(parts[1].trim(), isArabic)}';
    }
    return formatSingleTime(periodStr, isArabic);
  }

  /// Returns localized period strings if multiple periods exist, or single timeRange otherwise.
  List<String> formattedPeriods(bool isArabic) {
    if (periods != null && periods!.length > 1) {
      return periods!.map((p) => formatPeriodString(p, isArabic)).toList();
    }
    return [timeRange(isArabic)];
  }

  /// True if this entry spans multiple sub-periods.
  bool get hasMultiplePeriods => periods != null && periods!.length > 1;

  /// Parses "HH:mm" or "hh:mm AM/PM" into hour & minute (24h).
  (int hour, int minute) get startTimeParts => _parseTime(startTime);

  (int hour, int minute) get endTimeParts => _parseTime(endTime);

  /// Duration in minutes.
  int get durationMinutes {
    final (sh, sm) = startTimeParts;
    final (eh, em) = endTimeParts;
    return (eh * 60 + em) - (sh * 60 + sm);
  }

  /// Whether this entry is a lecture
  bool get isLecture => type == 'lecture';

  /// Whether this entry is a practical section/lab
  bool get isSection => type == 'section' || type == 'lab';

  /// Whether this entry is relevant for a given section number.
  bool isRelevantForSection(int section) {
    if (type == 'lecture' || type == 'rest' || type == 'project' || isForAllSections) return true;
    return forSections.contains(section);
  }

  /// Type display label (Strictly Lecture / Section / REST).
  String typeLabel(bool isArabic) {
    if (type == 'lecture') {
      return isArabic ? 'محاضرة' : 'Lecture';
    } else if (type == 'rest' || type == 'project') {
      return isArabic ? 'ريست' : 'REST';
    } else if (type == 'lab') {
      return isArabic ? 'عملي' : 'Lab';
    } else {
      return isArabic ? 'سكشن' : 'Section';
    }
  }

  /// Unique key to identify this entry
  String get uniqueKey => '${group}_${day}_${startTime}_${locationId}_$subjectId';

  ScheduleEntry copyWith({
    String? subjectId,
    String? subjectNameAr,
    String? subjectNameEn,
    String? type,
    String? day,
    String? startTime,
    String? endTime,
    String? locationId,
    String? locationNameAr,
    String? locationNameEn,
    String? locationType,
    String? instructorId,
    String? instructorNameAr,
    String? instructorNameEn,
    List<String>? instructors,
    List<int>? forSections,
    bool? isForAllSections,
    String? noteAr,
    String? noteEn,
    String? subjectColor,
    String? group,
    List<String>? periods,
  }) {
    return ScheduleEntry(
      subjectId: subjectId ?? this.subjectId,
      subjectNameAr: subjectNameAr ?? this.subjectNameAr,
      subjectNameEn: subjectNameEn ?? this.subjectNameEn,
      type: type ?? this.type,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      locationId: locationId ?? this.locationId,
      locationNameAr: locationNameAr ?? this.locationNameAr,
      locationNameEn: locationNameEn ?? this.locationNameEn,
      locationType: locationType ?? this.locationType,
      instructorId: instructorId ?? this.instructorId,
      instructorNameAr: instructorNameAr ?? this.instructorNameAr,
      instructorNameEn: instructorNameEn ?? this.instructorNameEn,
      instructors: instructors ?? this.instructors,
      forSections: forSections ?? this.forSections,
      isForAllSections: isForAllSections ?? this.isForAllSections,
      noteAr: noteAr ?? this.noteAr,
      noteEn: noteEn ?? this.noteEn,
      subjectColor: subjectColor ?? this.subjectColor,
      group: group ?? this.group,
      periods: periods ?? this.periods,
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'subjectNameAr': subjectNameAr,
        'subjectNameEn': subjectNameEn,
        'type': type,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
        'locationId': locationId,
        'locationNameAr': locationNameAr,
        'locationNameEn': locationNameEn,
        'locationType': locationType,
        'instructorId': instructorId,
        'instructorNameAr': instructorNameAr,
        'instructorNameEn': instructorNameEn,
        'instructors': instructors,
        'forSections': forSections,
        'isForAllSections': isForAllSections,
        'noteAr': noteAr,
        'noteEn': noteEn,
        'subjectColor': subjectColor,
        'group': group,
        'periods': periods,
      };

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    final rawInstructors = json['instructors'] ?? json['instructor'];
    final instructors = parseInstructors(rawInstructors);
    return ScheduleEntry(
      subjectId: json['subjectId'] as String? ?? 'general',
      subjectNameAr: json['subjectNameAr'] as String? ?? '',
      subjectNameEn: json['subjectNameEn'] as String? ?? '',
      type: json['type'] as String? ?? 'section',
      day: json['day'] as String? ?? 'saturday',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      locationNameAr: json['locationNameAr'] as String? ?? '',
      locationNameEn: json['locationNameEn'] as String? ?? '',
      locationType: json['locationType'] as String? ?? 'room',
      instructorId: json['instructorId'] as String? ?? '',
      instructorNameAr: json['instructorNameAr'] as String? ?? '',
      instructorNameEn: json['instructorNameEn'] as String? ?? '',
      instructors: instructors.isNotEmpty
          ? instructors
          : (json['instructors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      forSections: (json['forSections'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .where((s) => s > 0)
              .toList() ??
          const [],
      isForAllSections: json['isForAllSections'] as bool? ?? false,
      noteAr: json['noteAr'] as String?,
      noteEn: json['noteEn'] as String?,
      subjectColor: json['subjectColor'] as String? ?? '#6C63FF',
      group: json['group'] as String? ?? 'A',
      periods: (json['periods'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        subjectId, type, day, startTime, endTime, locationId,
        instructorId, instructors, forSections, group, periods,
      ];
}
