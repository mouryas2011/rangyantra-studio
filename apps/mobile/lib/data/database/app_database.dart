import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Database management for local project metadata and documents.
class AppDatabase {
  static const String databaseName = 'rangyantra_studio.db';
  static const int databaseVersion = 1;

  static Database? _instance;
  static bool _ffiInitialized = false;

  /// Returns the singleton SQLite [Database] instance.
  static Future<Database> getInstance() async {
    if (_instance != null && _instance!.isOpen) {
      return _instance!;
    }

    // Initialize FFI for Linux / Desktop / Unit testing environments
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }

    String dbPath;
    if (kIsWeb) {
      dbPath = databaseName;
    } else {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        dbPath = p.join(docsDir.path, databaseName);
      } catch (_) {
        // Fallback for headless test environments
        dbPath = inMemoryDatabasePath;
      }
    }

    _instance = await openDatabase(
      dbPath,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _instance!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        schema_version INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        aspect_ratio_id TEXT NOT NULL,
        width INTEGER NOT NULL,
        height INTEGER NOT NULL,
        fps INTEGER NOT NULL,
        duration_us INTEGER NOT NULL,
        clip_count INTEGER NOT NULL,
        thumbnail_path TEXT,
        json_data TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_projects_updated_at ON projects(updated_at DESC)');
    await db.execute('CREATE INDEX idx_projects_name ON projects(name COLLATE NOCASE)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration hooks for future database versions
  }

  /// Closes database connection (used during teardown/tests).
  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
    }
  }
}
