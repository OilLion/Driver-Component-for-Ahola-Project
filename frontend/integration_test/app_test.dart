import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  String routeIdToAccept = '5';
  String userName = 'Oli';
  String password = '1234';


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
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('menuScreen')), findsOneWidget);
    //await tester.pumpAndSettle();


    /// Get Routes on Menu Screen
    final Finder getRoutesButton = find.byKey(const Key('getRoutesButton'));

    await tester.tap(getRoutesButton);
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byKey(Key(routeIdToAccept)), findsOneWidget);

    /// Accept Route
    final Finder acceptRouteButton = find.byKey(Key(routeIdToAccept));

    await tester.tap(acceptRouteButton);
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('routeDisplayScreen')), findsOneWidget);

    /// Continue 1 Step
    final Finder continueButton = find.byType(ElevatedButton).first;

    await tester.tap(continueButton);
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();




















    });
}