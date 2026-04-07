import 'dart:io';

/// Unified Clean Architecture Code Generator
///
/// Combined generator with numbered menu system and subfolder support
class UnifiedGenerator {
  /// Main menu system
  static Future<void> showMainMenu() async {
    print('');
    print('🏗️  CLEAN ARCHITECTURE CODE GENERATOR');
    print('════════════════════════════════════════');
    print('');
    print('Available Commands:');
    print('');
    print('1️⃣  Generate Entity from Model');
    print('2️⃣  Generate Mapper from Model + Entity');
    print('3️⃣  Generate UseCase from Repository');
    print('4️⃣  Generate Remote DataSource from Model');
    print('5️⃣  Generate Local DataSource from Model');
    print('6️⃣  Generate Complete Feature Set');
    print('');
    print('0️⃣  Exit');
    print('');

    stdout.write('Select option (0-6): ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await handleGenerateEntity();
        break;
      case '2':
        await handleGenerateMapper();
        break;
      case '3':
        await handleGenerateUseCase();
        break;
      case '4':
        await handleGenerateRemoteDataSource();
        break;
      case '5':
        await handleGenerateLocalDataSource();
        break;
      case '6':
        await handleGenerateCompleteFeature();
        break;
      case '0':
        print('👋 Goodbye!');
        return;
      default:
        print('❌ Invalid option. Please try again.');
        await showMainMenu();
    }

    print('');
    print('✨ Operation completed!');
    print('');
    stdout.write('Continue? (y/n): ');
    final continueChoice = stdin.readLineSync();
    if (continueChoice?.toLowerCase().startsWith('y') ?? false) {
      await showMainMenu();
    }
  }

  /// Handle Generate Entity
  static Future<void> handleGenerateEntity() async {
    print('');
    print('📋 GENERATE ENTITY FROM MODEL');
    print('─────────────────────────────────');

    stdout.write('Enter model path: ');
    final modelPath = stdin.readLineSync();
    if (modelPath == null || modelPath.isEmpty) {
      print('❌ Model path is required');
      return;
    }

    stdout.write('Create entity in subfolder? (y/n): ');
    final useSubfolder =
        stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    String? customPath;
    if (!useSubfolder) {
      stdout.write('Enter custom entity path (or press Enter for default): ');
      final input = stdin.readLineSync();
      customPath = input?.isEmpty == false ? input : null;
    }

    await generateEntityFromModel(
      modelPath,
      useSubfolder: useSubfolder,
      customEntityPath: customPath,
    );
  }

  /// Handle Generate Mapper
  static Future<void> handleGenerateMapper() async {
    print('');
    print('🗺️  GENERATE MAPPER FROM MODEL + ENTITY');
    print('─────────────────────────────────────────');

    stdout.write('Enter model path: ');
    final modelPath = stdin.readLineSync();
    if (modelPath == null || modelPath.isEmpty) {
      print('❌ Model path is required');
      return;
    }

    stdout.write('Enter entity path: ');
    final entityPath = stdin.readLineSync();
    if (entityPath == null || entityPath.isEmpty) {
      print('❌ Entity path is required');
      return;
    }

    stdout.write('Create mapper in subfolder? (y/n): ');
    final useSubfolder =
        stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    String? customPath;
    String? subfolderName;

    if (useSubfolder) {
      stdout.write('Enter subfolder name: ');
      subfolderName = stdin.readLineSync();
      if (subfolderName == null || subfolderName.isEmpty) {
        print('❌ Subfolder name is required when using subfolder');
        return;
      }
    } else {
      stdout.write('Enter custom mapper path (or press Enter for default): ');
      final input = stdin.readLineSync();
      customPath = input?.isEmpty == false ? input : null;
    }

    await generateMapperFromFiles(
      modelPath,
      entityPath,
      customMapperPath: customPath,
      subfolderName: subfolderName,
    );
  }

  /// Handle Generate UseCase
  static Future<void> handleGenerateUseCase() async {
    print('');
    print('🎯 GENERATE USECASE FROM REPOSITORY');
    print('──────────────────────────────────────');

    stdout.write('Enter repository path: ');
    final repositoryPath = stdin.readLineSync();
    if (repositoryPath == null || repositoryPath.isEmpty) {
      print('❌ Repository path is required');
      return;
    }

    stdout.write('Create UseCase in subfolder? (y/n): ');
    final useSubfolder =
        stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    String? customPath;
    String? subfolderName;

    if (useSubfolder) {
      stdout.write('Enter subfolder name: ');
      subfolderName = stdin.readLineSync();
      if (subfolderName == null || subfolderName.isEmpty) {
        print('❌ Subfolder name is required when using subfolder');
        return;
      }
    } else {
      stdout.write('Enter custom UseCase path (or press Enter for default): ');
      final input = stdin.readLineSync();
      customPath = input?.isEmpty == false ? input : null;
    }

    await generateUseCaseFromRepository(
      repositoryPath,
      customUseCasePath: customPath,
      subfolderName: subfolderName,
    );
  }

