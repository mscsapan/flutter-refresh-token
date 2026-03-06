import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../failures/failures.dart';

/// Base contract for all async use cases.
///
/// [Output] — the domain object returned on success.
/// [Params] — the input parameter object (use [NoParams] when none needed).
abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Use case that accepts an optional parameter.
abstract class OptionalParamUseCase<Output, Params> {
  Future<Either<Failure, Output>> call([Params? params]);
}

/// Use case that executes synchronously (no async I/O, e.g. reading from cache).
abstract class SyncUseCase<Output, Params> {
  Either<Failure, Output> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
