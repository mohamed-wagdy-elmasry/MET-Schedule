import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:met1/core/localization/app_localizations.dart';
import 'package:met1/domain/entities/schedule_entry.dart';
import 'package:met1/presentation/widgets/schedule_card.dart';

void main() {
  testWidgets('ScheduleCard displays single instructor on one line', (tester) async {
    const entry = ScheduleEntry(
      subjectId: 'dss',
      subjectNameAr: 'نظم دعم القرار',
      subjectNameEn: 'Decision Support Systems',
      type: 'section',
      day: 'saturday',
      startTime: '11:20 ص',
      endTime: '12:30 م',
      locationId: 'room_rc504',
      locationNameAr: 'R.C504',
      locationNameEn: 'R.C504',
      locationType: 'room',
      instructorId: 'mohamed_moussa',
      instructorNameAr: 'م.م محمد موسى',
      instructorNameEn: 'Mohamed Moussa',
      instructors: ['م.م محمد موسى'],
      forSections: [1, 2],
      isForAllSections: false,
      subjectColor: '#6C5CE7',
      group: 'A',
    );

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
        home: Scaffold(
          body: ScheduleCard(entry: entry),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('م.م محمد موسى'), findsOneWidget);
    expect(find.text('R.C504'), findsOneWidget);
    expect(find.text('11:20 ص – 12:30 م'), findsOneWidget);
  });

  testWidgets('ScheduleCard displays multiple instructors on separate lines', (tester) async {
    const entry = ScheduleEntry(
      subjectId: 'gis',
      subjectNameAr: 'نظم المعلومات الجغرافية',
      subjectNameEn: 'Geographic Information Systems',
      type: 'section',
      day: 'saturday',
      startTime: '12:30 م',
      endTime: '1:55 م',
      locationId: 'l4',
      locationNameAr: 'L.4',
      locationNameEn: 'L.4',
      locationType: 'room',
      instructorId: 'multi',
      instructorNameAr: 'م. مروة السيد صالح / م. هند عزت',
      instructorNameEn: 'Marwa / Hend',
      instructors: ['م. مروة السيد صالح', 'م. هند عزت'],
      forSections: [1, 2],
      isForAllSections: false,
      subjectColor: '#00B894',
      group: 'A',
    );

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
        home: Scaffold(
          body: ScheduleCard(entry: entry),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('م. مروة السيد صالح'), findsOneWidget);
    expect(find.text('م. هند عزت'), findsOneWidget);
    // Ensure they are not joined with comma or slash
    expect(find.textContaining('م. مروة السيد صالح،'), findsNothing);
    expect(find.textContaining('م. مروة السيد صالح /'), findsNothing);

    // Verify vertical layout: instructor 1 is above instructor 2
    final firstPos = tester.getTopLeft(find.text('م. مروة السيد صالح'));
    final secondPos = tester.getTopLeft(find.text('م. هند عزت'));
    expect(firstPos.dy < secondPos.dy, isTrue,
        reason: 'First instructor must be placed above second instructor');
  });
}
