import 'package:flutter_test/flutter_test.dart';
import 'package:met1/domain/entities/schedule_entry.dart';

void main() {
  group('Time Parsing & Formatting Tests', () {
    test('ScheduleEntry.parseTime handles Arabic ص and م accurately', () {
      final morning = ScheduleEntry.parseTime('08:45 ص');
      expect(morning.$1, 8);
      expect(morning.$2, 45);

      final afternoon = ScheduleEntry.parseTime('03:05 م');
      expect(afternoon.$1, 15);
      expect(afternoon.$2, 5);

      final noon = ScheduleEntry.parseTime('12:00 م');
      expect(noon.$1, 12);
      expect(noon.$2, 0);

      final midnight = ScheduleEntry.parseTime('12:00 ص');
      expect(midnight.$1, 0);
      expect(midnight.$2, 0);
    });

    test('ScheduleEntry.parseTime handles English AM and PM accurately', () {
      final am = ScheduleEntry.parseTime('09:15 AM');
      expect(am.$1, 9);
      expect(am.$2, 15);

      final pm = ScheduleEntry.parseTime('04:30 PM');
      expect(pm.$1, 16);
      expect(pm.$2, 30);
    });

    test('Time validation detects invalid chronological ranges', () {
      final start = ScheduleEntry.parseTime('09:00 ص');
      final end = ScheduleEntry.parseTime('03:05 م');
      final startMin = start.$1 * 60 + start.$2;
      final endMin = end.$1 * 60 + end.$2;
      expect(endMin > startMin, isTrue);

      final invertedStart = ScheduleEntry.parseTime('03:05 م');
      final invertedEnd = ScheduleEntry.parseTime('09:00 ص');
      final invStartMin = invertedStart.$1 * 60 + invertedStart.$2;
      final invEndMin = invertedEnd.$1 * 60 + invertedEnd.$2;
      expect(invEndMin > invStartMin, isFalse);
    });
  });

  group('School Day Completion Logic Tests', () {
    bool isSchoolDayFinished({
      required List<ScheduleEntry> entries,
      required int currentHour,
      required int currentMinute,
    }) {
      if (entries.isEmpty) return false;

      final nowMinutes = currentHour * 60 + currentMinute;
      int maxEndMinutes = 0;

      for (final entry in entries) {
        final (endH, endM) = ScheduleEntry.parseTime(entry.endTime);
        final endMinutes = endH * 60 + endM;
        if (endMinutes > maxEndMinutes) {
          maxEndMinutes = endMinutes;
        }
      }

      if (maxEndMinutes > 0 && nowMinutes >= maxEndMinutes) {
        return true;
      }

      // Evening fallback
      if (nowMinutes >= 17 * 60) {
        return true;
      }

      return false;
    }

    test('Project/REST only day (e.g., Tuesday Group B) completes after end time', () {
      final entries = [
        const ScheduleEntry(
          subjectId: 'rest_tue',
          subjectNameAr: 'مشاريع تخرج / REST',
          subjectNameEn: 'Graduation Projects / REST',
          type: 'project',
          day: 'tuesday',
          startTime: '09:00 ص',
          endTime: '03:05 م',
          locationId: 'hall_rest',
          locationNameAr: 'مبنى المشاريع',
          locationNameEn: 'Project Building',
          locationType: 'hall',
          instructorId: 'supervisor',
          instructorNameAr: 'مشرف المشروع',
          instructorNameEn: 'Project Supervisor',
          forSections: [],
          isForAllSections: true,
          subjectColor: '#00B894',
          group: 'B',
        ),
      ];

      // At 9:18 PM (21:18) as in screenshot 2 -> should be finished!
      expect(
        isSchoolDayFinished(entries: entries, currentHour: 21, currentMinute: 18),
        isTrue,
      );

      // At 1:00 PM (13:00) during the day -> should NOT be finished
      expect(
        isSchoolDayFinished(entries: entries, currentHour: 13, currentMinute: 0),
        isFalse,
      );

      // At 3:06 PM (15:06) right after session ends -> should be finished!
      expect(
        isSchoolDayFinished(entries: entries, currentHour: 15, currentMinute: 6),
        isTrue,
      );
    });
  });
}
