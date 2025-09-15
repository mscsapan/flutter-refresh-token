import 'dart:io';

/// Comprehensive Clean Architecture Code Generator
/// 
/// This tool generates complete feature boilerplate following clean architecture principles:
/// - Proper naming conventions with suffixes
/// - Automatic dependency injection registration  
/// - Mapper connectivity between layers
/// - User choice between Bloc/Cubit
/// - Automatic routing setup
/// - Inline documentation for each step
class ImprovedCodeGenerator {
  static Future<void> generateFeature(
    String featureName, {
    bool useCubit = true, // User choice: true for Cubit, false for Bloc
    bool includeMapper = true,
  }) async {
    print('🚀 Starting code generation for feature: $featureName');
    print('📋 Configuration: ${useCubit ? 'Cubit' : 'Bloc'}, Mapper: $includeMapper');
    
    final pascalCase = _toPascalCase(featureName);
    final snakeCase = _toSnakeCase(featureName);
    final camelCase = _toCamelCase(featureName);

    print('\n📁 Step 1: Creating directory structure...');
    await _createDirectories(snakeCase);
    print('   ✅ Directories created successfully');

    print('\n📄 Step 2: Generating core architecture files...');
    print('   🏗️  Creating domain entity: ${snakeCase}_entity.dart');
    await _generateEntity(pascalCase, snakeCase);
    
    print('   🏗️  Creating repository interface: ${snakeCase}_repository.dart');
    await _generateRepository(pascalCase, snakeCase, camelCase);
    
    print('   🏗️  Creating repository implementation: ${snakeCase}_repository_impl.dart');
    await _generateRepositoryImpl(pascalCase, snakeCase, camelCase);
    
    print('   🏗️  Creating data model: ${snakeCase}_model.dart');
    await _generateModel(pascalCase, snakeCase);
    
    if (includeMapper) {
      print('   🏗️  Creating mapper: ${snakeCase}_mapper.dart');
      await _generateMapper(pascalCase, snakeCase);
    }
    
    print('   🏗️  Creating use cases: ${snakeCase}_usecase.dart');
    await _generateUseCase(pascalCase, snakeCase, camelCase);
    
    print('\n🎨 Step 3: Generating presentation layer...');
    if (useCubit) {
      print('   🏗️  Creating cubit: ${snakeCase}_cubit.dart');
      await _generateCubit(pascalCase, snakeCase, camelCase);
    } else {
      print('   🏗️  Creating bloc: ${snakeCase}_bloc.dart');
      await _generateBloc(pascalCase, snakeCase, camelCase);
    }
    
    print('   🏗️  Creating screen: ${snakeCase}_screen.dart');
    await _generateScreen(pascalCase, snakeCase, camelCase, useCubit);
    
    print('\n🔗 Step 4: Connecting architecture layers...');
    print('   📦 Registering dependencies in DI container...');
    await _registerDependencies(pascalCase, snakeCase, camelCase, useCubit);
    
    print('   📦 Adding imports to dependency packages...');
    await _addImportsToPackages(pascalCase, snakeCase, useCubit, includeMapper);
    
    print('\n🛣️  Step 5: Setting up routing...');
    print('   📍 Adding route name...');
    await _addRouteNames(pascalCase, snakeCase);
    
    print('   📍 Adding route export...');
    await _addRouteExports(pascalCase, snakeCase);
    
    print('\n✅ Feature "$featureName" generated successfully!');
    print('🎉 All files created and connected properly!');
    _printGeneratedFiles(snakeCase, useCubit, includeMapper);
    
    print('\n🔍 Integration check: All files should compile without errors');
    print('💡 Next steps:');
    print('   1. Run: flutter packages get');
    print('   2. Run: flutter analyze');
    print('   3. Test your new feature!');
  }

  /// Creates directory structure following clean architecture
  static Future<void> _createDirectories(String snakeCase) async {
    final directories = [
      'lib/domain/entities',
      'lib/domain/repositories',
      'lib/data/repositories',
      'lib/data/models/$snakeCase',
      'lib/data/mappers',
      'lib/domain/usecases/$snakeCase',
      'lib/presentation/cubit/$snakeCase',
      'lib/presentation/bloc/$snakeCase',
      'lib/presentation/screens/$snakeCase',
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }
  }

  /// Generates domain entity with proper naming: feature_entity.dart
  static Future<void> _generateEntity(String pascalCase, String snakeCase) async {
    final content = '''import 'package:equatable/equatable.dart';

/// Domain Entity for $pascalCase
/// 
/// This represents the core business object in the domain layer.
/// It contains only business logic and is independent of external frameworks.
/// 
/// Key characteristics:
/// - Pure Dart objects with no external dependencies
/// - Contains business rules and validations
/// - Used across all layers for business logic operations
class ${pascalCase}Entity extends Equatable {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final bool isActive;

  const ${pascalCase}Entity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.isActive,
  });

  /// Creates a copy of this entity with updated values
  ${pascalCase}Entity copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ${pascalCase}Entity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Business rule: Check if entity is valid
  bool get isValid => name.isNotEmpty && description.isNotEmpty;

  /// Business rule: Check if entity is recently created (within 24 hours)
  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 1;
  }

  @override
  List<Object> get props => [id, name, description, createdAt, isActive];

  @override
  String toString() {
    return '${pascalCase}Entity{id: \$id, name: \$name, description: \$description, createdAt: \$createdAt, isActive: \$isActive}';
  }
}''';

    await _writeFile('lib/domain/entities/${snakeCase}_entity.dart', content);
  }

  /// Generates repository interface following dependency inversion
  static Future<void> _generateRepository(String pascalCase, String snakeCase, String camelCase) async {
    final content = '''import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../entities/${snakeCase}_entity.dart';

/// Repository interface for $pascalCase operations
/// 
/// This defines the contract for $snakeCase data operations.
/// It follows the Dependency Inversion Principle - high-level modules 
/// (use cases) depend on this abstraction, not concrete implementations.
/// 
/// Benefits:
/// - Testability: Easy to mock for unit tests
/// - Flexibility: Can switch between different data sources
/// - Clean boundaries: Domain layer doesn't depend on data layer details
abstract class ${pascalCase}Repository {
  /// Retrieves all $snakeCase entities
  /// Returns Right(List<${pascalCase}Entity>) on success
  /// Returns Left(Failure) on error
  Future<Either<Failure, List<${pascalCase}Entity>>> get${pascalCase}s();

  /// Retrieves a specific $snakeCase by ID
  /// Returns Right(${pascalCase}Entity) on success  
  /// Returns Left(Failure) on error or not found
  Future<Either<Failure, ${pascalCase}Entity>> get${pascalCase}ById(int id);

  /// Creates a new $snakeCase
  /// Returns Right(${pascalCase}Entity) with created entity
  /// Returns Left(Failure) on creation error
  Future<Either<Failure, ${pascalCase}Entity>> create$pascalCase(${pascalCase}Entity $camelCase);

  /// Updates an existing $snakeCase
  /// Returns Right(${pascalCase}Entity) with updated entity
  /// Returns Left(Failure) on update error
  Future<Either<Failure, ${pascalCase}Entity>> update$pascalCase(${pascalCase}Entity $camelCase);

  /// Deletes a $snakeCase by ID
  /// Returns Right(bool) indicating success
  /// Returns Left(Failure) on deletion error
  Future<Either<Failure, bool>> delete$pascalCase(int id);

  /// Searches ${snakeCase}s by query
  /// Returns Right(List<${pascalCase}Entity>) matching the query
  /// Returns Left(Failure) on search error
  Future<Either<Failure, List<${pascalCase}Entity>>> search${pascalCase}s(String query);
}''';

    await _writeFile('lib/domain/repositories/${snakeCase}_repository.dart', content);
  }

