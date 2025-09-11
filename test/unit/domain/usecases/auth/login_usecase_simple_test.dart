import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_template/core/error/failures.dart';
import 'package:flutter_template/domain/entities/auth_response.dart';
import 'package:flutter_template/domain/entities/user.dart';
import 'package:flutter_template/domain/repositories/auth_repository.dart';
import 'package:flutter_template/domain/usecases/auth/auth_usecases.dart';

// Mock class for testing
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  
  const testUser = User(
    id: 1,
    name: 'Test User',
    email: testEmail,
    phone: '+1234567890',
    image: '',
    status: 1,
  );
  
  const testAuthResponse = AuthResponse(
    accessToken: 'token123',
    tokenType: 'Bearer',
    isVendor: 0,
    expireIn: 3600,
    user: testUser,
  );

  group('LoginUseCase', () {
    test(
      'should return AuthResponse when login is successful',
      () async {
        // Arrange
        when(() => mockRepository.login(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => const Right(testAuthResponse));

        // Act
        final result = await usecase(const LoginParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        expect(result, const Right(testAuthResponse));
        verify(() => mockRepository.login(
          email: testEmail,
          password: testPassword,
        )).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when login fails with server error',
      () async {
        // Arrange
        const serverFailure = ServerFailure('Login failed', 401);
        when(() => mockRepository.login(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => const Left(serverFailure));

        // Act
        final result = await usecase(const LoginParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        expect(result, const Left(serverFailure));
        verify(() => mockRepository.login(
          email: testEmail,
          password: testPassword,
        )).called(1);
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // Arrange
        const networkFailure = NetworkFailure('No internet connection');
        when(() => mockRepository.login(
          email: testEmail,
          password: testPassword,
        )).thenAnswer((_) async => const Left(networkFailure));

        // Act
        final result = await usecase(const LoginParams(
          email: testEmail,
          password: testPassword,
        ));

        // Assert
        expect(result, const Left(networkFailure));
        verify(() => mockRepository.login(
          email: testEmail,
          password: testPassword,
        )).called(1);
      },
    );
  });

  group('LoginParams', () {
    test('should support value equality', () {
      // Arrange
      const params1 = LoginParams(email: testEmail, password: testPassword);
      const params2 = LoginParams(email: testEmail, password: testPassword);
      const params3 = LoginParams(email: 'different@example.com', password: testPassword);

      // Assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should have correct props', () {
      // Arrange
      const params = LoginParams(email: testEmail, password: testPassword);

      // Assert
      expect(params.props, [testEmail, testPassword]);
    });
  });
}
