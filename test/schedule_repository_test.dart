import 'package:flutter_test/flutter_test.dart';
import 'package:met1/data/datasources/local_schedule_datasource.dart';
import 'package:met1/data/repositories/schedule_repository_impl.dart';
import 'package:met1/domain/entities/schedule_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalScheduleDataSource dataSource;
  late ScheduleRepositoryImpl repository;

  setUp(() {
    dataSource = LocalScheduleDataSource();
    repository = ScheduleRepositoryImpl(dataSource);
  });

  group('ScheduleRepository & LocalScheduleDataSource Tests', () {
    test('Loads all 70 entries (66 classes + 4 rest days) from schedule.json', () async {
      final entries = await repository.getAllEntries();
      expect(entries.length, equals(70));

      final groupA = entries.where((e) => e.group == 'A').toList();
      final groupB = entries.where((e) => e.group == 'B').toList();

      expect(groupA.length, equals(35));
      expect(groupB.length, equals(35));

      // Verify REST entries for Group A (Monday & Thursday)
      final monA = await repository.getFilteredEntries('A', 'monday', 1);
      expect(monA.length, equals(1));
      expect(monA.first.type, equals('rest'));
      expect(monA.first.subjectNameAr, equals('مشاريع تخرج / REST'));

      final thuA = await repository.getFilteredEntries('A', 'thursday', 1);
      expect(thuA.length, equals(1));
      expect(thuA.first.type, equals('rest'));

      // Verify REST entries for Group B (Tuesday & Thursday)
      final tueB = await repository.getFilteredEntries('B', 'tuesday', 15);
      expect(tueB.length, equals(1));
      expect(tueB.first.type, equals('rest'));

      final thuB = await repository.getFilteredEntries('B', 'thursday', 15);
      expect(thuB.length, equals(1));
      expect(thuB.first.type, equals('rest'));
    });

    test('All times strictly preserve 12-hour format with ص or م', () async {
      final entries = await repository.getAllEntries();
      final timeRegex = RegExp(r'^\d{1,2}:\d{2}\s+(ص|م)$');

      for (final e in entries) {
        expect(timeRegex.hasMatch(e.startTime), isTrue,
            reason: 'Start time "${e.startTime}" is not in 12h format with ص/م');
        expect(timeRegex.hasMatch(e.endTime), isTrue,
            reason: 'End time "${e.endTime}" is not in 12h format with ص/م');
        expect(e.timeRange(true), contains('–'));
      }
    });

    test('Sorting order from earliest to latest (11:55 ص before 12:30 م)', () async {
      // Test for Section 13 in Group A on Saturday:
      // Lecture: 9:00 ص - 10:45 ص
      // DSS Section: 10:45 ص - 11:55 ص
      // MA Section: 11:55 ص - 1:05 م
      final satEntries = await repository.getFilteredEntries('A', 'saturday', 13);
      expect(satEntries.length, equals(3));
      expect(satEntries[0].startTime, equals('9:00 ص'));
      expect(satEntries[1].startTime, equals('10:45 ص'));
      expect(satEntries[2].startTime, equals('11:55 ص'));

      // Check time parts comparison
      final (h1, m1) = satEntries[2].startTimeParts; // 11:55 ص
      final (h2, m2) = satEntries[1].startTimeParts; // 10:45 ص
      expect(h1 * 60 + m1 > h2 * 60 + m2, isTrue);

      // Verify against 12:30 م
      final entry1230 = ScheduleEntry(
        subjectId: 'test',
        subjectNameAr: 'Test',
        subjectNameEn: 'Test',
        type: 'section',
        day: 'saturday',
        startTime: '12:30 م',
        endTime: '1:55 م',
        locationId: 'l4',
        locationNameAr: 'L.4',
        locationNameEn: 'L.4',
        locationType: 'room',
        instructorId: 'inst',
        instructorNameAr: 'Inst',
        instructorNameEn: 'Inst',
        instructors: const ['Inst'],
        forSections: const [13],
        isForAllSections: false,
        subjectColor: '#000000',
        group: 'A',
      );
      final (h1230, m1230) = entry1230.startTimeParts;
      expect(h1 * 60 + m1 < h1230 * 60 + m1230, isTrue,
          reason: '11:55 ص must come before 12:30 م');
    });

    test('Section filtering for every section in Group A (1..14) has no duplicates', () async {
      for (var s = 1; s <= 14; s++) {
        final weekly = await repository.getWeeklySchedule('A', s);
        for (final dayEntry in weekly.entries) {
          final list = dayEntry.value;
          final seen = <String>{};
          for (final entry in list) {
            final key = '${entry.subjectNameAr}_${entry.startTime}_${entry.locationNameAr}';
            expect(seen.contains(key), isFalse,
                reason: 'Sec $s on ${dayEntry.key} has duplicate entry: $key');
            seen.add(key);

            // Must either be a lecture, rest, or contain s in forSections
            expect(entry.type == 'lecture' || entry.type == 'rest' || entry.forSections.contains(s), isTrue);
          }
        }
      }
    });

    test('Section filtering for every section in Group B (15..28) has no duplicates', () async {
      for (var s = 15; s <= 28; s++) {
        final weekly = await repository.getWeeklySchedule('B', s);
        for (final dayEntry in weekly.entries) {
          final list = dayEntry.value;
          final seen = <String>{};
          for (final entry in list) {
            final key = '${entry.subjectNameAr}_${entry.startTime}_${entry.locationNameAr}';
            expect(seen.contains(key), isFalse,
                reason: 'Sec $s on ${dayEntry.key} has duplicate entry: $key');
            seen.add(key);

            // Must either be a lecture, rest, or contain s in forSections
            expect(entry.type == 'lecture' || entry.type == 'rest' || entry.forSections.contains(s), isTrue);
          }
        }
      }
    });

    test('Instructor parsing handles single string, separators, and lists', () {
      expect(ScheduleEntry.parseInstructors('م.م محمد موسى'),
          equals(['م.م محمد موسى']));

      expect(ScheduleEntry.parseInstructors('م.م محمد موسى / م. سارة محمود'),
          equals(['م.م محمد موسى', 'م. سارة محمود']));

      expect(ScheduleEntry.parseInstructors('م.م محمد موسى، م. سارة محمود'),
          equals(['م.م محمد موسى', 'م. سارة محمود']));

      expect(ScheduleEntry.parseInstructors('م.م محمد موسى, م. سارة محمود'),
          equals(['م.م محمد موسى', 'م. سارة محمود']));

      expect(ScheduleEntry.parseInstructors('م.م محمد موسى\nم. سارة محمود'),
          equals(['م.م محمد موسى', 'م. سارة محمود']));

      expect(ScheduleEntry.parseInstructors(['م.م محمد موسى', 'م. سارة محمود']),
          equals(['م.م محمد موسى', 'م. سارة محمود']));

      expect(ScheduleEntry.parseInstructors(['م.م محمد موسى / م. هند']),
          equals(['م.م محمد موسى', 'م. هند']));

      expect(ScheduleEntry.parseInstructors(''), equals([]));
      expect(ScheduleEntry.parseInstructors(null), equals([]));
    });
  });
}