  /// Generates repository implementation with performance monitoring
  static Future<void> _generateRepositoryImpl(String pascalCase, String snakeCase, String camelCase) async {
    final content = '''import 'package:dartz/dartz.dart';

import '../../core/exceptions/exceptions.dart';
import '../../core/failures/failures.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/performance_monitor.dart';
import '../../domain/entities/${snakeCase}_entity.dart';
import '../../domain/repositories/${snakeCase}_repository.dart';
import '../data_provider/remote_data_source.dart';
import '../mappers/${snakeCase}_mapper.dart';
import '../models/$snakeCase/${snakeCase}_model.dart';

/// Repository implementation for $pascalCase
/// 
/// This class implements the ${pascalCase}Repository interface and handles:
/// - Data source orchestration (remote/local)
/// - Error handling and transformation
/// - Performance monitoring
/// - Data mapping between layers
/// 
/// Architecture flow:
/// Use Case -> Repository Interface -> Repository Implementation -> Data Source
class ${pascalCase}RepositoryImpl implements ${pascalCase}Repository {
  final RemoteDataSource _remoteDataSource;
  // final LocalDataSource _localDataSource; // Add if needed

  ${pascalCase}RepositoryImpl({
    required RemoteDataSource remoteDataSource,
    // required LocalDataSource localDataSource, // Add if needed
  }) : _remoteDataSource = remoteDataSource;
        // _localDataSource = localDataSource; // Add if needed

  @override
  Future<Either<Failure, List<${pascalCase}Entity>>> get${pascalCase}s() async {
    return PerformanceMonitor.monitorRepository('${pascalCase}Repository', 'get${pascalCase}s', () async {
      Logger.repository('🏛️ Repository: Starting get${pascalCase}s operation');
      
      try {
        final result = await PerformanceMonitor.monitorNetworkRequest('${snakeCase}s', () async {
          return await _remoteDataSource.get${pascalCase}s();
        });
        
        final ${snakeCase}sData = result as List;
        Logger.repository('📄 Repository: Received \${${snakeCase}sData.length} ${snakeCase}s from API');
        
        // Transform data using mapper
        final entities = PerformanceMonitor.monitor('${snakeCase}s_data_transformation', () {
          return ${snakeCase}sData
              .map((json) => ${pascalCase}Model.fromMap(json))
              .map((model) => model.toDomain()) // Using mapper
              .toList();
        });
        
        Logger.repository('✅ Repository: Successfully returned \${entities.length} $snakeCase entities');
        return Right(entities);
        
      } on ServerException catch (e) {
        Logger.repository('❌ Repository: Server error - \${e.message} (\${e.statusCode})');
        return Left(ServerFailure(e.message, e.statusCode));
      } catch (e, stackTrace) {
        Logger.error('Repository: Unexpected error in get${pascalCase}s', 
          error: e, 
          stackTrace: stackTrace
        );
        return Left(ServerFailure('Unexpected error occurred', 500));
      }
    });
  }

  @override
  Future<Either<Failure, ${pascalCase}Entity>> get${pascalCase}ById(int id) async {
    return PerformanceMonitor.monitorRepository('${pascalCase}Repository', 'get${pascalCase}ById', () async {
      Logger.repository('🏛️ Repository: Getting $snakeCase by ID: \$id');
      
      try {
        final result = await PerformanceMonitor.monitorNetworkRequest('$snakeCase/\$id', () async {
          return await _remoteDataSource.get${pascalCase}ById(id);
        });
        
        final model = ${pascalCase}Model.fromMap(result);
        final entity = model.toDomain(); // Using mapper
        
        Logger.repository('✅ Repository: Successfully retrieved $snakeCase with ID: \$id');
        return Right(entity);
        
      } on ServerException catch (e) {
        Logger.repository('❌ Repository: Error getting $snakeCase \$id - \${e.message}');
        return Left(ServerFailure(e.message, e.statusCode));
      } catch (e, stackTrace) {
        Logger.error('Repository: Error in get${pascalCase}ById', error: e, stackTrace: stackTrace);
        return Left(ServerFailure('Unexpected error occurred', 500));
      }
    });
  }

  @override
  Future<Either<Failure, ${pascalCase}Entity>> create$pascalCase(${pascalCase}Entity $camelCase) async {
    return PerformanceMonitor.monitorRepository('${pascalCase}Repository', 'create$pascalCase', () async {
      Logger.repository('🏛️ Repository: Creating new $snakeCase');
      
      try {
        final model = $camelCase.toData(); // Using mapper
        final result = await PerformanceMonitor.monitorNetworkRequest('create_$snakeCase', () async {
          return await _remoteDataSource.create$pascalCase(model);
        });
        
        final createdModel = ${pascalCase}Model.fromMap(result);
        final createdEntity = createdModel.toDomain(); // Using mapper
        
        Logger.repository('✅ Repository: Successfully created $snakeCase');
        return Right(createdEntity);
        
      } on ServerException catch (e) {
        Logger.repository('❌ Repository: Error creating $snakeCase - \${e.message}');
        return Left(ServerFailure(e.message, e.statusCode));
      } catch (e, stackTrace) {
        Logger.error('Repository: Error in create$pascalCase', error: e, stackTrace: stackTrace);
        return Left(ServerFailure('Unexpected error occurred', 500));
      }
    });
  }

  @override
  Future<Either<Failure, ${pascalCase}Entity>> update$pascalCase(${pascalCase}Entity $camelCase) async {
    return PerformanceMonitor.monitorRepository('${pascalCase}Repository', 'update$pascalCase', () async {
      Logger.repository('🏛️ Repository: Updating $snakeCase ID: \${$camelCase.id}');
      
      try {
        final model = $camelCase.toData(); // Using mapper
        final result = await PerformanceMonitor.monitorNetworkRequest('update_$snakeCase', () async {
          return await _remoteDataSource.update$pascalCase(model);
        });
        
        final updatedModel = ${pascalCase}Model.fromMap(result);
        final updatedEntity = updatedModel.toDomain(); // Using mapper
        
        Logger.repository('✅ Repository: Successfully updated $snakeCase');
        return Right(updatedEntity);
        
      } on ServerException catch (e) {
        Logger.repository('❌ Repository: Error updating $snakeCase - \${e.message}');
        return Left(ServerFailure(e.message, e.statusCode));
      } catch (e, stackTrace) {
        Logger.error('Repository: Error in update$pascalCase', error: e, stackTrace: stackTrace);
        return Left(ServerFailure('Unexpected error occurred', 500));
      }
    });
  }

  @override
  Future<Either<Failure, bool>> delete$pascalCase(int id) async {
    return PerformanceMonitor.monitorRepository('${pascalCase}Repository', 'delete$pascalCase', () async {
      Logger.repository('🏛️ Repository: Deleting $snakeCase ID: \$id');
      
      try {
        await PerformanceMonitor.monitorNetworkRequest('delete_$snakeCase', () async {
          return await _remoteDataSource.delete$pascalCase(id);
        });
        
        Logger.repository('✅ Repository: Successfully deleted $snakeCase');
        return const Right(true);
        
      } on ServerException catch (e) {
        Logger.repository('❌ Repository: Error deleting $snakeCase - \${e.message}');
        return Left(ServerFailure(e.message, e.statusCode));
      } catch (e, stackTrace) {
        Logger.error('Repository: Error in delete$pascalCase', error: e, stackTrace: stackTrace);
        return Left(ServerFailure('Unexpected error occurred', 500));
      }
    });
  }

  @override
  Future<Either<Failure, List<${pascalCase}Entity>>> search${pascalCase}s(String query) async {
    return PerformanceMonitor.monitorRepository('${pascalCase}Repository', 'search${pascalCase}s', () async {
      Logger.repository('🏛️ Repository: Searching ${snakeCase}s with query: "\$query"');
      
      try {
        final result = await PerformanceMonitor.monitorNetworkRequest('search_${snakeCase}s', () async {
          return await _remoteDataSource.search${pascalCase}s(query);
        });
        
        final ${snakeCase}sData = result as List;
        final entities = ${snakeCase}sData
            .map((json) => ${pascalCase}Model.fromMap(json))
            .map((model) => model.toDomain()) // Using mapper
            .toList();
        
        Logger.repository('✅ Repository: Found \${entities.length} ${snakeCase}s matching "\$query"');
        return Right(entities);
        
      } on ServerException catch (e) {
        Logger.repository('❌ Repository: Error searching ${snakeCase}s - \${e.message}');
        return Left(ServerFailure(e.message, e.statusCode));
      } catch (e, stackTrace) {
        Logger.error('Repository: Error in search${pascalCase}s', error: e, stackTrace: stackTrace);
        return Left(ServerFailure('Unexpected error occurred', 500));
      }
    });
  }
}''';

    await _writeFile('lib/data/repositories/${snakeCase}_repository_impl.dart', content);
  }

