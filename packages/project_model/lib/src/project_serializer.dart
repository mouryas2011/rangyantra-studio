import 'dart:convert';
import 'project.dart';

/// Handles versioned JSON serialization, schema migration, and integrity validation.
class ProjectSerializer {
  static const int supportedVersion = 1;

  /// Serializes a project to a formatted JSON string.
  static String serialize(Project project, {bool pretty = true}) {
    final map = project.toJson();
    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(map);
    }
    return jsonEncode(map);
  }

  /// Deserializes a JSON string into a [Project], performing version migrations if needed.
  static Project deserialize(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid project JSON structure: expected root object.');
    }
    return deserializeMap(decoded);
  }

  /// Deserializes a Map into a [Project], with schema migration if needed.
  static Project deserializeMap(Map<String, dynamic> rawMap) {
    final version = (rawMap['schemaVersion'] as num?)?.toInt() ?? 1;

    // Schema migration pipeline
    Map<String, dynamic> migrated = rawMap;
    if (version < supportedVersion) {
      migrated = _migrateSchema(rawMap, version, supportedVersion);
    } else if (version > supportedVersion) {
      // Future version warning / backward compatibility fallback
      // In production, we log a warning or parse supported fields
    }

    _validateSchema(migrated);
    return Project.fromJson(migrated);
  }

  /// Performs schema migrations between versions.
  static Map<String, dynamic> _migrateSchema(
    Map<String, dynamic> oldData,
    int fromVersion,
    int toVersion,
  ) {
    var data = Map<String, dynamic>.from(oldData);
    // When migrating v1 -> v2 in future, add migrations here
    data['schemaVersion'] = toVersion;
    return data;
  }

  /// Validates core required fields of the project document.
  static void _validateSchema(Map<String, dynamic> map) {
    if (!map.containsKey('id') || map['id'] == null || (map['id'] as String).isEmpty) {
      throw const FormatException('Project schema error: missing or empty "id"');
    }
    if (!map.containsKey('name') || map['name'] == null) {
      throw const FormatException('Project schema error: missing "name"');
    }
  }
}
