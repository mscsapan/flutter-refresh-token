import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Represents server-side validation errors returned in HTTP 422 responses.
///
/// Instead of 50+ named required fields (which are brittle and require
/// updating whenever the API changes), errors are stored as a generic
/// `Map<String, List<String>>` keyed by field name.
///
/// Usage:
/// ```dart
/// final errors = Errors.fromMap(responseBody['errors']);
/// final emailErrors  = errors.forField('email');   // ['Email is required']
/// final phoneErrors  = errors.forField('phone');   // []
/// final hasEmailError = errors.hasField('email');  // true
/// ```
class Errors extends Equatable {
  /// Raw field → list-of-messages map exactly as returned by the server.
  final Map<String, List<String?>?>? fields;

  const Errors(this.fields);

  // ---------------------------------------------------------------------------
  // Accessors
  // ---------------------------------------------------------------------------

  /// Returns the list of error messages for [fieldName], or an empty list if
  /// there are no errors for that field.
  // List<String?>? forField(String fieldName) => (fields?[fieldName] ?? []).whereType<String>().toList();
  List<String> forField(String fieldName) => (fields?[fieldName] ?? []).whereType<String>().toList();

  /// Returns the first error message for [fieldName], or `null`.
  String? firstErrorFor(String fieldName) => forField(fieldName).firstOrNull??'';

  /// Whether there is at least one error for [fieldName].
  bool hasField(String fieldName) => (fields?.containsKey(fieldName)??false) && (fields?[fieldName]?.isNotEmpty??false);

  /// Whether there are no validation errors at all.
  bool get isEmpty => fields?.isEmpty??false;

  /// All field names that have errors.
  Iterable<String> get errorFields => fields?.keys??<String>[];

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Builds an [Errors] object from the server's `errors` map where values can
  /// be `List<dynamic>` or a plain `String`.
  factory Errors.fromMap(Map<String, dynamic> map) {
    final result = <String, List<String>>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is List) {
        result[entry.key] = List<String>.from(value.map((e) => e.toString()));
      } else if (value is String) {
        result[entry.key] = [value];
      }
    }
    return Errors(result);
  }

  factory Errors.fromJson(String source) => Errors.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Returns an empty [Errors] (no validation failures).
  factory Errors.empty() => const Errors({});

  Map<String, dynamic> toMap() => fields ?? <String,dynamic>{};

  String toJson() => json.encode(toMap());

  // ---------------------------------------------------------------------------
  // Equatable
  // ---------------------------------------------------------------------------

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [fields];
}
