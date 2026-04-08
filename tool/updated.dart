import 'dart:io';
import 'dart:convert';

/// Unified Clean Architecture Code Generator
///
/// Smart version with auto-detection and path history
class UnifiedGenerator {
  static const String _historyFile = '.code_generator_history.json';
  static Map<String, dynamic> _pathHistory = {};

  /// Load path history
  static Future<void> _loadHistory() async {
    final file = File(_historyFile);
    if (await file.exists()) {
      final content = await file.readAsString();
      _pathHistory = json.decode(content) as Map<String, dynamic>;
    }
  }

  /// Save path history
  static Future<void> _saveHistory() async {
    final file = File(_historyFile);
    await file.writeAsString(json.encode(_pathHistory));
  }

  /// Save feature paths
  static Future<void> _saveFeaturePaths(
      String featureName,
      String? modelPath,
      String? entityPath,
      String? mapperPath,
      ) async {
    _pathHistory[featureName] = {
      'model': modelPath,
      'entity': entityPath,
      'mapper': mapperPath,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await _saveHistory();
  }

  /// Get feature paths
  static Map<String, dynamic>? _getFeaturePaths(String featureName) {
    return _pathHistory[featureName] as Map<String, dynamic>?;
  }

  /// Auto-detect paths based on model path
  static Future<Map<String, String?>> _autoDetectPaths(String modelPath) async {
    final modelFile = File(modelPath);
    if (!await modelFile.exists()) {
      return {'model': null, 'entity': null, 'mapper': null};
    }

    final content = await modelFile.readAsString();
    final analysis = _analyzeModel(content, modelPath);

    if (analysis == null) {
      return {'model': null, 'entity': null, 'mapper': null};
    }

    final featureName = analysis.featureName;

    // Check history first
    final historyPaths = _getFeaturePaths(featureName);
    if (historyPaths != null) {
      return {
        'model': historyPaths['model'] as String?,
        'entity': historyPaths['entity'] as String?,
        'mapper': historyPaths['mapper'] as String?,
      };
    }

    // Auto-detect entity path
    String? entityPath;
    final possibleEntityPaths = [
      'lib/domain/entities/$featureName/${featureName}_entity.dart',
      'lib/domain/entities/${featureName}_entity.dart',
    ];

    for (final path in possibleEntityPaths) {
      if (await File(path).exists()) {
        entityPath = path;
        break;
      }
    }

    // Auto-detect mapper path
    String? mapperPath;
    final possibleMapperPaths = [
      'lib/data/mappers/$featureName/${featureName}_mapper.dart',
      'lib/data/mappers/${featureName}_mapper.dart',
    ];

    for (final path in possibleMapperPaths) {
      if (await File(path).exists()) {
        mapperPath = path;
        break;
      }
    }

    return {
      'model': modelPath,
      'entity': entityPath,
      'mapper': mapperPath,
    };
  }

  /// Main menu system
  static Future<void> showMainMenu() async {
    await _loadHistory();

    print('');
    print('🏗️  CLEAN ARCHITECTURE CODE GENERATOR');
    print('════════════════════════════════════════');
    print('');
    print('Available Commands:');
    print('');
    print('1️⃣  Generate Entity from Model');
    print('2️⃣  Generate Mapper from Model + Entity');
    print('3️⃣  Quick Sync (Auto-detect paths)');
    print('4️⃣  Generate UseCase from Repository');
    print('5️⃣  Generate Remote DataSource from Model');
    print('6️⃣  Generate Local DataSource from Model');
    print('7️⃣  Generate Complete Feature Set');
    print('8️⃣  View Path History');
    print('9️⃣  Clear Path History');
    print('');
    print('0️⃣  Exit');
    print('');

    stdout.write('Select option (0-9): ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await handleGenerateEntity();
        break;
      case '2':
        await handleGenerateMapper();
        break;
      case '3':
        await handleQuickSync();
        break;
      case '4':
        await handleGenerateUseCase();
        break;
      case '5':
        await handleGenerateRemoteDataSource();
        break;
      case '6':
        await handleGenerateLocalDataSource();
        break;
      case '7':
        await handleGenerateCompleteFeature();
        break;
      case '8':
        await handleViewHistory();
        break;
      case '9':
        await handleClearHistory();
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

  /// NEW: Quick Sync - Auto-detect everything
  static Future<void> handleQuickSync() async {
    print('');
    print('⚡ QUICK SYNC - AUTO-DETECT PATHS');
    print('─────────────────────────────────────');
    print('Just provide the model path, I\'ll find the rest!');
    print('');

    stdout.write('Enter model path: ');
    final modelPath = stdin.readLineSync();
    if (modelPath == null || modelPath.isEmpty) {
      print('❌ Model path is required');
      return;
    }

    print('');
    print('🔍 Auto-detecting paths...');

    final paths = await _autoDetectPaths(modelPath);

    if (paths['entity'] == null || paths['mapper'] == null) {
      print('');
      print('⚠️  Could not auto-detect all paths');
      print('');
      if (paths['entity'] == null) {
        print('❌ Entity not found. Generate it first using Option 1');
      }
      if (paths['mapper'] == null) {
        print('❌ Mapper not found. Generate it first using Option 2');
      }
      return;
    }

    print('');
    print('✅ Paths detected:');
    print('   📄 Model:  ${paths['model']}');
    print('   📄 Entity: ${paths['entity']}');
    print('   📄 Mapper: ${paths['mapper']}');
    print('');

    stdout.write('Continue with sync? (y/n): ');
    final confirm = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    if (!confirm) {
      print('❌ Operation cancelled');
      return;
    }

    await syncEntityAndMapper(
      paths['model']!,
      paths['entity']!,
      paths['mapper']!,
    );
  }

  /// View Path History
  static Future<void> handleViewHistory() async {
    print('');
    print('📚 PATH HISTORY');
    print('─────────────────────────────────────');

    if (_pathHistory.isEmpty) {
      print('No history found. Generate some files first!');
      return;
    }

    _pathHistory.forEach((featureName, paths) {
      final pathMap = paths as Map<String, dynamic>;
      print('');
      print('Feature: $featureName');
      print('  Model:  ${pathMap['model'] ?? 'N/A'}');
      print('  Entity: ${pathMap['entity'] ?? 'N/A'}');
      print('  Mapper: ${pathMap['mapper'] ?? 'N/A'}');
      print('  Last Updated: ${pathMap['lastUpdated'] ?? 'N/A'}');
    });
  }

  /// Clear Path History
  static Future<void> handleClearHistory() async {
    print('');
    stdout.write('Clear all path history? (y/n): ');
    final confirm = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

    if (confirm) {
      _pathHistory.clear();
      await _saveHistory();
      print('✅ History cleared');
    } else {
      print('❌ Operation cancelled');
    }
  }

  /// Handle Generate Entity with smart folder detection
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

    // Check if model file exists
    if (!await File(modelPath).exists()) {
      print('❌ Model file not found: $modelPath');
      return;
    }

    // Analyze model to get feature name
    final modelContent = await File(modelPath).readAsString();
    final analysis = _analyzeModel(modelContent, modelPath);

    if (analysis == null) {
      print('❌ Could not analyze model file');
      return;
    }

    final featureName = analysis.featureName;

    // Check history for this feature
    final historyPaths = _getFeaturePaths(featureName);
    String? suggestedFolder;

    if (historyPaths != null && historyPaths['entity'] != null) {
      final entityPath = historyPaths['entity'] as String;
      suggestedFolder = entityPath.substring(0, entityPath.lastIndexOf('/'));

      print('');
      print('💡 Found previous location: $suggestedFolder');
      stdout.write('Use this location? (y/n): ');
      final useHistory = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

      if (useHistory) {
        final entityPath = '$suggestedFolder/${featureName}_entity.dart';

        if (await File(entityPath).exists()) {
          print('');
          print('⚠️  FILE ALREADY EXISTS: $entityPath');
          print('💡 Use Option 3 (Quick Sync) to update it');
          return;
        }

        await generateEntityFromModel(
          modelPath,
          customEntityPath: suggestedFolder,
          featureName: featureName,
        );
        return;
      }
    }

    // Show folder selection
    final selectedFolder = await _selectOrCreateFolder(
      'lib/domain/entities',
      'entity',
      suggestedName: featureName,
    );

    if (selectedFolder == null) {
      print('❌ Operation cancelled');
      return;
    }

    await generateEntityFromModel(
      modelPath,
      customEntityPath: selectedFolder,
      featureName: featureName,
    );
  }

  /// Handle Generate Mapper with smart detection
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

    if (!await File(modelPath).exists()) {
      print('❌ Model file not found: $modelPath');
      return;
    }

    // Auto-detect entity path
    print('');
    print('🔍 Auto-detecting entity path...');
    final paths = await _autoDetectPaths(modelPath);

    String? entityPath = paths['entity'];

    if (entityPath != null && await File(entityPath).exists()) {
      print('✅ Found entity: $entityPath');
      stdout.write('Use this entity? (y/n): ');
      final useAuto = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

      if (!useAuto) {
        stdout.write('Enter entity path: ');
        entityPath = stdin.readLineSync();
      }
    } else {
      stdout.write('Enter entity path: ');
      entityPath = stdin.readLineSync();
    }

    if (entityPath == null || entityPath.isEmpty) {
      print('❌ Entity path is required');
      return;
    }

    if (!await File(entityPath).exists()) {
      print('❌ Entity file not found: $entityPath');
      return;
    }

    // Get feature name
    final modelContent = await File(modelPath).readAsString();
    final analysis = _analyzeModel(modelContent, modelPath);

    if (analysis == null) {
      print('❌ Could not analyze model file');
      return;
    }

    final featureName = analysis.featureName;

    // Check history
    final historyPaths = _getFeaturePaths(featureName);
    String? suggestedFolder;

    if (historyPaths != null && historyPaths['mapper'] != null) {
      final mapperPath = historyPaths['mapper'] as String;
      suggestedFolder = mapperPath.substring(0, mapperPath.lastIndexOf('/'));

      print('');
      print('💡 Found previous location: $suggestedFolder');
      stdout.write('Use this location? (y/n): ');
      final useHistory = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

      if (useHistory) {
        final mapperPath = '$suggestedFolder/${featureName}_mapper.dart';

        if (await File(mapperPath).exists()) {
          print('');
          print('⚠️  FILE ALREADY EXISTS: $mapperPath');
          print('💡 Use Option 3 (Quick Sync) to update it');
          return;
        }

        await generateMapperFromFiles(
          modelPath,
          entityPath,
          customMapperPath: suggestedFolder,
          featureName: featureName,
        );
        return;
      }
    }

    // Show folder selection
    final selectedFolder = await _selectOrCreateFolder(
      'lib/data/mappers',
      'mapper',
      suggestedName: featureName,
    );

    if (selectedFolder == null) {
      print('❌ Operation cancelled');
      return;
    }

    await generateMapperFromFiles(
      modelPath,
      entityPath,
      customMapperPath: selectedFolder,
      featureName: featureName,
    );
  }

  /// Smart folder selection with suggestions
  static Future<String?> _selectOrCreateFolder(
      String basePath,
      String fileType, {
        String? suggestedName,
      }) async {
    print('');
    print('📁 SELECT DESTINATION FOLDER');
    print('─────────────────────────────');

    // Create base directory if it doesn't exist
    final baseDir = Directory(basePath);
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    // Get existing folders
    final folders = <String>[];
    await for (final entity in baseDir.list()) {
      if (entity is Directory) {
        final folderName = entity.path.split(Platform.pathSeparator).last;
        folders.add(folderName);
      }
    }

    if (folders.isEmpty) {
      if (suggestedName != null) {
        print('ℹ️  No existing folders found in $basePath');
        print('');
        print('💡 Suggested folder name: $suggestedName');
        stdout.write('Use suggested name? (y/n): ');
        final useSuggested = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

        if (useSuggested) {
          final newFolderPath = '$basePath/$suggestedName';
          await Directory(newFolderPath).create(recursive: true);
          print('✅ Created folder: $newFolderPath');
          return newFolderPath;
        }
      }

      print('');
      stdout.write('Enter new folder name: ');
      final folderName = stdin.readLineSync();

      if (folderName == null || folderName.isEmpty) {
        print('❌ Folder name is required');
        return null;
      }

      final newFolderPath = '$basePath/$folderName';
      await Directory(newFolderPath).create(recursive: true);
      print('✅ Created folder: $newFolderPath');

      return newFolderPath;
    }

    // Display available folders
    print('Available folders:');
    print('');

    // Show suggested folder first if it exists
    int suggestedIndex = -1;
    if (suggestedName != null && folders.contains(suggestedName)) {
      suggestedIndex = folders.indexOf(suggestedName);
      print('${suggestedIndex + 1}. ${folders[suggestedIndex]} 💡 (Suggested)');
    }

    for (var i = 0; i < folders.length; i++) {
      if (i != suggestedIndex) {
        print('${i + 1}. ${folders[i]}');
      }
    }
    print('${folders.length + 1}. Create New Folder');
    print('');

    if (suggestedName != null && suggestedIndex >= 0) {
      stdout.write('Select option (Enter for suggested): ');
    } else {
      stdout.write('Select option: ');
    }

    final choice = stdin.readLineSync();

    // Use suggested if Enter pressed and suggestion exists
    if ((choice == null || choice.isEmpty) && suggestedIndex >= 0) {
      return '$basePath/${folders[suggestedIndex]}';
    }

    if (choice == null || choice.isEmpty) {
      print('❌ Invalid selection');
      return null;
    }

    final selection = int.tryParse(choice);
    if (selection == null || selection < 1 || selection > folders.length + 1) {
      print('❌ Invalid selection');
      return null;
    }

    // Create new folder
    if (selection == folders.length + 1) {
      if (suggestedName != null) {
        print('');
        print('💡 Suggested folder name: $suggestedName');
        stdout.write('Use suggested name? (y/n): ');
        final useSuggested = stdin.readLineSync()?.toLowerCase().startsWith('y') ?? false;

        if (useSuggested) {
          final newFolderPath = '$basePath/$suggestedName';

          if (await Directory(newFolderPath).exists()) {
            print('❌ Folder already exists: $newFolderPath');
            return null;
          }

          await Directory(newFolderPath).create(recursive: true);
          print('✅ Created folder: $newFolderPath');
          return newFolderPath;
        }
      }

      stdout.write('Enter new folder name: ');
      final folderName = stdin.readLineSync();

      if (folderName == null || folderName.isEmpty) {
        print('❌ Folder name is required');
        return null;
      }

      final newFolderPath = '$basePath/$folderName';

      if (await Directory(newFolderPath).exists()) {
        print('❌ Folder already exists: $newFolderPath');
        return null;
      }

      await Directory(newFolderPath).create(recursive: true);
      print('✅ Created folder: $newFolderPath');

      return newFolderPath;
    }

    // Use existing folder
    final selectedFolder = folders[selection - 1];
    return '$basePath/$selectedFolder';
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
        String? customEntityPath,
        String? featureName,
      }) async {
    print('');
    print('🏗️ Generating entity...');

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

    featureName ??= analysis.featureName;

    // Determine entity path
    String entityPath;
    if (customEntityPath != null) {
      entityPath = '$customEntityPath/${featureName}_entity.dart';
    } else {
      entityPath = 'lib/domain/entities/${featureName}_entity.dart';
      await Directory('lib/domain/entities').create(recursive: true);
    }

    // Check if file already exists
    if (await File(entityPath).exists()) {
      print('');
      print('⚠️  FILE ALREADY EXISTS: $entityPath');
      print('💡 Use Option 3 (Quick Sync) to update it');
      return;
    }

    // Generate entity content
    final entityContent = _generateEntityContent(analysis);

    // Write entity file
    await File(entityPath).writeAsString(entityContent);

    print('✅ Entity generated: $entityPath');

    // Save to history
    await _saveFeaturePaths(featureName, modelPath, entityPath, null);
  }

