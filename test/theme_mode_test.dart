import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:met1/core/localization/app_localizations.dart';
import 'package:met1/core/theme/app_theme.dart';
import 'package:met1/domain/entities/schedule_entry.dart';
import 'package:met1/presentation/bloc/preferences_cubit.dart';
import 'package:met1/presentation/widgets/schedule_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeMode & Light/Dark Theme Tests', () {
    test('PreferencesCubit defaults to light and toggles to dark mode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = PreferencesCubit(prefs);

      expect(cubit.state.themeMode, ThemeMode.light);
      expect(cubit.state.isDarkMode, isFalse);

      await cubit.toggleThemeMode();
      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.state.isDarkMode, isTrue);

      // Verify persistence
      expect(prefs.getString('app_theme_mode'), 'dark');

      await cubit.toggleThemeMode();
      expect(cubit.state.themeMode, ThemeMode.light);
      expect(prefs.getString('app_theme_mode'), 'light');
    });

    test('AppTheme lightTheme and darkTheme have proper brightness and colors', () {
      final dark = AppTheme.darkTheme;
      final light = AppTheme.lightTheme;

      expect(dark.brightness, Brightness.dark);
      expect(light.brightness, Brightness.light);
      expect(dark.scaffoldBackgroundColor, AppTheme.bgDark);
      expect(light.scaffoldBackgroundColor, AppTheme.bgLight);

      expect(AppTheme.sessionColor('lecture', true), AppTheme.lectureColor);
      expect(AppTheme.sessionColor('lecture', false), AppTheme.lectureColorLight);
      expect(AppTheme.getRestColor(true), AppTheme.restColor);
      expect(AppTheme.getRestColor(false), AppTheme.restColorLight);
    });

    testWidgets('ScheduleCard renders cleanly in both dark and light modes', (tester) async {
      const entry = ScheduleEntry(
        subjectId: 'dss',
        subjectNameAr: 'نظم دعم القرار',
        subjectNameEn: 'Decision Support Systems',
        type: 'lecture',
        day: 'saturday',
        startTime: '08:45',
        endTime: '10:15',
        locationId: 'hall_1',
        locationNameAr: 'مدرج 1',
        locationNameEn: 'Hall 1',
        locationType: 'hall',
        instructorId: 'dr_dss',
        instructorNameAr: 'د. سمير',
        instructorNameEn: 'Dr. Samir',
        forSections: [],
        isForAllSections: true,
        subjectColor: '#6C63FF',
        group: 'A',
      );

      // Render in Dark Mode
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('ar'), Locale('en')],
          locale: Locale('ar'),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: ScheduleCard(entry: entry),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('نظم دعم القرار'), findsOneWidget);

      // Render in Light Mode
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('ar'), Locale('en')],
          locale: Locale('ar'),
          themeMode: ThemeMode.light,
          home: Scaffold(
            body: ScheduleCard(entry: entry),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('نظم دعم القرار'), findsOneWidget);
    });
  });
}