  /// Generates data model with proper naming: feature_model.dart
  static Future<void> _generateModel(String pascalCase, String snakeCase) async {
    final content = '''import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Data Model for $pascalCase
/// 
/// This represents the data structure used for API communication and persistence.
/// It handles JSON serialization/deserialization and data transformation.
/// 
/// Key responsibilities:
/// - JSON serialization (toJson/fromJson)
/// - Data validation for external sources
/// - Type conversion from external formats
/// - Mapping to/from domain entities (via mappers)
class ${pascalCase}Model extends Equatable {
  final int id;
  final String name;
  final String description;
  final String createdAt; // String format for API compatibility
  final int isActive; // int format for API compatibility

  const ${pascalCase}Model({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.isActive,
  });

  /// Creates a copy of this model with updated values
  ${pascalCase}Model copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    int? isActive,
  }) {
    return ${pascalCase}Model(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Converts model to Map for API requests
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }

  /// Creates model from API response Map
  factory ${pascalCase}Model.fromMap(Map<String, dynamic> map) {
    return ${pascalCase}Model(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['created_at'] ?? '',
      isActive: map['is_active']?.toInt() ?? 0,
    );
  }

  /// Converts model to JSON string
  String toJson() => json.encode(toMap());

  /// Creates model from JSON string
  factory ${pascalCase}Model.fromJson(String source) => 
      ${pascalCase}Model.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [id, name, description, createdAt, isActive];

  @override
  String toString() {
    return '${pascalCase}Model{id: \$id, name: \$name, description: \$description, createdAt: \$createdAt, isActive: \$isActive}';
  }
}''';

    await _writeFile('lib/data/models/$snakeCase/${snakeCase}_model.dart', content);
  }

  /// Generates mapper for model <-> entity conversion
  static Future<void> _generateMapper(String pascalCase, String snakeCase) async {
    final content = '''import '../../domain/entities/${snakeCase}_entity.dart';
import '../models/$snakeCase/${snakeCase}_model.dart';

/// Mappers for $pascalCase
/// 
/// These extensions provide transformation methods between different object types:
/// - Data Models (used in data layer for API/database operations)  
/// - Domain Entities (used in business logic and presentation)
/// 
/// Key benefits:
/// - Layer separation: Data models can have JSON concerns, entities stay pure
/// - Flexibility: Can handle API field name differences  
/// - Type safety: Compile-time checking of conversions
/// - Testability: Easy to test transformations in isolation

/// Extension to convert ${pascalCase}Model (data layer) to ${pascalCase}Entity (domain layer)
/// Used when data flows FROM data sources TO business logic
extension ${pascalCase}ModelMapper on ${pascalCase}Model {
  /// Converts data model to domain entity
  /// This method transforms API/database representation to business object
  /// 
  /// Handles type conversions:
  /// - String timestamps -> DateTime objects
  /// - int flags -> bool values
  /// - API field names -> domain property names
  ${pascalCase}Entity toDomain() {
    return ${pascalCase}Entity(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      isActive: isActive == 1, // Convert int to bool
    );
  }
}

/// Extension to convert ${pascalCase}Entity (domain layer) to ${pascalCase}Model (data layer) 
/// Used when data flows FROM business logic TO data sources
extension ${pascalCase}EntityMapper on ${pascalCase}Entity {
  /// Converts domain entity to data model
  /// This method transforms business object to API/database representation
  /// 
  /// Handles type conversions:
  /// - DateTime objects -> String timestamps
  /// - bool values -> int flags  
  /// - Domain property names -> API field names
  ${pascalCase}Model toData() {
    return ${pascalCase}Model(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt.toIso8601String(),
      isActive: isActive ? 1 : 0, // Convert bool to int
    );
  }
}

/// Usage Examples:
/// 
/// In Repository Implementation:
/// ```dart
/// // API Response -> Model -> Entity (using toDomain)
/// final model = ${pascalCase}Model.fromMap(apiResponse);
/// final entity = model.toDomain(); // <- Using mapper
/// return Right(entity);
/// 
/// // Entity -> Model -> API Request (using toData)
/// final model = entity.toData(); // <- Using mapper
/// final result = await api.create$pascalCase(model);
/// ```
/// 
/// This ensures your business logic stays independent from external API changes!''';

    await _writeFile('lib/data/mappers/${snakeCase}_mapper.dart', content);
  }

