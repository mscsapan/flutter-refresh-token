import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

class GetExistingUserInfoUseCase implements SyncUseCase<AuthResponse, NoParams> {
  final AuthRepository repository;

  GetExistingUserInfoUseCase(this.repository);

  @override
  Either<Failure, AuthResponse> call(NoParams params) {
    return repository.getExistingUserInfo();
  }
}
