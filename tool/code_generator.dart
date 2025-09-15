import 'dart:io';

import 'package:flutter/material.dart';

class CodeGenerator {
  static Future<void> generateFeature(String featureName) async {
    final pascalCase = _toPascalCase(featureName);
    final snakeCase = _toSnakeCase(featureName);
    final camelCase = _toCamelCase(featureName);

    // Create directories
    await _createDirectories(snakeCase);

    // Generate files
    await _generateEntity(pascalCase, snakeCase);
    await _generateRepository(pascalCase, snakeCase);
    await _generateRepositoryImpl(pascalCase, snakeCase);
    await _generateModel(pascalCase, snakeCase);
    await _generateUseCase(pascalCase, snakeCase, camelCase);
    await _generateCubit(pascalCase, snakeCase, camelCase);
    await _generateScreen(pascalCase, snakeCase);

    debugPrint('✅ Feature "$featureName" generated successfully!');
    debugPrint('📁 Files created:');
    debugPrint('  - lib/domain/entities/$snakeCase.dart');
    debugPrint('  - lib/domain/repositories/${snakeCase}_repository.dart');
    debugPrint('  - lib/data/repositories/${snakeCase}_repository_impl.dart');
    debugPrint('  - lib/data/models/$snakeCase/${snakeCase}_model.dart');
    debugPrint('  - lib/domain/usecases/$snakeCase/get_${snakeCase}_usecase.dart');
    debugPrint('  - lib/presentation/cubit/$snakeCase/${snakeCase}_cubit.dart');
    debugPrint('  - lib/presentation/cubit/$snakeCase/${snakeCase}_state.dart');
    debugPrint('  - lib/presentation/screens/$snakeCase/${snakeCase}_screen.dart');
  }

  static Future<void> _createDirectories(String snakeCase) async {
    final directories = [
      'lib/domain/entities',
      'lib/domain/repositories',
      'lib/data/repositories',
      'lib/data/models/$snakeCase',
      'lib/domain/usecases/$snakeCase',
      'lib/presentation/cubit/$snakeCase',
      'lib/presentation/screens/$snakeCase',
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }
  }

  static Future<void> _generateEntity(
    String pascalCase,
    String snakeCase,
  ) async {
    final content =
        '''import 'package:equatable/equatable.dart';

class $pascalCase extends Equatable {
  final int id;
  final String name;
  // TODO: Add your entity properties here

  const $pascalCase({
    required this.id,
    required this.name,
  });

  $pascalCase copyWith({
    int? id,
    String? name,
  }) {
    return $pascalCase(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  List<Object> get props => [id, name];
}''';

    await _writeFile('lib/domain/entities/$snakeCase.dart', content);
  }

  static Future<void> _generateRepository(
    String pascalCase,
    String snakeCase,
  ) async {
    final content =
        '''import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../entities/$snakeCase.dart';

abstract class ${pascalCase}Repository {
  Future<Either<Failure, List<$pascalCase>>> get${pascalCase}s();
  Future<Either<Failure, $pascalCase>> get${pascalCase}ById(int id);
  Future<Either<Failure, $pascalCase>> create$pascalCase($pascalCase $snakeCase);
  Future<Either<Failure, $pascalCase>> update$pascalCase($pascalCase $snakeCase);
  Future<Either<Failure, bool>> delete$pascalCase(int id);
}''';

    await _writeFile(
      'lib/domain/repositories/${snakeCase}_repository.dart',
      content,
    );
  }

