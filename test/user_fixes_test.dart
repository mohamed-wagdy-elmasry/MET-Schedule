import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:met1/core/localization/app_localizations.dart';
import 'package:met1/core/theme/app_theme.dart';
import 'package:met1/domain/entities/schedule_entry.dart';
import 'package:met1/domain/repositories/schedule_repository.dart';
import 'package:met1/presentation/widgets/schedule_card.dart';
import 'package:met1/presentation/widgets/edit_session_modal.dart';
import 'package:met1/presentation/widgets/color_customization_modal.dart';
import 'package:met1/presentation/bloc/preferences_cubit.dart';
import 'package:met1/presentation/bloc/schedule_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduleRepo implements ScheduleRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<ScheduleEntry>> getAllEntries() async => [];

  @override
  Future<List<ScheduleEntry>> getEntriesForDay(String group, String day) async => [];

  @override
  Future<List<ScheduleEntry>> getFilteredEntries(String group, String day, int section) async => [];

  @override
  Future<Map<String, List<ScheduleEntry>>> getWeeklySchedule(String group, int section) async => {};

  @override
  Future<List<Map<String, dynamic>>> getCampusDirectory() async => [];

  @override
  Future<void> addEntry(ScheduleEntry entry) async {}

  @override
  Future<void> updateEntry(ScheduleEntry original, ScheduleEntry updated) async {}

  @override
  Future<void> deleteEntry(ScheduleEntry entry) async {}

  @override
  Future<void> resetScheduleToDefault() async {}

  @override
  Future<bool> hasCustomSchedule() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Instructor Number Sanitization Tests', () {
    test('parseInstructors removes English, Arabic, and Eastern Arabic digits', () {
      expect(ScheduleEntry.parseInstructors('د. محمد وجدي 123'), equals(['د. محمد وجدي']));
      expect(ScheduleEntry.parseInstructors('م.م آية الشيخ ٦٣٧'), equals(['م.م آية الشيخ']));
      expect(ScheduleEntry.parseInstructors('637'), equals([]));
      expect(ScheduleEntry.parseInstructors('١٢٣٤٥'), equals([]));
    });

    test('instructorName getter never displays digits', () {
      const entryWithDigits = ScheduleEntry(
        subjectId: 'sub1',
        subjectNameAr: 'نظم المعلومات',
        subjectNameEn: 'Information Systems',
        type: 'lecture',
        day: 'saturday',
        startTime: '08:45 ص',
        endTime: '10:15 ص',
        locationId: 'room1',
        locationNameAr: 'مدرج A',
        locationNameEn: 'Hall A',
        locationType: 'hall',
        instructorId: '637',
        instructorNameAr: 'د. أحمد 637',
        instructorNameEn: 'Dr. Ahmed 637',
        instructors: [],
        forSections: [],
        isForAllSections: true,
        subjectColor: '#6C63FF',
        group: 'A',
      );

      expect(entryWithDigits.instructorName(true), equals('د. أحمد'));
      expect(entryWithDigits.instructorName(false), equals('Dr. Ahmed'));
    });
  });

  group('Large Font Scale Responsiveness Tests', () {
    testWidgets('NextClassCard renders with large text scale without overflow', (tester) async {
      const entry = ScheduleEntry(
        subjectId: 'dss',
        subjectNameAr: 'نظم دعم القرار الإداري المتقدمة',
        subjectNameEn: 'Advanced Decision Support Systems',
        type: 'section',
        day: 'wednesday',
        startTime: '09:35 ص',
        endTime: '10:45 ص',
        locationId: 'l1',
        locationNameAr: 'معمل L.1',
        locationNameEn: 'Lab L.1',
        locationType: 'lab',
        instructorId: 'aya',
        instructorNameAr: 'م.م آية الشيخ',
        instructorNameEn: 'Aya El-Sheikh',
        instructors: ['م.م آية الشيخ'],
        forSections: [1],
        isForAllSections: false,
        subjectColor: '#F59E0B',
        group: 'A',
      );

      final sp = await SharedPreferences.getInstance();
      final prefsCubit = PreferencesCubit(sp);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          locale: const Locale('ar'),
          theme: AppTheme.darkTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.8), // Large accessibility font scale
            ),
            child: BlocProvider<PreferencesCubit>.value(
              value: prefsCubit,
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: NextClassCard(
                    entry: entry,
                    currentDay: 'wednesday',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('نظم دعم القرار الإداري المتقدمة'), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });
  });

  group('Modal Dismiss & Close Button Tests', () {
    testWidgets('EditSessionModal renders close button and pops when tapped', (tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefsCubit = PreferencesCubit(sp);
      final scheduleCubit = ScheduleCubit(_FakeScheduleRepo());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          locale: const Locale('ar'),
          theme: AppTheme.darkTheme,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<PreferencesCubit>.value(value: prefsCubit),
              BlocProvider<ScheduleCubit>.value(value: scheduleCubit),
            ],
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  key: const ValueKey('open_modal_btn'),
                  onPressed: () => EditSessionModal.show(context),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('open_modal_btn')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('إضافة محاضرة جديدة'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('إضافة محاضرة جديدة'), findsNothing);
    });

    testWidgets('ColorCustomizationModal renders close button and pops when tapped', (tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefsCubit = PreferencesCubit(sp);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar'), Locale('en')],
          locale: const Locale('ar'),
          theme: AppTheme.darkTheme,
          home: BlocProvider<PreferencesCubit>.value(
            value: prefsCubit,
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  key: const ValueKey('open_colors_btn'),
                  onPressed: () => ColorCustomizationModal.show(context),
                  child: const Text('Open Colors'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('open_colors_btn')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('تخصيص ألوان التطبيق'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('تخصيص ألوان التطبيق'), findsNothing);
    });
  });
}
