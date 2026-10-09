import 'package:flutter_test/flutter_test.dart';
import 'package:met1/main.dart';
import 'package:met1/presentation/screens/home_screen.dart';
import 'package:met1/presentation/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke test: app launches with SplashScreen then navigates to HomeScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'has_onboarded': true,
      'has_seen_inapp_feature_tour_v8': true,
      'student_group': 'A',
      'student_section': 1,
      'app_locale': 'ar',
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(METApp(prefs: prefs));
    await tester.pump();

    // Verify initial splash screen renders
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance past splash transition timer (2000ms + animation 500ms)
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Verify HomeScreen is now displayed
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
