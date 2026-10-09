import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:met1/core/localization/app_localizations.dart';
import 'package:met1/presentation/widgets/feature_tour_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FeatureTourOverlay Tests', () {
    test('defaultSteps covers all 15 comprehensive sections across all 4 screens and week view', () {
      final steps = TourStep.defaultSteps();
      expect(steps.length, equals(15));
      
      // Verify tab distribution
      final tab0Steps = steps.where((s) => s.targetTabIndex == 0).toList();
      final tab1Steps = steps.where((s) => s.targetTabIndex == 1).toList();
      final tab2Steps = steps.where((s) => s.targetTabIndex == 2).toList();
      final tab3Steps = steps.where((s) => s.targetTabIndex == 3).toList();

      expect(tab0Steps.length, equals(7)); // Today (3) + ViewToggle (1) + Week (2) + BottomNav (1)
      expect(tab1Steps.length, equals(2)); // Grad Project Header + Tabs
      expect(tab2Steps.length, equals(3)); // Campus Directory, Attendance, Portals
      expect(tab3Steps.length, equals(3)); // Prefs, Theme, Notifications

      // Verify Week View specific steps
      expect(steps.any((s) => s.id == 'week_day_selector'), isTrue);
      expect(steps.any((s) => s.id == 'week_schedule_list'), isTrue);
    });

    testWidgets('renders all tour steps sequentially and completes', (tester) async {
      bool completed = false;
      bool skipped = false;

      final key1 = GlobalKey();
      final key2 = GlobalKey();

      final steps = [
        TourStep(
          id: 'step1',
          targetKey: key1,
          icon: Icons.alarm,
          title: (_) => 'Step 1 Title',
          description: (_) => 'Step 1 Description',
        ),
        TourStep(
          id: 'step2',
          targetKey: key2,
          icon: Icons.list,
          title: (_) => 'Step 2 Title',
          description: (_) => 'Step 2 Description',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(key: key1, width: 200, height: 100, color: Colors.blue),
                    Container(key: key2, width: 200, height: 100, color: Colors.green),
                  ],
                ),
                FeatureTourOverlay(
                  steps: steps,
                  onComplete: () => completed = true,
                  onSkip: () => skipped = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Step 1
      expect(find.text('Step 1 Title'), findsOneWidget);
      expect(find.text('Step 1 Description'), findsOneWidget);

      // Tap Next
      final nextFinder = find.byType(ElevatedButton);
      expect(nextFinder, findsOneWidget);
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      // Check Step 2
      expect(find.text('Step 2 Title'), findsOneWidget);
      expect(find.text('Step 2 Description'), findsOneWidget);

      // Tap Finish
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(skipped, isFalse);

      final hasSeen = await FeatureTourOverlay.hasSeenTour();
      expect(hasSeen, isTrue);
    });

    testWidgets('Arabic RTL uses Left arrow for Next and Right arrow for Previous', (tester) async {
      final steps = [
        TourStep(
          id: 'step1',
          icon: Icons.alarm,
          title: (loc) => loc.isArabic ? 'العنوان ١' : 'Title 1',
          description: (loc) => loc.isArabic ? 'الوصف ١' : 'Desc 1',
        ),
        TourStep(
          id: 'step2',
          icon: Icons.list,
          title: (loc) => loc.isArabic ? 'العنوان ٢' : 'Title 2',
          description: (loc) => loc.isArabic ? 'الوصف ٢' : 'Desc 2',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: FeatureTourOverlay(
              steps: steps,
              onComplete: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Next button has arrow_forward_rounded (pointing RIGHT →)
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      // Tap Next to reach Step 2
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Step 2: Previous button has arrow_back_rounded (pointing LEFT ←)
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('skip button marks tour as seen and triggers onSkip', (tester) async {
      bool completed = false;
      bool skipped = false;

      final steps = [
        TourStep(
          id: 'step1',
          icon: Icons.alarm,
          title: (_) => 'Step 1',
          description: (_) => 'Desc 1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [AppLocalizationsDelegate()],
          home: Scaffold(
            body: FeatureTourOverlay(
              steps: steps,
              onComplete: () => completed = true,
              onSkip: () => skipped = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Skip (close icon)
      final skipFinder = find.byIcon(Icons.close_rounded);
      expect(skipFinder, findsOneWidget);
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      expect(skipped, isTrue);
      expect(completed, isFalse);

      final hasSeen = await FeatureTourOverlay.hasSeenTour();
      expect(hasSeen, isTrue);
    });
  });
}