  /// Handle Generate Remote DataSource
  static Future<void> handleGenerateRemoteDataSource() async {
    print('');
    print('🌐 GENERATE REMOTE DATASOURCE FROM MODEL');
    print('───────────────────────────────────────────');

    stdout.write('Enter model path: ');
    final modelPath = stdin.readLineSync();
    if (modelPath == null || modelPath.isEmpty) {
      print('❌ Model path is required');
      return;
    }

    stdout.write('Create DataSource in subfolder? (y/n): ');
    final useSubfolder =
        stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    String? customPath;
    String? subfolderName;

    if (useSubfolder) {
      stdout.write('Enter subfolder name: ');
      subfolderName = stdin.readLineSync();
      if (subfolderName == null || subfolderName.isEmpty) {
        print('❌ Subfolder name is required when using subfolder');
        return;
      }
    } else {
      stdout.write(
        'Enter custom DataSource path (or press Enter for default): ',
      );
      final input = stdin.readLineSync();
      customPath = input?.isEmpty == false ? input : null;
    }

    await generateDataSourceFromModel(
      modelPath,
      isRemote: true,
      customDataSourcePath: customPath,
      subfolderName: subfolderName,
    );
  }

  /// Handle Generate Local DataSource
  static Future<void> handleGenerateLocalDataSource() async {
    print('');
    print('💾 GENERATE LOCAL DATASOURCE FROM MODEL');
    print('─────────────────────────────────────────');

    stdout.write('Enter model path: ');
    final modelPath = stdin.readLineSync();
    if (modelPath == null || modelPath.isEmpty) {
      print('❌ Model path is required');
      return;
    }

    stdout.write('Create DataSource in subfolder? (y/n): ');
    final useSubfolder =
        stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    String? customPath;
    String? subfolderName;

    if (useSubfolder) {
      stdout.write('Enter subfolder name: ');
      subfolderName = stdin.readLineSync();
      if (subfolderName == null || subfolderName.isEmpty) {
        print('❌ Subfolder name is required when using subfolder');
        return;
      }
    } else {
      stdout.write(
        'Enter custom DataSource path (or press Enter for default): ',
      );
      final input = stdin.readLineSync();
      customPath = input?.isEmpty == false ? input : null;
    }

    await generateDataSourceFromModel(
      modelPath,
      isRemote: false,
      customDataSourcePath: customPath,
      subfolderName: subfolderName,
    );
  }

  /// Handle Generate Complete Feature
  static Future<void> handleGenerateCompleteFeature() async {
    print('');
    print('🏗️  GENERATE COMPLETE FEATURE SET');
    print('──────────────────────────────────────');

    stdout.write('Enter model path: ');
    final modelPath = stdin.readLineSync();
    if (modelPath == null || modelPath.isEmpty) {
      print('❌ Model path is required');
      return;
    }

    print('');
    print('⚠️  This will generate:');
    print('   - Entity');
    print('   - Repository Interface');
    print('   - Repository Implementation');
    print('   - UseCase');
    print('   - Remote DataSource');
    print('   - Local DataSource');
    print('   - Mapper');
    print('');

    stdout.write('Continue? (y/n): ');
    final confirm =
        stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;
    if (!confirm) {
      print('❌ Operation cancelled');
      return;
    }

    await generateCompleteFeature(modelPath);
  }

  /// Core generation methods

  /// Generates an entity from an existing model file
  static Future<void> generateEntityFromModel(
    String modelPath, {
    bool useSubfolder = true,
    String? customEntityPath,
  }) async {
    print('🏗️ Generating entity from model: $modelPath');

    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      print('❌ Model file not found: $modelPath');
      return;
    }

    final modelContent = await modelFile.readAsString();
    final analysis = _analyzeModel(modelContent, modelPath);

    if (analysis == null) {
      print('❌ Could not analyze model file');
      return;
    }

    print('📋 Analysis complete:');
    print('   - Model Class: ${analysis.className}');
    print('   - Feature Name: ${analysis.featureName}');
    print('   - Properties: ${analysis.properties.length}');

    // Determine entity path
    String entityPath;
    if (customEntityPath != null) {
      entityPath = customEntityPath;
    } else if (useSubfolder) {
      entityPath =
          'lib/domain/entities/${analysis.featureName}/${analysis.featureName}_entity.dart';
      await Directory(
        'lib/domain/entities/${analysis.featureName}',
      ).create(recursive: true);
    } else {
      entityPath = 'lib/domain/entities/${analysis.featureName}_entity.dart';
      await Directory('lib/domain/entities').create(recursive: true);
    }

