/// Local data source — parses `schedule.json` or `bis_schedule.json` from assets into domain entities.
///
/// Decoupled from presentation: this is the single place that understands the JSON shape.
library;

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/schedule_entry.dart';

class LocalScheduleDataSource {
  List<ScheduleEntry>? _cachedEntries;
  static const String _prefCustomScheduleKey = 'custom_user_schedule_json';

  /// Loads and flattens the JSON schedule into a list of [ScheduleEntry].
  ///
  /// Checks local user edits in SharedPreferences first; falls back to asset JSON.
  Future<List<ScheduleEntry>> loadSchedule({bool forceReload = false}) async {
    if (_cachedEntries != null && !forceReload) return _cachedEntries!;

    // 1. Check if user has saved custom schedule
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_prefCustomScheduleKey);
      if (customJson != null && customJson.isNotEmpty) {
        final decoded = json.decode(customJson);
        if (decoded is List) {
          final entries = <ScheduleEntry>[];
          for (final raw in decoded) {
            if (raw is Map<String, dynamic>) {
              entries.add(ScheduleEntry.fromJson(raw));
            }
          }
          if (entries.isNotEmpty) {
            _cachedEntries = entries;
            return entries;
          }
        }
      }
    } catch (_) {
      // Fall back to default asset on error
    }

    // 2. Load from bundled asset
    String jsonStr;
    try {
      jsonStr = await rootBundle.loadString(AppConstants.scheduleAssetPath);
    } catch (_) {
      jsonStr = await rootBundle.loadString('assets/data/bis_schedule.json');
    }

    final dynamic decoded = json.decode(jsonStr);
    final entries = <ScheduleEntry>[];

    if (decoded is List) {
      // New Flat List Schema (schedule.json)
      for (final rawItem in decoded) {
        if (rawItem is Map<String, dynamic>) {
          entries.add(_parseFlatEntry(rawItem));
        }
      }
    } else if (decoded is Map<String, dynamic>) {
      // Legacy Nested Map Schema
      final groups = decoded['groups'] as Map<String, dynamic>?;
      if (groups != null) {
        for (final groupKey in ['A', 'B']) {
          final group = groups[groupKey] as Map<String, dynamic>?;
          if (group == null) continue;
          final schedule = group['schedule'] as Map<String, dynamic>?;
          if (schedule == null) continue;

          for (final dayKey in AppConstants.daysEn) {
            final dayList = schedule[dayKey] as List<dynamic>?;
            if (dayList == null) continue;

            for (final rawItem in dayList) {
              final item = rawItem as Map<String, dynamic>;
              entries.add(_parseLegacyEntry(item, dayKey, groupKey));
            }
          }
        }
      }
    }

    _cachedEntries = entries;
    return entries;
  }

  /// Save customized schedule entries to local storage
  Future<void> saveSchedule(List<ScheduleEntry> entries) async {
    _cachedEntries = List.from(entries);
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_prefCustomScheduleKey, json.encode(jsonList));
  }

  /// Reset schedule back to default assets schedule
  Future<void> resetScheduleToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCustomScheduleKey);
    _cachedEntries = null;
    await loadSchedule(forceReload: true);
  }

  /// Check whether user has custom edits
  Future<bool> hasCustomEdits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_prefCustomScheduleKey);
  }

  /// Parses a flat item from the new schedule.json specification.
  ScheduleEntry _parseFlatEntry(Map<String, dynamic> item) {
    final group = (item['group'] as String?)?.trim().toUpperCase() ?? 'A';
    final rawDay = (item['day'] as String?) ?? 'saturday';
    final day = normalizeDay(rawDay);

    final type = (item['type'] as String?)?.trim().toLowerCase() ?? 'section';
    final rawSections = item['sections'] as List<dynamic>? ?? [];
    final List<int> forSections = rawSections
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .where((s) => s > 0)
        .toList();
    final bool isForAll = type == 'lecture' || type == 'rest' || type == 'project' || forSections.isEmpty;

    final subject = (item['subject'] as String?) ??
        (item['subjectAr'] as String?) ??
        (item['subject_name_ar'] as String?) ??
        '';
    final subjectInfo = _getSubjectMeta(subject);

    final room = (item['room'] as String?) ??
        (item['roomAr'] as String?) ??
        (item['location_name_ar'] as String?) ??
        '';
    final roomEn = (item['roomEn'] as String?) ??
        (item['location_name_en'] as String?) ??
        _getRoomEn(room);

    // Keep times strictly in 12-hour format with ص / م as in the file
    final startTime = (item['start'] as String?) ??
        (item['startTime'] as String?) ??
        (item['start_time'] as String?) ??
        '';
    final endTime = (item['end'] as String?) ??
        (item['endTime'] as String?) ??
        (item['end_time'] as String?) ??
        '';

    final rawInstructor = item['instructors'] ?? item['instructor'] ?? item['instructor_name_ar'];
    final instructors = ScheduleEntry.parseInstructors(rawInstructor);
    final instructorAr = instructors.join(' / ');
    final instructorEn = (item['instructorEn'] as String?) ?? instructorAr;

    final color = (item['color'] as String?) ?? subjectInfo.color;

    return ScheduleEntry(
      subjectId: (item['subjectId'] as String?) ?? subjectInfo.id,
      subjectNameAr: subject,
      subjectNameEn: (item['subjectEn'] as String?) ?? subjectInfo.nameEn,
      type: type,
      day: day,
      startTime: startTime,
      endTime: endTime,
      locationId: roomEn.toLowerCase().replaceAll(' ', '_'),
      locationNameAr: room,
      locationNameEn: roomEn,
      locationType: _getLocationType(type, room),
      instructorId: instructorEn.toLowerCase().replaceAll(' ', '_'),
      instructorNameAr: instructorAr,
      instructorNameEn: instructorEn,
      instructors: instructors,
      forSections: forSections,
      isForAllSections: isForAll,
      noteAr: item['noteAr'] as String?,
      noteEn: item['noteEn'] as String?,
      subjectColor: color,
      group: group,
      periods: (item['periods'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  /// Parses a single schedule item from legacy JSON format.
  ScheduleEntry _parseLegacyEntry(
    Map<String, dynamic> item,
    String day,
    String group,
  ) {
    final type = (item['type'] as String?) ?? 'section';
    final rawSections = item['sections'] as List<dynamic>? ?? [];
    final List<int> forSections = rawSections.cast<int>();
    final bool isForAll = type == 'lecture' || forSections.isEmpty;

    final subjectId = (item['subjectId'] as String?) ?? (item['subject_id'] as String?) ?? 'general';
    final subjectAr = (item['subjectAr'] as String?) ?? (item['subject_name_ar'] as String?) ?? '';
    final subjectEn = (item['subjectEn'] as String?) ?? (item['subject_name_en'] as String?) ?? subjectAr;

    final rawInstructor = item['instructors'] ?? item['instructor'] ?? item['instructor_name_ar'];
    final instructors = ScheduleEntry.parseInstructors(rawInstructor);
    final instructorAr = instructors.isNotEmpty ? instructors.join(' / ') : ((item['instructor'] as String?) ?? '');
    final instructorEn = (item['instructorEn'] as String?) ?? (item['instructor_name_en'] as String?) ?? instructorAr;

    final roomAr = (item['room'] as String?) ?? (item['location_name_ar'] as String?) ?? '';
    final roomEn = (item['roomEn'] as String?) ?? (item['location_name_en'] as String?) ?? roomAr;

    final startTime = (item['start'] as String?) ?? (item['startTime'] as String?) ?? (item['start_time'] as String?) ?? '09:00 AM';
    final endTime = (item['end'] as String?) ?? (item['endTime'] as String?) ?? (item['end_time'] as String?) ?? '10:45 AM';
    final color = (item['color'] as String?) ?? '#6C5CE7';
    final rawPeriods = item['periods'] as List<dynamic>?;
    final List<String>? periods = rawPeriods?.map((e) => e.toString()).toList();
    final noteAr = item['noteAr'] as String?;
    final noteEn = item['noteEn'] as String?;

    return ScheduleEntry(
      subjectId: subjectId,
      subjectNameAr: subjectAr,
      subjectNameEn: subjectEn,
      type: type,
      day: day,
      startTime: startTime,
      endTime: endTime,
      locationId: roomEn.toLowerCase().replaceAll(' ', '_'),
      locationNameAr: roomAr,
      locationNameEn: roomEn,
      locationType: _getLocationType(type, roomAr),
      instructorId: instructorEn.toLowerCase().replaceAll(' ', '_'),
      instructorNameAr: instructorAr,
      instructorNameEn: instructorEn,
      instructors: instructors,
      forSections: forSections,
      isForAllSections: isForAll,
      noteAr: noteAr,
      noteEn: noteEn,
      subjectColor: color,
      group: group,
      periods: periods,
    );
  }

  /// Normalizes Arabic or English day name to English lowercase day key.
  static String normalizeDay(String raw) {
    final d = raw.trim().toLowerCase();
    switch (d) {
      case 'السبت':
      case 'saturday':
        return 'saturday';
      case 'الأحد':
      case 'الاحد':
      case 'sunday':
        return 'sunday';
      case 'الاثنين':
      case 'الإثنين':
      case 'monday':
        return 'monday';
      case 'الثلاثاء':
      case 'tuesday':
        return 'tuesday';
      case 'الأربعاء':
      case 'الاربعاء':
      case 'wednesday':
        return 'wednesday';
      case 'الخميس':
      case 'thursday':
        return 'thursday';
      case 'الجمعة':
      case 'friday':
        return 'friday';
      default:
        return d;
    }
  }

  static String _getLocationType(String type, String room) {
    if (type == 'lecture' || room.contains('مدرج') || room.toLowerCase().contains('hall')) {
      return 'hall';
    }
    if (room.contains('معمل') || room.toLowerCase().contains('lab')) {
      return 'lab';
    }
    return 'room';
  }

  static String _getRoomEn(String room) {
    if (room.startsWith('مدرج ')) {
      return 'Hall ${room.replaceFirst('مدرج ', '')}';
    }
    if (room.startsWith('معمل ')) {
      return 'Lab ${room.replaceFirst('معمل ', '')}';
    }
    return room;
  }

  static ({String id, String nameEn, String color}) _getSubjectMeta(String subjectAr) {
    final s = subjectAr.trim();
    if (s.contains('مشروع') || s.contains('مشاريع') || s.contains('REST') || s.contains('rest')) {
      return (id: 'project', nameEn: 'Graduation Project / REST', color: '#00CEC9');
    } else if (s.contains('نظم دعم القرار')) {
      return (id: 'dss', nameEn: 'Decision Support Systems', color: '#6C5CE7');
    } else if (s.contains('محاسبة إدارية') || s.contains('محاسبه إداريه')) {
      return (id: 'ma', nameEn: 'Managerial Accounting', color: '#0984E3');
    } else if (s.contains('نظم المعلومات الجغرافية') || s.contains('الجغرافيه')) {
      return (id: 'gis', nameEn: 'Geographic Information Systems', color: '#00B894');
    } else if (s.contains('دراسات محاسبية') || s.contains('دراسات محاسبيه')) {
      return (id: 'ase', nameEn: 'Accounting Studies (English)', color: '#E17055');
    } else if (s.contains('الموارد البشرية') || s.contains('الموارد البشريه')) {
      return (id: 'hrm', nameEn: 'Human Resource Management', color: '#FD79A8');
    }
    return (id: 'general', nameEn: subjectAr, color: '#6C5CE7');
  }

  /// Loads campus directory data.
  Future<List<Map<String, dynamic>>> loadCampusDirectory() async {
    return [
      { 'id': 'hall_a', 'name_ar': 'مدرج A', 'name_en': 'Lecture Hall A', 'floor_ar': 'الدور الأرضي', 'floor_en': 'Ground Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'hall' },
      { 'id': 'hall_d', 'name_ar': 'مدرج D', 'name_en': 'Lecture Hall D', 'floor_ar': 'الدور الثاني', 'floor_en': '2nd Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'hall' },
      { 'id': 'hall_e', 'name_ar': 'مدرج E', 'name_en': 'Lecture Hall E', 'floor_ar': 'الدور الثاني', 'floor_en': '2nd Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'hall' },
      { 'id': 'hall_f', 'name_ar': 'مدرج F', 'name_en': 'Lecture Hall F', 'floor_ar': 'الدور الثالث', 'floor_en': '3rd Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'hall' },
      { 'id': 'hall_g', 'name_ar': 'مدرج G', 'name_en': 'Lecture Hall G', 'floor_ar': 'الدور الثالث', 'floor_en': '3rd Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'hall' },
      { 'id': 'lab_1h', 'name_ar': 'معمل 1 هـ', 'name_en': 'Computer Lab 1 H', 'floor_ar': 'الدور الأول', 'floor_en': '1st Floor', 'building_ar': 'مبنى الحاسبات', 'building_en': 'Computing Building', 'type': 'lab' },
      { 'id': 'lab_2h', 'name_ar': 'معمل 2 هـ', 'name_en': 'Computer Lab 2 H', 'floor_ar': 'الدور الأول', 'floor_en': '1st Floor', 'building_ar': 'مبنى الحاسبات', 'building_en': 'Computing Building', 'type': 'lab' },
      { 'id': 'lab_3h', 'name_ar': 'معمل 3 هـ', 'name_en': 'Computer Lab 3 H', 'floor_ar': 'الدور الثاني', 'floor_en': '2nd Floor', 'building_ar': 'مبنى الحاسبات', 'building_en': 'Computing Building', 'type': 'lab' },
      { 'id': 'lab_4h', 'name_ar': 'معمل 4 هـ', 'name_en': 'Computer Lab 4 H', 'floor_ar': 'الدور الثاني', 'floor_en': '2nd Floor', 'building_ar': 'مبنى الحاسبات', 'building_en': 'Computing Building', 'type': 'lab' },
      { 'id': 'lab_5h', 'name_ar': 'معمل 5 هـ', 'name_en': 'Computer Lab 5 H', 'floor_ar': 'الدور الثالث', 'floor_en': '3rd Floor', 'building_ar': 'مبنى الحاسبات', 'building_en': 'Computing Building', 'type': 'lab' },
      { 'id': 'room_l1', 'name_ar': 'قاعة L.1', 'name_en': 'Room L.1', 'floor_ar': 'الدور الأول', 'floor_en': '1st Floor', 'building_ar': 'الجناح L', 'building_en': 'Wing L', 'type': 'room' },
      { 'id': 'room_l2', 'name_ar': 'قاعة L.2', 'name_en': 'Room L.2', 'floor_ar': 'الدور الأول', 'floor_en': '1st Floor', 'building_ar': 'الجناح L', 'building_en': 'Wing L', 'type': 'room' },
      { 'id': 'room_l3', 'name_ar': 'قاعة L.3', 'name_en': 'Room L.3', 'floor_ar': 'الدور الأول', 'floor_en': '1st Floor', 'building_ar': 'الجناح L', 'building_en': 'Wing L', 'type': 'room' },
      { 'id': 'room_l4', 'name_ar': 'قاعة L.4', 'name_en': 'Room L.4', 'floor_ar': 'الدور الثاني', 'floor_en': '2nd Floor', 'building_ar': 'الجناح L', 'building_en': 'Wing L', 'type': 'room' },
      { 'id': 'room_ld202', 'name_ar': 'قاعة L.D202', 'name_en': 'Room L.D202', 'floor_ar': 'الدور الثاني', 'floor_en': '2nd Floor', 'building_ar': 'الجناح LD', 'building_en': 'Wing LD', 'type': 'room' },
      { 'id': 'room_ld302', 'name_ar': 'قاعة L.D302', 'name_en': 'Room L.D302', 'floor_ar': 'الدور الثالث', 'floor_en': '3rd Floor', 'building_ar': 'الجناح LD', 'building_en': 'Wing LD', 'type': 'room' },
      { 'id': 'room_ld305', 'name_ar': 'قاعة L.D305', 'name_en': 'Room L.D305', 'floor_ar': 'الدور الثالث', 'floor_en': '3rd Floor', 'building_ar': 'الجناح LD', 'building_en': 'Wing LD', 'type': 'room' },
      { 'id': 'room_ld402', 'name_ar': 'قاعة L.D402', 'name_en': 'Room L.D402', 'floor_ar': 'الدور الرابع', 'floor_en': '4th Floor', 'building_ar': 'الجناح LD', 'building_en': 'Wing LD', 'type': 'room' },
      { 'id': 'room_ld405', 'name_ar': 'قاعة L.D405', 'name_en': 'Room L.D405', 'floor_ar': 'الدور الرابع', 'floor_en': '4th Floor', 'building_ar': 'الجناح LD', 'building_en': 'Wing LD', 'type': 'room' },
      { 'id': 'room_rc504', 'name_ar': 'قاعة R.C504', 'name_en': 'Room R.C504', 'floor_ar': 'الدور الخامس', 'floor_en': '5th Floor', 'building_ar': 'الجناح RC', 'building_en': 'Wing RC', 'type': 'room' },
      { 'id': 'room_rc505', 'name_ar': 'قاعة R.C505', 'name_en': 'Room R.C505', 'floor_ar': 'الدور الخامس', 'floor_en': '5th Floor', 'building_ar': 'الجناح RC', 'building_en': 'Wing RC', 'type': 'room' },
      { 'id': 'room_rc507', 'name_ar': 'قاعة R.C507', 'name_en': 'Room R.C507', 'floor_ar': 'الدور الخامس', 'floor_en': '5th Floor', 'building_ar': 'الجناح RC', 'building_en': 'Wing RC', 'type': 'room' },
      { 'id': 'room_rd505', 'name_ar': 'قاعة R.D505', 'name_en': 'Room R.D505', 'floor_ar': 'الدور الخامس', 'floor_en': '5th Floor', 'building_ar': 'الجناح RD', 'building_en': 'Wing RD', 'type': 'room' },
      { 'id': 'room_rlg003', 'name_ar': 'قاعة R.LG003', 'name_en': 'Room R.LG003', 'floor_ar': 'الدور الأرضي المنخفض', 'floor_en': 'Lower Ground Floor', 'building_ar': 'الجناح R', 'building_en': 'Wing R', 'type': 'room' },
      { 'id': 'room_rlg004', 'name_ar': 'قاعة R.LG004', 'name_en': 'Room R.LG004', 'floor_ar': 'الدور الأرضي المنخفض', 'floor_en': 'Lower Ground Floor', 'building_ar': 'الجناح R', 'building_en': 'Wing R', 'type': 'room' },
      { 'id': 'room_rlg005', 'name_ar': 'قاعة R.LG005', 'name_en': 'Room R.LG005', 'floor_ar': 'الدور الأرضي المنخفض', 'floor_en': 'Lower Ground Floor', 'building_ar': 'الجناح R', 'building_en': 'Wing R', 'type': 'room' },
      { 'id': 'room_rlg006', 'name_ar': 'قاعة R.LG006', 'name_en': 'Room R.LG006', 'floor_ar': 'الدور الأرضي المنخفض', 'floor_en': 'Lower Ground Floor', 'building_ar': 'الجناح R', 'building_en': 'Wing R', 'type': 'room' },
      { 'id': 'room_lg007', 'name_ar': 'قاعة LG 007', 'name_en': 'Room LG 007', 'floor_ar': 'الدور الأرضي المنخفض', 'floor_en': 'Lower Ground Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'room' },
      { 'id': 'room_lg008', 'name_ar': 'قاعة LG 008', 'name_en': 'Room LG 008', 'floor_ar': 'الدور الأرضي المنخفض', 'floor_en': 'Lower Ground Floor', 'building_ar': 'المبنى الرئيسي', 'building_en': 'Main Building', 'type': 'room' },
      { 'id': 'room_g002', 'name_ar': 'قاعة G 002', 'name_en': 'Room G 002', 'floor_ar': 'الدور الأرضي', 'floor_en': 'Ground Floor', 'building_ar': 'الجناح G', 'building_en': 'Wing G', 'type': 'room' },
      { 'id': 'room_g009', 'name_ar': 'قاعة G 009', 'name_en': 'Room G 009', 'floor_ar': 'الدور الأرضي', 'floor_en': 'Ground Floor', 'building_ar': 'الجناح G', 'building_en': 'Wing G', 'type': 'room' },
      { 'id': 'room_r501', 'name_ar': 'قاعة R 501', 'name_en': 'Room R 501', 'floor_ar': 'الدور الخامس', 'floor_en': '5th Floor', 'building_ar': 'الجناح R', 'building_en': 'Wing R', 'type': 'room' },
      { 'id': 'room_r521', 'name_ar': 'قاعة R 521', 'name_en': 'Room R 521', 'floor_ar': 'الدور الخامس', 'floor_en': '5th Floor', 'building_ar': 'الجناح R', 'building_en': 'Wing R', 'type': 'room' },
    ];
  }
}