  static Future<void> _generateRepositoryImpl(
    String pascalCase,
    String snakeCase,
  ) async {
    final content =
        '''import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../core/exceptions/exceptions.dart';
import '../../core/failures/failures.dart';
import '../../domain/entities/$snakeCase.dart';
import '../../domain/repositories/${snakeCase}_repository.dart';
import '../data_provider/remote_data_source.dart';
import '../models/$snakeCase/${snakeCase}_model.dart';

class ${pascalCase}RepositoryImpl implements ${pascalCase}Repository {
  final RemoteDataSource remoteDataSources;

  ${pascalCase}RepositoryImpl({required this.remoteDataSources});

  @override
  Future<Either<Failure, List<$pascalCase>>> get${pascalCase}s() async {
    debugPrint('$snakeCase-debug: $snakeCase-repo impl get${pascalCase}s');
    try {
      final result = await remoteDataSources.get${pascalCase}s();
      final ${snakeCase}s = result as List;
      final ${snakeCase}Models = List<${pascalCase}Model>.from(${snakeCase}s.map((e) => ${pascalCase}Model.fromMap(e))).toList();
      final ${snakeCase}Entities = ${snakeCase}Models.map((model) => model.toEntity()).toList();
      return Right(${snakeCase}Entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, $pascalCase>> get${pascalCase}ById(int id) async {
    debugPrint('$snakeCase-debug: $snakeCase-repo impl get${pascalCase}ById');
    try {
      final result = await remoteDataSources.get${pascalCase}ById(id);
      final ${snakeCase}Model = ${pascalCase}Model.fromMap(result);
      return Right(${snakeCase}Model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, $pascalCase>> create$pascalCase($pascalCase $snakeCase) async {
    debugPrint('$snakeCase-debug: $snakeCase-repo impl create$pascalCase');
    try {
      final ${snakeCase}Model = ${pascalCase}Model.fromEntity($snakeCase);
      final result = await remoteDataSources.create$pascalCase(${snakeCase}Model);
      final created${pascalCase}Model = ${pascalCase}Model.fromMap(result);
      return Right(created${pascalCase}Model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, $pascalCase>> update$pascalCase($pascalCase $snakeCase) async {
    debugPrint('$snakeCase-debug: $snakeCase-repo impl update$pascalCase');
    try {
      final ${snakeCase}Model = ${pascalCase}Model.fromEntity($snakeCase);
      final result = await remoteDataSources.update$pascalCase(${snakeCase}Model);
      final updated${pascalCase}Model = ${pascalCase}Model.fromMap(result);
      return Right(updated${pascalCase}Model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }

  @override
  Future<Either<Failure, bool>> delete$pascalCase(int id) async {
    debugPrint('$snakeCase-debug: $snakeCase-repo impl delete$pascalCase');
    try {
      await remoteDataSources.delete$pascalCase(id);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    }
  }
}''';

    await _writeFile(
      'lib/data/repositories/${snakeCase}_repository_impl.dart',
      content,
    );
  }

  static Future<void> _generateModel(
    String pascalCase,
    String snakeCase,
  ) async {
    final content =
        '''import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/$snakeCase.dart';

class ${pascalCase}Model extends Equatable {
  final int id;
  final String name;
  // TODO: Add your model properties here

  const ${pascalCase}Model({
    required this.id,
    required this.name,
  });

  ${pascalCase}Model copyWith({
    int? id,
    String? name,
  }) {
    return ${pascalCase}Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  // Convert from domain entity to data model
  factory ${pascalCase}Model.fromEntity($pascalCase $snakeCase) {
    return ${pascalCase}Model(
      id: $snakeCase.id,
      name: $snakeCase.name,
    );
  }

  // Convert to domain entity
  $pascalCase toEntity() {
    return $pascalCase(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory ${pascalCase}Model.fromMap(Map<String, dynamic> map) {
    return ${pascalCase}Model(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ${pascalCase}Model.fromJson(String source) => ${pascalCase}Model.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, name];
}''';

    await _writeFile(
      'lib/data/models/$snakeCase/${snakeCase}_model.dart',
      content,
    );
  }

