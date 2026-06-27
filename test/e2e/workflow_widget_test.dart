import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/screens/assistant_screen.dart';
import 'package:traindelay_app/screens/create_account_screen.dart';
import 'package:traindelay_app/screens/history_screen.dart';
import 'package:traindelay_app/screens/home_screen.dart';
import 'package:traindelay_app/screens/prediction_screen.dart';
import 'package:traindelay_app/screens/sign_in_screen.dart';
import 'package:traindelay_app/services/backend_service.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(() async {
    await loadTestEnv();
  });

  group('E2E: Authentication screens', () {
    testWidgets('sign-in screen renders email, password, and action buttons',
        (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const SignInScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Welcome back to NextTrain'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('create account screen renders all registration fields',
        (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const CreateAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('sign-in validates empty credentials', (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const SignInScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '');
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email and password'), findsOneWidget);
    });
  });

  group('E2E: Home navigation workflow', () {
    testWidgets('bottom nav switches between Home, Predict, Assistant, Profile',
        (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SRI LANKA RAILWAYS'), findsOneWidget);
      expect(find.text('QUICK ACCESS'), findsOneWidget);

      await tester.tap(find.text('Predict'));
      await tester.pumpAndSettle();
      expect(find.text('CALCULATE DELAY'), findsOneWidget);
      expect(find.textContaining('NEURAL FORECAST'), findsOneWidget);

      await tester.tap(find.text('Assistant'));
      await tester.pumpAndSettle();
      expect(find.text('NextTrain AI'), findsOneWidget);
      expect(find.text('Ask NextTrain AI...'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to view your profile'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('QUICK ACCESS'), findsOneWidget);
    });

    testWidgets('home quick access navigates to predict tab', (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Predict Delay'));
      expect(find.text('CALCULATE DELAY'), findsOneWidget);
    });

    testWidgets('home opens history screen from quick access', (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('History'));
      expect(find.text('Prediction History'), findsOneWidget);
      expect(find.text('No predictions yet'), findsOneWidget);
    });
  });

  group('E2E: Delay prediction workflow', () {
    testWidgets('calculate delay shows result dialog', (tester) async {
      predictionHistoryNotifier.value = [];
      await configureLargeTestSurface(tester);

      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Predict'));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('CALCULATE DELAY'));

      expect(find.text('Prediction Result'), findsOneWidget);
      expect(find.textContaining('Estimated Delay:'), findsOneWidget);
    });

    testWidgets('prediction adds record to in-memory history', (tester) async {
      predictionHistoryNotifier.value = [];
      await configureLargeTestSurface(tester);

      await tester.pumpWidget(wrapApp(const PredictionScreen()));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('CALCULATE DELAY'));

      expect(predictionHistoryNotifier.value, isNotEmpty);
      expect(predictionHistoryNotifier.value.first.trainName, isNotEmpty);
      expect(
        predictionHistoryNotifier.value.first.delayMinutes,
        inInclusiveRange(5, 60),
      );
    });
  });

  group('E2E: History workflow', () {
    testWidgets('history screen lists stored predictions', (tester) async {
      await configureLargeTestSurface(tester);
      predictionHistoryNotifier.value = [
        const PredictionRecord(
          trainName: 'Udarata Menike',
          route: 'Colombo → Kandy',
          delayMinutes: 14,
          date: 'Just now',
          accuracy: '94%',
        ),
      ];

      await tester.pumpWidget(wrapApp(const HistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Udarata Menike'), findsOneWidget);
      expect(find.text('Colombo → Kandy'), findsOneWidget);
      expect(find.text('14 min'), findsOneWidget);
      expect(find.textContaining('Accuracy: 94%'), findsOneWidget);
    });
  });

  group('E2E: AI assistant workflow', () {
    testWidgets('assistant screen renders chat UI', (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const AssistantScreen()));
      await tester.pumpAndSettle();

      expect(find.text('NextTrain AI'), findsOneWidget);
      expect(find.textContaining('Welcome to NextTrain AI'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('assistant sends a user message into the chat', (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const AssistantScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'What trains go from Colombo to Kandy?',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('What trains go from Colombo to Kandy?'), findsOneWidget);
    });
  });

  group('E2E: Profile workflow', () {
    testWidgets('profile screen prompts sign-in when unauthenticated', (tester) async {
      await configureLargeTestSurface(tester);
      await tester.pumpWidget(wrapApp(const HomeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to view your profile'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
    });
  });
}
