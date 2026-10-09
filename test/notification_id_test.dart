import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:met1/core/services/notification_service.dart';
import 'package:met1/data/datasources/local_schedule_datasource.dart';
import 'package:met1/domain/entities/schedule_entry.dart';

void main() {
  group('NotificationService Deterministic ID Tests', () {
    test('Same entry produces identical ID across calls and property orderings', () {
      const entry1 = ScheduleEntry(
        subjectId: 'dss',
        subjectNameAr: 'نظم دعم القرار',
        subjectNameEn: 'DSS',
        type: 'lecture',
        day: 'saturday',
        startTime: '08:45',
        endTime: '10:15',
        locationId: 'hall_d',
        locationNameAr: 'مدرج د',
        locationNameEn: 'Hall D',
        locationType: 'hall',
        instructorId: 'dr_wagdy',
        instructorNameAr: 'د. محمد وجدي',
        instructorNameEn: 'Dr. Mohamed Wagdy',
        forSections: [1, 2, 3],
        isForAllSections: false,
        subjectColor: '#4F46E5',
        group: 'A',
      );

      const entry2 = ScheduleEntry(
        subjectId: 'dss',
        subjectNameAr: 'نظم دعم القرار',
        subjectNameEn: 'DSS',
        type: 'lecture',
        day: 'saturday',
        startTime: '08:45',
        endTime: '10:15',
        locationId: 'hall_d',
        locationNameAr: 'مدرج د',
        locationNameEn: 'Hall D',
        locationType: 'hall',
        instructorId: 'dr_wagdy',
        instructorNameAr: 'د. محمد وجدي',
        instructorNameEn: 'Dr. Mohamed Wagdy',
        forSections: [3, 1, 2], // Permuted sections order
        isForAllSections: false,
        subjectColor: '#4F46E5',
        group: 'A',
      );

      final id1 = NotificationService.generateEntryNotificationId(entry1);
      final id2 = NotificationService.generateEntryNotificationId(entry1);
      final id3 = NotificationService.generateEntryNotificationId(entry2);

      expect(id1, equals(id2), reason: 'ID must be deterministic across calls');
      expect(id1, equals(id3), reason: 'ID must be independent of section list order');
      expect(id1, isPositive);
      expect(id1, greaterThanOrEqualTo(100000));
    });

    test('No collisions across all 70 bundled entries in schedule.json and no collision with reserved IDs', () async {
      final file = File('assets/data/schedule.json');
      expect(file.existsSync(), isTrue);
      final content = await file.readAsString();
      final List<dynamic> rawList = json.decode(content);

      final List<ScheduleEntry> entries = [];
      for (final raw in rawList) {
        if (raw is Map<String, dynamic>) {
          // Parse using LocalScheduleDataSource's flat entry parser logic
          final group = (raw['group'] as String?)?.trim().toUpperCase() ?? 'A';
          final day = LocalScheduleDataSource.normalizeDay((raw['day'] as String?) ?? 'saturday');
          final type = (raw['type'] as String?)?.trim().toLowerCase() ?? 'section';
          final rawSections = raw['sections'] as List<dynamic>? ?? [];
          final forSections = rawSections
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((s) => s > 0)
              .toList();
          final isForAll = type == 'lecture' || type == 'rest' || type == 'project' || forSections.isEmpty;
          final subject = (raw['subject'] as String?) ?? '';
          final room = (raw['room'] as String?) ?? '';
          final instructor = (raw['instructor'] as String?) ?? '';
          final start = (raw['start'] as String?) ?? '';
          final end = (raw['end'] as String?) ?? '';

          entries.add(ScheduleEntry(
            subjectId: subject,
            subjectNameAr: subject,
            subjectNameEn: subject,
            type: type,
            day: day,
            startTime: start,
            endTime: end,
            locationId: room,
            locationNameAr: room,
            locationNameEn: room,
            locationType: 'hall',
            instructorId: instructor,
            instructorNameAr: instructor,
            instructorNameEn: instructor,
            forSections: forSections,
            isForAllSections: isForAll,
            subjectColor: '#4F46E5',
            group: group,
          ));
        }
      }

      expect(entries.length, equals(70));

      final idSet = <int>{};
      final reservedIds = {
        NotificationService.welcomeNotificationId,
        NotificationService.fridayReminderId,
        NotificationService.testNotificationId,
      };

      for (final entry in entries) {
        final id = NotificationService.generateEntryNotificationId(entry);

        expect(id, isPositive);
        expect(id, greaterThanOrEqualTo(100000), reason: 'Must not overlap with 0-99999 reserved range');
        expect(reservedIds.contains(id), isFalse, reason: 'Must never collide with reserved system notification IDs');

        final added = idSet.add(id);
        expect(added, isTrue, reason: 'Duplicate notification ID ($id) detected for entry ${entry.subjectNameAr} (${entry.day} ${entry.startTime})');
      }

      expect(idSet.length, equals(entries.length));
    });
  });
}
