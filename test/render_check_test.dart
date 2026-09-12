import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumpul_in/screens/login_screen.dart';
import 'package:kumpul_in/screens/register_screen.dart';

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/logo1.1.png'),
      tester.element(find.byType(MaterialApp)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login golden 1100x980', (tester) async {
    tester.view.physicalSize = const Size(1100, 980);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpScreen(tester, const LoginScreen());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/login_1100.png'),
    );
  });

  testWidgets('login golden 800x700', (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpScreen(tester, const LoginScreen());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/login_700.png'),
    );
  });

  testWidgets('register golden 1100x980', (tester) async {
    tester.view.physicalSize = const Size(1100, 980);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pumpScreen(tester, const RegisterScreen());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/register_1100.png'),
    );
  });
}
