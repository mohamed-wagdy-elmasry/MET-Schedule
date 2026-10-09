import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:met1/core/localization/app_localizations.dart';
import 'package:met1/domain/entities/schedule_entry.dart';
import 'package:met1/domain/repositories/schedule_repository.dart';
import 'package:met1/main.dart';
import 'package:met1/presentation/bloc/preferences_cubit.dart';
import 'package:met1/presentation/bloc/schedule_cubit.dart';
import 'package:met1/presentation/screens/timetable_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeScheduleRepository implements ScheduleRepository {
  bool shouldThrow = false;
  int getWeeklyScheduleCallCount = 0;

  @override
  Future<List<ScheduleEntry>> getAllEntries() async => [];

  @override
  Future<List<ScheduleEntry>> getEntriesForDay(String group, String day) async => [];

  @override
  Future<List<ScheduleEntry>> getFilteredEntries(String group, String day, int section) async => [];

  @override
  Future<Map<String, List<ScheduleEntry>>> getWeeklySchedule(String group, int section) async {
    getWeeklyScheduleCallCount++;
    if (shouldThrow) {
      throw Exception('Data parsing error occurred');
    }
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getCampusDirectory() async => [];

  @override
  Future<void> updateEntry(ScheduleEntry original, ScheduleEntry updated) async {}

  @override
  Future<void> addEntry(ScheduleEntry entry) async {}

  @override
  Future<void> deleteEntry(ScheduleEntry entry) async {}

  @override
  Future<void> resetScheduleToDefault() async {}

  @override
  Future<bool> hasCustomSchedule() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cubit Stability Tests (Item 1)', () {
    testWidgets('Toggling theme or locale does NOT recreate ScheduleCubit and does NOT reset state', (tester) async {
      SharedPreferences.setMockInitialValues({
        'has_onboarded': true,
        'has_seen_inapp_feature_tour_v8': true,
        'student_group': 'A',
        'student_section': 1,
        'app_locale': 'ar',
      });
      final prefs = await SharedPreferences.getInstance();
      final fakeRepo = _FakeScheduleRepository();

      final prefsCubit = PreferencesCubit(prefs);
      final scheduleCubit = ScheduleCubit(fakeRepo);

      // Preload some state into scheduleCubit
      await scheduleCubit.loadSchedule('A', 1);
      final initialScheduleState = scheduleCubit.state;

      await tester.pumpWidget(
        METApp(
          prefs: prefs,
          preferencesCubit: prefsCubit,
          scheduleCubit: scheduleCubit,
        ),
      );
      await tester.pump();

      // Retrieve cubits from context
      final BuildContext initialContext = tester.element(find.byType(MaterialApp));
      final obtainedScheduleCubit = initialContext.read<ScheduleCubit>();
      expect(identical(obtainedScheduleCubit, scheduleCubit), isTrue);

      // 1. Toggle Theme Mode
      prefsCubit.toggleThemeMode();
      await tester.pumpAndSettle();

      final BuildContext contextAfterTheme = tester.element(find.byType(MaterialApp));
      final cubitAfterTheme = contextAfterTheme.read<ScheduleCubit>();
      expect(
        identical(cubitAfterTheme, scheduleCubit),
        isTrue,
        reason: 'ScheduleCubit instance must remain identical after theme toggle',
      );
      expect(cubitAfterTheme.state, equals(initialScheduleState));

      // 2. Toggle Locale
      prefsCubit.toggleLocale();
      await tester.pumpAndSettle();

      final BuildContext contextAfterLocale = tester.element(find.byType(MaterialApp));
      final cubitAfterLocale = contextAfterLocale.read<ScheduleCubit>();
      expect(
        identical(cubitAfterLocale, scheduleCubit),
        isTrue,
        reason: 'ScheduleCubit instance must remain identical after locale toggle',
      );
      expect(cubitAfterLocale.state, equals(initialScheduleState));
    });
  });

  group('TimetableScreen Error State & Retry Tests (Item 5)', () {
    testWidgets('TimetableScreen renders errorMessage and Retry button triggers cubit load', (tester) async {
      SharedPreferences.setMockInitialValues({
        'student_group': 'B',
        'student_section': 20,
        'app_locale': 'en',
      });
      final prefs = await SharedPreferences.getInstance();
      final fakeRepo = _FakeScheduleRepository()..shouldThrow = true;

      final prefsCubit = PreferencesCubit(prefs);
      final scheduleCubit = ScheduleCubit(fakeRepo);

      // Trigger error in cubit
      await scheduleCubit.loadSchedule('B', 20);
      expect(scheduleCubit.state.errorMessage, contains('Data parsing error occurred'));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: prefsCubit),
            BlocProvider.value(value: scheduleCubit),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Scaffold(
              body: TimetableScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify error UI is displayed
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Failed to load schedule'), findsOneWidget);
      expect(find.textContaining('Data parsing error occurred'), findsOneWidget);

      // Verify Retry button is present
      final retryFinder = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retryFinder, findsOneWidget);

      // Now set repo to succeed on retry
      fakeRepo.shouldThrow = false;
      final callsBeforeRetry = fakeRepo.getWeeklyScheduleCallCount;

      await tester.tap(retryFinder);
      await tester.pump();

      expect(fakeRepo.getWeeklyScheduleCallCount, equals(callsBeforeRetry + 1));
    });
  });
}