    // Generate entity content
    final entityContent = _generateEntityContent(analysis);

    // Write entity file
    await File(entityPath).writeAsString(entityContent);

    print('✅ Entity generated successfully: $entityPath');
  }

  /// Generates a mapper from existing model and entity files
  static Future<void> generateMapperFromFiles(
    String modelPath,
    String entityPath, {
    String? customMapperPath,
    String? subfolderName,
  }) async {
    print('🗺️ Generating mapper from model and entity');
    print('   Model: $modelPath');
    print('   Entity: $entityPath');

    final modelFile = File(modelPath);
    final entityFile = File(entityPath);

    if (!await modelFile.exists()) {
      print('❌ Model file not found: $modelPath');
      return;
    }

    if (!await entityFile.exists()) {
      print('❌ Entity file not found: $entityPath');
      return;
    }

    final modelContent = await modelFile.readAsString();
    final entityContent = await entityFile.readAsString();

    final modelAnalysis = _analyzeModel(modelContent, modelPath);
    final entityAnalysis = _analyzeEntity(entityContent, entityPath);

    if (modelAnalysis == null || entityAnalysis == null) {
      print('❌ Could not analyze files');
      return;
    }

    // Determine mapper path
    String mapperPath;
    if (customMapperPath != null) {
      mapperPath = customMapperPath;
    } else if (subfolderName != null) {
      mapperPath =
          'lib/data/mappers/$subfolderName/${modelAnalysis.featureName}_mapper.dart';
      await Directory(
        'lib/data/mappers/$subfolderName',
      ).create(recursive: true);
    } else {
      mapperPath = 'lib/data/mappers/${modelAnalysis.featureName}_mapper.dart';
      await Directory('lib/data/mappers').create(recursive: true);
    }

    // Generate mapper content
    final mapperContent = _generateMapperContent(
      modelAnalysis,
      entityAnalysis,
      modelPath,
      entityPath,
    );

    // Write mapper file
    await File(mapperPath).writeAsString(mapperContent);

    print('✅ Mapper generated successfully: $mapperPath');
  }

  /// Generates a use case from an existing repository
  static Future<void> generateUseCaseFromRepository(
    String repositoryPath, {
    String? customUseCasePath,
    String? subfolderName,
  }) async {
    print('🎯 Generating UseCase from repository: $repositoryPath');

    final repoFile = File(repositoryPath);
    if (!await repoFile.exists()) {
      print('❌ Repository file not found: $repositoryPath');
      return;
    }

    final repoContent = await repoFile.readAsString();
    final analysis = _analyzeRepository(repoContent, repositoryPath);

    if (analysis == null) {
      print('❌ Could not analyze repository file');
      return;
    }

    print('📋 Analysis complete:');
    print('   - Repository: ${analysis.className}');
    print('   - Feature: ${analysis.featureName}');
    print('   - Methods: ${analysis.methods.length}');

    // Determine use case path
    String useCasePath;
    if (customUseCasePath != null) {
      useCasePath = customUseCasePath;
    } else if (subfolderName != null) {
      useCasePath =
          'lib/domain/use_cases/$subfolderName/${analysis.featureName}_use_case.dart';
      await Directory(
        'lib/domain/use_cases/$subfolderName',
      ).create(recursive: true);
    } else {
      useCasePath =
          'lib/domain/use_cases/${analysis.featureName}/${analysis.featureName}_use_case.dart';
      await Directory(
        'lib/domain/use_cases/${analysis.featureName}',
      ).create(recursive: true);
    }

    // Generate use case content
    final useCaseContent = _generateUseCaseContent(analysis);

    // Write use case file
    await File(useCasePath).writeAsString(useCaseContent);

    print('✅ UseCase generated successfully: $useCasePath');
  }

  /// Generates a data source from existing model
  static Future<void> generateDataSourceFromModel(
    String modelPath, {
    bool isRemote = true,
    String? customDataSourcePath,
    String? subfolderName,
  }) async {
    final sourceType = isRemote ? 'Remote' : 'Local';
    print('🌐 Generating $sourceType DataSource from model: $modelPath');

    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      print('❌ Model file not found: $modelPath');
      return;
    }

    final modelContent = await modelFile.readAsString();
    final analysis = _analyzeModel(modelContent, modelPath);

    if (analysis == null) {
      print('❌ Could not analyze model file');
      return;
    }

    print('📋 Analysis complete:');
    print('   - Model Class: ${analysis.className}');
    print('   - Feature: ${analysis.featureName}');

    // Determine data source path
    String dataSourcePath;
    if (customDataSourcePath != null) {
      dataSourcePath = customDataSourcePath;
    } else if (subfolderName != null) {
      dataSourcePath =
          'lib/data/data_sources/$subfolderName/${analysis.featureName}_${sourceType.toLowerCase()}_data_source.dart';
      await Directory(
        'lib/data/data_sources/$subfolderName',
      ).create(recursive: true);
    } else {
      dataSourcePath =
          'lib/data/data_sources/${analysis.featureName}_${sourceType.toLowerCase()}_data_source.dart';
      await Directory('lib/data/data_sources').create(recursive: true);
    }

    // Generate data source content
    final dataSourceContent = _generateDataSourceContent(analysis, isRemote);

    // Write data source file
    await File(dataSourcePath).writeAsString(dataSourceContent);

    print('✅ $sourceType DataSource generated successfully: $dataSourcePath');
  }

  /// Generates complete feature set from model
  static Future<void> generateCompleteFeature(String modelPath) async {
    print('🏗️ Generating complete feature set from: $modelPath');

    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      print('❌ Model file not found: $modelPath');
      return;
    }

    final modelContent = await modelFile.readAsString();
    final analysis = _analyzeModel(modelContent, modelPath);

    if (analysis == null) {
      print('❌ Could not analyze model file');
      return;
    }

    final featureName = analysis.featureName;
    print(
      '📋 Generating complete feature set for: ${featureName.toUpperCase()}',
    );

    // Create directory structure
    await _createFeatureDirectories(featureName);

    // Generate all files
    await _generateEntityForFeature(analysis);
    await _generateMapperForFeature(analysis, modelPath);
    await _generateRepositoryInterfaceForFeature(analysis);
    await _generateRepositoryImplForFeature(analysis);
    await _generateDataSourceForFeature(analysis, true); // Remote
    await _generateDataSourceForFeature(analysis, false); // Local
    await _generateUseCaseForFeature(analysis);

    print('✅ Complete feature set generated for: ${featureName.toUpperCase()}');
    print('📁 Generated files:');
    print(
      '   - Entity: lib/domain/entities/$featureName/${featureName}_entity.dart',
    );
    print(
      '   - Repository Interface: lib/domain/repositories/${featureName}_repository.dart',
    );
    print(
      '   - UseCase: lib/domain/use_cases/$featureName/${featureName}_use_case.dart',
    );
    print(
      '   - Repository Impl: lib/data/repositories/${featureName}_repository_impl.dart',
    );
    print('   - Mapper: lib/data/mappers/${featureName}_mapper.dart');
    print(
      '   - Remote DataSource: lib/data/data_sources/${featureName}_remote_data_source.dart',
    );
    print(
      '   - Local DataSource: lib/data/data_sources/${featureName}_local_data_source.dart',
    );
  }

  // Helper methods for complete feature generation
  static Future<void> _createFeatureDirectories(String featureName) async {
    final dirs = [
      'lib/domain/entities/$featureName',
      'lib/domain/repositories',
      'lib/domain/use_cases/$featureName',
      'lib/data/repositories',
      'lib/data/mappers',
      'lib/data/data_sources',
    ];

    for (final dir in dirs) {
      await Directory(dir).create(recursive: true);
    }
  }

  static Future<void> _generateEntityForFeature(ModelAnalysis analysis) async {
    final entityContent = _generateEntityContent(analysis);
    await File(
      'lib/domain/entities/${analysis.featureName}/${analysis.featureName}_entity.dart',
    ).writeAsString(entityContent);
  }

  static Future<void> _generateMapperForFeature(
    ModelAnalysis analysis,
    String modelPath,
  ) async {
    // Create mock entity analysis for mapper generation
    final entityAnalysis = EntityAnalysis(
      className: _toClassCase(analysis.featureName) + 'Entity',
      featureName: analysis.featureName,
      properties: analysis.properties
          .map(
            (p) => PropertyInfo(
              type: _convertModelTypeToEntityType(p.type),
              name: p.name,
              isNullable: p.isNullable,
            ),
          )
          .toList(),
      filePath:
          'lib/domain/entities/${analysis.featureName}/${analysis.featureName}_entity.dart',
    );

    final mapperContent = _generateMapperContent(
      analysis,
      entityAnalysis,
      modelPath,
      entityAnalysis.filePath,
    );
    await File(
      'lib/data/mappers/${analysis.featureName}_mapper.dart',
    ).writeAsString(mapperContent);
  }

  static Future<void> _generateRepositoryInterfaceForFeature(
    ModelAnalysis analysis,
  ) async {
    final content = _generateRepositoryInterfaceContent(analysis);
    await File(
      'lib/domain/repositories/${analysis.featureName}_repository.dart',
    ).writeAsString(content);
  }

  static Future<void> _generateRepositoryImplForFeature(
    ModelAnalysis analysis,
  ) async {
    final content = _generateRepositoryImplContent(analysis);
    await File(
      'lib/data/repositories/${analysis.featureName}_repository_impl.dart',
    ).writeAsString(content);
  }

  static Future<void> _generateDataSourceForFeature(
    ModelAnalysis analysis,
    bool isRemote,
  ) async {
    final content = _generateDataSourceContent(analysis, isRemote);
    final type = isRemote ? 'remote' : 'local';
    await File(
      'lib/data/data_sources/${analysis.featureName}_${type}_data_source.dart',
    ).writeAsString(content);
  }

  static Future<void> _generateUseCaseForFeature(ModelAnalysis analysis) async {
    // Create mock repository analysis for use case generation
    final repoAnalysis = RepositoryAnalysis(
      className: _toClassCase(analysis.featureName) + 'Repository',
      featureName: analysis.featureName,
      methods: [
        MethodInfo(
          name: 'get${_toClassCase(analysis.featureName)}Data',
          returnType:
              'Either<Failure, ${_toClassCase(analysis.featureName)}Entity>',
          parameters: [],
        ),
      ],
      filePath:
          'lib/domain/repositories/${analysis.featureName}_repository.dart',
    );

    final content = _generateUseCaseContent(repoAnalysis);
    await File(
      'lib/domain/use_cases/${analysis.featureName}/${analysis.featureName}_use_case.dart',
    ).writeAsString(content);
  }

  // Analysis methods
  static ModelAnalysis? _analyzeModel(String content, String filePath) {
    try {
      // Extract class name
      final classMatch = RegExp(
        r'class\s+(\w+)\s+(?:extends|implements|\{)',
      ).firstMatch(content);
      if (classMatch == null) return null;

      final className = classMatch.group(1)!;
      final featureName = _toSnakeCase(className.replaceAll('Model', ''));

      // Extract properties with nullable info
      final propertyMatches = RegExp(
        r'final\s+([^;]+?)\s+(\w+);',
      ).allMatches(content);

      final properties = propertyMatches.map((match) {
        final type = match.group(1)!.trim();
        final name = match.group(2)!.trim();
        final isNullable = type.endsWith('?');
        return PropertyInfo(type: type, name: name, isNullable: isNullable);
      }).toList();

      return ModelAnalysis(
        className: className,
        featureName: featureName,
        properties: properties,
        filePath: filePath,
      );
    } catch (e) {
      print('Error analyzing model: $e');
      return null;
    }
  }

  static EntityAnalysis? _analyzeEntity(String content, String filePath) {
    try {
      // Extract class name
      final classMatch = RegExp(
        r'class\s+(\w+)\s+(?:extends|implements|\{)',
      ).firstMatch(content);
      if (classMatch == null) return null;

      final className = classMatch.group(1)!;
      final featureName = _toSnakeCase(className.replaceAll('Entity', ''));

      // Extract properties with nullable info
      final propertyMatches = RegExp(
        r'final\s+([^;]+?)\s+(\w+);',
      ).allMatches(content);

      final properties = propertyMatches.map((match) {
        final type = match.group(1)!.trim();
        final name = match.group(2)!.trim();
        final isNullable = type.endsWith('?');
        return PropertyInfo(type: type, name: name, isNullable: isNullable);
      }).toList();

      return EntityAnalysis(
        className: className,
        featureName: featureName,
        properties: properties,
        filePath: filePath,
      );
    } catch (e) {
      print('Error analyzing entity: $e');
      return null;
    }
  }

  static RepositoryAnalysis? _analyzeRepository(
    String content,
    String filePath,
  ) {
    try {
      // Try to find abstract class first, then regular class
      var classMatch = RegExp(
        r'(?:abstract\s+)?class\s+(\w+)',
      ).firstMatch(content);

      if (classMatch == null) return null;

      final className = classMatch.group(1)!;
      final featureName = _toSnakeCase(
        className.replaceAll('RepositoryImpl', '').replaceAll('Repository', ''),
      );

      // Extract methods with more detail
      final methodMatches = RegExp(
        r'Future<([^>]+)>\s+(\w+)\(([^)]*)\)',
      ).allMatches(content);

      final methods = methodMatches.map((m) {
        final returnType = m.group(1)!.trim();
        final name = m.group(2)!.trim();
        final params = m.group(3)!.trim();

        return MethodInfo(
          name: name,
          returnType: 'Future<$returnType>',
          parameters: params.isEmpty
              ? []
              : params.split(',').map((p) => p.trim()).toList(),
        );
      }).toList();

      return RepositoryAnalysis(
        className: className,
        featureName: featureName,
        methods: methods,
        filePath: filePath,
      );
    } catch (e) {
      print('Error analyzing repository: $e');
      return null;
    }
  }

  // Content generation methods
  static String _generateEntityContent(ModelAnalysis analysis) {
    final className = _toClassCase(analysis.featureName) + 'Entity';

    final entityProperties = analysis.properties.map((prop) {
      final entityType = _convertModelTypeToEntityType(prop.type);
      return PropertyInfo(
        type: entityType,
        name: prop.name,
        isNullable: prop.isNullable,
      );
    }).toList();

    final propertyDeclarations = entityProperties
        .map((p) => '  final ${p.type} ${p.name};')
        .join('\n');

    final constructorParams = entityProperties
        .map((p) => '    required this.${p.name},')
        .join('\n');

    final copyWithParams = entityProperties
        .map((p) => '    ${p.type}? ${p.name},')
        .join('\n');

    final copyWithAssignments = entityProperties
        .map((p) => '      ${p.name}: ${p.name} ?? this.${p.name},')
        .join('\n');

    final propsContent = entityProperties.map((p) => p.name).join(', ');

    return '''import 'package:equatable/equatable.dart';

/// Domain Entity for ${analysis.featureName.toUpperCase()}
/// 
/// This represents the core business object in the domain layer.
class $className extends Equatable {
$propertyDeclarations

  const $className({
$constructorParams
  });

  $className copyWith({
$copyWithParams
  }) {
    return $className(
$copyWithAssignments
    );
  }

  @override
  List<Object?> get props => [$propsContent];

  @override
  String toString() {
    return '$className{${entityProperties.map((p) => '${p.name}: \\\$${p.name}').join(', ')}}';
  }
}''';
  }

  static String _generateMapperContent(
    ModelAnalysis modelAnalysis,
    EntityAnalysis entityAnalysis,
    String modelPath,
    String entityPath,
  ) {
    final modelClass = modelAnalysis.className;
    final entityClass = entityAnalysis.className;
    final featureName = modelAnalysis.featureName;

    // Extract relative paths for imports
    final modelImportPath = _getRelativeImportPath(modelPath, 'data/mappers');
    final entityImportPath = _getRelativeImportPath(entityPath, 'data/mappers');

    final modelToEntityMappings = _generatePropertyMappings(
      modelAnalysis.properties,
      entityAnalysis.properties,
      isModelToEntity: true,
    );

    final entityToModelMappings = _generatePropertyMappings(
      entityAnalysis.properties,
      modelAnalysis.properties,
      isModelToEntity: false,
    );

    return '''import '$entityImportPath';
import '$modelImportPath';

/// Mappers for ${featureName.toUpperCase()}
extension ${modelClass}Mapper on $modelClass {
  /// Converts data model to domain entity
  $entityClass toDomain() {
    return $entityClass(
$modelToEntityMappings
    );
  }
}

extension ${entityClass}Mapper on $entityClass {
  /// Converts domain entity to data model
  $modelClass toData() {
    return $modelClass(
$entityToModelMappings
    );
  }
}''';
  }

  static String _generateUseCaseContent(RepositoryAnalysis analysis) {
    final featureName = analysis.featureName;
    final pascalFeatureName = _toClassCase(featureName);
    final useCaseClass = 'Get${pascalFeatureName}UseCase';
    final repositoryClass = '${pascalFeatureName}Repository';
    final entityClass = '${pascalFeatureName}Entity';

    // Determine if the method has parameters
    final hasParams =
        analysis.methods.isNotEmpty &&
        analysis.methods.first.parameters.isNotEmpty;
    final paramsType = hasParams ? '${pascalFeatureName}Params' : 'NoParams';

    return '''import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../../core/use_cases/use_case.dart';
import '../entities/$featureName/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use Case for fetching ${featureName.toUpperCase()} data
/// 
/// This encapsulates the business logic for getting $featureName data
class $useCaseClass implements UseCase<$entityClass, $paramsType> {
  final $repositoryClass repository;

  $useCaseClass(this.repository);

  @override
  Future<Either<Failure, $entityClass>> call($paramsType params) async {
    return await repository.get${pascalFeatureName}Data();
  }
}''';
  }

  static String _generateDataSourceContent(
    ModelAnalysis analysis,
    bool isRemote,
  ) {
    final featureName = analysis.featureName;
    final pascalFeatureName = _toClassCase(featureName);
    final sourceType = isRemote ? 'Remote' : 'Local';
    final abstractClass = '$pascalFeatureName${sourceType}DataSource';
    final implClass = '$pascalFeatureName${sourceType}DataSourceImpl';

    final dataSourceContent = isRemote
        ? _generateRemoteDataSourceContent(analysis, abstractClass, implClass)
        : _generateLocalDataSourceContent(analysis, abstractClass, implClass);

    return dataSourceContent;
  }

  static String _generateRemoteDataSourceContent(
    ModelAnalysis analysis,
    String abstractClass,
    String implClass,
  ) {
    final featureName = analysis.featureName;
    final pascalFeatureName = _toClassCase(featureName);

    return '''import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/exceptions/exceptions.dart';

/// Abstract class for ${featureName.toUpperCase()} remote data source
abstract class $abstractClass {
  Future<Map<String, dynamic>> get${pascalFeatureName}Data();
}

/// Implementation of ${featureName.toUpperCase()} remote data source
class $implClass implements $abstractClass {
  final http.Client client;
  static const String baseUrl = 'https://your-api-url.com';

  $implClass({required this.client});

  @override
  Future<Map<String, dynamic>> get${pascalFeatureName}Data() async {
    try {
      final response = await client.get(
        Uri.parse('\$baseUrl/$featureName'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Failed to fetch $featureName data',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException('Network error: \$e', 0);
    }
  }
}''';
  }

  static String _generateLocalDataSourceContent(
    ModelAnalysis analysis,
    String abstractClass,
    String implClass,
  ) {
    final featureName = analysis.featureName;
    final pascalFeatureName = _toClassCase(featureName);

    return '''import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/exceptions/exceptions.dart';

/// Abstract class for ${featureName.toUpperCase()} local data source
abstract class $abstractClass {
  Future<Map<String, dynamic>> get${pascalFeatureName}Data();
  Future<void> cache${pascalFeatureName}Data(Map<String, dynamic> data);
}

/// Implementation of ${featureName.toUpperCase()} local data source
class $implClass implements $abstractClass {
  final SharedPreferences sharedPreferences;
  static const String cacheKey = 'CACHED_${featureName.toUpperCase()}_DATA';

  $implClass({required this.sharedPreferences});

  @override
  Future<Map<String, dynamic>> get${pascalFeatureName}Data() async {
    final jsonString = sharedPreferences.getString(cacheKey);
    
    if (jsonString != null) {
      final data = json.decode(jsonString);
      return data as Map<String, dynamic>;
    } else {
      throw CacheException('No cached data found for $featureName');
    }
  }

  @override
  Future<void> cache${pascalFeatureName}Data(Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    await sharedPreferences.setString(cacheKey, jsonString);
  }
}''';
  }

  static String _generateRepositoryInterfaceContent(ModelAnalysis analysis) {
    final featureName = analysis.featureName;
    final pascalFeatureName = _toClassCase(featureName);
    final repositoryClass = '${pascalFeatureName}Repository';
    final entityClass = '${pascalFeatureName}Entity';

    return '''import 'package:dartz/dartz.dart';

import '../../core/failures/failures.dart';
import '../entities/$featureName/${featureName}_entity.dart';

/// Repository interface for ${featureName.toUpperCase()}
/// 
/// Defines the contract for $featureName data operations
abstract class $repositoryClass {
  Future<Either<Failure, $entityClass>> get${pascalFeatureName}Data();
}''';
  }

  static String _generateRepositoryImplContent(ModelAnalysis analysis) {
    final featureName = analysis.featureName;
    final pascalFeatureName = _toClassCase(featureName);
    final repositoryClass = '${pascalFeatureName}Repository';
    final repositoryImplClass = '${pascalFeatureName}RepositoryImpl';
    final entityClass = '${pascalFeatureName}Entity';
    final modelClass = '${pascalFeatureName}Model';

    return '''import 'package:dartz/dartz.dart';

import '../../core/exceptions/exceptions.dart';
import '../../core/failures/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/$featureName/${featureName}_entity.dart';
import '../../domain/repositories/${featureName}_repository.dart';
import '../data_sources/${featureName}_local_data_source.dart';
import '../data_sources/${featureName}_remote_data_source.dart';
import '../mappers/${featureName}_mapper.dart';
import '../models/$featureName/${featureName}_model.dart';

/// Implementation of ${featureName.toUpperCase()} repository
class $repositoryImplClass implements $repositoryClass {
  final ${pascalFeatureName}RemoteDataSource remoteDataSource;
  final ${pascalFeatureName}LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  $repositoryImplClass({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, $entityClass>> get${pascalFeatureName}Data() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.get${pascalFeatureName}Data();
        final model = $modelClass.fromMap(remoteData);
        final entity = model.toDomain();
        
        // Cache the data
        await localDataSource.cache${pascalFeatureName}Data(remoteData);
        
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.statusCode));
      }
    } else {
      try {
        final localData = await localDataSource.get${pascalFeatureName}Data();
        final model = $modelClass.fromMap(localData);
        final entity = model.toDomain();
        
        return Right(entity);
      } on CacheException {
        return Left(CacheFailure('No cached data available'));
      }
    }
  }
}''';
  }

  // Helper methods

  /// Converts PascalCase/camelCase to snake_case
  static String _toSnakeCase(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '')
        .toLowerCase();
  }

  /// Converts snake_case to PascalCase
  static String _toClassCase(String input) {
    return input
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join('');
  }

  /// Get relative import path from source to target
  static String _getRelativeImportPath(String absolutePath, String fromDir) {
    // Extract the path after 'lib/'
    final libIndex = absolutePath.indexOf('lib/');
    if (libIndex == -1) return absolutePath;

    final relativePath = absolutePath.substring(libIndex + 4);

    // Count directory depth
    final fromDepth = fromDir.split('/').length;
    final goUp = '../' * fromDepth;

    return '$goUp$relativePath';
  }

  static String _convertModelTypeToEntityType(String modelType) {
    if (modelType.contains('List<') && modelType.contains('Model')) {
      return modelType.replaceAll('Model', 'Entity');
    }
    if (modelType.contains('Model')) {
      return modelType.replaceAll('Model', 'Entity');
    }
    return modelType;
  }

  static String _generatePropertyMappings(
    List<PropertyInfo> sourceProps,
    List<PropertyInfo> targetProps, {
    required bool isModelToEntity,
  }) {
    final mappings = <String>[];

    for (final targetProp in targetProps) {
      final sourceProp = sourceProps.firstWhere(
        (p) => p.name == targetProp.name,
        orElse: () => PropertyInfo(
          type: 'dynamic',
          name: targetProp.name,
          isNullable: true,
        ),
      );

      // Handle List<Model> to List<Entity> conversion
      if (sourceProp.type.contains('List<') &&
          sourceProp.type.contains('Model') &&
          targetProp.type.contains('List<') &&
          targetProp.type.contains('Entity')) {
        if (sourceProp.isNullable) {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}?.map((item) => item.toDomain()).toList(),',
          );
        } else {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}.map((item) => item.toDomain()).toList(),',
          );
        }
      }
      // Handle List<Entity> to List<Model> conversion
      else if (sourceProp.type.contains('List<') &&
          sourceProp.type.contains('Entity') &&
          targetProp.type.contains('List<') &&
          targetProp.type.contains('Model')) {
        if (sourceProp.isNullable) {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}?.map((item) => item.toData()).toList(),',
          );
        } else {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}.map((item) => item.toData()).toList(),',
          );
        }
      }
      // Handle single Model to Entity conversion
      else if (sourceProp.type.contains('Model') &&
          targetProp.type.contains('Entity')) {
        if (sourceProp.isNullable) {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}?.toDomain(),',
          );
        } else {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}.toDomain(),',
          );
        }
      }
      // Handle single Entity to Model conversion
      else if (sourceProp.type.contains('Entity') &&
          targetProp.type.contains('Model')) {
        if (sourceProp.isNullable) {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}?.toData(),',
          );
        } else {
          mappings.add(
            '      ${targetProp.name}: ${sourceProp.name}.toData(),',
          );
        }
      }
      // Direct assignment for primitive types
      else {
        mappings.add('      ${targetProp.name}: ${sourceProp.name},');
      }
    }

    return mappings.join('\n');
  }
}

// Data classes
class ModelAnalysis {
  final String className;
  final String featureName;
  final List<PropertyInfo> properties;
  final String filePath;

  ModelAnalysis({
    required this.className,
    required this.featureName,
    required this.properties,
    required this.filePath,
  });
}

class EntityAnalysis {
  final String className;
  final String featureName;
  final List<PropertyInfo> properties;
  final String filePath;

  EntityAnalysis({
    required this.className,
    required this.featureName,
    required this.properties,
    required this.filePath,
  });
}

class RepositoryAnalysis {
  final String className;
  final String featureName;
  final List<MethodInfo> methods;
  final String filePath;

  RepositoryAnalysis({
    required this.className,
    required this.featureName,
    required this.methods,
    required this.filePath,
  });
}

class PropertyInfo {
  final String type;
  final String name;
  final bool isNullable;

  PropertyInfo({
    required this.type,
    required this.name,
    this.isNullable = false,
  });
}

class MethodInfo {
  final String name;
  final String returnType;
  final List<String> parameters;

  MethodInfo({
    required this.name,
    required this.returnType,
    required this.parameters,
  });
}

// Main function
void main(List<String> args) async {
  await UnifiedGenerator.showMainMenu();
}