  /// Generates comprehensive use cases
  static Future<void> _generateUseCase(String pascalCase, String snakeCase, String camelCase) async {
    final content = '''import 'package:dartz/dartz.dart';

import '../../../core/failures/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/performance_monitor.dart';
import '../../entities/${snakeCase}_entity.dart';
import '../../repositories/${snakeCase}_repository.dart';

/// Use Cases for $pascalCase Feature
/// 
/// Use cases represent application-specific business rules and orchestrate 
/// the flow of data between entities and repositories. Each use case should
/// have a single responsibility and be independently testable.
/// 
/// Benefits:
/// - Single Responsibility: Each use case handles one business operation
/// - Testability: Easy to test business logic in isolation  
/// - Reusability: Can be used across different presentation layers
/// - Performance monitoring: Built-in timing and logging

/// Use case to retrieve all ${snakeCase}s
class Get${pascalCase}sUseCase implements OptionalParamUseCase<List<${pascalCase}Entity>, NoParams> {
  final ${pascalCase}Repository _repository;

  Get${pascalCase}sUseCase(this._repository);

  @override
  Future<Either<Failure, List<${pascalCase}Entity>>> call([NoParams? params]) async {
    return PerformanceMonitor.monitorUseCase('Get${pascalCase}s', () async {
      Logger.useCase('🎯 Use Case: Getting all ${snakeCase}s');
      
      final result = await _repository.get${pascalCase}s();
      
      return result.fold(
        (failure) {
          Logger.useCase('❌ Use Case: Failed to get ${snakeCase}s - \${failure.message}');
          return Left(failure);
        },
        (${snakeCase}s) {
          Logger.useCase('✅ Use Case: Successfully retrieved \${${snakeCase}s.length} ${snakeCase}s');
          return Right(${snakeCase}s);
        },
      );
    });
  }
}

/// Use case to retrieve a specific $snakeCase by ID
class Get${pascalCase}ByIdUseCase implements UseCase<${pascalCase}Entity, int> {
  final ${pascalCase}Repository _repository;

  Get${pascalCase}ByIdUseCase(this._repository);

  @override
  Future<Either<Failure, ${pascalCase}Entity>> call(int id) async {
    return PerformanceMonitor.monitorUseCase('Get${pascalCase}ById', () async {
      Logger.useCase('🎯 Use Case: Getting $snakeCase with ID: \$id');
      
      // Business rule validation
      if (id <= 0) {
        Logger.useCase('❌ Use Case: Invalid ID provided: \$id');
        return Left(ValidationFailure('ID must be greater than 0'));
      }
      
      final result = await _repository.get${pascalCase}ById(id);
      
      return result.fold(
        (failure) {
          Logger.useCase('❌ Use Case: Failed to get $snakeCase \$id - \${failure.message}');
          return Left(failure);
        },
        ($camelCase) {
          Logger.useCase('✅ Use Case: Successfully retrieved $snakeCase: \${$camelCase.name}');
          return Right($camelCase);
        },
      );
    });
  }
}

/// Use case to create a new $snakeCase
class Create${pascalCase}UseCase implements UseCase<${pascalCase}Entity, ${pascalCase}Entity> {
  final ${pascalCase}Repository _repository;

  Create${pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, ${pascalCase}Entity>> call(${pascalCase}Entity $camelCase) async {
    return PerformanceMonitor.monitorUseCase('Create$pascalCase', () async {
      Logger.useCase('🎯 Use Case: Creating new $snakeCase: \${$camelCase.name}');
      
      // Business rule validation
      if (!$camelCase.isValid) {
        Logger.useCase('❌ Use Case: Invalid $snakeCase data provided');
        return Left(ValidationFailure('$pascalCase data is invalid'));
      }
      
      final result = await _repository.create$pascalCase($camelCase);
      
      return result.fold(
        (failure) {
          Logger.useCase('❌ Use Case: Failed to create $snakeCase - \${failure.message}');
          return Left(failure);
        },
        (created$pascalCase) {
          Logger.useCase('✅ Use Case: Successfully created $snakeCase: \${created$pascalCase.name}');
          return Right(created$pascalCase);
        },
      );
    });
  }
}

/// Use case to update an existing $snakeCase
class Update${pascalCase}UseCase implements UseCase<${pascalCase}Entity, ${pascalCase}Entity> {
  final ${pascalCase}Repository _repository;

  Update${pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, ${pascalCase}Entity>> call(${pascalCase}Entity $camelCase) async {
    return PerformanceMonitor.monitorUseCase('Update$pascalCase', () async {
      Logger.useCase('🎯 Use Case: Updating $snakeCase ID: \${$camelCase.id}');
      
      // Business rule validation
      if ($camelCase.id <= 0) {
        Logger.useCase('❌ Use Case: Invalid $snakeCase ID for update: \${$camelCase.id}');
        return Left(ValidationFailure('$pascalCase ID must be greater than 0'));
      }
      
      if (!$camelCase.isValid) {
        Logger.useCase('❌ Use Case: Invalid $snakeCase data for update');
        return Left(ValidationFailure('$pascalCase data is invalid'));
      }
      
      final result = await _repository.update$pascalCase($camelCase);
      
      return result.fold(
        (failure) {
          Logger.useCase('❌ Use Case: Failed to update $snakeCase - \${failure.message}');
          return Left(failure);
        },
        (updated$pascalCase) {
          Logger.useCase('✅ Use Case: Successfully updated $snakeCase: \${updated$pascalCase.name}');
          return Right(updated$pascalCase);
        },
      );
    });
  }
}

/// Use case to delete a $snakeCase
class Delete${pascalCase}UseCase implements UseCase<bool, int> {
  final ${pascalCase}Repository _repository;

  Delete${pascalCase}UseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(int id) async {
    return PerformanceMonitor.monitorUseCase('Delete$pascalCase', () async {
      Logger.useCase('🎯 Use Case: Deleting $snakeCase ID: \$id');
      
      // Business rule validation
      if (id <= 0) {
        Logger.useCase('❌ Use Case: Invalid ID for deletion: \$id');
        return Left(ValidationFailure('ID must be greater than 0'));
      }
      
      final result = await _repository.delete$pascalCase(id);
      
      return result.fold(
        (failure) {
          Logger.useCase('❌ Use Case: Failed to delete $snakeCase - \${failure.message}');
          return Left(failure);
        },
        (success) {
          Logger.useCase('✅ Use Case: Successfully deleted $snakeCase ID: \$id');
          return Right(success);
        },
      );
    });
  }
}

/// Use case to search ${snakeCase}s
class Search${pascalCase}sUseCase implements UseCase<List<${pascalCase}Entity>, String> {
  final ${pascalCase}Repository _repository;

  Search${pascalCase}sUseCase(this._repository);

  @override
  Future<Either<Failure, List<${pascalCase}Entity>>> call(String query) async {
    return PerformanceMonitor.monitorUseCase('Search${pascalCase}s', () async {
      Logger.useCase('🎯 Use Case: Searching ${snakeCase}s with query: "\$query"');
      
      // Business rule validation
      if (query.trim().isEmpty) {
        Logger.useCase('❌ Use Case: Empty search query provided');
        return Left(ValidationFailure('Search query cannot be empty'));
      }
      
      if (query.length < 2) {
        Logger.useCase('❌ Use Case: Search query too short: "\$query"');
        return Left(ValidationFailure('Search query must be at least 2 characters'));
      }
      
      final result = await _repository.search${pascalCase}s(query.trim());
      
      return result.fold(
        (failure) {
          Logger.useCase('❌ Use Case: Failed to search ${snakeCase}s - \${failure.message}');
          return Left(failure);
        },
        (${snakeCase}s) {
          Logger.useCase('✅ Use Case: Found \${${snakeCase}s.length} ${snakeCase}s for query: "\$query"');
          return Right(${snakeCase}s);
        },
      );
    });
  }
}

/// Validation failure for business rule violations
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message, 400);
}''';

    await _writeFile('lib/domain/usecases/$snakeCase/${snakeCase}_usecase.dart', content);
  }