  static Future<void> _generateUseCase(
    String pascalCase,
    String snakeCase,
    String camelCase,
  ) async {
    final content =
        '''import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/$snakeCase.dart';
import '../../repositories/${snakeCase}_repository.dart';

class Get${pascalCase}sUseCase implements OptionalParamUseCase<List<$pascalCase>, NoParams> {
  final ${pascalCase}Repository repository;

  Get${pascalCase}sUseCase(this.repository);

  @override
  Future<Either<Failure, List<$pascalCase>>> call([NoParams? params]) async {
    debugPrint('$snakeCase-debug: get-${snakeCase}s-use case');
    return await repository.get${pascalCase}s();
  }
}

class Get${pascalCase}ByIdUseCase implements UseCase<$pascalCase, int> {
  final ${pascalCase}Repository repository;

  Get${pascalCase}ByIdUseCase(this.repository);

  @override
  Future<Either<Failure, $pascalCase>> call(int id) async {
    debugPrint('$snakeCase-debug: get-$snakeCase-by-id-use case');
    return await repository.get${pascalCase}ById(id);
  }
}

class Create${pascalCase}UseCase implements UseCase<$pascalCase, $pascalCase> {
  final ${pascalCase}Repository repository;

  Create${pascalCase}UseCase(this.repository);

  @override
  Future<Either<Failure, $pascalCase>> call($pascalCase $camelCase) async {
    debugPrint('$snakeCase-debug: create-$snakeCase-use case');
    return await repository.create$pascalCase($camelCase);
  }
}

class Update${pascalCase}UseCase implements UseCase<$pascalCase, $pascalCase> {
  final ${pascalCase}Repository repository;

  Update${pascalCase}UseCase(this.repository);

  @override
  Future<Either<Failure, $pascalCase>> call($pascalCase $camelCase) async {
    debugPrint('$snakeCase-debug: update-$snakeCase-use case');
    return await repository.update$pascalCase($camelCase);
  }
}

class Delete${pascalCase}UseCase implements UseCase<bool, int> {
  final ${pascalCase}Repository repository;

  Delete${pascalCase}UseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(int id) async {
    debugPrint('$snakeCase-debug: delete-$snakeCase-use case');
    return await repository.delete$pascalCase(id);
  }
}''';

    await _writeFile(
      'lib/domain/usecases/$snakeCase/get_${snakeCase}_usecase.dart',
      content,
    );
  }

  static Future<void> _generateCubit(
    String pascalCase,
    String snakeCase,
    String camelCase,
  ) async {
    final cubitContent =
        '''import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/$snakeCase.dart';
import '../../../domain/usecases/$snakeCase/get_${snakeCase}_usecase.dart';

part '${snakeCase}_state.dart';

class ${pascalCase}Cubit extends Cubit<${pascalCase}State> {
  final Get${pascalCase}sUseCase _get${pascalCase}sUseCase;

  ${pascalCase}Cubit({required Get${pascalCase}sUseCase get${pascalCase}sUseCase})
      : _get${pascalCase}sUseCase = get${pascalCase}sUseCase,
        super(const ${pascalCase}Initial());

  List<$pascalCase> temp${pascalCase}s = [];

  Future<void> get${pascalCase}s() async {
    debugPrint('$snakeCase-debug: $snakeCase-cubit get${pascalCase}s');

    emit(const ${pascalCase}Loading());

    final result = await _get${pascalCase}sUseCase();
    result.fold((failure) {
      final errors = ${pascalCase}Error(failure.message, failure.statusCode);
      emit(errors);
    }, (success) {
      temp${pascalCase}s = success;
      final loaded = ${pascalCase}Loaded(success);
      emit(loaded);
    });
  }
}''';

    await _writeFile(
      'lib/presentation/cubit/$snakeCase/${snakeCase}_cubit.dart',
      cubitContent,
    );

    final stateContent =
        '''part of '${snakeCase}_cubit.dart';

sealed class ${pascalCase}State extends Equatable {
  const ${pascalCase}State();

  @override
  List<Object?> get props => [];
}

final class ${pascalCase}Initial extends ${pascalCase}State {
  const ${pascalCase}Initial();
}

final class ${pascalCase}Loading extends ${pascalCase}State {
  const ${pascalCase}Loading();
}

final class ${pascalCase}Error extends ${pascalCase}State {
  final String message;
  final int statusCode;
  
  const ${pascalCase}Error(this.message, this.statusCode);
  
  @override
  List<Object?> get props => [message, statusCode];
}

final class ${pascalCase}Loaded extends ${pascalCase}State {
  final List<$pascalCase> ${camelCase}s;
  
  const ${pascalCase}Loaded(this.${camelCase}s);
  
  @override
  List<Object?> get props => [${camelCase}s];
}''';

    await _writeFile(
      'lib/presentation/cubit/$snakeCase/${snakeCase}_state.dart',
      stateContent,
    );
  }

