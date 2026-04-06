import 'package:bloc_clean_architecture/data/mappers/auth/login_response_mapper.dart';
import 'package:bloc_clean_architecture/data/models/auth/login_response_model.dart';
import 'package:bloc_clean_architecture/data/models/auth/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloc_clean_architecture/core/failures/failures.dart';
import 'package:bloc_clean_architecture/domain/repositories/auth_repository.dart';
import 'package:bloc_clean_architecture/domain/usecases/auth/auth_usecases.dart';

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

  // ✅ UserModel used consistently as the input parameter
  const testUser = UserModel(
    id: 1,
    name: 'Test User',
    email: testEmail,
    phone: '+1234567890',
    image: '',
    status: 1,
  );

  const testAuthResponse = LoginResponseModel(
    accessToken: 'token123',
    tokenType: 'Bearer',
    isVendor: 0,
    expireIn: 3600,
    user: testUser,
  );

  // ✅ The input UserModel used to call the usecase
  const testLoginUser = UserModel(
    email: testEmail,
    phone: testPassword,
  );

  group('LoginUseCase', () {
    test(
      'should return AuthResponse when login is successful',
          () async {
        // Arrange
        // ✅ Fixed: Mock matches the actual input & returns domain object
        when(() => mockRepository.login(testLoginUser))
            .thenAnswer((_) async => Right(testAuthResponse.toDomain()));

        // Act
        final result = await usecase(testLoginUser);

        // Assert
        // ✅ Fixed: Compare with domain object, not response model
        expect(result, Right(testAuthResponse.toDomain()));
        verify(() => mockRepository.login(testLoginUser)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when login fails with server error',
          () async {
        // Arrange
        const serverFailure = ServerFailure('Login failed', 401);

        // ✅ Fixed: Removed misplaced parenthesis, bracket was inside when()
        when(() => mockRepository.login(testLoginUser))
            .thenAnswer((_) async => const Left(serverFailure));

        // Act
        // ✅ Fixed: Removed extra ); and use consistent testLoginUser
        final result = await usecase(testLoginUser);

        // Assert
        expect(result, const Left(serverFailure));
        // ✅ Fixed: verify matches actual call signature
        verify(() => mockRepository.login(testLoginUser)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
          () async {
        // Arrange
        const networkFailure = NetworkFailure('No internet connection');

        // ✅ Fixed: Use UserModel consistently instead of named params
        when(() => mockRepository.login(testLoginUser))
            .thenAnswer((_) async => const Left(networkFailure));

        // Act
        // ✅ Fixed: Use testLoginUser instead of LoginParams
        final result = await usecase(testLoginUser);

        // Assert
        expect(result, const Left(networkFailure));
        // ✅ Fixed: verify matches actual call signature
        verify(() => mockRepository.login(testLoginUser)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });

  group('LoginParams', () {
    test('should support value equality', () {
      // ✅ Using UserModel since LoginParams doesn't exist in this architecture
      const params1 = UserModel(email: testEmail, phone: testPassword);
      const params2 = UserModel(email: testEmail, phone: testPassword);
      const params3 = UserModel(
        email: 'different@example.com',
        phone: testPassword,
      );

      // Assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should have correct props', () {
      // Arrange
      const params = UserModel(email: testEmail, phone: testPassword);

      // Assert
      // ✅ Verify props match UserModel's equatable props
      expect(params.props, contains(testEmail));
      expect(params.props, contains(testPassword));
    });
  });
}