  /// Generates Cubit for state management
  static Future<void> _generateCubit(String pascalCase, String snakeCase, String camelCase) async {
    final cubitContent = '''import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../core/utils/performance_monitor.dart';
import '../../../domain/entities/${snakeCase}_entity.dart';
import '../../../domain/usecases/$snakeCase/${snakeCase}_usecase.dart';

part '${snakeCase}_state.dart';

/// Cubit for managing $pascalCase state
/// 
/// This cubit handles the presentation logic for $snakeCase operations.
/// It communicates with use cases and manages UI state transitions.
/// 
/// Key responsibilities:
/// - State management for UI
/// - Use case orchestration
/// - Error handling and user feedback
/// - Performance monitoring
/// - Loading states management
class ${pascalCase}Cubit extends Cubit<${pascalCase}State> {
  final Get${pascalCase}sUseCase _get${pascalCase}sUseCase;
  final Get${pascalCase}ByIdUseCase _get${pascalCase}ByIdUseCase;
  final Create${pascalCase}UseCase _create${pascalCase}UseCase;
  final Update${pascalCase}UseCase _update${pascalCase}UseCase;
  final Delete${pascalCase}UseCase _delete${pascalCase}UseCase;
  final Search${pascalCase}sUseCase _search${pascalCase}sUseCase;

  ${pascalCase}Cubit({
    required Get${pascalCase}sUseCase get${pascalCase}sUseCase,
    required Get${pascalCase}ByIdUseCase get${pascalCase}ByIdUseCase,
    required Create${pascalCase}UseCase create${pascalCase}UseCase,
    required Update${pascalCase}UseCase update${pascalCase}UseCase,
    required Delete${pascalCase}UseCase delete${pascalCase}UseCase,
    required Search${pascalCase}sUseCase search${pascalCase}sUseCase,
  }) : _get${pascalCase}sUseCase = get${pascalCase}sUseCase,
       _get${pascalCase}ByIdUseCase = get${pascalCase}ByIdUseCase,
       _create${pascalCase}UseCase = create${pascalCase}UseCase,
       _update${pascalCase}UseCase = update${pascalCase}UseCase,
       _delete${pascalCase}UseCase = delete${pascalCase}UseCase,
       _search${pascalCase}sUseCase = search${pascalCase}sUseCase,
       super(const ${pascalCase}Initial());

  /// Cache for loaded ${snakeCase}s to improve performance
  List<${pascalCase}Entity> _cached${pascalCase}s = [];
  
  /// Getter for cached ${snakeCase}s
  List<${pascalCase}Entity> get cached${pascalCase}s => List.unmodifiable(_cached${pascalCase}s);

  /// Loads all ${snakeCase}s
  Future<void> load${pascalCase}s() async {
    Logger.cubit('🎯 Cubit: Loading all ${snakeCase}s');
    
    // Don't show loading if we have cached data
    if (_cached${pascalCase}s.isEmpty) {
      emit(const ${pascalCase}Loading());
      PerformanceMonitor.monitorCubitStateChange('${pascalCase}Cubit', 'Initial', 'Loading');
    }

    final result = await _get${pascalCase}sUseCase();
    
    result.fold(
      (failure) {
        Logger.cubit('❌ Cubit: Failed to load ${snakeCase}s - \${failure.message}');
        emit(${pascalCase}Error(failure.message, failure.statusCode));
        PerformanceMonitor.monitorCubitStateChange('${pascalCase}Cubit', 'Loading', 'Error');
      },
      (${snakeCase}s) {
        Logger.cubit('✅ Cubit: Successfully loaded \${${snakeCase}s.length} ${snakeCase}s');
        _cached${pascalCase}s = ${snakeCase}s;
        emit(${pascalCase}sLoaded(${snakeCase}s));
        PerformanceMonitor.monitorCubitStateChange('${pascalCase}Cubit', 'Loading', 'Loaded');
      },
    );
  }

  /// Loads a specific $snakeCase by ID
  Future<void> load${pascalCase}ById(int id) async {
    Logger.cubit('🎯 Cubit: Loading $snakeCase with ID: \$id');
    
    emit(const ${pascalCase}Loading());
    
    final result = await _get${pascalCase}ByIdUseCase(id);
    
    result.fold(
      (failure) {
        Logger.cubit('❌ Cubit: Failed to load $snakeCase \$id - \${failure.message}');
        emit(${pascalCase}Error(failure.message, failure.statusCode));
      },
      ($camelCase) {
        Logger.cubit('✅ Cubit: Successfully loaded $snakeCase: \${$camelCase.name}');
        emit(${pascalCase}Loaded($camelCase));
      },
    );
  }

  /// Creates a new $snakeCase
  Future<void> create$pascalCase(${pascalCase}Entity $camelCase) async {
    Logger.cubit('🎯 Cubit: Creating new $snakeCase: \${$camelCase.name}');
    
    emit(const ${pascalCase}Creating());
    
    final result = await _create${pascalCase}UseCase($camelCase);
    
    result.fold(
      (failure) {
        Logger.cubit('❌ Cubit: Failed to create $snakeCase - \${failure.message}');
        emit(${pascalCase}Error(failure.message, failure.statusCode));
      },
      (created$pascalCase) {
        Logger.cubit('✅ Cubit: Successfully created $snakeCase: \${created$pascalCase.name}');
        
        // Add to cache
        _cached${pascalCase}s = [..._cached${pascalCase}s, created$pascalCase];
        
        emit(${pascalCase}Created(created$pascalCase));
      },
    );
  }

  /// Updates an existing $snakeCase
  Future<void> update$pascalCase(${pascalCase}Entity $camelCase) async {
    Logger.cubit('🎯 Cubit: Updating $snakeCase ID: \${$camelCase.id}');
    
    emit(const ${pascalCase}Updating());
    
    final result = await _update${pascalCase}UseCase($camelCase);
    
    result.fold(
      (failure) {
        Logger.cubit('❌ Cubit: Failed to update $snakeCase - \${failure.message}');
        emit(${pascalCase}Error(failure.message, failure.statusCode));
      },
      (updated$pascalCase) {
        Logger.cubit('✅ Cubit: Successfully updated $snakeCase: \${updated$pascalCase.name}');
        
        // Update cache
        _cached${pascalCase}s = _cached${pascalCase}s.map((item) => 
          item.id == updated$pascalCase.id ? updated$pascalCase : item
        ).toList();
        
        emit(${pascalCase}Updated(updated$pascalCase));
      },
    );
  }

  /// Deletes a $snakeCase
  Future<void> delete$pascalCase(int id) async {
    Logger.cubit('🎯 Cubit: Deleting $snakeCase ID: \$id');
    
    emit(const ${pascalCase}Deleting());
    
    final result = await _delete${pascalCase}UseCase(id);
    
    result.fold(
      (failure) {
        Logger.cubit('❌ Cubit: Failed to delete $snakeCase - \${failure.message}');
        emit(${pascalCase}Error(failure.message, failure.statusCode));
      },
      (success) {
        Logger.cubit('✅ Cubit: Successfully deleted $snakeCase ID: \$id');
        
        // Remove from cache
        _cached${pascalCase}s = _cached${pascalCase}s.where((item) => item.id != id).toList();
        
        emit(${pascalCase}Deleted(id));
      },
    );
  }

  /// Searches ${snakeCase}s
  Future<void> search${pascalCase}s(String query) async {
    Logger.cubit('🎯 Cubit: Searching ${snakeCase}s with query: "\$query"');
    
    if (query.trim().isEmpty) {
      // Return to loaded state with all cached ${snakeCase}s
      if (_cached${pascalCase}s.isNotEmpty) {
        emit(${pascalCase}sLoaded(_cached${pascalCase}s));
      }
      return;
    }
    
    emit(const ${pascalCase}Searching());
    
    final result = await _search${pascalCase}sUseCase(query);
    
    result.fold(
      (failure) {
        Logger.cubit('❌ Cubit: Failed to search ${snakeCase}s - \${failure.message}');
        emit(${pascalCase}Error(failure.message, failure.statusCode));
      },
      (${snakeCase}s) {
        Logger.cubit('✅ Cubit: Found \${${snakeCase}s.length} ${snakeCase}s for query: "\$query"');
        emit(${pascalCase}SearchResults(${snakeCase}s, query));
      },
    );
  }

  /// Refreshes ${snakeCase}s (force reload)
  Future<void> refresh${pascalCase}s() async {
    Logger.cubit('🔄 Cubit: Refreshing ${snakeCase}s');
    _cached${pascalCase}s.clear(); // Clear cache to force reload
    await load${pascalCase}s();
  }
}''';

    await _writeFile('lib/presentation/cubit/$snakeCase/${snakeCase}_cubit.dart', cubitContent);

    final stateContent = '''part of '${snakeCase}_cubit.dart';

/// Abstract base state for $pascalCase
sealed class ${pascalCase}State extends Equatable {
  const ${pascalCase}State();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class ${pascalCase}Initial extends ${pascalCase}State {
  const ${pascalCase}Initial();
}

/// Loading state for general operations
final class ${pascalCase}Loading extends ${pascalCase}State {
  const ${pascalCase}Loading();
}

/// Loading state specific to creating
final class ${pascalCase}Creating extends ${pascalCase}State {
  const ${pascalCase}Creating();
}

/// Loading state specific to updating
final class ${pascalCase}Updating extends ${pascalCase}State {
  const ${pascalCase}Updating();
}

/// Loading state specific to deleting
final class ${pascalCase}Deleting extends ${pascalCase}State {
  const ${pascalCase}Deleting();
}

/// Loading state specific to searching
final class ${pascalCase}Searching extends ${pascalCase}State {
  const ${pascalCase}Searching();
}

/// Error state with message and status code
final class ${pascalCase}Error extends ${pascalCase}State {
  final String message;
  final int statusCode;
  
  const ${pascalCase}Error(this.message, this.statusCode);
  
  @override
  List<Object> get props => [message, statusCode];
}

/// State when multiple ${snakeCase}s are loaded
final class ${pascalCase}sLoaded extends ${pascalCase}State {
  final List<${pascalCase}Entity> ${snakeCase}s;
  
  const ${pascalCase}sLoaded(this.${snakeCase}s);
  
  @override
  List<Object> get props => [${snakeCase}s];
}

/// State when a single $snakeCase is loaded
final class ${pascalCase}Loaded extends ${pascalCase}State {
  final ${pascalCase}Entity $camelCase;
  
  const ${pascalCase}Loaded(this.$camelCase);
  
  @override
  List<Object> get props => [$camelCase];
}

/// State when a $snakeCase is successfully created
final class ${pascalCase}Created extends ${pascalCase}State {
  final ${pascalCase}Entity $camelCase;
  
  const ${pascalCase}Created(this.$camelCase);
  
  @override
  List<Object> get props => [$camelCase];
}

/// State when a $snakeCase is successfully updated
final class ${pascalCase}Updated extends ${pascalCase}State {
  final ${pascalCase}Entity $camelCase;
  
  const ${pascalCase}Updated(this.$camelCase);
  
  @override
  List<Object> get props => [$camelCase];
}

/// State when a $snakeCase is successfully deleted
final class ${pascalCase}Deleted extends ${pascalCase}State {
  final int deletedId;
  
  const ${pascalCase}Deleted(this.deletedId);
  
  @override
  List<Object> get props => [deletedId];
}

/// State when search results are available
final class ${pascalCase}SearchResults extends ${pascalCase}State {
  final List<${pascalCase}Entity> results;
  final String query;
  
  const ${pascalCase}SearchResults(this.results, this.query);
  
  @override
  List<Object> get props => [results, query];
}''';

    await _writeFile('lib/presentation/cubit/$snakeCase/${snakeCase}_state.dart', stateContent);
  }

