import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<String, LogoutParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(LogoutParams params) async {
    return await repository.logout(params.token);
  }
}

class LogoutParams extends Equatable {
  final String token;

  const LogoutParams({required this.token});

  @override
  List<Object> get props => [token];
}
