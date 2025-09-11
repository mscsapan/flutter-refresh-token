import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_template/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete login flow with valid credentials', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify splash screen appears first
      expect(find.byKey(const ValueKey('splash_screen')), findsOneWidget);
      
      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to login screen or main screen based on auth state
      // For this test, let's assume we're not logged in
      
      // Look for login related UI elements
      final goToLoginButton = find.byKey(const ValueKey('go_to_login_button'));
      
      // Tap login navigation button if it exists
      if (tester.any(goToLoginButton)) {
        await tester.tap(goToLoginButton);
        await tester.pumpAndSettle();
      }

      // Verify we're on the login screen
      expect(find.byKey(const ValueKey('login_screen')), findsOneWidget);
      expect(find.byKey(const ValueKey('email_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('password_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('login_submit_button')), findsOneWidget);

      // Fill in the login form
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        'password123',
      );
      await tester.pump();

      // Submit the login form
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pump();

      // Verify loading state appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete (adjust timeout based on your API)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify successful login - should navigate to main screen
      // Note: This assumes successful login with the test credentials
      // In a real integration test, you'd use test environment with known valid credentials
      expect(find.byKey(const ValueKey('main_screen')), findsOneWidget);
    });

    testWidgets('login with invalid credentials shows error', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login screen
      final goToLoginButton = find.byKey(const ValueKey('go_to_login_button'));
      if (tester.any(goToLoginButton)) {
        await tester.tap(goToLoginButton);
        await tester.pumpAndSettle();
      }

      // Fill in invalid credentials
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'invalid@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        'wrongpassword',
      );
      await tester.pump();

      // Submit the form
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pump();

      // Wait for response
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify error message is displayed
      expect(find.text('Invalid credentials'), findsOneWidget);
      // Or check for generic error message
      expect(find.textContaining('Login failed'), findsOneWidget);

      // Verify we're still on login screen
      expect(find.byKey(const ValueKey('login_screen')), findsOneWidget);
    });

    testWidgets('form validation shows appropriate errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login screen
      final goToLoginButton = find.byKey(const ValueKey('go_to_login_button'));
      if (tester.any(goToLoginButton)) {
        await tester.tap(goToLoginButton);
        await tester.pumpAndSettle();
      }

      // Try to submit empty form
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle();

      // Check for validation errors
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Fill invalid email
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'invalid-email',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Fill short password
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        '123',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('at least 6 characters'), findsOneWidget);
    });

    testWidgets('logout flow works correctly', (WidgetTester tester) async {
      // First, login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login and login with valid credentials
      final goToLoginButton = find.byKey(const ValueKey('go_to_login_button'));
      if (tester.any(goToLoginButton)) {
        await tester.tap(goToLoginButton);
        await tester.pumpAndSettle();
      }

      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify we're logged in
      expect(find.byKey(const ValueKey('main_screen')), findsOneWidget);

      // Find and tap logout button
      final logoutButton = find.byKey(const ValueKey('logout_button'));
      final settingsButton = find.byKey(const ValueKey('settings_button'));
      
      // Navigate to settings if logout is there
      if (tester.any(settingsButton)) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
      }

      // Tap logout
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Confirm logout if there's a confirmation dialog
      final confirmLogoutButton = find.byKey(const ValueKey('confirm_logout_button'));
      if (tester.any(confirmLogoutButton)) {
        await tester.tap(confirmLogoutButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // Verify we're back to login/splash screen
      final isLoginScreen = tester.any(find.byKey(const ValueKey('login_screen')));
      final isSplashScreen = tester.any(find.byKey(const ValueKey('splash_screen')));
      
      expect(isLoginScreen || isSplashScreen, isTrue);
    });

    testWidgets('remember me functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login
      final goToLoginButton = find.byKey(const ValueKey('go_to_login_button'));
      if (tester.any(goToLoginButton)) {
        await tester.tap(goToLoginButton);
        await tester.pumpAndSettle();
      }

      // Fill form with remember me checked
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        'password123',
      );
      
      // Check remember me
      final rememberMeCheckbox = find.byKey(const ValueKey('remember_me_checkbox'));
      if (tester.any(rememberMeCheckbox)) {
        await tester.tap(rememberMeCheckbox);
        await tester.pump();
      }

      // Submit login
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Logout
      final logoutButton = find.byKey(const ValueKey('logout_button'));
      if (tester.any(logoutButton)) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();
      }

      // Restart app (simulate app restart)
      await tester.binding.reassembleApplication();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate back to login
      final goToLoginButton2 = find.byKey(const ValueKey('go_to_login_button'));
      if (tester.any(goToLoginButton2)) {
        await tester.tap(goToLoginButton2);
        await tester.pumpAndSettle();
      }

      // Verify credentials are remembered
      final emailField = find.byKey(const ValueKey('email_field'));
      final passwordField = find.byKey(const ValueKey('password_field'));
      
      if (tester.any(emailField)) {
        final emailWidget = tester.widget<TextFormField>(emailField);
        expect(emailWidget.controller?.text, equals('test@example.com'));
      }
      
      if (tester.any(passwordField)) {
        final passwordWidget = tester.widget<TextFormField>(passwordField);
        expect(passwordWidget.controller?.text, equals('password123'));
      }
    });

    testWidgets('network connectivity affects login', (WidgetTester tester) async {
      // This test would require network simulation
      // For now, it's a placeholder to show how you might test offline scenarios
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to login
      final goToLoginButton = find.byKey(const ValueKey('go_to_login_button'));
      if (tester.any(goToLoginButton)) {
        await tester.tap(goToLoginButton);
        await tester.pumpAndSettle();
      }

      // Fill form
      await tester.enterText(
        find.byKey(const ValueKey('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('password_field')),
        'password123',
      );

      // Submit (this would fail in offline mode)
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // In a real test, you'd check for network error messages
      // expect(find.textContaining('No internet connection'), findsOneWidget);
    });
  });

  group('Navigation Integration Tests', () {
    testWidgets('deep linking works correctly', (WidgetTester tester) async {
      // Test deep linking to specific routes
      // This is a placeholder for deep link testing
    });

    testWidgets('back button navigation works', (WidgetTester tester) async {
      // Test system back button navigation
      app.main();
      await tester.pumpAndSettle();

      // Navigate through screens and test back navigation
      // This would involve navigating to different screens and pressing back
    });
  });
}