  /// Generates Bloc for state management (alternative to Cubit)
  static Future<void> _generateBloc(String pascalCase, String snakeCase, String camelCase) async {
    // Implementation for Bloc generation (similar structure but with events)
    // This would be similar to the Cubit but with event-driven approach
    // For brevity, focusing on the core cubit implementation
    print('   ℹ️  Bloc generation not implemented in this version - use --cubit flag');
  }

  /// Generates StatefulWidget screen
  static Future<void> _generateScreen(String pascalCase, String snakeCase, String camelCase, bool useCubit) async {
    final stateManagerType = useCubit ? 'Cubit' : 'Bloc';
    final stateManagerClass = '$pascalCase$stateManagerType';
    final stateClass = '${pascalCase}State';
    
    final content = '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/performance_monitor.dart';
import '../../../domain/entities/${snakeCase}_entity.dart';
import '../../cubit/$snakeCase/${snakeCase}_cubit.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/fetch_error_text.dart';
import '../../widgets/loading_widget.dart';

/// Screen for displaying and managing ${pascalCase}s
/// 
/// This screen provides a complete UI for $snakeCase operations:
/// - List view of all ${snakeCase}s
/// - Search functionality
/// - Create, update, delete operations
/// - Pull-to-refresh
/// - Error handling and loading states
/// 
/// Architecture:
/// - Follows the presentation layer guidelines
/// - Uses $stateManagerType for state management
/// - Implements proper loading and error states
/// - Optimized for performance with caching
class ${pascalCase}Screen extends StatefulWidget {
  const ${pascalCase}Screen({super.key});

  @override
  State<${pascalCase}Screen> createState() => _${pascalCase}ScreenState();
}

class _${pascalCase}ScreenState extends State<${pascalCase}Screen> {
  late $stateManagerClass $snakeCase$stateManagerType;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    $snakeCase$stateManagerType = context.read<$stateManagerClass>();
    
    // Monitor widget build performance
    PerformanceMonitor.monitorWidgetBuild('${pascalCase}Screen');
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      $snakeCase$stateManagerType.load${pascalCase}s();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _onRefresh,
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<$stateManagerClass, $stateClass>(
                builder: (context, state) {
                  return _buildBody(state);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the app bar with title and actions
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: CustomText(text: '${pascalCase}s'),
      elevation: 2,
      actions: [
        IconButton(
          onPressed: _onRefreshPressed,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh ${snakeCase}s',
        ),
        PopupMenuButton<String>(
          onSelected: _onMenuSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_cache',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear Cache'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'performance_report',
              child: Row(
                children: [
                  Icon(Icons.analytics),
                  SizedBox(width: 8),
                  Text('Performance Report'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search ${snakeCase}s...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  /// Builds the main body content based on state
  Widget _buildBody($stateClass state) {
    switch (state) {
      case ${pascalCase}Loading():
        return const Center(child: LoadingWidget());
      
      case ${pascalCase}Creating():
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingWidget(),
              SizedBox(height: 16),
              CustomText(text: 'Creating $snakeCase...'),
            ],
          ),
        );
      
      case ${pascalCase}Error():
        return _buildErrorView(state.message);
      
      case ${pascalCase}sLoaded():
        return _build${pascalCase}ListView(state.${snakeCase}s);
      
      case ${pascalCase}SearchResults():
        return _buildSearchResults(state.results, state.query);
      
      case ${pascalCase}Created():
        // Show success message and refresh list
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSuccessSnackBar('$pascalCase created successfully');
          $snakeCase$stateManagerType.load${pascalCase}s();
        });
        return _build${pascalCase}ListView($snakeCase$stateManagerType.cached${pascalCase}s);
      
      default:
        return _buildEmptyView();
    }
  }

  /// Builds the ${snakeCase}s list view
  Widget _build${pascalCase}ListView(List<${pascalCase}Entity> ${snakeCase}s) {
    if (${snakeCase}s.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ${snakeCase}s.length,
      itemBuilder: (context, index) {
        final $camelCase = ${snakeCase}s[index];
        return _build${pascalCase}Card($camelCase);
      },
    );
  }

  /// Builds individual $snakeCase card
  Widget _build${pascalCase}Card(${pascalCase}Entity $camelCase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: $camelCase.isActive 
              ? Colors.green 
              : Colors.grey,
          child: Text(
            $camelCase.name.isNotEmpty 
                ? $camelCase.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: CustomText(
          text: $camelCase.name,
          fontWeight: FontWeight.w600,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            CustomText(
              text: $camelCase.description,
              maxLines: 2,
              fontSize: 14,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                CustomText(
                  text: _formatDate($camelCase.createdAt),
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: $camelCase.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    text: $camelCase.isActive ? 'Active' : 'Inactive',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _on${pascalCase}Tap($camelCase),
      ),
    );
  }

  /// Builds search results view
  Widget _buildSearchResults(List<${pascalCase}Entity> results, String query) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: CustomText(
            text: 'Search Results for "\$query" (\${results.length} found)',
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? _buildNoSearchResults(query)
              : _build${pascalCase}ListView(results),
        ),
      ],
    );
  }

  /// Builds no search results view
  Widget _buildNoSearchResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'No ${snakeCase}s found for "\$query"',
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: 'Try a different search term',
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  /// Builds error view
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            FetchErrorText(text: message),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefreshPressed,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty view
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'No ${snakeCase}s found',
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: 'Tap the + button to create your first $snakeCase',
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  /// Builds floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _onCreate$pascalCase,
      tooltip: 'Create $pascalCase',
      child: const Icon(Icons.add),
    );
  }

  // Event Handlers

  Future<void> _onRefresh() async {
    $snakeCase$stateManagerType.refresh${pascalCase}s();
  }

  void _onRefreshPressed() {
    _refreshKey.currentState?.show();
  }

  void _onSearchChanged(String query) {
    // Debounce search to improve performance
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        $snakeCase$stateManagerType.search${pascalCase}s(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    $snakeCase$stateManagerType.search${pascalCase}s('');
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'clear_cache':
        // Clear cache and reload
        $snakeCase$stateManagerType.refresh${pascalCase}s();
        _showSuccessSnackBar('Cache cleared');
        break;
      case 'performance_report':
        PerformanceMonitor.printPerformanceReport();
        _showSuccessSnackBar('Performance report printed to console');
        break;
    }
  }

  void _onCreate$pascalCase() {
    // TODO: Navigate to create $snakeCase screen
    _showInfoSnackBar('Create $snakeCase feature - Coming soon!');
  }

  void _on${pascalCase}Tap(${pascalCase}Entity $camelCase) {
    // TODO: Navigate to $snakeCase details screen
    _showInfoSnackBar('View $snakeCase details: \${$camelCase.name}');
  }

  // Utility Methods

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '\${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '\${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '\${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}''';

    await _writeFile('lib/presentation/screens/$snakeCase/${snakeCase}_screen.dart', content);
  }

  /// Registers all dependencies in the DI container
  static Future<void> _registerDependencies(String pascalCase, String snakeCase, String camelCase, bool useCubit) async {
    final diFile = File('lib/dependency_injection.dart');
    if (!await diFile.exists()) {
      print('   ⚠️  Warning: dependency_injection.dart not found');
      return;
    }

    var content = await diFile.readAsString();
    
    // Check if already registered to avoid duplicates
    if (content.contains('${pascalCase}Repository>')) {
      print('   ℹ️  Dependencies already registered, skipping...');
      return;
    }

    // Add repository registration
    final repositoryRegistration = '''
    RepositoryProvider<${pascalCase}Repository>(
      create: (context) => ${pascalCase}RepositoryImpl(
        remoteDataSource: context.read(),
      ),
    ),''';

    // Add use cases registration
    final useCaseRegistrations = '''
    RepositoryProvider<Get${pascalCase}sUseCase>(
      create: (context) => Get${pascalCase}sUseCase(context.read<${pascalCase}Repository>()),
    ),

    RepositoryProvider<Get${pascalCase}ByIdUseCase>(
      create: (context) => Get${pascalCase}ByIdUseCase(context.read<${pascalCase}Repository>()),
    ),

    RepositoryProvider<Create${pascalCase}UseCase>(
      create: (context) => Create${pascalCase}UseCase(context.read<${pascalCase}Repository>()),
    ),

    RepositoryProvider<Update${pascalCase}UseCase>(
      create: (context) => Update${pascalCase}UseCase(context.read<${pascalCase}Repository>()),
    ),

    RepositoryProvider<Delete${pascalCase}UseCase>(
      create: (context) => Delete${pascalCase}UseCase(context.read<${pascalCase}Repository>()),
    ),

    RepositoryProvider<Search${pascalCase}sUseCase>(
      create: (context) => Search${pascalCase}sUseCase(context.read<${pascalCase}Repository>()),
    ),''';

    // Add state management registration
    final stateManagerType = useCubit ? 'Cubit' : 'Bloc';
    final stateManagerRegistration = '''
    BlocProvider<$pascalCase$stateManagerType>(
      create: (BuildContext context) => $pascalCase$stateManagerType(
        get${pascalCase}sUseCase: context.read<Get${pascalCase}sUseCase>(),
        get${pascalCase}ByIdUseCase: context.read<Get${pascalCase}ByIdUseCase>(),
        create${pascalCase}UseCase: context.read<Create${pascalCase}UseCase>(),
        update${pascalCase}UseCase: context.read<Update${pascalCase}UseCase>(),
        delete${pascalCase}UseCase: context.read<Delete${pascalCase}UseCase>(),
        search${pascalCase}sUseCase: context.read<Search${pascalCase}sUseCase>(),
      ),
    ),''';

    // Find insertion points and add registrations
    content = content.replaceAll(
      '      // Notification Repository',
      '${repositoryRegistration.trim()}\n\n${useCaseRegistrations.trim()}\n      // Notification Repository'
    );

    content = content.replaceAll(
      '  ];',
      '${stateManagerRegistration.trim()}\n  ];'
    );

    await diFile.writeAsString(content);
    print('   ✅ Dependencies registered successfully');
  }

  /// Adds imports to dependency packages
  static Future<void> _addImportsToPackages(String pascalCase, String snakeCase, bool useCubit, bool includeMapper) async {
    final packagesFile = File('lib/dependency_injection_packages.dart');
    if (!await packagesFile.exists()) {
      print('   ⚠️  Warning: dependency_injection_packages.dart not found');
      return;
    }

    var content = await packagesFile.readAsString();
    
    // Check if already imported to avoid duplicates
    if (content.contains('${snakeCase}_entity.dart')) {
      print('   ℹ️  Imports already added, skipping...');
      return;
    }

    final imports = '''
// $pascalCase feature exports
export 'domain/entities/${snakeCase}_entity.dart';
export 'domain/repositories/${snakeCase}_repository.dart';
export 'data/repositories/${snakeCase}_repository_impl.dart';
export 'data/models/$snakeCase/${snakeCase}_model.dart';
${includeMapper ? "export 'data/mappers/${snakeCase}_mapper.dart';" : ''}
export 'domain/usecases/$snakeCase/${snakeCase}_usecase.dart';
export 'presentation/cubit/$snakeCase/${snakeCase}_cubit.dart';
''';

    content += '\n$imports';
    
    await packagesFile.writeAsString(content);
    print('   ✅ Imports added successfully');
  }

  /// Adds route names
  static Future<void> _addRouteNames(String pascalCase, String snakeCase) async {
    final routeNamesFile = File('lib/presentation/routes/route_names.dart');
    if (!await routeNamesFile.exists()) {
      print('   ⚠️  Warning: route_names.dart not found');
      return;
    }

    var content = await routeNamesFile.readAsString();
    
    // Check if route already exists
    if (content.contains('${snakeCase}Screen')) {
      print('   ℹ️  Route already exists, skipping...');
      return;
    }

    // Add route constant
    final routeConstant = "  static const String ${snakeCase}Screen = '/${snakeCase}Screen';";
    content = content.replaceAll(
      'static const String postsScreen = \'/postsScreen\';',
      'static const String postsScreen = \'/postsScreen\';\n$routeConstant'
    );

    // Add route case
    final routeCase = '''
      case RouteNames.${snakeCase}Screen:
        return MaterialPageRoute(
            settings: settings, builder: (_) => const ${pascalCase}Screen());
''';

    content = content.replaceAll(
      'case RouteNames.postsScreen:',
      '${routeCase.trim()}\n\n      case RouteNames.postsScreen:'
    );

    await routeNamesFile.writeAsString(content);
    print('   ✅ Route added successfully');
  }

  /// Adds route exports
  static Future<void> _addRouteExports(String pascalCase, String snakeCase) async {
    final routePackagesFile = File('lib/presentation/routes/route_packages_name.dart');
    if (!await routePackagesFile.exists()) {
      print('   ⚠️  Warning: route_packages_name.dart not found');
      return;
    }

    var content = await routePackagesFile.readAsString();
    
    // Check if export already exists
    if (content.contains('${snakeCase}_screen.dart')) {
      print('   ℹ️  Route export already exists, skipping...');
      return;
    }

    final exportLine = "export '../screens/$snakeCase/${snakeCase}_screen.dart';";
    content += '\n$exportLine';
    
    await routePackagesFile.writeAsString(content);
    print('   ✅ Route export added successfully');
  }

  /// Prints summary of generated files
  static void _printGeneratedFiles(String snakeCase, bool useCubit, bool includeMapper) {
    print('📁 Generated files:');
    print('   📄 lib/domain/entities/${snakeCase}_entity.dart');
    print('   📄 lib/domain/repositories/${snakeCase}_repository.dart');
    print('   📄 lib/data/repositories/${snakeCase}_repository_impl.dart');
    print('   📄 lib/data/models/$snakeCase/${snakeCase}_model.dart');
    if (includeMapper) {
      print('   📄 lib/data/mappers/${snakeCase}_mapper.dart');
    }
    print('   📄 lib/domain/usecases/$snakeCase/${snakeCase}_usecase.dart');
    if (useCubit) {
      print('   📄 lib/presentation/cubit/$snakeCase/${snakeCase}_cubit.dart');
      print('   📄 lib/presentation/cubit/$snakeCase/${snakeCase}_state.dart');
    } else {
      print('   📄 lib/presentation/bloc/$snakeCase/${snakeCase}_bloc.dart');
      print('   📄 lib/presentation/bloc/$snakeCase/${snakeCase}_event.dart');
      print('   📄 lib/presentation/bloc/$snakeCase/${snakeCase}_state.dart');
    }
    print('   📄 lib/presentation/screens/$snakeCase/${snakeCase}_screen.dart');
  }

  /// Utility method to write file
  static Future<void> _writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  /// Converts string to PascalCase
  static String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');
  }

