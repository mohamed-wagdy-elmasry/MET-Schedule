import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:met1/core/theme/app_theme.dart';
import 'package:met1/domain/entities/schedule_entry.dart';
import 'package:met1/data/datasources/local_schedule_datasource.dart';
import 'package:met1/presentation/bloc/preferences_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduleEntry & Customization Tests', () {
    test('ScheduleEntry toJson and fromJson work correctly', () {
      final entry = ScheduleEntry(
        subjectId: 'met_4102',
        subjectNameAr: 'نظم معلومات محاسبية',
        subjectNameEn: 'Accounting Information Systems',
        type: 'lecture',
        day: 'saturday',
        startTime: '10:45',
        endTime: '12:15',
        locationId: 'مدرج 2',
        locationNameAr: 'مدرج 2',
        locationNameEn: 'Hall 2',
        locationType: 'hall',
        instructorId: 'inst_1',
        instructorNameAr: 'د. سامح',
        instructorNameEn: 'Dr. Sameh',
        group: 'A',
        forSections: const [1, 2, 3],
        isForAllSections: false,
        noteAr: 'ملاحظة تجريبية',
        subjectColor: '#6C5CE7',
      );

      final json = entry.toJson();
      expect(json['subjectNameAr'], 'نظم معلومات محاسبية');
      expect(json['group'], 'A');
      expect(json['locationId'], 'مدرج 2');
      expect(json['noteAr'], 'ملاحظة تجريبية');

      final reconstructed = ScheduleEntry.fromJson(json);
      expect(reconstructed.subjectNameAr, 'نظم معلومات محاسبية');
      expect(reconstructed.group, 'A');
      expect(reconstructed.locationId, 'مدرج 2');
      expect(reconstructed.forSections, [1, 2, 3]);
      expect(reconstructed.noteAr, 'ملاحظة تجريبية');
    });

    test('ScheduleEntry copyWith updates fields properly', () {
      final entry = ScheduleEntry(
        subjectId: 'met_4102',
        subjectNameAr: 'مادة أصلية',
        subjectNameEn: 'Original Subject',
        type: 'lecture',
        day: 'saturday',
        startTime: '09:00',
        endTime: '10:30',
        locationId: 'قاعة 1',
        locationNameAr: 'قاعة 1',
        locationNameEn: 'Room 1',
        locationType: 'hall',
        instructorId: 'inst_1',
        instructorNameAr: 'أستاذ أ',
        instructorNameEn: 'Prof A',
        group: 'A',
        forSections: const [],
        isForAllSections: true,
        subjectColor: '#6C5CE7',
      );

      final modified = entry.copyWith(
        subjectNameAr: 'مادة معدلة',
        locationId: 'معمل 5',
        instructorNameAr: 'دكتور معدل',
      );

      expect(modified.subjectNameAr, 'مادة معدلة');
      expect(modified.locationId, 'معمل 5');
      expect(modified.instructorNameAr, 'دكتور معدل');
      expect(modified.startTime, '09:00'); // Unchanged
    });

    test('LocalScheduleDataSource saves and resets custom schedule', () async {
      SharedPreferences.setMockInitialValues({});
      final ds = LocalScheduleDataSource();

      expect(await ds.hasCustomEdits(), isFalse);

      final entry = ScheduleEntry(
        subjectId: 'custom_1',
        subjectNameAr: 'حصة إضافية جديدة',
        subjectNameEn: 'Custom Class',
        type: 'section',
        day: 'monday',
        startTime: '12:00',
        endTime: '13:30',
        locationId: 'معمل 3',
        locationNameAr: 'معمل 3',
        locationNameEn: 'Lab 3',
        locationType: 'lab',
        instructorId: 'inst_2',
        instructorNameAr: 'معيد تجريبي',
        instructorNameEn: 'Teaching Assistant',
        group: 'A',
        forSections: const [1],
        isForAllSections: false,
        subjectColor: '#00CEC9',
      );

      await ds.saveSchedule([entry]);
      expect(await ds.hasCustomEdits(), isTrue);

      final loaded = await ds.loadSchedule();
      expect(loaded.length, 1);
      expect(loaded.first.subjectNameAr, 'حصة إضافية جديدة');

      await ds.resetScheduleToDefault();
      expect(await ds.hasCustomEdits(), isFalse);
    });

    test('PreferencesCubit updates primary color and session colors', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final cubit = PreferencesCubit(sp);

      expect(cubit.state.primaryColor, AppTheme.primary);

      // Change primary color
      const newColor = Color(0xFF007AFF);
      await cubit.setPrimaryColor(newColor.toARGB32());
      expect(cubit.state.primaryColor, newColor);

      // Change session color for lecture
      const lectureColor = Color(0xFFFF5722);
      await cubit.setSessionColor('lecture', lectureColor.toARGB32());
      expect(cubit.state.getCustomSessionColor('lecture'), lectureColor);

      // Reset colors
      await cubit.resetColors();
      expect(cubit.state.primaryColor, AppTheme.primary);
      expect(cubit.state.getCustomSessionColor('lecture'), isNull);
    });
  });
}
