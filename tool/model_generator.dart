import 'dart:io';

void main(List<String> args) async {
  print('🚀 Dart Model Generator\n');

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

    final generatedCode = _generateCompleteModel(modelInfo, content);
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

    buffer.writeln('class ${model.className} extends ${model.extendsClass} {');

    for (final field in model.fields) {
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln();

    buffer.writeln(_generateConstructor(model));
    buffer.writeln();
    buffer.writeln(_generateCopyWith(model));
    buffer.writeln();
    buffer.writeln(_generateToMap(model));
    buffer.writeln();
    buffer.writeln(_generateFromMap(model));
    buffer.writeln();
    buffer.writeln(_generateToJson(model));
    buffer.writeln();
    buffer.writeln(_generateFromJson(model));
    buffer.writeln();

    if (model.extendsClass == 'Equatable') {
      buffer.writeln('  @override');
      buffer.writeln('  bool get stringify => true;');
      buffer.writeln();
    }

    if (model.extendsClass == 'Equatable') {
      buffer.writeln(_generateProps(model));
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

  static String _generateCopyWith(ModelInfo model) {
    final buffer = StringBuffer();
    buffer.writeln('  ${model.className} copyWith({');

    for (final field in model.fields) {
      // Generate parameter type for copyWith
      String paramType;

      if (field.isNullable) {
        // For nullable fields like "UserProfileModel?" or "List<String?>?"
        // We need double nullable: "UserProfileModel??" or "List<String?>??"
        paramType = '${field.type}?';
      } else {
        // For non-nullable fields like "int" or "String"
        // We need single nullable: "int?" or "String?"
        paramType = '${field.type}?';
      }

      buffer.writeln('    $paramType ${field.name},');
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
        // Handle List types
        final elementType = '${field.listElementType}${field.isListElementNullable ? '?' : ''}';

        if (field.isPrimitive) {
          // List of primitives like List<String?>? or List<int>
          if (field.isNullable) {
            // Nullable list → return null if map value is null
            buffer.writeln("map['${field.name}'] != null ? List<$elementType>.from((map['${field.name}'] as List<dynamic>).map<$elementType>((x) => x),) : null,");
          } else {
            // Non-nullable list → return empty list if map value is null
            buffer.writeln("map['${field.name}'] != null ? List<$elementType>.from((map['${field.name}'] as List<dynamic>).map<$elementType>((x) => x),) : [],");
          }
        } else {
          // List of objects like List<HomeModel?>? or List<UserModel>
          if (field.isListElementNullable) {
            // Elements can be null → preserve null values, NO whereType
            if (field.isNullable) {
              // Nullable list → return null if map value is null
              buffer.writeln("map['${field.name}'] != null ? (map['${field.name}'] as List<dynamic>).map((x) => x != null ? ${field.listElementType}.fromMap(x as Map<String, dynamic>) : null).toList() : null,");
            } else {
              // Non-nullable list → return empty list if map value is null
              buffer.writeln("map['${field.name}'] != null ? (map['${field.name}'] as List<dynamic>).map((x) => x != null ? ${field.listElementType}.fromMap(x as Map<String, dynamic>) : null).toList() : [],");
            }
          } else {
            // Elements cannot be null
            if (field.isNullable) {
              // Nullable list → return null if map value is null
              buffer.writeln("map['${field.name}'] != null ? (map['${field.name}'] as List<dynamic>).map((x) => ${field.listElementType}.fromMap(x as Map<String, dynamic>)).toList() : null,");
            } else {
              // Non-nullable list → return empty list if map value is null
              buffer.writeln("map['${field.name}'] != null ? (map['${field.name}'] as List<dynamic>).map((x) => ${field.listElementType}.fromMap(x as Map<String, dynamic>)).toList() : [],");
            }
          }
        }
      } else if (field.isPrimitive) {
        // Handle primitive types
        final baseType = field.type.replaceAll('?', '');

        switch (baseType) {
          case 'int':
            if (field.isNullable) {
              buffer.writeln("map['${field.name}'] != null ? int.parse(map['${field.name}'].toString()) : null,");
            } else {
              buffer.writeln("map['${field.name}'] != null ? int.parse(map['${field.name}'].toString()) : 0,");
            }
            break;
          case 'double':
            if (field.isNullable) {
              buffer.writeln("map['${field.name}'] != null ? double.parse(map['${field.name}'].toString()) : null,");
            } else {
              buffer.writeln("map['${field.name}'] != null ? double.parse(map['${field.name}'].toString()) : 0,");
            }
            break;
          case 'String':
            if (field.isNullable) {
              buffer.writeln("map['${field.name}'],");
            } else {
              buffer.writeln("map['${field.name}'] ?? '',");
            }
            break;
          case 'bool':
            if (field.isNullable) {
              buffer.writeln("map['${field.name}'],");
            } else {
              buffer.writeln("map['${field.name}'] ?? false,");
            }
            break;
          default:
            buffer.writeln("map['${field.name}'],");
        }
      } else {
        // Handle object types like UserProfileModel?
        final baseType = field.type.replaceAll('?', '');

        if (field.isNullable) {
          buffer.writeln("map['${field.name}'] != null ? $baseType.fromMap(map['${field.name}'] as Map<String, dynamic>) : null,");
        } else {
          buffer.writeln("$baseType.fromMap(map['${field.name}'] as Map<String, dynamic>),");
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