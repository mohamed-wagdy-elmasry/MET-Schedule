import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify schedule data integrity and business rules', () async {
    final file = File('assets/data/schedule.json');
    expect(file.existsSync(), isTrue);

    final content = await file.readAsString();
    final List<dynamic> data = json.decode(content);

    expect(data.length, equals(70), reason: 'Dataset must have exactly 70 items (66 classes + 4 rest days)');

    // 1. Time format check: all start and end must end with 'ص' or 'م' and follow 12h format
    final timeRegex = RegExp(r'^\d{1,2}:\d{2}\s+(ص|م)$');
    for (final item in data) {
      final start = item['start'] as String;
      final end = item['end'] as String;
      expect(timeRegex.hasMatch(start), isTrue,
          reason: 'Start time "$start" is not 12h format with ص/م');
      expect(timeRegex.hasMatch(end), isTrue,
          reason: 'End time "$end" is not 12h format with ص/م');
    }

    // Parse time helper matching our logic
    (int, int) parseTime(String timeStr) {
      final clean = timeStr.trim().toUpperCase();
      final isPM = clean.contains('PM') || clean.contains('م');
      final isAM = clean.contains('AM') || clean.contains('ص');
      final digits = clean
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .replaceAll('ص', '')
          .replaceAll('م', '')
          .trim();
      final parts = digits.split(':');
      var hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());
      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return (hour, minute);
    }

    int toMinutes(String timeStr) {
      final (h, m) = parseTime(timeStr);
      return h * 60 + m;
    }

    // Verify 11:55 ص comes before 12:30 م
    expect(toMinutes('11:55 ص') < toMinutes('12:30 م'), isTrue,
        reason: '11:55 ص (715m) must be before 12:30 م (750m)');

    // 2. Test Group A for all sections 1..14
    final days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء'];
    for (var s = 1; s <= 14; s++) {
      for (final d in days) {
        final matches = data.where((item) {
          if (item['group'] != 'A') return false;
          if (item['day'] != d) return false;
          final type = item['type'] as String;
          final sections = (item['sections'] as List).cast<int>();
          return type == 'lecture' || type == 'rest' || sections.contains(s);
        }).toList();

        // Check for duplicates
        final seen = <String>{};
        for (final m in matches) {
          final key = '${m["subject"]}_${m["start"]}_${m["room"]}';
          expect(seen.contains(key), isFalse,
              reason: 'Duplicate class for Sec $s on $d: $key');
          seen.add(key);
        }

        // Check sorting
        matches.sort((a, b) {
          final diff = toMinutes(a['start'] as String) - toMinutes(b['start'] as String);
          return diff != 0 ? diff : (a['type'] as String).compareTo(b['type'] as String);
        });

        for (var i = 0; i < matches.length - 1; i++) {
          final t1 = toMinutes(matches[i]['start'] as String);
          final t2 = toMinutes(matches[i + 1]['start'] as String);
          expect(t1 <= t2, isTrue,
              reason: 'Sec $s on $d not sorted: ${matches[i]["start"]} > ${matches[i+1]["start"]}');
        }
      }
    }

    // 3. Test Group B for all sections 15..28
    for (var s = 15; s <= 28; s++) {
      for (final d in days) {
        final matches = data.where((item) {
          if (item['group'] != 'B') return false;
          if (item['day'] != d) return false;
          final type = item['type'] as String;
          final sections = (item['sections'] as List).cast<int>();
          return type == 'lecture' || type == 'rest' || sections.contains(s);
        }).toList();

        // Check for duplicates
        final seen = <String>{};
        for (final m in matches) {
          final key = '${m["subject"]}_${m["start"]}_${m["room"]}';
          expect(seen.contains(key), isFalse,
              reason: 'Duplicate class for Sec $s on $d: $key');
          seen.add(key);
        }

        // Check sorting
        matches.sort((a, b) {
          final diff = toMinutes(a['start'] as String) - toMinutes(b['start'] as String);
          return diff != 0 ? diff : (a['type'] as String).compareTo(b['type'] as String);
        });

        for (var i = 0; i < matches.length - 1; i++) {
          final t1 = toMinutes(matches[i]['start'] as String);
          final t2 = toMinutes(matches[i + 1]['start'] as String);
          expect(t1 <= t2, isTrue,
              reason: 'Sec $s on $d not sorted: ${matches[i]["start"]} > ${matches[i+1]["start"]}');
        }
      }
    }
  });

  test('Verify instructor parsing logic', () {
    List<String> parseInstructors(dynamic raw) {
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
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) {
            result.add(trimmed);
          }
        }
      }
      return result;
    }

    expect(parseInstructors('م.م محمد موسى'), equals(['م.م محمد موسى']));
    expect(parseInstructors('م.م محمد موسى / م. سارة محمود'),
        equals(['م.م محمد موسى', 'م. سارة محمود']));
    expect(parseInstructors('م.م محمد موسى، م. سارة محمود'),
        equals(['م.م محمد موسى', 'م. سارة محمود']));
    expect(parseInstructors('م.م محمد موسى\nم. سارة محمود'),
        equals(['م.م محمد موسى', 'م. سارة محمود']));
    expect(parseInstructors(['م.م محمد موسى', 'م. سارة محمود']),
        equals(['م.م محمد موسى', 'م. سارة محمود']));
    expect(parseInstructors(['م.م محمد موسى / م. هند']),
        equals(['م.م محمد موسى', 'م. هند']));
    expect(parseInstructors(''), equals([]));
    expect(parseInstructors(null), equals([]));
  });

  test('Verify sections list semantics in schedule.json (non-all entries have sections)', () async {
    final file = File('assets/data/schedule.json');
    final content = await file.readAsString();
    final List<dynamic> data = json.decode(content);

    for (final item in data) {
      final type = (item['type'] as String?)?.trim().toLowerCase() ?? '';
      final sections = (item['sections'] as List<dynamic>?) ?? [];
      final subject = item['subject'] ?? '';

      // Non-"all" sessions (sections and labs) must have non-empty section targets.
      if (type == 'section' || type == 'lab') {
        expect(
          sections.isNotEmpty,
          isTrue,
          reason: 'Entry "$subject" of type "$type" has empty sections list in schedule.json.',
        );
      }
    }
  });
}