  static Future<void> _generateScreen(
    String pascalCase,
    String snakeCase,
  ) async {
    final content =
        '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/$snakeCase.dart';
import '../../cubit/$snakeCase/${snakeCase}_cubit.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/fetch_error_text.dart';
import '../../widgets/loading_widget.dart';

class ${pascalCase}Screen extends StatefulWidget {
  const ${pascalCase}Screen({super.key});

  @override
  State<${pascalCase}Screen> createState() => _${pascalCase}ScreenState();
}

class _${pascalCase}ScreenState extends State<${pascalCase}Screen> {
  late ${pascalCase}Cubit ${snakeCase}Cubit;

  @override
  void initState() {
    super.initState();
    ${snakeCase}Cubit = context.read<${pascalCase}Cubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: CustomText(text: '${pascalCase}s'),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint('$snakeCase-debug: user triggered get${pascalCase}s function');
              ${snakeCase}Cubit.get${pascalCase}s();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<${pascalCase}Cubit, ${pascalCase}State>(
        builder: (context, state) {
          if (state is ${pascalCase}Loading) {
            return const LoadingWidget();
          } else if (state is ${pascalCase}Error) {
            return FetchErrorText(text: state.message);
          } else if (state is ${pascalCase}Loaded) {
            return Loaded${pascalCase}View(${snakeCase}s: state.${snakeCase}s);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: 'Tap the button to load ${snakeCase}s'),
                  const SizedBox(height: 20),
                  if (${snakeCase}Cubit.temp${pascalCase}s.isNotEmpty)
                    Loaded${pascalCase}View(${snakeCase}s: ${snakeCase}Cubit.temp${pascalCase}s),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class Loaded${pascalCase}View extends StatelessWidget {
  const Loaded${pascalCase}View({super.key, this.${snakeCase}s});

  final List<$pascalCase>? ${snakeCase}s;

  @override
  Widget build(BuildContext context) {
    if (${snakeCase}s?.isNotEmpty ?? false) {
      return ListView.builder(
        itemCount: ${snakeCase}s?.length,
        itemBuilder: (context, index) {
          final item = ${snakeCase}s?[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: 'ID: \${item?.id}'),
                    const SizedBox(height: 4),
                    CustomText(text: 'Name: \${item?.name}'),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return const FetchErrorText(text: 'No ${snakeCase}s found');
    }
  }
}''';

    await _writeFile(
      'lib/presentation/screens/$snakeCase/${snakeCase}_screen.dart',
      content,
    );
  }

  static Future<void> _writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  static String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  static String _toSnakeCase(String input) {
    return input.toLowerCase().replaceAll(' ', '_');
  }

  static String _toCamelCase(String input) {
    final pascalCase = _toPascalCase(input);
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    debugPrint('❌ Please provide a feature name');
    debugPrint('Usage: dart tool/code_generator.dart <feature_name>');
    debugPrint('Example: dart tool/code_generator.dart user_profile');
    return;
  }

  final featureName = args[0];
  await CodeGenerator.generateFeature(featureName);
}
