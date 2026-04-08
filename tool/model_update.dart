import 'dart:io';

void main(List<String> args) async {
  print('🚀 Dart Model Generator (Smart Update)\n');

  if (args.isEmpty) {
    print('Usage: dart model_generate.dart <path_to_model.dart>');
    print('Example: dart model_generate.dart lib/models/cart_model.dart\n');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);

  if (!await file.exists()) {
    print('❌ Error: File not found: $filePath');
    exit(1);
  }

  try {
    await ModelGenerator.generate(file);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

class ModelGenerator {
  static Future<void> generate(File file) async {
    final content = await file.readAsString();
    final modelInfo = _parseModel(content);

    if (modelInfo == null) {
      throw Exception('No valid model class found in file');
    }

    print('📝 Found model: ${modelInfo.className}');
    print('📋 Fields: ${modelInfo.fields.length}');
    for (var field in modelInfo.fields) {
      print('   - ${field.type} ${field.name}');
    }
    print('');

    // Check if file already has generated code
    final hasGeneratedCode = content.contains('// Generated code - do not modify by hand');

    String generatedCode;
    if (hasGeneratedCode) {
      print('♻️  Updating existing model (preserving manual changes)...\n');
      generatedCode = _updateExistingModel(modelInfo, content);
    } else {
      print('✨ Generating new model...\n');
      generatedCode = _generateCompleteModel(modelInfo, content);
    }

    await file.writeAsString(generatedCode);

    print('✅ Model generated successfully!');
    print('📄 File: ${file.path}\n');
  }

  static ModelInfo? _parseModel(String content) {
    final classRegex = RegExp(
      r'class\s+(\w+)\s+extends\s+(\w+)\s*\{',
      multiLine: true,
    );

    final classMatch = classRegex.firstMatch(content);
    if (classMatch == null) return null;

    final className = classMatch.group(1)!;
    final extendsClass = classMatch.group(2)!;

    final fields = <FieldInfo>[];
    final fieldRegex = RegExp(
      r'final\s+([\w<>?,\s]+)\s+(\w+);',
      multiLine: true,
    );

    for (final match in fieldRegex.allMatches(content)) {
      final type = match.group(1)!.trim();
      final name = match.group(2)!;
      fields.add(_parseField(name, type));
    }

    return ModelInfo(
      className: className,
      extendsClass: extendsClass,
      fields: fields,
    );
  }

  static FieldInfo _parseField(String name, String type) {
    final isNullable = type.endsWith('?');
    final cleanType = type.replaceAll('?', '').trim();

    if (cleanType.startsWith('List<')) {
      final elementTypeMatch = RegExp(r'List<(.+)>').firstMatch(cleanType);
      final elementType = elementTypeMatch?.group(1) ?? 'dynamic';
      final isElementNullable = elementType.endsWith('?');
      final cleanElementType = elementType.replaceAll('?', '');

      return FieldInfo(
        name: name,
        type: type,
        isNullable: isNullable,
        isList: true,
        isPrimitive: _isPrimitive(cleanElementType),
        listElementType: cleanElementType,
        isListElementNullable: isElementNullable,
      );
    }

    return FieldInfo(
      name: name,
      type: type,
      isNullable: isNullable,
      isPrimitive: _isPrimitive(cleanType),
    );
  }

  static bool _isPrimitive(String type) {
    const primitives = {'int', 'String', 'bool', 'double', 'num', 'dynamic'};
    return primitives.contains(type);
  }

  // ✅ NEW: Smart update - preserves manual changes
  static String _updateExistingModel(ModelInfo model, String originalContent) {
    final buffer = StringBuffer();

    // Preserve everything before class declaration
    final classStart = originalContent.indexOf('class ${model.className}');
    if (classStart > 0) {
      buffer.write(originalContent.substring(0, classStart));
    }

    // Class declaration
    buffer.writeln('class ${model.className} extends ${model.extendsClass} {');

    // Fields
    for (final field in model.fields) {
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln();

    // Constructor - always regenerate
    buffer.write(_generateConstructor(model));
    buffer.writeln();

    // Extract and preserve manually modified methods
    final preservedMethods = _extractManualMethods(originalContent, [
      'copyWith',
      'toMap',
      'fromMap',
      'toJson',
      'fromJson',
    ]);

    // copyWith - use preserved or generate new
    if (preservedMethods['copyWith'] != null) {
      buffer.write(preservedMethods['copyWith']);
    } else {
      buffer.write(_generateCopyWith(model));
    }
    buffer.writeln();

    // toMap - use preserved or generate new
    if (preservedMethods['toMap'] != null) {
      buffer.write(preservedMethods['toMap']);
    } else {
      buffer.write(_generateToMap(model));
    }
    buffer.writeln();

    // fromMap - use preserved or generate new
    if (preservedMethods['fromMap'] != null) {
      buffer.write(preservedMethods['fromMap']);
    } else {
      buffer.write(_generateFromMap(model));
    }
    buffer.writeln();

    // toJson - use preserved or generate new
    if (preservedMethods['toJson'] != null) {
      buffer.write(preservedMethods['toJson']);
    } else {
      buffer.write(_generateToJson(model));
    }
    buffer.writeln();

    // fromJson - use preserved or generate new
    if (preservedMethods['fromJson'] != null) {
      buffer.write(preservedMethods['fromJson']);
    } else {
      buffer.write(_generateFromJson(model));
    }
    buffer.writeln();

    // Extract custom methods (methods not in the standard list)
    final customMethods = _extractCustomMethods(originalContent);
    for (var method in customMethods) {
      buffer.writeln(method);
      buffer.writeln();
    }

    // Equatable members
    if (model.extendsClass == 'Equatable') {
      buffer.writeln('  @override');
      buffer.writeln('  bool get stringify => true;');
      buffer.writeln();
      buffer.write(_generateProps(model));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  // ✅ Extract manually modified methods
  static Map<String, String> _extractManualMethods(String content, List<String> methodNames) {
    final methods = <String, String>{};

    for (var methodName in methodNames) {
      // Look for method with // MANUAL or // CUSTOM comment
      final manualPattern = RegExp(
        r'(\/\/ MANUAL.*?\n.*?' + methodName + r'.*?\{.*?\n.*?\})',
        multiLine: true,
        dotAll: true,
      );

      final manualMatch = manualPattern.firstMatch(content);
      if (manualMatch != null) {
        methods[methodName] = manualMatch.group(1)!;
        continue;
      }

      // Extract method normally
      RegExp? methodPattern;

      if (methodName == 'fromMap' || methodName == 'fromJson') {
        methodPattern = RegExp(
          r'factory\s+\w+\.' + methodName + r'\s*\([^)]*\)\s*\{(?:[^{}]*|\{[^{}]*\})*\}',
          multiLine: true,
        );
      } else {
        methodPattern = RegExp(
          r'\w+\s+' + methodName + r'\s*\([^)]*\)\s*\{(?:[^{}]*|\{[^{}]*\})*\}',
          multiLine: true,
        );
      }

      final match = methodPattern.firstMatch(content);
      if (match != null) {
        final methodCode = match.group(0)!;
        // Check if method has been manually modified (contains custom keys)
        if (methodCode.contains("'to_does'") ||
            methodCode.contains('"to_does"') ||
            methodCode.contains('// CUSTOM') ||
            _hasCustomMapKeys(methodCode)) {
          methods[methodName] = '  $methodCode';
        }
      }
    }

    return methods;
  }

  // Check if method has custom map keys (snake_case, etc.)
  static bool _hasCustomMapKeys(String methodCode) {
    final customKeyPattern = RegExp("['\\\"]([a-z]+_[a-z_]+)['\\\"]");
    return customKeyPattern.hasMatch(methodCode);
  }

  // Extract custom methods that aren't standard generated ones
  static List<String> _extractCustomMethods(String content) {
    final customMethods = <String>[];
    final standardMethods = [
      'copyWith',
      'toMap',
      'fromMap',
      'toJson',
      'fromJson',
      'props',
      'stringify',
    ];

    // Find all methods
    final methodPattern = RegExp(
      r'(  (?:\/\/.*\n\s*)?(?:@override\s+)?(?:[\w<>?]+\s+)?(\w+)\s*\([^)]*\)\s*(?:=>|{).*?(?:;|\n  \}))',
      multiLine: true,
      dotAll: true,
    );

    for (var match in methodPattern.allMatches(content)) {
      final methodCode = match.group(1)!;
      final methodName = match.group(2)!;

      if (!standardMethods.contains(methodName) &&
          methodCode.startsWith('  ') &&
          !methodCode.contains('final ')) {
        customMethods.add(methodCode);
      }
    }

    return customMethods;
  }

  static String _generateCompleteModel(ModelInfo model, String originalContent) {
    final buffer = StringBuffer();

    final lines = originalContent.split('\n');
    final existingImports = <String>[];
    var hasDartConvert = false;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('import ')) {
        if (trimmed.contains('dart:convert')) {
          hasDartConvert = true;
        } else {
          existingImports.add(line);
        }
      }
    }

    if (!hasDartConvert) {
      buffer.writeln("import 'dart:convert';");
    }

    for (var import in existingImports) {
      buffer.writeln(import);
    }

    if (hasDartConvert || existingImports.isNotEmpty) {
      buffer.writeln();
    }

    // Add marker for smart updates
    buffer.writeln('// Generated code - do not modify by hand');
    buffer.writeln('// To preserve custom changes, add // MANUAL comment above modified methods');
    buffer.writeln();

    buffer.writeln('class ${model.className} extends ${model.extendsClass} {');

    for (final field in model.fields) {
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln();

    buffer.write(_generateConstructor(model));
    buffer.writeln();

    buffer.write(_generateCopyWith(model));
    buffer.writeln();

    buffer.write(_generateToMap(model));
    buffer.writeln();

    buffer.write(_generateFromMap(model));
    buffer.writeln();

    buffer.write(_generateToJson(model));
    buffer.writeln();

    buffer.write(_generateFromJson(model));
    buffer.writeln();

    if (model.extendsClass == 'Equatable') {
      buffer.writeln('  @override');
      buffer.writeln('  bool get stringify => true;');
      buffer.writeln();
      buffer.write(_generateProps(model));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateConstructor(ModelInfo model) {
    final buffer = StringBuffer();
    buffer.writeln('  const ${model.className}({');

    for (final field in model.fields) {
      buffer.writeln('    required this.${field.name},');
    }

    buffer.writeln('  });');
    return buffer.toString();
  }

  // ✅ FIX: Proper nullable handling in copyWith
  static String _generateCopyWith(ModelInfo model) {
    final buffer = StringBuffer();
    buffer.writeln('  ${model.className} copyWith({');

    for (final field in model.fields) {
      // Only add single ? for all fields
      buffer.writeln('    ${field.type}? ${field.name},');
    }

    buffer.writeln('  }) {');
    buffer.writeln('    return ${model.className}(');

    for (final field in model.fields) {
      buffer.writeln('      ${field.name}: ${field.name} ?? this.${field.name},');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');

    return buffer.toString();
  }

  static String _generateToMap(ModelInfo model) {
    final buffer = StringBuffer();
    buffer.writeln('  Map<String, dynamic> toMap() {');
    buffer.writeln('    return <String, dynamic>{');

    for (final field in model.fields) {
      if (field.isList) {
        if (field.isPrimitive) {
          buffer.writeln("      '${field.name}': ${field.name}?.map((x) => x).toList(),");
        } else {
          buffer.writeln("      '${field.name}': ${field.name}?.map((x) => x?.toMap()).toList(),");
        }
      } else if (field.isPrimitive) {
        buffer.writeln("      '${field.name}': ${field.name},");
      } else {
        buffer.writeln("      '${field.name}': ${field.name}?.toMap(),");
      }
    }

    buffer.writeln('    };');
    buffer.writeln('  }');

    return buffer.toString();
  }

  static String _generateFromMap(ModelInfo model) {
    final buffer = StringBuffer();
    buffer.writeln('  factory ${model.className}.fromMap(Map<String, dynamic> map) {');
    buffer.writeln('    return ${model.className}(');

    for (final field in model.fields) {
      buffer.write('      ${field.name}: ');

      if (field.isList) {
        if (field.isPrimitive) {
          final defaultValue = field.isNullable ? 'null' : '[]';
          buffer.writeln(
              "map['${field.name}'] != null ? List<${field.listElementType}${field.isListElementNullable ? '?' : ''}>.from((map['${field.name}'] as List<dynamic>).map<${field.listElementType}${field.isListElementNullable ? '?' : ''}>((x) => x),) : $defaultValue,");
        } else {
          final defaultValue = field.isNullable ? 'null' : '[]';

          if (field.isListElementNullable) {
            buffer.writeln(
                "map['${field.name}'] != null ? (map['${field.name}'] as List<dynamic>).map((x) => x != null ? ${field.listElementType}.fromMap(x as Map<String, dynamic>) : null).toList() : $defaultValue,");
          } else {
            buffer.writeln(
                "map['${field.name}'] != null ? (map['${field.name}'] as List<dynamic>).map((x) => ${field.listElementType}.fromMap(x as Map<String, dynamic>)).toList() : $defaultValue,");
          }
        }
      } else if (field.isPrimitive) {
        final baseType = field.type.replaceAll('?', '');
        switch (baseType) {
          case 'int':
            final defaultValue = field.isNullable ? 'null' : '0';
            buffer.writeln("map['${field.name}'] != null ? int.parse(map['${field.name}'].toString()) : $defaultValue,");
            break;
          case 'double':
            final defaultValue = field.isNullable ? 'null' : '0.0'; // ✅ FIX: Use 0.0
            buffer.writeln("map['${field.name}'] != null ? double.parse(map['${field.name}'].toString()) : $defaultValue,");
            break;
          case 'String':
            final defaultValue = field.isNullable ? 'null' : "''";
            buffer.writeln("map['${field.name}'] ?? $defaultValue,");
            break;
          case 'bool':
            final defaultValue = field.isNullable ? 'null' : 'false';
            buffer.writeln("map['${field.name}'] ?? $defaultValue,");
            break;
          default:
            buffer.writeln("map['${field.name}'],");
        }
      } else {
        if (field.isNullable) {
          final baseType = field.type.replaceAll('?', '');
          buffer.writeln("map['${field.name}'] != null ? $baseType.fromMap(map['${field.name}'] as Map<String, dynamic>) : null,");
        } else {
          buffer.writeln("${field.type}.fromMap(map['${field.name}'] as Map<String, dynamic>),");
        }
      }
    }

    buffer.writeln('    );');
    buffer.writeln('  }');

    return buffer.toString();
  }

  static String _generateToJson(ModelInfo model) {
    return "  String toJson() => json.encode(toMap());";
  }

  static String _generateFromJson(ModelInfo model) {
    return "  factory ${model.className}.fromJson(String source) => ${model.className}.fromMap(json.decode(source) as Map<String, dynamic>);";
  }

  static String _generateProps(ModelInfo model) {
    final buffer = StringBuffer();
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props {');
    buffer.write('    return [');
    buffer.write(model.fields.map((f) => f.name).join(', '));
    buffer.writeln('];');
    buffer.writeln('  }');

    return buffer.toString();
  }
}

class ModelInfo {
  final String className;
  final String extendsClass;
  final List<FieldInfo> fields;

  ModelInfo({
    required this.className,
    required this.extendsClass,
    required this.fields,
  });
}

class FieldInfo {
  final String name;
  final String type;
  final bool isNullable;
  final bool isList;
  final bool isPrimitive;
  final String? listElementType;
  final bool isListElementNullable;

  FieldInfo({
    required this.name,
    required this.type,
    required this.isNullable,
    this.isList = false,
    this.isPrimitive = true,
    this.listElementType,
    this.isListElementNullable = false,
  });
}