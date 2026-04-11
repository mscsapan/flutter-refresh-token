part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<HomeModel?>? homeData;

  const HomeLoaded(this.homeData);

  @override
  List<Object?> get props => [homeData];
}

final class HomeError extends HomeState {
  final String message;
  final int statusCode;

  const HomeError(this.message, this.statusCode);

  @override
  List<Object> get props => [message, statusCode];
}