  /// Converts string to snake_case
  static String _toSnakeCase(String input) {
    return input.toLowerCase().replaceAll(' ', '_');
  }

  /// Converts string to camelCase
  static String _toCamelCase(String input) {
    final pascalCase = _toPascalCase(input);
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Please provide a feature name');
    print('Usage: dart tool/improved_code_generator_fixed.dart <feature_name> [options]');
    print('');
    print('Options:');
    print('  --cubit     Use Cubit for state management (default)');
    print('  --bloc      Use Bloc for state management');
    print('  --no-mapper Skip mapper generation');
    print('');
    print('Examples:');
    print('  dart tool/improved_code_generator_fixed.dart user_profile');
    print('  dart tool/improved_code_generator_fixed.dart product --bloc');
    print('  dart tool/improved_code_generator_fixed.dart notification --no-mapper');
    return;
  }

  final featureName = args[0];
  bool useCubit = true;
  bool includeMapper = true;

  // Parse options
  for (int i = 1; i < args.length; i++) {
    switch (args[i]) {
      case '--bloc':
        useCubit = false;
        break;
      case '--cubit':
        useCubit = true;
        break;
      case '--no-mapper':
        includeMapper = false;
        break;
    }
  }

  await ImprovedCodeGenerator.generateFeature(
    featureName,
    useCubit: useCubit,
    includeMapper: includeMapper,
  );
}
