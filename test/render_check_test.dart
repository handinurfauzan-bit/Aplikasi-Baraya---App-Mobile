import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kumpul_in/screens/login_screen.dart';
import 'package:kumpul_in/screens/register_screen.dart';

void main() {
  testWidgets('login golden 1100x980', (tester) async {
    tester.view.physicalSize = const Size(1100, 980);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/login_1100.png'),
    );
  });

  testWidgets('login golden 800x700', (tester) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/login_700.png'),
    );
  });

  testWidgets('register golden 1100x980', (tester) async {
    tester.view.physicalSize = const Size(1100, 980);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/register_1100.png'),
    );
  });
}
