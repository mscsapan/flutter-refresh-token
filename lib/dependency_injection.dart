import '/presentation/cubit/home/home_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/home_repository_impl.dart';
import 'dependency_injection_packages.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/home/home_usecases.dart';

class DInjector {
  static late final SharedPreferences _sharedPreferences;
  static late final LocalDataSource _localDataSource;

  /// Pre-configured [FlutterSecureStorage] instance for sensitive data.
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> initDB() async {

    _sharedPreferences = await SharedPreferences.getInstance();

    _localDataSource = LocalDataSourceImpl(sharedPreferences: _sharedPreferences, secureStorage: _secureStorage);

    DioClient.configure(localDataSource: _localDataSource);

    // Initialise the token manager so cached tokens are available immediately
    await TokenManager.instance.init();
  }

  static final repositoryProvider = <RepositoryProvider>[
    RepositoryProvider<SharedPreferences>(create: (context) => _sharedPreferences),

    RepositoryProvider<FlutterSecureStorage>(create: (context) => _secureStorage),

    RepositoryProvider<LocalDataSource>(create: (context) => _localDataSource),
    // Core dependencies — Dio HTTP client
    RepositoryProvider<Dio>(
      create: (context) => DioClient.create(localDataSource: context.read<LocalDataSource>()),
    ),

    // Data sources
    RepositoryProvider<RemoteDataSource>(
      create: (context) => RemoteDataSourceImpl(dio: context.read<Dio>()),
    ),

    // Repository implementations
    RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        remoteDataSources: context.read(),
        localDataSources: context.read(),
        tokenManager: TokenManager.instance,
      ),
    ),
    RepositoryProvider<SettingRepository>(
      create: (context) => SettingRepositoryImpl(
        remoteDataSources: context.read(),
        localDataSources: context.read(),
      ),
    ),
    RepositoryProvider<HomeRepository>(
      create: (context) => HomeRepositoryImpl(remoteDataSources: context.read()),
    ),

    // Combined Auth Use Cases
    RepositoryProvider<AuthUseCases>(
      create: (context) => AuthUseCases.create(context.read<AuthRepository>()),
    ),
    RepositoryProvider<GetSettingUseCase>(
      create: (context) => GetSettingUseCase(context.read<SettingRepository>()),
    ),

    RepositoryProvider<HomeDataUseCases>(
      create: (context) => HomeDataUseCases.create(context.read<HomeRepository>()),
    ),
  ];

  static final blocProviders = <BlocProvider>[
    BlocProvider<InternetStatusBloc>(create: (context) => InternetStatusBloc()),
    // AuthSessionCubit manages session lifecycle (token refresh & expiry).
    // It listens to TokenRefreshService.sessionStream which is broadcast by
    // AuthInterceptor (or _TokenOnlyInterceptor) on every 401.
    BlocProvider<AuthSessionCubit>(
      create: (context) =>
          AuthSessionCubit(tokenRefreshService: DioClient.tokenRefreshService),
    ),
    BlocProvider<LoginBloc>(
      create: (BuildContext context) =>
          LoginBloc(authUseCases: context.read<AuthUseCases>()),
    ),
    BlocProvider<SettingCubit>(
      create: (BuildContext context) =>
          SettingCubit(getSettingUseCase: context.read<GetSettingUseCase>()),
    ),

    BlocProvider<HomeCubit>(
      create: (BuildContext context) =>
          HomeCubit(userCase: context.read<HomeDataUseCases>()),
    ),
  ];
}
