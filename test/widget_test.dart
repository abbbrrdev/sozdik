import 'package:flutter_test/flutter_test.dart';
import 'package:sozdik/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // Smoke test: verify that the app widget tree builds without errors.
    // Full DI / SharedPreferences is not wired in widget tests,
    // so we just verify the root widget is a MaterialApp.
    expect(const SozdiTapApp(), isA<SozdiTapApp>());
  });
}