  /// Sync Entity and Mapper from Model
  static Future<void> syncEntityAndMapper(
      String modelPath,
      String entityPath,
      String mapperPath,
      ) async {
    print('');
    print('🔄 Syncing files...');

    final modelContent = await File(modelPath).readAsString();
    final modelAnalysis = _analyzeModel(modelContent, modelPath);

    if (modelAnalysis == null) {
      print('❌ Could not analyze model file');
      return;
    }

    final featureName = modelAnalysis.featureName;

    // Generate updated entity
    final entityContent = _generateEntityContent(modelAnalysis);
    await File(entityPath).writeAsString(entityContent);
    print('✅ Entity updated');

    // Generate entity analysis for mapper
    final entityAnalysis = EntityAnalysis(
      className: _toClassCase(modelAnalysis.featureName) + 'Entity',
      featureName: modelAnalysis.featureName,
      properties: modelAnalysis.properties
          .map(
            (p) => PropertyInfo(
          type: _convertModelTypeToEntityType(p.type),
          name: p.name,
          isNullable: p.isNullable,
        ),
      )
          .toList(),
      filePath: entityPath,
    );

    // Generate updated mapper
    final mapperContent = _generateMapperContent(
      modelAnalysis,
      entityAnalysis,
      modelPath,
      entityPath,
    );
    await File(mapperPath).writeAsString(mapperContent);
    print('✅ Mapper updated');

    // Save to history
    await _saveFeaturePaths(featureName, modelPath, entityPath, mapperPath);

    print('');
    print('🎉 Sync completed!');
  }

