import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';

import 'package:bloc_clean_architecture/domain/entities/auth_response.dart';
import 'package:bloc_clean_architecture/domain/entities/user.dart';

/// Test data constants and helper objects
class TestData {
  // Test user data
  static const testEmail = 'test@example.com';
  static const testPassword = 'password123';
  static const testToken = 'test_access_token_123';
  
  static const testUser = User(
    id: 1,
    name: 'Test User',
    email: testEmail,
    phone: '+1234567890',
    status: 0,
    image: '',
  );
  
  static const testAuthResponse = AuthResponse(
    accessToken: testToken,
    tokenType: 'Bearer',
    isVendor: 0,
    expireIn: 3600,
    user: testUser,
  );
  
  // Different test scenarios
  static const testVendorUser = User(
    id: 2,
    name: 'Vendor User',
    email: 'vendor@example.com',
    phone: '+1234567890',
    status: 0,
    image: '',
  );
  
  static const testVendorAuthResponse = AuthResponse(
    accessToken: 'vendor_token_456',
    tokenType: 'Bearer',
    isVendor: 1,
    expireIn: 7200,
    user: testVendorUser,
  );
  
  // API Response Mock Data
  static Map<String, dynamic> get testUserResponseJson => {
    'access_token': testToken,
    'token_type': 'Bearer',
    'is_vendor': 0,
    'expires_in': 3600,
    'user': {
      'id': 1,
      'name': 'Test User',
      'email': testEmail,
      'phone': '+1234567890',
      'image': '',
      'status': 0,
    },
  };
  
  // Error scenarios
  static const testValidationErrors = {
    'email': ['The email field is required.'],
    'password': ['The password must be at least 6 characters.'],
  };
  
  static const testServerErrorResponse = {
    'success': false,
    'message': 'Internal server error',
    'status_code': 500,
  };
}

/// Widget testing helpers
class WidgetTestHelpers {
  /// Wraps a widget with MaterialApp for testing
  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }
  
  /// Wraps a widget with a BLoC provider for testing
  static Widget wrapWithBloc<T extends StateStreamableSource<Object?>>(
    T bloc,
    Widget child,
  ) {
    return MaterialApp(
      home: BlocProvider<T>.value(
        value: bloc,
        child: Scaffold(body: child),
      ),
    );
  }
  
  /// Wraps a widget with multiple BLoC providers
  static Widget wrapWithMultipleBlocs(
    List<BlocProvider> providers,
    Widget child,
  ) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: providers,
        child: Scaffold(body: child),
      ),
    );
  }
  
  /// Creates a full app widget for integration testing
  static Widget createFullAppWidget({
    String? initialRoute,
    List<BlocProvider>? blocProviders,
    List<RepositoryProvider>? repositoryProviders,
  }) {
    return MultiRepositoryProvider(
      providers: repositoryProviders ?? [],
      child: MultiBlocProvider(
        providers: blocProviders ?? [],
        child: MaterialApp(
          initialRoute: initialRoute ?? '/',
          routes: {
            '/': (context) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
            '/login': (context) => const Scaffold(
              body: Center(child: Text('Login')),
            ),
          },
        ),
      ),
    );
  }
}

/// Test utilities for common testing patterns
class TestUtilities {
  /// Sets up mock SharedPreferences for testing
  static void setupMockSharedPreferences({
    Map<String, Object> values = const {},
  }) {
    SharedPreferences.setMockInitialValues(values);
  }
  
  /// Pumps and settles the widget tree
  static Future<void> pumpAndSettle(
    WidgetTester tester, [
    Duration timeout = const Duration(seconds: 5),
  ]) async {
    await tester.pump();
    await tester.pumpAndSettle(timeout);
  }
  
  /// Common finder methods
  static Finder findByText(String text) => find.text(text);
  static Finder findByKey(String key) => find.byKey(ValueKey(key));
  static Finder findByType<T>() => find.byType(T);
  static Finder findByIcon(IconData icon) => find.byIcon(icon);
  
  /// Input helpers
  static Future<void> enterText(
    WidgetTester tester,
    String key,
    String text,
  ) async {
    await tester.enterText(findByKey(key), text);
    await tester.pump();
  }
  
  static Future<void> tapButton(
    WidgetTester tester,
    String key, {
    Duration? pumpDuration,
  }) async {
    await tester.tap(findByKey(key));
    await pumpAndSettle(tester, pumpDuration ?? const Duration(seconds: 2));
  }
  
  /// Assertion helpers
  static void expectToFindText(String text, {int count = 1}) {
    if (count == 1) {
      expect(findByText(text), findsOneWidget);
    } else {
      expect(findByText(text), findsNWidgets(count));
    }
  }
  
  static void expectNotToFindText(String text) {
    expect(findByText(text), findsNothing);
  }
  
  static void expectToFindWidget<T>({int count = 1}) {
    if (count == 1) {
      expect(findByType<T>(), findsOneWidget);
    } else {
      expect(findByType<T>(), findsNWidgets(count));
    }
  }
  
  static void expectToFindKey(String key) {
    expect(findByKey(key), findsOneWidget);
  }
  
  /// Form testing helpers
  static Future<void> fillLoginForm(
    WidgetTester tester, {
    String email = TestData.testEmail,
    String password = TestData.testPassword,
    bool rememberMe = false,
  }) async {
    await enterText(tester, 'email_field', email);
    await enterText(tester, 'password_field', password);
    
    if (rememberMe) {
      await tester.tap(findByKey('remember_me_checkbox'));
      await tester.pump();
    }
  }
  
  /// Loading state helpers
  static void expectLoadingState() {
    expectToFindWidget<CircularProgressIndicator>();
  }
  
  static void expectErrorState(String errorMessage) {
    expectToFindText(errorMessage);
  }
  
  /// Scroll helpers
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable,
  ) async {
    await tester.scrollUntilVisible(finder, 500.0, scrollable: scrollable);
    await pumpAndSettle(tester);
  }
  
  /// Navigation helpers
  static void expectRoute(String routeName) {
    // This would need to be implemented based on your routing solution
    // For now, it's a placeholder
  }
}

/// Custom matchers for testing
class CustomMatchers {
  static Matcher isFailure() => const TypeMatcher<Exception>();
  static Matcher isSuccess() => isNot(isFailure());
  
  static Matcher isEither() => const TypeMatcher<Either>();
  static Matcher isRight() => predicate((Either either) => either.isRight());
  static Matcher isLeft() => predicate((Either either) => either.isLeft());
}

/// Mock response builders for API testing
class MockResponseBuilder {
  static Map<String, dynamic> successResponse({
    required Map<String, dynamic> data,
    String message = 'Success',
  }) {
    return {
      'success': true,
      'message': message,
      'data': data,
      'status_code': 200,
    };
  }
  
  static Map<String, dynamic> errorResponse({
    required String message,
    int statusCode = 400,
    Map<String, dynamic>? errors,
  }) {
    return {
      'success': false,
      'message': message,
      'status_code': statusCode,
      if (errors != null) 'errors': errors,
    };
  }
  
  static Map<String, dynamic> validationErrorResponse({
    required Map<String, List<String>> errors,
    String message = 'Validation failed',
  }) {
    return {
      'success': false,
      'message': message,
      'status_code': 422,
      'errors': errors,
    };
  }
  
  static Map<String, dynamic> unauthorizedResponse() {
    return errorResponse(
      message: 'Unauthorized access',
      statusCode: 401,
    );
  }
  
  static Map<String, dynamic> serverErrorResponse() {
    return errorResponse(
      message: 'Internal server error',
      statusCode: 500,
    );
  }
}
