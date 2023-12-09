import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  String routeIdToAccept = '1';
  String userName = 'Christian';
  String password = '1234';
  int delayTime = 3;
  int amountOfSteps = 4;

  testWidgets('Whole App Test',
      (WidgetTester tester) async {
    /// Setup
    app.main();
    await tester.pumpAndSettle();

    /// Login
    final Finder loginButton = find.byKey(const Key('login'));
    final Finder userNameField = find.byKey(const Key('userNameField'));
    final Finder passwordField = find.byKey(const Key('passwordField'));

    await tester.enterText(userNameField, userName);
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: delayTime));

    expect(find.byKey(const Key('menuScreen')), findsOneWidget);

    /// Get Routes on Menu Screen
    final Finder getRoutesButton = find.byKey(const Key('getRoutesButton'));

    await tester.tap(getRoutesButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: delayTime));


    expect(find.byKey(Key(routeIdToAccept)), findsOneWidget);

    /// Accept Route
    final Finder acceptRouteButton = find.byKey(Key(routeIdToAccept));

    await tester.tap(acceptRouteButton);
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: delayTime));

    expect(find.byKey(const Key('routeDisplayScreen')), findsOneWidget);

    /// Continue through the Steps

    for (int i=0;i<amountOfSteps-1;i++){
      Finder continueButton = find.byType(ElevatedButton).at(i);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      await Future.delayed(Duration(seconds: delayTime));
    }


    });
}