  /// Generates a mapper from existing model and entity files
  static Future<void> generateMapperFromFiles(
      String modelPath,
      String entityPath, {
        String? customMapperPath,
        String? featureName,
      }) async {
    print('');
    print('🗺️ Generating mapper...');

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

    featureName ??= modelAnalysis.featureName;

    // Determine mapper path
    String mapperPath;
    if (customMapperPath != null) {
      mapperPath = '$customMapperPath/${featureName}_mapper.dart';
    } else {
      mapperPath = 'lib/data/mappers/${featureName}_mapper.dart';
      await Directory('lib/data/mappers').create(recursive: true);
    }

    // Check if file already exists
    if (await File(mapperPath).exists()) {
      print('');
      print('⚠️  FILE ALREADY EXISTS: $mapperPath');
      print('💡 Use Option 3 (Quick Sync) to update it');
      return;
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

    print('✅ Mapper generated: $mapperPath');

    // Save to history
    final existingPaths = _getFeaturePaths(featureName);
    await _saveFeaturePaths(
      featureName,
      modelPath,
      existingPaths?['entity'] as String? ?? entityPath,
      mapperPath,
    );
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
          returnType: 'Either<Failure, ${_toClassCase(analysis.featureName)}Entity>',
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
      final classMatch = RegExp(r'class\s+(\w+)\s+(?:extends|implements|\{)').firstMatch(content);
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
        return PropertyInfo(
          type: type,
          name: name,
          isNullable: isNullable,
        );
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
      final classMatch = RegExp(r'class\s+(\w+)\s+(?:extends|implements|\{)').firstMatch(content);
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
        return PropertyInfo(
          type: type,
          name: name,
          isNullable: isNullable,
        );
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
        className
            .replaceAll('RepositoryImpl', '')
            .replaceAll('Repository', ''),
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
          parameters: params.isEmpty ? [] : params.split(',').map((p) => p.trim()).toList(),
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

  // Content generation methods - SIMPLIFIED ENTITY (No copyWith, toString)
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

  @override
  List<Object?> get props => [$propsContent];
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
    final hasParams = analysis.methods.isNotEmpty &&
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
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
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